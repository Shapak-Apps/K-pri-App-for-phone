#include "bridge_engine.h"
#include <cmath>

namespace {

    constexpr int32_t kCablePts = 40;
    constexpr int32_t kHangers  = 11;
    constexpr int32_t kWavePts  = 48;
    constexpr int32_t kTrail    = 8;
    constexpr int32_t kTotal    = kCablePts * 2 + kHangers * 2 +
                                  kWavePts * 4 + kTrail * 2;

    constexpr float kDeck  = 0.66f;
    constexpr float kTop   = 0.18f;
    constexpr float kX1    = 0.30f;
    constexpr float kX2    = 0.70f;
    constexpr float kWater = 0.86f;
    constexpr float kTau   = 6.2831853f;

    [[gnu::always_inline]] inline float parabola(float x, float sagY) noexcept {
        const float u = (x - 0.5f) / 0.2f;
        return kTop + (sagY - kTop) * (1.0f - u * u);
    }

    [[gnu::always_inline]] inline float cableY(float x, float sagY) noexcept {
        const float end = kDeck - 0.02f;
        if (x < kX1) {
            const float t = (x - 0.04f) / (kX1 - 0.04f);
            return end + (kTop - end) * t;
        }
        if (x > kX2) {
            const float t = (x - kX2) / (0.96f - kX2);
            return kTop + (end - kTop) * t;
        }
        return parabola(x, sagY);
    }

} // namespace

extern "C" {

KP_EXPORT int32_t bridge_frame(float t, float* out, int32_t cap) {
    if (!out || cap < kTotal) return -1;

    const float sagY = 0.44f + 0.015f * std::sin(t * 2.0f);

    int32_t i = 0;

    for (int32_t k = 0; k < kCablePts; ++k) {
        const float x = 0.04f + 0.92f * (k / static_cast<float>(kCablePts - 1));
        out[i++] = x;
        out[i++] = cableY(x, sagY);
    }

    for (int32_t k = 0; k < kHangers; ++k) {
        const float x = kX1 + (kX2 - kX1) * (k / static_cast<float>(kHangers - 1));
        out[i++] = x;
        out[i++] = parabola(x, sagY);
    }

    for (int32_t k = 0; k < kWavePts; ++k) {
        const float x = k / static_cast<float>(kWavePts - 1);
        out[i++] = x;
        out[i++] = kWater + 0.012f * std::sin((x * 3.0f + t * 0.35f) * kTau);
    }

    for (int32_t k = 0; k < kWavePts; ++k) {
        const float x = k / static_cast<float>(kWavePts - 1);
        out[i++] = x;
        out[i++] = kWater + 0.02f +
                   0.008f * std::sin((x * 2.2f - t * 0.22f + 0.37f) * kTau);
    }

    const float p = t * 0.45f;
    const float base = p - std::floor(p);
    for (int32_t k = 0; k < kTrail; ++k) {
        float q = base - k * 0.018f;
        if (q < 0.0f) q += 1.0f;
        out[i++] = 0.06f + 0.88f * q;
        out[i++] = kDeck - 0.035f;
    }

    return kTotal;
}

} // extern "C"