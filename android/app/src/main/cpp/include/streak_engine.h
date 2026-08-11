#pragma once
#include <cstdint>
#include <vector>
namespace kp {
    int32_t current_streak(const std::vector<int32_t>& ymd, int32_t today_ymd);
    int32_t best_streak(const std::vector<int32_t>& ymd);
}