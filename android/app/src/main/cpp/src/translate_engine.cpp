#include "translate_engine.h"
#include "json_lite.h"
#include <cctype>

namespace kt {

    namespace {

        [[gnu::always_inline]] static inline uint32_t next_cp(const std::string& t, size_t& i) noexcept {
            unsigned char c = static_cast<unsigned char>(t[i]);
            uint32_t cp = 0;

            if (c < 0x80) {
                cp = c;
                i += 1;
            } else if ((c >> 5) == 0x6 && i + 1 < t.size()) {
                cp = ((c & 0x1F) << 6) | (t[i + 1] & 0x3F);
                i += 2;
            } else if ((c >> 4) == 0xE && i + 2 < t.size()) {
                cp = ((c & 0x0F) << 12) | ((t[i + 1] & 0x3F) << 6) | (t[i + 2] & 0x3F);
                i += 3;
            } else if ((c >> 3) == 0x1E && i + 3 < t.size()) {
                cp = ((c & 0x07) << 18) | ((t[i + 1] & 0x3F) << 12) |
                     ((t[i + 2] & 0x3F) << 6) | (t[i + 3] & 0x3F);
                i += 4;
            } else {
                i += 1;
                return 0;
            }

            return cp;
        }

        [[gnu::always_inline]] static inline bool is_sep_at(const std::string& s, size_t pos) noexcept {
            return pos < s.size() && (s[pos] == '.' || s[pos] == '!' || s[pos] == '?');
        }

        [[gnu::always_inline]] static inline std::string enc4(uint32_t cp) noexcept {
            std::string s;
            s.reserve(4);
            s += static_cast<char>(0xF0 | (cp >> 18));
            s += static_cast<char>(0x80 | ((cp >> 12) & 0x3F));
            s += static_cast<char>(0x80 | ((cp >> 6) & 0x3F));
            s += static_cast<char>(0x80 | (cp & 0x3F));
            return s;
        }

    } // namespace

    [[nodiscard]] std::string detect_script(const std::string& t) {
        int cyr = 0, lat = 0, ara = 0, cjk = 0, dev = 0, tk = 0;
        size_t i = 0;

        while (i < t.size()) {
            const uint32_t cp = next_cp(t, i);

            if (cp >= 0x0400 && cp <= 0x04FF) ++cyr;
            else if ((cp >= 'A' && cp <= 'Z') || (cp >= 'a' && cp <= 'z')) {
                ++lat;
                if (cp == 0xE4 || cp == 0xC4 || cp == 0x17E || cp == 0x17D ||
                    cp == 0x148 || cp == 0x147 || cp == 0x15F || cp == 0x15E ||
                    cp == 0xFD || cp == 0xDD) ++tk;
            } else if (cp >= 0x0600 && cp <= 0x06FF) ++ara;
            else if ((cp >= 0x4E00 && cp <= 0x9FFF) || (cp >= 0x3040 && cp <= 0x30FF) ||
                     (cp >= 0xAC00 && cp <= 0xD7AF)) ++cjk;
            else if (cp >= 0x0900 && cp <= 0x097F) ++dev;
        }

        if (tk > 0) return "tk";

        int mx = 0;
        std::string best = "lat";

        auto consider = [&](int v, const std::string& n) {
            if (v > mx) {
                mx = v;
                best = n;
            }
        };

        consider(cyr, "cyr");
        consider(lat, "lat");
        consider(ara, "ara");
        consider(cjk, "cjk");
        consider(dev, "dev");

        return mx == 0 ? "lat" : best;
    }

    [[nodiscard]] std::string normalize(const std::string& t) {
        std::string out;
        out.reserve(t.size());

        bool sp = false, nl = false, started = false;

        for (char ch : t) {
            if (ch == '\n' || ch == '\r') {
                if (started && !nl) {
                    out += '\n';
                    nl = true;
                    sp = false;
                }
            } else if (ch == ' ' || ch == '\t') {
                if (started && !sp && !nl) {
                    out += ' ';
                    sp = true;
                }
            } else {
                started = true;
                sp = false;
                nl = false;
                out += ch;
            }
        }

        while (!out.empty() && (out.back() == '\n' || out.back() == ' ')) {
            out.pop_back();
        }

        return out;
    }

    [[nodiscard]] std::string split_chunks(const std::string& text, int32_t max) {
        std::string out;
        out.reserve(text.size() + 16);

        size_t start = 0;

        while (start < text.size()) {
            size_t end = start + static_cast<size_t>(max);

            if (end >= text.size()) {
                end = text.size();
            } else {
                size_t cut = std::string::npos;

                for (size_t p = end; p > start + max / 2; --p) {
                    if (is_sep_at(text, p) && p + 1 < text.size() && text[p + 1] == ' ') {
                        cut = p + 2;
                        break;
                    }
                    if (text[p] == '\n') {
                        cut = p + 1;
                        break;
                    }
                }

                if (cut == std::string::npos) {
                    for (size_t p = end; p > start + max / 2; --p) {
                        if (text[p] == ' ') {
                            cut = p + 1;
                            break;
                        }
                    }
                }

                end = (cut == std::string::npos) ? end : cut;
            }

            if (!out.empty()) out += '\x1F';
            out.append(text, start, end - start);
            start = end;
        }

        return out;
    }

    [[nodiscard]] bool parse_gtx(const std::string& json, std::string& out_text, std::string& out_detected) {
        auto root = kj::parse(json);
        if (!root || root->type != kj::Type::Arr || root->arr.empty()) return false;

        auto& first = root->arr[0];
        if (!first || first->type != kj::Type::Arr) return false;

        std::string buf;
        buf.reserve(json.size() / 2);

        for (auto& chunk : first->arr) {
            if (chunk && chunk->type == kj::Type::Arr && !chunk->arr.empty()) {
                auto& s = chunk->arr[0];
                if (s && s->type == kj::Type::Str) buf += s->str;
            }
        }

        if (buf.empty()) return false;

        out_text = std::move(buf);

        if (root->arr.size() > 2) {
            auto& d = root->arr[2];
            if (d && d->type == kj::Type::Str) out_detected = d->str;
        }

        return true;
    }

    [[nodiscard]] std::string flag_emoji(const std::string& cc) {
        if (cc.size() != 2) return "\xF0\x9F\x8F\xB3\xEF\xB8\x8F";

        const uint32_t base = 0x1F1E6 - 'A';
        return enc4(base + static_cast<uint32_t>(toupper(static_cast<unsigned char>(cc[0])))) +
               enc4(base + static_cast<uint32_t>(toupper(static_cast<unsigned char>(cc[1]))));
    }

} // namespace kt