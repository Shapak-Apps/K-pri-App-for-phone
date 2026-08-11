#pragma once
#include <cstdint>
namespace kp {
// 0 = ок, <0 = ошибка (Dart уходит в fallback)
    int32_t resize_image(const char* src, const char* dst, int32_t max_side, int32_t quality);
}