#pragma once
#include <cstdint>
#include <string>
#include <vector>
namespace kp {
    int32_t peak_hour(const int32_t* epoch, int32_t n);
    void    weekly_counts(const int32_t* epoch, int32_t n, int32_t now_sec, int32_t* out7);
    double  avg_length(const int32_t* lens, int32_t n);
    std::string top_language(const char** codes, int32_t n);
    std::vector<std::string> top_phrases(const char** srcs, int32_t n, int32_t k);
}