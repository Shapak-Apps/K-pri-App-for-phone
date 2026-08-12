#pragma once
#include <cstdint>
#include <string>

namespace kp {

    enum class ClipSkip : int32_t {
        TRANSLATABLE     = 0,
        EMPTY            = 1,
        URL              = 2,
        EMAIL            = 3,
        CODE             = 4,
        PATH             = 5,
        HASH             = 6,
        NUMERIC          = 7,
        EMOJI_ONLY       = 8,
        LOW_TEXT_RATIO   = 9,
    };

    ClipSkip classify(const std::string& text);

    const char* skip_name(ClipSkip s);

}