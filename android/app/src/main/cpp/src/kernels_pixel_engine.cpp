// ─────────────────────────────────────────────────────────────────────────────
// KÖPRI PIXEL-MATH ENGINE
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <android/log.h>

#if defined(__aarch64__) && defined(__ARM_NEON)
#  include <arm_neon.h>
#  define KP_NEON 1
#else
#  define KP_NEON 0
#endif

#define KPENG_PIX_TAG "KOPRI_ENG_PIX"

namespace {

    constexpr int32_t kMaxAbsScale = 1 << 20;

    bool g_neon_ok = false;

    inline uint8_t ref_gray_px(uint8_t r, uint8_t g, uint8_t b) noexcept {
    const float yv = 0.299f * static_cast<float>(r) +
                     0.587f * static_cast<float>(g) +
                     0.114f * static_cast<float>(b);
    return static_cast<uint8_t>(std::min(255.f, std::max(0.f, yv)));
}

inline uint8_t ref_contrast_px(uint8_t x, int32_t scale_q8) noexcept {
const int32_t t = (static_cast<int32_t>(x) - 128) * scale_q8;
const int32_t bias = (t < 0) ? 255 : 0;
const int32_t q = ((t + bias) >> 8) + 128;
return static_cast<uint8_t>(std::min(255, std::max(0, q)));
}

void ref_gray(uint8_t* dst, const uint8_t* src, int32_t n) noexcept {
for (int32_t i = 0; i < n; ++i) {
dst[i] = ref_gray_px(src[3 * i], src[3 * i + 1], src[3 * i + 2]);
}
}

void ref_contrast(uint8_t* dst, const uint8_t* src, int32_t n, int32_t scale_q8) noexcept {
for (int32_t i = 0; i < n; ++i) {
dst[i] = ref_contrast_px(src[i], scale_q8);
}
}

#if KP_NEON
inline void u8x8_to_f32(uint8x8_t v, float32x4_t& lo, float32x4_t& hi) noexcept {
    const uint16x8_t w = vmovl_u8(v);
    lo = vcvtq_f32_u32(vmovl_u16(vget_low_u16(w)));
    hi = vcvtq_f32_u32(vmovl_u16(vget_high_u16(w)));
}

void neon_gray(uint8_t* dst, const uint8_t* src, int32_t n) noexcept {
    const float32x4_t kr    = vdupq_n_f32(0.299f);
    const float32x4_t kg    = vdupq_n_f32(0.587f);
    const float32x4_t kb    = vdupq_n_f32(0.114f);
    const float32x4_t vzero = vdupq_n_f32(0.0f);
    const float32x4_t vcap  = vdupq_n_f32(255.0f);

    int32_t i = 0;
    for (; i + 8 <= n; i += 8) {
        const uint8x8x3_t px = vld3_u8(src + static_cast<size_t>(i) * 3);
        float32x4_t rl, rh, gl, gh, bl, bh;
        u8x8_to_f32(px.val[0], rl, rh);
        u8x8_to_f32(px.val[1], gl, gh);
        u8x8_to_f32(px.val[2], bl, bh);

        float32x4_t yl = vaddq_f32(vaddq_f32(vmulq_f32(rl, kr), vmulq_f32(gl, kg)),
                                   vmulq_f32(bl, kb));
        float32x4_t yh = vaddq_f32(vaddq_f32(vmulq_f32(rh, kr), vmulq_f32(gh, kg)),
                                   vmulq_f32(bh, kb));
        yl = vminq_f32(vmaxq_f32(yl, vzero), vcap);
        yh = vminq_f32(vmaxq_f32(yh, vzero), vcap);

        const uint16x8_t n16 = vcombine_u16(vmovn_u32(vcvtq_u32_f32(yl)),
                                            vmovn_u32(vcvtq_u32_f32(yh)));
        vst1_u8(dst + i, vmovn_u16(n16));
    }
    for (; i < n; ++i) {
        dst[i] = ref_gray_px(src[3 * i], src[3 * i + 1], src[3 * i + 2]);
    }
}

void neon_contrast(uint8_t* dst, const uint8_t* src, int32_t n, int32_t scale_q8) noexcept {
    const int32x4_t vs   = vdupq_n_s32(scale_q8);
    const int32x4_t v128 = vdupq_n_s32(128);
    const int32x4_t v255 = vdupq_n_s32(255);
    const int32x4_t v0   = vdupq_n_s32(0);

    auto step = [&](uint32x4_t u) noexcept -> uint32x4_t {
        const int32x4_t x = vreinterpretq_s32_u32(u);
        const int32x4_t t = vmulq_s32(vsubq_s32(x, v128), vs);
        const int32x4_t bias = vandq_s32(vshrq_n_s32(t, 31), v255);   // 255, если t < 0
        int32x4_t q = vaddq_s32(vshrq_n_s32(vaddq_s32(t, bias), 8), v128);
        q = vminq_s32(vmaxq_s32(q, v0), v255);
        return vreinterpretq_u32_s32(q);
    };

    int32_t i = 0;
    for (; i + 16 <= n; i += 16) {
        const uint8x16_t c = vld1q_u8(src + i);
        const uint16x8_t w_lo = vmovl_u8(vget_low_u8(c));
        const uint16x8_t w_hi = vmovl_u8(vget_high_u8(c));

        const uint32x4_t r0 = step(vmovl_u16(vget_low_u16(w_lo)));
        const uint32x4_t r1 = step(vmovl_u16(vget_high_u16(w_lo)));
        const uint32x4_t r2 = step(vmovl_u16(vget_low_u16(w_hi)));
        const uint32x4_t r3 = step(vmovl_u16(vget_high_u16(w_hi)));

        const uint16x8_t a = vcombine_u16(vmovn_u32(r0), vmovn_u32(r1));
        const uint16x8_t b = vcombine_u16(vmovn_u32(r2), vmovn_u32(r3));
        vst1q_u8(dst + i, vcombine_u8(vmovn_u16(a), vmovn_u16(b)));
    }
    for (; i < n; ++i) {
        dst[i] = ref_contrast_px(src[i], scale_q8);
    }
}

bool selftest() noexcept {
    static const int32_t lens[] = {0, 1, 7, 8, 9, 15, 16, 17, 31, 32, 33, 255, 256, 1023};
    static const int32_t scales[] = {0, 1, -256, 128, 256, 258, 300, 512, 1280, 4096,
                                     65536, kMaxAbsScale, -kMaxAbsScale};

    static uint8_t rgb[3 * 1024 + 8];
    static uint8_t ramp[256];
    static uint8_t ref[1024 + 8];
    static uint8_t got[1024 + 8];

    uint32_t seed = 0x9E3779B9u;
    for (auto& v : rgb) {
        seed = seed * 1664525u + 1013904223u;
        v = static_cast<uint8_t>(seed >> 24);
    }
    for (int i = 0; i < 256; ++i) ramp[i] = static_cast<uint8_t>(i);

    for (int32_t L : lens) {
        ref_gray(ref, rgb, L);
        neon_gray(got, rgb, L);
        if (std::memcmp(ref, got, static_cast<size_t>(L)) != 0) return false;
    }

    for (int32_t s : scales) {
        for (int32_t L : lens) {
            if (L > 256) continue;
            ref_contrast(ref, ramp, L, s);
            neon_contrast(got, ramp, L, s);
            if (std::memcmp(ref, got, static_cast<size_t>(L)) != 0) return false;
        }
        std::memcpy(ref, ramp, 256);
        std::memcpy(got, ramp, 256);
        ref_contrast(ref, ref, 256, s);
        neon_contrast(got, got, 256, s);
        if (std::memcmp(ref, got, 256) != 0) return false;
    }
    return true;
}
#endif // KP_NEON

} // namespace

__attribute__((constructor)) static void kp_pixel_engine_ctor() noexcept {
#if KP_NEON
g_neon_ok = selftest();
#endif
__android_log_print(ANDROID_LOG_INFO, KPENG_PIX_TAG,
"pixel-math engine ready (neon=%d, selftest=%s)",
KP_NEON, g_neon_ok ? "OK" : "scalar-fallback");
}

extern "C" {

void kp_asm_gray_rgb888(uint8_t* dst, const uint8_t* src, int32_t n) {
    if (!dst || !src || n <= 0) return;
#if KP_NEON
    if (g_neon_ok) { neon_gray(dst, src, n); return; }
#endif
    ref_gray(dst, src, n);
}

void kp_asm_contrast_u8(uint8_t* dst, const uint8_t* src, int32_t n, int32_t scale_q8) {
    if (!dst || !src || n <= 0) return;
    scale_q8 = std::clamp(scale_q8, -kMaxAbsScale, kMaxAbsScale);
#if KP_NEON
    if (g_neon_ok) { neon_contrast(dst, src, n, scale_q8); return; }
#endif
    ref_contrast(dst, src, n, scale_q8);
}

void kp_asm_sin_f4(const float* x, float* y, int32_t n) {
    if (!x || !y || n <= 0) return;
    for (int32_t i = 0; i < n; ++i) {
        y[i] = std::sin(x[i]);
    }
}

} // extern "C"