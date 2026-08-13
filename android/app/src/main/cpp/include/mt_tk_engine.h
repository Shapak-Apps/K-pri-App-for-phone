#pragma once
#include <cstdint>

namespace kp {

        int32_t mt_load(int32_t n, const char** ru, const char** en, const char** tk);

        int32_t mt_translate(const char* text, const char* from,
        char* out, int32_t out_sz, int32_t* quality);

}