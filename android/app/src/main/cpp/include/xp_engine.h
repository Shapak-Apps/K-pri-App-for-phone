#pragma once
#include <cstdint>
#include <string>
#include <vector>

namespace kp {
    [[nodiscard]] int32_t level(int32_t xp);
    [[nodiscard]] int32_t xp_next(int32_t xp);
    [[nodiscard]] int32_t xp_current(int32_t xp);
    [[nodiscard]] double progress(int32_t xp);
}

// Plain C symbols (no name mangling) so Dart bindings can look them up
// directly by name.
extern "C" {
/// 1 XP per character of the TRANSLATED text (cap 500 per translation).
/// +30% for rare target language, +50 for the first translation of window.
/// [[maybe_unused]] — used by Dart via FFI at runtime; C++ analyzer can't
/// see cross-language calls, so we silence the false "never used" warning.
[[maybe_unused]] int32_t kp_compute_translation_xp(
        int32_t char_count,
        int32_t is_rare_language,
        int32_t is_first_in_window);
}