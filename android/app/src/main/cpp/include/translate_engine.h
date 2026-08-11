#pragma once
#include <cstdint>
#include <string>

namespace kt {
// 'cyr' | 'lat' | 'tk' | 'ara' | 'cjk' | 'dev'
    std::string detect_script(const std::string& text);

// trim + схлопывание пробелов/табов, новые строки сохраняются
    std::string normalize(const std::string& text);

// Чанки ≤ max, разделитель '\x1F'
    std::string split_chunks(const std::string& text, int32_t max);

// Ответ Google gtx: текст + detected. false если не распознано
    bool parse_gtx(const std::string& json, std::string& out_text, std::string& out_detected);

// 'RU' → 🇷🇺 (UTF-8)
    std::string flag_emoji(const std::string& cc);
}