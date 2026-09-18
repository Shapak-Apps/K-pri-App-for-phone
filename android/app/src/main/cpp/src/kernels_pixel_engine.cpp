// ─────────────────────────────────────────────────────────────────────────────
// KÖPRI PIXEL-MATH ENGINE (2 of 2 optimization cores)
//
// Serves the image/splash drivers (image_fast.cpp, splash_engine.cpp) via the
// KP_HAS_ASM_KERNELS switch. Same safety contract as the text engine:
// weak symbols, load-time self-test with permanent scalar fallback, zero
// allocations, pure functions, strict (ptr, n) validation, bounded chunks.
// ─────────────────────────────────────────────────────────────────────────────
#include <cstdint>
#include <cmath>
#include <algorithm>
#include <android/log.h>

// NEON intrinsics are used only on AArch64 (64-bit ARM). The advanced
// intrinsics we rely on (vcvtmq_s32_f32, vaddvq_u8) are AArch64-only;
// on 32-bit ARMv7 they either do not exist or have different semantics.
// ARMv7 devices fall back to the scalar reference path — same behaviour,
// no performance gain. Modern Android devices (95%+) are AArch64, so this
// is acceptable.
#if (defined(__ARM_NEON) || defined(__ARM_NEON__)) && defined(__aarch64__)
#  include <arm_neon.h>
#  define KP_NEON 1
#else
#  define KP_NEON 0
#endif

#define KPENG_PIX_TAG "KOPRI_ENG_PIX"

namespace {

    int g_ok = 0;

// ── Scalar references (canonical semantics) ─────────────────────────────────
    void ref_gray(const uint8_t* src, uint8_t* dst, int32_t n) noexcept {
        for (int32_t i = 0; i < n; ++i) {
            const float yv = 0.299f * src[i * 3 + 0] +
                             0.587f * src[i * 3 + 1] +
                             0.114f * src[i * 3 + 2];
            dst[i] = static_cast<unsigned char>(std::min(255.f, std::max(0.f, yv)));
        }
    }

// Exact integer emulation of: trunc((v-128)*scale/256) + 128, clamped.
    void ref_contrast(const uint8_t* src, uint8_t* dst, int32_t n, int32_t scale_q8) noexcept {
        for (int32_t i = 0; i < n; ++i) {
            const int32_t t = (static_cast<int32_t>(src[i]) - 128) * scale_q8;
            const int32_t bias = (t < 0) ? 255 : 0;          // trunc-toward-zero div
            int32_t q = (t + bias) >> 8;
            q += 128;
            q = q < 0 ? 0 : (q > 255 ? 255 : q);
            dst[i] = static_cast<uint8_t>(q);
        }
    }

#if KP_NEON
// ── NEON kernels ─────────────────────────────────────────────────────────────
// RGB888 → gray, same float expression & associativity as the scalar
// reference, so results are bit-identical (floor == trunc for y >= 0).
    void neon_gray(const uint8_t* src, uint8_t* dst, int32_t n) noexcept {
        const float32x4_t kr = vdupq_n_f32(0.299f);
        const float32x4_t kg = vdupq_n_f32(0.587f);
        const float32x4_t kb = vdupq_n_f32(0.114f);
        const float32x4_t vcap = vdupq_n_f32(255.0f);
        int32_t i = 0;

        for (; i + 8 <= n; i += 8) {
            const uint8x8x3_t px = vld3_u8(src + static_cast<size_t>(i) * 3);
            const uint16x8_t r16 = vmovl_u8(px.val[0]);
            const uint16x8_t g16 = vmovl_u8(px.val[1]);
            const uint16x8_t b16 = vmovl_u8(px.val[2]);

            uint8x8_t out8;
            {
                // low 4 pixels
                const float32x4_t rf = vcvtq_f32_s32(vmovl_s16(vget_low_s16(vreinterpretq_s16_u16(r16))));
                const float32x4_t gf = vcvtq_f32_s32(vmovl_s16(vget_low_s16(vreinterpretq_s16_u16(g16))));
                const float32x4_t bf = vcvtq_f32_s32(vmovl_s16(vget_low_s16(vreinterpretq_s16_u16(b16))));
                float32x4_t y = vmulq_f32(rf, kr);
                y = vmlaq_f32(y, gf, kg);
                y = vmlaq_f32(y, bf, kb);
                y = vminq_f32(y, vcap);
                const int32x4_t yi = vcvtmq_s32_f32(y);           // floor == trunc (y >= 0)
                // high 4 pixels
                const float32x4_t rf2 = vcvtq_f32_s32(vmovl_s16(vget_high_s16(vreinterpretq_s16_u16(r16))));
                const float32x4_t gf2 = vcvtq_f32_s32(vmovl_s16(vget_high_s16(vreinterpretq_s16_u16(g16))));
                const float32x4_t bf2 = vcvtq_f32_s32(vmovl_s16(vget_high_s16(vreinterpretq_s16_u16(b16))));
                float32x4_t y2 = vmulq_f32(rf2, kr);
                y2 = vmlaq_f32(y2, gf2, kg);
                y2 = vmlaq_f32(y2, bf2, kb);
                y2 = vminq_f32(y2, vcap);
                const int32x4_t yi2 = vcvtmq_s32_f32(y2);

                const int16x8_t y16 = vcombine_s16(vqmovn_s32(yi), vqmovn_s32(yi2));
                out8 = vqmovun_s16(y16);
            }
            vst1_u8(dst + i, out8);
        }
        for (; i < n; ++i) {
            const float yv = 0.299f * src[i * 3 + 0] +
                             0.587f * src[i * 3 + 1] +
                             0.114f * src[i * 3 + 2];
            dst[i] = static_cast<unsigned char>(std::min(255.f, std::max(0.f, yv)));
        }
    }

// In-place safe (dst may alias src): loads a chunk fully before storing.
    void neon_contrast(const uint8_t* src, uint8_t* dst, int32_t n, int32_t scale_q8) noexcept {
        const int32x4_t vs = vdupq_n_s32(scale_q8);
        const int32x4_t v128 = vdupq_n_s32(128);
        const int32x4_t v255 = vdupq_n_s32(255);
        const int32x4_t v0 = vdupq_n_s32(0);
        const int32x4_t vbias = vdupq_n_s32(255);
        int32_t i = 0;

        for (; i + 16 <= n; i += 16) {
            const uint8x16_t c = vld1q_u8(src + i);
            const uint16x8_t lo16 = vmovl_u8(vget_low_u8(c));
            const uint16x8_t hi16 = vmovl_u8(vget_high_u8(c));

            const int32x4_t a = vmovl_s16(vget_low_s16(vreinterpretq_s16_u16(lo16)));
            const int32x4_t b = vmovl_s16(vget_high_s16(vreinterpretq_s16_u16(lo16)));
            const int32x4_t d = vmovl_s16(vget_low_s16(vreinterpretq_s16_u16(hi16)));
            const int32x4_t e = vmovl_s16(vget_high_s16(vreinterpretq_s16_u16(hi16)));

            auto step = [&](int32x4_t x) -> int32x4_t {
                const int32x4_t t = vmulq_s32(vsubq_s32(x, v128), vs);
                const int32x4_t bias = vandq_s32(vshrq_n_s32(t, 31), vbias);
                int32x4_t q = vshrq_n_s32(vaddq_s32(t, bias), 8);
                q = vaddq_s32(q, v128);
                q = vmaxq_s32(q, v0);
                return vminq_s32(q, v255);
            };

            const int16x8_t lo8 = vcombine_s16(vqmovn_s32(step(a)), vqmovn_s32(step(b)));
            const int16x8_t hi8 = vcombine_s16(vqmovn_s32(step(d)), vqmovn_s32(step(e)));
            vst1q_u8(dst + i, vcombine_u8(vqmovun_s16(lo8), vqmovun_s16(hi8)));
        }
        for (; i < n; ++i) {
            const int32_t t = (static_cast<int32_t>(src[i]) - 128) * scale_q8;
            const int32_t bias = (t < 0) ? 255 : 0;
            int32_t q = (t + bias) >> 8;
            q += 128;
            q = q < 0 ? 0 : (q > 255 ? 255 : q);
            dst[i] = static_cast<uint8_t>(q);
        }
    }
#endif // KP_NEON

    bool selftest() noexcept {
#if KP_NEON
        uint8_t src[3 * 256];
        uint8_t d1[256], d2[256];
        for (int i = 0; i < 3 * 256; ++i) src[i] = static_cast<uint8_t>((i * 31 + 7) & 0xFF);
        static const int lens[] = {0, 1, 7, 8, 9, 15, 16, 17, 31, 32, 33, 255, 256};
        for (int L : lens) {
            ref_gray(src, d1, L);
            neon_gray(src, d2, L);
            for (int i = 0; i < L; ++i) if (d1[i] != d2[i]) return false;
        }
        for (int scale : {128, 256, 258, 300, 512, 1280}) {
            for (int L : lens) {
                ref_contrast(src, d1, L, scale);
                neon_contrast(src, d2, L, scale);
                for (int i = 0; i < L; ++i) if (d1[i] != d2[i]) return false;
            }
            // in-place aliasing check
            uint8_t a[64], b[64];
            for (int i = 0; i < 64; ++i) { a[i] = src[i]; b[i] = src[i]; }
            ref_contrast(a, a, 64, scale);
            neon_contrast(b, b, 64, scale);
            for (int i = 0; i < 64; ++i) if (a[i] != b[i]) return false;
        }
        return true;
#else
        return false;
#endif
    }

} // namespace

__attribute__((constructor)) static void kp_pixel_engine_ctor() noexcept {
#if KP_NEON
    g_ok = selftest() ? 1 : 0;
#endif
    __android_log_print(ANDROID_LOG_INFO, KPENG_PIX_TAG,
                        "pixel-math engine ready (neon=%d, selftest=%s)",
                        KP_NEON, g_ok ? "OK" : "scalar-fallback");
}

extern "C" {

// Drivers: image_fast.cpp (OCR grayscale prep).
__attribute__((weak)) void kp_asm_gray_rgb888(uint8_t* dst, const uint8_t* src, int32_t n) {
    if (!dst || !src || n <= 0) return;
#if KP_NEON
    if (g_ok) { neon_gray(src, dst, n); return; }
#endif
    ref_gray(src, dst, n);
}

// Drivers: image_fast.cpp (OCR contrast boost). dst may alias src.
__attribute__((weak)) void kp_asm_contrast_u8(uint8_t* dst, const uint8_t* src, int32_t n, int32_t scale_q8) {
    if (!dst || !src || n <= 0) return;
#if KP_NEON
    if (g_ok) { neon_contrast(src, dst, n, scale_q8); return; }
#endif
    ref_contrast(src, dst, n, scale_q8);
}

// Drivers: splash_engine.cpp (4-lane sine). Exact libm semantics.
__attribute__((weak)) void kp_asm_sin_f4(const float* x, float* y, int32_t n) {
    if (!x || !y || n <= 0) return;
    int32_t i = 0;
    for (; i + 4 <= n; i += 4) {
        y[i + 0] = std::sin(x[i + 0]);
        y[i + 1] = std::sin(x[i + 1]);
        y[i + 2] = std::sin(x[i + 2]);
        y[i + 3] = std::sin(x[i + 3]);
    }
    for (; i < n; ++i) y[i] = std::sin(x[i]);
}

} // extern "C"