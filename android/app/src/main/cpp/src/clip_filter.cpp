#include "clip_filter.h"
#include "translate_engine.h"
#include <cctype>
#include <cstring>
#include <string>

#if defined(KP_HAS_ASM_KERNELS)
extern "C" void kp_asm_clip_stats(const uint8_t* p, int32_t n, uint32_t* out4);
#endif

namespace kp {

    namespace {

        [[gnu::always_inline]] static inline char ascii_lower(char c) noexcept {
            return (c >= 'A' && c <= 'Z') ? static_cast<char>(c + 32) : c;
        }

        static bool starts_with_ci(const std::string& s, const char* prefix) noexcept {
            for (size_t i = 0; prefix[i] != '\0'; ++i) {
                if (i >= s.size()) return false;
                if (ascii_lower(s[i]) != prefix[i]) return false;
            }
            return true;
        }

        static bool contains_ci(const std::string& s, const char* sub) noexcept {
            const size_t n = std::strlen(sub);
            if (n > s.size()) return false;

            for (size_t i = 0; i + n <= s.size(); ++i) {
                bool ok = true;
                for (size_t j = 0; j < n; ++j) {
                    if (ascii_lower(s[i + j]) != sub[j]) {
                        ok = false;
                        break;
                    }
                }
                if (ok) return true;
            }

            return false;
        }

        [[gnu::always_inline]] static inline bool is_hex(char c) noexcept {
            return (c >= '0' && c <= '9') ||
                   (c >= 'a' && c <= 'f') ||
                   (c >= 'A' && c <= 'F');
        }

        static bool looks_like_email(const std::string& s) noexcept {
            size_t at = std::string::npos;
            int at_count = 0;

            for (size_t i = 0; i < s.size(); ++i) {
                if (s[i] == '@') {
                    if (at_count == 0) at = i;
                    ++at_count;
                }
            }

            if (at_count != 1 || at == 0 || at + 1 >= s.size()) return false;

            size_t dot = std::string::npos;
            for (size_t i = at + 1; i < s.size(); ++i) {
                if (s[i] == '.') {
                    dot = i;
                    break;
                }
            }

            return dot != std::string::npos && dot + 2 < s.size();
        }

        static bool looks_like_hash(const std::string& s) noexcept {
            if (s.size() < 32) return false;

            for (char c : s) {
                if (!is_hex(c)) return false;
            }

            return true;
        }

        static bool looks_like_path(const std::string& s) noexcept {
            if (s.empty()) return false;
            if (s[0] == '/' || s[0] == '~') return true;

            if (s.size() >= 3 && std::isalpha(static_cast<unsigned char>(s[0])) &&
                s[1] == ':' && (s[2] == '\\' || s[2] == '/')) {
                return true;
            }

            if (s.size() >= 2 && s[0] == '.' && (s[1] == '/' || s[1] == '\\')) return true;

            return false;
        }

        struct Stats {
            size_t total_cp = 0;
            size_t letters = 0;
            size_t digits = 0;
            size_t spaces = 0;
            size_t code_chars = 0;
            size_t emoji_only = 0;
        };

        static Stats collect_stats(const std::string& s) {
            Stats st;
            size_t i = 0;
            const size_t n = s.size();

            while (i < n) {
                unsigned char c = static_cast<unsigned char>(s[i]);

                if (c < 0x80) {
#if defined(KP_HAS_ASM_KERNELS)
                    size_t j = i;
                    while (j < n && static_cast<unsigned char>(s[j]) < 0x80) ++j;
                    const int32_t run = static_cast<int32_t>(j - i);
                    uint32_t cnt[4] = {0, 0, 0, 0};
                    kp_asm_clip_stats(reinterpret_cast<const uint8_t*>(s.data()) + i, run, cnt);
                    st.total_cp += static_cast<size_t>(run);
                    st.letters += cnt[0];
                    st.digits += cnt[1];
                    st.spaces += cnt[2];
                    st.code_chars += cnt[3];
                    i = j;
#else
                    ++st.total_cp;
            if (std::isalpha(c)) ++st.letters;
            else if (std::isdigit(c)) ++st.digits;
            else if (c == ' ' || c == '\t') ++st.spaces;
            else if (c == '{' || c == '}' || c == '[' || c == ']' ||
                     c == '(' || c == ')' || c == ';' || c == '=' ||
                     c == '<' || c == '>' || c == '_' || c == '#' ||
                     c == '/' || c == '*' || c == '+' || c == '-' ||
                     c == '&' || c == '|' || c == '^' || c == '~' ||
                     c == '`') {
                ++st.code_chars;
            }
            ++i;
#endif
                } else {
                    uint32_t cp = 0;
                    size_t step = 1;

                    if ((c >> 5) == 0x06 && i + 1 < n) {
                        cp = ((c & 0x1F) << 6) | (s[i+1] & 0x3F);
                        step = 2;
                    } else if ((c >> 4) == 0x0E && i + 2 < n) {
                        cp = ((c & 0x0F) << 12) | ((s[i+1] & 0x3F) << 6) | (s[i+2] & 0x3F);
                        step = 3;
                    } else if ((c >> 3) == 0x1E && i + 3 < n) {
                        cp = ((c & 0x07) << 18) | ((s[i+1] & 0x3F) << 12) |
                             ((s[i+2] & 0x3F) << 6) | (s[i+3] & 0x3F);
                        step = 4;
                    }

                    ++st.total_cp;

                    if ((cp >= 0x0041 && cp <= 0x024F) ||
                        (cp >= 0x0400 && cp <= 0x04FF) ||
                        (cp >= 0x0600 && cp <= 0x06FF) ||
                        (cp >= 0x0900 && cp <= 0x097F) ||
                        (cp >= 0x4E00 && cp <= 0x9FFF) ||
                        (cp >= 0x3040 && cp <= 0x30FF) ||
                        (cp >= 0xAC00 && cp <= 0xD7AF)) {
                        ++st.letters;
                    } else if ((cp >= 0x1F600 && cp <= 0x1F64F) ||
                               (cp >= 0x1F300 && cp <= 0x1F5FF) ||
                               (cp >= 0x1F900 && cp <= 0x1F9FF) ||
                               (cp >= 0x1FA70 && cp <= 0x1FAFF) ||
                               (cp >= 0x2600 && cp <= 0x26FF)) {
                        ++st.emoji_only;
                    }

                    i += step;
                }
            }

            return st;
        }

    } // namespace

    [[nodiscard]] ClipSkip classify(const std::string& raw) {
        const std::string s = kt::normalize(raw);

        if (s.size() < 2) return ClipSkip::EMPTY;
        if (s.size() > 2000) return ClipSkip::EMPTY;

        if (starts_with_ci(s, "http://") ||
            starts_with_ci(s, "https://") ||
            starts_with_ci(s, "ftp://") ||
            starts_with_ci(s, "www.") ||
            starts_with_ci(s, "mailto:") ||
            starts_with_ci(s, "tel:")) {
            return ClipSkip::URL;
        }

        if (looks_like_email(s)) return ClipSkip::EMAIL;
        if (looks_like_hash(s)) return ClipSkip::HASH;
        if (looks_like_path(s)) return ClipSkip::PATH;

        int code_kw = 0;
        static const char* keywords[] = {
                "function", "const ", "var ", "let ", "return", "import ",
                "export ", "class ", "public ", "private", "void ",
                "int ", "def ", "lambda", "async ", "await ", "=>",
                "printf", "cout", "println", "console.log", "system.out"
        };

        for (const char* kw : keywords) {
            if (contains_ci(s, kw)) {
                ++code_kw;
                if (code_kw >= 2) break;
            }
        }

        Stats st = collect_stats(s);

        if (st.total_cp == 0) return ClipSkip::EMPTY;

        if (st.letters == 0 && st.digits == 0 && st.emoji_only > 0) {
            return ClipSkip::EMOJI_ONLY;
        }

        if (st.letters == 0 && st.digits > 0) {
            return ClipSkip::NUMERIC;
        }

        const double code_ratio = static_cast<double>(st.code_chars + code_kw * 5) / static_cast<double>(st.total_cp);
        if (code_ratio > 0.25 || code_kw >= 2) {
            return ClipSkip::CODE;
        }

        const double text_ratio = static_cast<double>(st.letters) / static_cast<double>(st.total_cp);
        if (text_ratio < 0.40) {
            return ClipSkip::LOW_TEXT_RATIO;
        }

        return ClipSkip::TRANSLATABLE;
    }

    [[nodiscard]] const char* skip_name(ClipSkip s) {
        switch (s) {
            case ClipSkip::TRANSLATABLE: return "TRANSLATABLE";
            case ClipSkip::EMPTY: return "EMPTY";
            case ClipSkip::URL: return "URL";
            case ClipSkip::EMAIL: return "EMAIL";
            case ClipSkip::CODE: return "CODE";
            case ClipSkip::PATH: return "PATH";
            case ClipSkip::HASH: return "HASH";
            case ClipSkip::NUMERIC: return "NUMERIC";
            case ClipSkip::EMOJI_ONLY: return "EMOJI_ONLY";
            case ClipSkip::LOW_TEXT_RATIO: return "LOW_TEXT_RATIO";
        }
        return "?";
    }

} // namespace kp