#pragma GCC optimize("O3,fast-math,unroll-loops")
#pragma clang optimize on
#include "splash_engine.h"
#include <cmath>
#include <algorithm>
#include <cstdint>

#if defined(KP_HAS_ASM_KERNELS)
extern "C" void kp_asm_sin_f4(const float* x, float* y, int32_t n);
#endif

namespace splash {
    namespace {

        constexpr float PI_F = 3.14159265358979323846f;

        inline float fract(float v) { return v - std::floor(v); }

        inline float hash_noise(int i) {
            uint32_t h = (uint32_t)(i * 2654435761u);
            h ^= h >> 16;
            h *= 0x85ebca6b;
            h ^= h >> 13;
            h *= 0xc2b2ae35;
            h ^= h >> 16;
            return (float)(h & 0x7FFFFF) * 4.76837158203125e-7f;
        }

        inline float clamp01(float t) { return t < 0.0f ? 0.0f : (t > 1.0f ? 1.0f : t); }

        inline float ease_out_cubic(float t) {
            const float u = 1.0f - t;
            return 1.0f - u * u * u;
        }

        inline float ease_out(float t) {
            const float u = 1.0f - t;
            return 1.0f - u * u;
        }

        inline float ease_out_back(float t) {
            const float c1 = 1.70158f, c3 = c1 + 1.0f;
            const float u = t - 1.0f;
            return 1.0f + c3 * u * u * u + c1 * u * u;
        }

#if defined(KP_HAS_ASM_KERNELS)
        inline float red_pi(float x) {
            const float pi2 = 2.0f * PI_F;
            x = std::fmod(x, pi2);
            if (x > PI_F) x -= pi2;
            else if (x < -PI_F) x += pi2;
            return x;
        }
#endif

    }

    void init_tables() {}

    int compute_particles(double t, int count, float* out, int cap) {
        const int n = std::min(count, cap);
        const float tf = (float)t;
        const float pi2 = 2.0f * PI_F;
        const float tpi2 = tf * pi2;
        const float w4 = tf * 4.0f * PI_F;

#if defined(KP_HAS_ASM_KERNELS)
        int i = 0;
        const int n4 = n & ~3;
        float pa[4], pb[4], pc[4], pd[4], sa[4], sb[4], sc[4], sd[4];
        for (; i < n4; i += 4) {
            for (int k = 0; k < 4; ++k) {
                const int ii = i + k;
                const float a = 2.0f + ii * 0.5f;
                const float b = 3.0f + ii * 0.3f;
                pa[k] = red_pi(a * tf * pi2 + ii * PI_F / 6.0f);
                pb[k] = red_pi(b * tpi2);
                pc[k] = red_pi(tpi2 + (float)ii);
                pd[k] = red_pi(w4 + (float)ii);
            }
            kp_asm_sin_f4(pa, sa, 4);
            kp_asm_sin_f4(pb, sb, 4);
            kp_asm_sin_f4(pc, sc, 4);
            kp_asm_sin_f4(pd, sd, 4);
            for (int k = 0; k < 4; ++k) {
                const int ii = i + k;
                const float x = 120.0f * sa[k];
                const float y = 100.0f * sb[k];
                const float op = (sc[k] + 1.0f) * 0.5f;
                const float alpha = op * 0.6f;
                const float size = 2.0f + 2.0f * sd[k];
                float* o = out + (size_t)ii * 5;
                o[0] = x;
                o[1] = y;
                o[2] = size;
                o[3] = alpha;
                o[4] = size * 3.5f;
            }
        }
        for (; i < n; ++i) {
            const float a = 2.0f + i * 0.5f;
            const float b = 3.0f + i * 0.3f;
            const float delta = i * PI_F / 6.0f;
            const float x = 120.0f * std::sin(a * tf * pi2 + delta);
            const float y = 100.0f * std::sin(b * tpi2);
            const float op = (std::sin(tpi2 + i) + 1.0f) * 0.5f;
            const float alpha = op * 0.6f;
            const float size = 2.0f + 2.0f * std::sin(w4 + i);
            float* o = out + (size_t)i * 5;
            o[0] = x;
            o[1] = y;
            o[2] = size;
            o[3] = alpha;
            o[4] = size * 3.5f;
        }
#else
        for (int i = 0; i < n; ++i) {
            const float a = 2.0f + i * 0.5f;
            const float b = 3.0f + i * 0.3f;
            const float delta = i * PI_F / 6.0f;
            const float x = 120.0f * std::sin(a * tf * pi2 + delta);
            const float y = 100.0f * std::sin(b * tpi2);
            const float op = (std::sin(tpi2 + i) + 1.0f) * 0.5f;
            const float alpha = op * 0.6f;
            const float size = 2.0f + 2.0f * std::sin(w4 + i);
            float* o = out + (size_t)i * 5;
            o[0] = x;
            o[1] = y;
            o[2] = size;
            o[3] = alpha;
            o[4] = size * 3.5f;
        }
#endif
        return n;
    }

    int compute_streaks(double time, double intensity, int count, float* out, int cap) {
        const int n = std::min(count, cap);
        int w = 0;
        const float tf = (float)time;
        const float intf = (float)intensity;
        const float pi2 = 2.0f * PI_F;

#if defined(KP_HAS_ASM_KERNELS)
        int i = 0;
        const int n4 = n & ~3;
        float ph[4], sv[4], ang[4], rn[4], ln[4], h3[4];
        for (; i < n4; i += 4) {
            for (int k = 0; k < 4; ++k) {
                const int ii = i + k;
                ang[k] = hash_noise(ii) * pi2;
                const float speed = 0.5f + hash_noise(ii + 1000) * 1.1f;
                const float seed = hash_noise(ii + 2000);
                const float prog = fract(tf * speed + seed);
                ph[k] = PI_F * prog;
                rn[k] = 0.12f + 0.95f * prog * prog * std::sqrt(prog);
                ln[k] = (4.0f + 30.0f * prog) * intf;
                h3[k] = hash_noise(ii + 3000);
            }
            kp_asm_sin_f4(ph, sv, 4);
            for (int k = 0; k < 4; ++k) {
                const float alpha = sv[k] * 0.65f * intf;
                if (alpha <= 0.01f) continue;
                float* o = out + (size_t)w * 5;
                o[0] = ang[k];
                o[1] = rn[k];
                o[2] = ln[k];
                o[3] = alpha;
                o[4] = h3[k];
                ++w;
            }
        }
        for (; i < n; ++i) {
            const float angS = hash_noise(i) * pi2;
            const float speed = 0.5f + hash_noise(i + 1000) * 1.1f;
            const float seed = hash_noise(i + 2000);
            const float prog = fract(tf * speed + seed);
            const float prog2 = prog * prog;
            const float prog25 = prog2 * std::sqrt(prog);
            const float r_norm = 0.12f + 0.95f * prog25;
            const float len = (4.0f + 30.0f * prog) * intf;
            const float alpha = std::sin(PI_F * prog) * 0.65f * intf;
            if (alpha <= 0.01f) continue;
            float* o = out + (size_t)w * 5;
            o[0] = angS;
            o[1] = r_norm;
            o[2] = len;
            o[3] = alpha;
            o[4] = hash_noise(i + 3000);
            ++w;
        }
#else
        for (int i = 0; i < n; ++i) {
            const float ang = hash_noise(i) * pi2;
            const float speed = 0.5f + hash_noise(i + 1000) * 1.1f;
            const float seed = hash_noise(i + 2000);
            const float prog = fract(tf * speed + seed);
            const float prog2 = prog * prog;
            const float prog25 = prog2 * std::sqrt(prog);
            const float r_norm = 0.12f + 0.95f * prog25;
            const float len = (4.0f + 30.0f * prog) * intf;
            const float alpha = std::sin(PI_F * prog) * 0.65f * intf;
            if (alpha <= 0.01f) continue;
            float* o = out + (size_t)w * 5;
            o[0] = ang;
            o[1] = r_norm;
            o[2] = len;
            o[3] = alpha;
            o[4] = hash_noise(i + 3000);
            ++w;
        }
#endif
        return w;
    }

    int compute_letters(double main_t, double wave_phase, int count, float* out, int cap) {
        const int n = std::min(count, cap);
        const float mt = (float)main_t;
        const float wp = (float)wave_phase;

#if defined(KP_HAS_ASM_KERNELS)
        int i = 0;
        const int n4 = n & ~3;
        float ph[4], sv[4];
        for (; i < n4; i += 4) {
            for (int k = 0; k < 4; ++k)
                ph[k] = red_pi(wp + (i + k) * 0.5f);
            kp_asm_sin_f4(ph, sv, 4);
            for (int k = 0; k < 4; ++k) {
                const int ii = i + k;
                const float s = 0.25f + ii * 0.08f;
                const float e = s + 0.25f;
                const float t = clamp01((mt - s) / (e - s));
                const float scale = ease_out_back(t);
                const float y_off = 50.0f * (1.0f - ease_out_cubic(t));
                const float rot = (-PI_F / 6.0f) * (1.0f - ease_out(t));
                const float wave = sv[k] * 2.0f;
                float* o = out + (size_t)ii * 4;
                o[0] = y_off;
                o[1] = scale;
                o[2] = rot;
                o[3] = wave;
            }
        }
        for (; i < n; ++i) {
            const float s = 0.25f + i * 0.08f;
            const float e = s + 0.25f;
            const float t = clamp01((mt - s) / (e - s));
            const float scale = ease_out_back(t);
            const float y_off = 50.0f * (1.0f - ease_out_cubic(t));
            const float rot = (-PI_F / 6.0f) * (1.0f - ease_out(t));
            const float wave = std::sin(wp + i * 0.5f) * 2.0f;
            float* o = out + (size_t)i * 4;
            o[0] = y_off;
            o[1] = scale;
            o[2] = rot;
            o[3] = wave;
        }
#else
        for (int i = 0; i < n; ++i) {
            const float s = 0.25f + i * 0.08f;
            const float e = s + 0.25f;
            const float t = clamp01((mt - s) / (e - s));
            const float scale = ease_out_back(t);
            const float y_off = 50.0f * (1.0f - ease_out_cubic(t));
            const float rot = (-PI_F / 6.0f) * (1.0f - ease_out(t));
            const float wave = std::sin(wp + i * 0.5f) * 2.0f;
            float* o = out + (size_t)i * 4;
            o[0] = y_off;
            o[1] = scale;
            o[2] = rot;
            o[3] = wave;
        }
#endif
        return n;
    }

}

extern "C" {
void sp_init() { splash::init_tables(); }
int sp_particles(double t, int32_t count, float* out, int32_t cap) { return splash::compute_particles(t, count, out, cap); }
int sp_streaks(double time, double intensity, int32_t count, float* out, int32_t cap) { return splash::compute_streaks(time, intensity, count, out, cap); }
int sp_letters(double main_t, double wave_phase, int32_t count, float* out, int32_t cap) { return splash::compute_letters(main_t, wave_phase, count, out, cap); }
}