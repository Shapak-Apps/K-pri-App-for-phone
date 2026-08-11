#pragma once
#include <cstdint>
#include <string>
namespace kp {
    std::string json_to_csv(const std::string& json);
    int32_t json_count(const std::string& json);
}