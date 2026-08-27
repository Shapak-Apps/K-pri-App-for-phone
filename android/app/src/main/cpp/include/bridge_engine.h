#pragma once
#include <cstdint>

#ifndef KP_EXPORT
#define KP_EXPORT __attribute__((visibility("default")))
#endif

extern "C" {
KP_EXPORT int32_t bridge_frame(float t, float* out, int32_t cap);
}