#pragma once
#include <cstdint>
namespace kp {
    int32_t level(int32_t xp);
    int32_t xp_next(int32_t xp);
    int32_t xp_current(int32_t xp);
    double  progress(int32_t xp);
}