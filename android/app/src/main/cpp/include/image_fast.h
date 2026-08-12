#pragma once
#include <cstdint>
namespace kp {
    int32_t resize_image(const char* src, const char* dst, int32_t max_side, int32_t quality);
}