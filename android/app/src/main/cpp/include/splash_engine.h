#pragma once
#include <cstdint>

namespace splash {

    void init_tables();

    int compute_particles(double t, int count, float* out, int cap);

    int compute_streaks(double time, double intensity, int count, float* out, int cap);

    int compute_letters(double main_t, double wave_phase, int count, float* out, int cap);

}