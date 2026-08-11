#include "splash_engine.h"
#include <cmath>
#include <algorithm>

namespace splash {
    namespace {

        double fract(double v) { return v - std::floor(v); }

        double hash_noise(int i) {
            return fract(std::sin(i * 127.1 + 311.7) * 43758.5453);
        }

        double clamp01(double t) { return t < 0.0 ? 0.0 : (t > 1.0 ? 1.0 : t); }

        double ease_out_cubic(double t) {
            const double u = 1.0 - t;
            return 1.0 - u * u * u;
        }

        double ease_out(double t) {
            const double u = 1.0 - t;
            return 1.0 - u * u;
        }

        double ease_out_back(double t) {
            const double c1 = 1.70158, c3 = c1 + 1.0;
            const double u = t - 1.0;
            return 1.0 + c3 * u * u * u + c1 * u * u;
        }

    }

    void init_tables() {

    }

    int compute_particles(double t, int count, float* out, int cap) {
        const int n = std::min(count, cap);
        for (int i = 0; i < n; ++i) {
            const double a = 2.0 + i * 0.5;
            const double b = 3.0 + i * 0.3;
            const double delta = i * M_PI / 6.0;

            const double x = 120.0 * std::sin(a * t * 2.0 * M_PI + delta);
            const double y = 100.0 * std::sin(b * t * 2.0 * M_PI);

            const double op = (std::sin(t * 2.0 * M_PI + i) + 1.0) * 0.5;
            const double alpha = op * 0.6;
            const double size = 2.0 + 2.0 * std::sin(t * 4.0 * M_PI + i);

            float* o = out + (size_t)i * 5;
            o[0] = (float)x;
            o[1] = (float)y;
            o[2] = (float)size;
            o[3] = (float)alpha;
            o[4] = (float)(size * 3.5);
        }
        return n;
    }

    int compute_streaks(double time, double intensity, int count, float* out, int cap) {
        const int n = std::min(count, cap);
        int w = 0;

        for (int i = 0; i < n; ++i) {
            const double ang = hash_noise(i) * 2.0 * M_PI;
            const double speed = 0.5 + hash_noise(i + 1000) * 1.1;
            const double seed = hash_noise(i + 2000);

            const double prog = fract(time * speed + seed);
            const double r_norm = 0.12 + 0.95 * std::pow(prog, 2.4);
            const double len = (4.0 + 30.0 * prog) * intensity;
            const double alpha = std::sin(M_PI * prog) * 0.65 * intensity;

            if (alpha <= 0.01) continue;

            float* o = out + (size_t)w * 5;
            o[0] = (float)ang;
            o[1] = (float)r_norm;
            o[2] = (float)len;
            o[3] = (float)alpha;
            o[4] = (float)hash_noise(i + 3000);
            ++w;
        }
        return w;
    }

    int compute_letters(double main_t, double wave_phase, int count, float* out, int cap) {
        const int n = std::min(count, cap);
        for (int i = 0; i < n; ++i) {
            const double s = 0.25 + i * 0.08;
            const double e = s + 0.25;
            const double t = clamp01((main_t - s) / (e - s));

            const double scale = ease_out_back(t);
            const double y_off = 50.0 * (1.0 - ease_out_cubic(t));
            const double rot = (-M_PI / 6.0) * (1.0 - ease_out(t));
            const double wave = std::sin(wave_phase + i * 0.5) * 2.0;

            float* o = out + (size_t)i * 4;
            o[0] = (float)y_off;
            o[1] = (float)scale;
            o[2] = (float)rot;
            o[3] = (float)wave;
        }
        return n;
    }

}

// ── FFI exports ─────────────────────────────────────────────
extern "C" {

void sp_init() { splash::init_tables(); }

int sp_particles(double t, int32_t count, float* out, int32_t cap) {
    return splash::compute_particles(t, count, out, cap);
}

int sp_streaks(double time, double intensity, int32_t count, float* out, int32_t cap) {
    return splash::compute_streaks(time, intensity, count, out, cap);
}

int sp_letters(double main_t, double wave_phase, int32_t count, float* out, int32_t cap) {
    return splash::compute_letters(main_t, wave_phase, count, out, cap);
}

}