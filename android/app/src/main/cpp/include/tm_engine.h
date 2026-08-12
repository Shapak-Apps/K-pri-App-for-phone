#pragma once
#include <cstdint>

namespace kp {

    int32_t tm_rebuild(int32_t n, const char** srcs, const char** dsts,
                       const char** froms, const char** tos);

    int32_t tm_add(const char* src, const char* dst,
                   const char* from, const char* to);

    int32_t tm_lookup(const char* src, const char* from, const char* to,
                      char* out_dst, int32_t out_sz);

    int32_t tm_clear();

}