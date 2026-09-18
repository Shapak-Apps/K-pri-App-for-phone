// ─────────────────────────────────────────────────────────────────────────────
// KÖPRI TEXT-SCAN ENGINE (1 of 2 optimization cores)
//
// Provides the hot byte-scan kernels used by the driver modules
// (json_lite / clip_filter / csv_engine / stats_engine) through the
// KP_HAS_ASM_KERNELS switch. Design guarantees:
//   * weak symbols  → can never clash with asm/*.S or future definitions;
//   * load-time self-test (NEON vs scalar reference); on any mismatch the
//     engine permanently falls back to the scalar reference (g_ok = 0);
//   * zero allocations, zero mutable globals after init → thread-safe;
//   * every entry point validates (ptr, n) before touching memory;
//   * chunk loops are bounded by i + 16 <= n, tails handled scalar.
// ─────────────────────────────────────────────────────────────────────────────
#include <cstdint>
#include <cstring>
#include <array>
#include <android/log.h>

// NEON intrinsics are used only on AArch64 (64-bit ARM). The advanced
// intrinsics we rely on (vcvtmq_s32_f32, vqtbl4q_u8, vaddvq_u8,
// vmaxvq_u8, vminvq_u8, vaddvq_s64) are AArch64-only; on 32-bit ARMv7
// they either do not exist or have different semantics. ARMv7 devices
// fall back to the scalar reference path — same behaviour, no perf gain.
#if (defined(__ARM_NEON) || defined(__ARM_NEON__)) && defined(__aarch64__)
#  include <arm_neon.h>
#  define KP_NEON 1
#else
#  define KP_NEON 0
#endif

#define KPENG_TEXT_TAG "KOPRI_ENG_TEXT"

namespace {

// Set once by the constructor, read-only afterwards. 1 = NEON verified.
    int g_ok = 0;

// ── Byte classes (C-locale semantics, identical to the drivers) ─────────────
    [[gnu::always_inline]] inline bool k_letter(unsigned char c) noexcept {
        const unsigned char o = static_cast<unsigned char>(c | 0x20u);
        return o >= 'a' && o <= 'z';
    }
    [[gnu::always_inline]] inline bool k_digit(unsigned char c) noexcept {
        return c >= '0' && c <= '9';
    }
    [[gnu::always_inline]] inline bool k_space(unsigned char c) noexcept {
        return c == ' ' || c == '\t';
    }
    // FIX: k_code must be constexpr — it is evaluated at compile time to build
    // the 256-entry lookup table (kCodeLut). A plain `inline` function cannot
    // appear in a constant expression, which broke the constexpr initializer.
    // constexpr functions are still callable at runtime (scalar fallback path),
    // so behaviour is unchanged.
    [[gnu::always_inline]] constexpr bool k_code(unsigned char c) noexcept {
        switch (c) {
            case '{': case '}': case '[': case ']': case '(': case ')':
            case ';': case '=': case '<': case '>': case '_': case '#':
            case '/': case '*': case '+': case '-': case '&': case '|':
            case '^': case '~': case '`':
                return true;
            default:
                return false;
        }
    }
    [[gnu::always_inline]] inline bool k_json_stop(unsigned char c) noexcept {
        return c == '"' || c == '\\';
    }
    [[gnu::always_inline]] inline bool k_ws(unsigned char c) noexcept {
        return c == ' ' || c == '\n' || c == '\r' ||
               c == '\t' || c == '\f' || c == '\v';
    }
    [[gnu::always_inline]] inline bool k_csv_stop(unsigned char c) noexcept {
        return c == '"' || c == '\n' || c == '\r';
    }

// ── Scalar references (canonical semantics, always available) ───────────────
    void ref_clip_stats(const uint8_t* p, int32_t n, uint32_t* out4) noexcept {
        uint32_t L = 0, D = 0, S = 0, C = 0;
        for (int32_t i = 0; i < n; ++i) {
            const unsigned char c = p[i];
            if (k_letter(c)) ++L;
            else if (k_digit(c)) ++D;
            else if (k_space(c)) ++S;
            else if (k_code(c)) ++C;
        }
        out4[0] = L; out4[1] = D; out4[2] = S; out4[3] = C;
    }

    int32_t ref_scan_until(const uint8_t* p, int32_t n,
                           bool (*stop)(unsigned char)) noexcept {
        int32_t i = 0;
        while (i < n && !stop(p[i])) ++i;
        return i;
    }

    int32_t ref_ws_run(const uint8_t* p, int32_t n) noexcept {
        int32_t i = 0;
        while (i < n && k_ws(p[i])) ++i;
        return i;
    }

    int64_t ref_sum(const int32_t* p, int32_t n) noexcept {
        int64_t s = 0;
        for (int32_t i = 0; i < n; ++i) s += p[i];
        return s;
    }

// 256-entry code-char lookup table, built at compile time.
    constexpr std::array<uint8_t, 256> make_code_lut() {
        std::array<uint8_t, 256> t{};
        for (int c = 0; c < 256; ++c) t[static_cast<size_t>(c)] = k_code(static_cast<unsigned char>(c)) ? 1 : 0;
        return t;
    }
    constexpr auto kCodeLut = make_code_lut();

#if KP_NEON
// ── NEON kernels ─────────────────────────────────────────────────────────────
    void neon_clip_stats(const uint8_t* p, int32_t n, uint32_t* out4) noexcept {
        uint32_t L = 0, D = 0, S = 0, C = 0;
        int32_t i = 0;

        const uint8x16_t vA = vdupq_n_u8('a'),  vZ = vdupq_n_u8('z');
        const uint8x16_t v0 = vdupq_n_u8('0'),  v9 = vdupq_n_u8('9');
        const uint8x16_t vSp = vdupq_n_u8(' '), vTb = vdupq_n_u8('\t');
        const uint8x16_t vOr = vdupq_n_u8(0x20), v1 = vdupq_n_u8(1);
        const uint8x16_t v3F = vdupq_n_u8(0x3F);
        const uint8x16_t s0 = vdupq_n_u8(0), s1 = vdupq_n_u8(1);
        const uint8x16_t s2 = vdupq_n_u8(2), s3 = vdupq_n_u8(3);

        uint8x16x4_t t;
        t.val[0] = vld1q_u8(kCodeLut.data());
        t.val[1] = vld1q_u8(kCodeLut.data() + 16);
        t.val[2] = vld1q_u8(kCodeLut.data() + 32);
        t.val[3] = vld1q_u8(kCodeLut.data() + 48);

        for (; i + 16 <= n; i += 16) {
            const uint8x16_t c = vld1q_u8(p + i);
            const uint8x16_t o = vorrq_u8(c, vOr);
            const uint8x16_t mL = vandq_u8(vcgeq_u8(o, vA), vcleq_u8(o, vZ));
            const uint8x16_t mD = vandq_u8(vcgeq_u8(c, v0), vcleq_u8(c, v9));
            const uint8x16_t mS = vorrq_u8(vceqq_u8(c, vSp), vceqq_u8(c, vTb));

            const uint8x16_t idx = vandq_u8(c, v3F);
            const uint8x16_t sel = vshrq_n_u8(c, 6);
            const uint8x16_t base = vqtbl4q_u8(t, idx);
            uint8x16_t mC = vbslq_u8(vceqq_u8(sel, s0), base, vdupq_n_u8(0));
            mC = vbslq_u8(vceqq_u8(sel, s1), base, mC);
            mC = vbslq_u8(vceqq_u8(sel, s2), base, mC);
            mC = vbslq_u8(vceqq_u8(sel, s3), base, mC);
            mC = vceqq_u8(mC, v1);

            L += vaddvq_u8(vshrq_n_u8(mL, 7));
            D += vaddvq_u8(vshrq_n_u8(mD, 7));
            S += vaddvq_u8(vshrq_n_u8(mS, 7));
            C += vaddvq_u8(vshrq_n_u8(mC, 7));
        }
        for (; i < n; ++i) {
            const unsigned char c = p[i];
            if (k_letter(c)) ++L;
            else if (k_digit(c)) ++D;
            else if (k_space(c)) ++S;
            else if (k_code(c)) ++C;
        }
        out4[0] = L; out4[1] = D; out4[2] = S; out4[3] = C;
    }

// Advance over bytes that are NOT a/b; returns count (== n when none found).
    int32_t neon_scan2(const uint8_t* p, int32_t n,
                       unsigned char a, unsigned char b) noexcept {
        int32_t i = 0;
        const uint8x16_t va = vdupq_n_u8(a), vb = vdupq_n_u8(b);
        for (; i + 16 <= n; i += 16) {
            const uint8x16_t c = vld1q_u8(p + i);
            const uint8x16_t m = vorrq_u8(vceqq_u8(c, va), vceqq_u8(c, vb));
            if (vmaxvq_u8(m) != 0) {
                for (int k = 0; k < 16; ++k) {
                    if (p[i + k] == a || p[i + k] == b) return i + k;
                }
            }
        }
        for (; i < n; ++i) {
            if (p[i] == a || p[i] == b) return i;
        }
        return n;
    }

// Advance over bytes that are NOT a/b/c (CSV stop set).
    int32_t neon_scan3(const uint8_t* p, int32_t n,
                       unsigned char a, unsigned char b, unsigned char c) noexcept {
        int32_t i = 0;
        const uint8x16_t va = vdupq_n_u8(a), vb = vdupq_n_u8(b), vc = vdupq_n_u8(c);
        for (; i + 16 <= n; i += 16) {
            const uint8x16_t x = vld1q_u8(p + i);
            const uint8x16_t m = vorrq_u8(vorrq_u8(vceqq_u8(x, va), vceqq_u8(x, vb)), vceqq_u8(x, vc));
            if (vmaxvq_u8(m) != 0) {
                for (int k = 0; k < 16; ++k) {
                    const unsigned char q = p[i + k];
                    if (q == a || q == b || q == c) return i + k;
                }
            }
        }
        for (; i < n; ++i) {
            const unsigned char q = p[i];
            if (q == a || q == b || q == c) return i;
        }
        return n;
    }

// Count of leading whitespace bytes.
    int32_t neon_ws_run(const uint8_t* p, int32_t n) noexcept {
        int32_t i = 0;
        const uint8x16_t wSp = vdupq_n_u8(' '),  wNl = vdupq_n_u8('\n');
        const uint8x16_t wCr = vdupq_n_u8('\r'), wTb = vdupq_n_u8('\t');
        const uint8x16_t wFf = vdupq_n_u8('\f'), wVt = vdupq_n_u8('\v');
        for (; i + 16 <= n; i += 16) {
            const uint8x16_t c = vld1q_u8(p + i);
            uint8x16_t m = vceqq_u8(c, wSp);
            m = vorrq_u8(m, vceqq_u8(c, wNl));
            m = vorrq_u8(m, vceqq_u8(c, wCr));
            m = vorrq_u8(m, vceqq_u8(c, wTb));
            m = vorrq_u8(m, vceqq_u8(c, wFf));
            m = vorrq_u8(m, vceqq_u8(c, wVt));
            if (vminvq_u8(m) != 0xFF) {
                for (int k = 0; k < 16; ++k) {
                    if (!k_ws(p[i + k])) return i + k;
                }
            }
        }
        for (; i < n; ++i) {
            if (!k_ws(p[i])) return i;
        }
        return n;
    }

    int64_t neon_sum(const int32_t* p, int32_t n) noexcept {
        int64x2_t acc = vdupq_n_s64(0);
        int32_t i = 0;
        for (; i + 8 <= n; i += 8) {
            acc = vpadalq_s32(acc, vld1q_s32(p + i));
            acc = vpadalq_s32(acc, vld1q_s32(p + i + 4));
        }
        int64_t s = vaddvq_s64(acc);
        for (; i < n; ++i) s += p[i];
        return s;
    }
#endif // KP_NEON

// ── Load-time self-test: NEON must bit-match the scalar reference ───────────
    bool selftest() noexcept {
#if KP_NEON
        uint8_t buf[512];
        for (int i = 0; i < 512; ++i) {
            unsigned char c = static_cast<unsigned char>(i & 0x7F);
            if (i % 97 == 0) c = '"';
            if (i % 89 == 0) c = '\\';
            if (i % 53 == 0) c = '\n';
            if (i % 41 == 0) c = '\t';
            if (i % 37 == 0) c = '\r';
            buf[i] = c;
        }
        static const int lens[] = {0, 1, 2, 15, 16, 17, 31, 32, 33, 64, 65, 127, 128, 129, 255, 256, 257, 511, 512};
        for (int off = 0; off < 3; ++off) {
            for (int L : lens) {
                if (off + L > 512) continue;
                const uint8_t* q = buf + off;
                uint32_t a[4], b[4];
                ref_clip_stats(q, L, a);
                neon_clip_stats(q, L, b);
                if (a[0] != b[0] || a[1] != b[1] || a[2] != b[2] || a[3] != b[3]) return false;
                if (ref_scan_until(q, L, k_json_stop) != neon_scan2(q, L, '"', '\\')) return false;
                if (ref_scan_until(q, L, k_csv_stop) != neon_scan3(q, L, '"', '\n', '\r')) return false;
                if (ref_ws_run(q, L) != neon_ws_run(q, L)) return false;
            }
        }
        int32_t arr[300];
        for (int i = 0; i < 300; ++i) arr[i] = static_cast<int32_t>((i * 1103515245 + 12345) % 2001) - 1000;
        for (int L : lens) {
            if (L > 300) continue;
            if (ref_sum(arr, L) != neon_sum(arr, L)) return false;
        }
        return true;
#else
        return false; // no NEON: engines run scalar by design
#endif
    }

} // namespace

// Runs before main(): verifies kernels, logs the verdict, arms the fallback.
__attribute__((constructor)) static void kp_text_engine_ctor() noexcept {
#if KP_NEON
    g_ok = selftest() ? 1 : 0;
#endif
    __android_log_print(ANDROID_LOG_INFO, KPENG_TEXT_TAG,
                        "text-scan engine ready (neon=%d, selftest=%s)",
                        KP_NEON, g_ok ? "OK" : "scalar-fallback");
}

extern "C" {

// Drivers: clip_filter.cpp (ASCII-run classification).
__attribute__((weak)) void kp_asm_clip_stats(const uint8_t* p, int32_t n, uint32_t* out4) {
    if (!out4) return;
    if (!p || n <= 0) { out4[0] = out4[1] = out4[2] = out4[3] = 0; return; }
#if KP_NEON
    if (g_ok) { neon_clip_stats(p, n, out4); return; }
#endif
    ref_clip_stats(p, n, out4);
}

// Drivers: json_lite.cpp (skip until quote/backslash).
__attribute__((weak)) int32_t kp_asm_json_scan(const uint8_t* p, int32_t n) {
    if (!p || n <= 0) return 0;
#if KP_NEON
    if (g_ok) return neon_scan2(p, n, '"', '\\');
#endif
    return ref_scan_until(p, n, k_json_stop);
}

// Drivers: json_lite.cpp (leading whitespace run).
__attribute__((weak)) int32_t kp_asm_json_ws(const uint8_t* p, int32_t n) {
    if (!p || n <= 0) return 0;
#if KP_NEON
    if (g_ok) return neon_ws_run(p, n);
#endif
    return ref_ws_run(p, n);
}

// Drivers: csv_engine.cpp (skip until quote/CR/LF).
__attribute__((weak)) int32_t kp_asm_csv_scan(const uint8_t* p, int32_t n) {
    if (!p || n <= 0) return 0;
#if KP_NEON
    if (g_ok) return neon_scan3(p, n, '"', '\n', '\r');
#endif
    return ref_scan_until(p, n, k_csv_stop);
}

// Drivers: stats_engine.cpp (64-bit sum of int32 array).
__attribute__((weak)) int64_t kp_asm_sum_i32(const int32_t* p, int32_t n) {
    if (!p || n <= 0) return 0;
#if KP_NEON
    if (g_ok) return neon_sum(p, n);
#endif
    return ref_sum(p, n);
}

} // extern "C"