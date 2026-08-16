#include "json_lite.h"
#include <cctype>
#include <cstring>
#include <sstream>
#include <locale>

namespace kj {
    namespace {

        struct Parser {
            const std::string& s;
            size_t i = 0;

            explicit Parser(const std::string& t) : s(t) {}

            void skip_ws() {
                while (i < s.size()) {
                    char c = s[i];
                    if (c == ' ' || c == '\n' || c == '\r' || c == '\t' || c == '\f' || c == '\v') ++i;
                    else break;
                }
            }

            bool try_eat(char c) {
                skip_ws();
                if (i < s.size() && s[i] == c) { ++i; return true; }
                return false;
            }

            void expect(char c) {
                if (!try_eat(c)) throw std::runtime_error(std::string("Expected '") + c + "'");
            }

            uint32_t parse_hex4() {
                if (i + 4 > s.size()) throw std::runtime_error("Unexpected end of hex");
                uint32_t cp = 0;
                for (int j = 0; j < 4; ++j) {
                    char c = s[i++];
                    cp <<= 4;
                    if (c >= '0' && c <= '9') cp |= (c - '0');
                    else if (c >= 'a' && c <= 'f') cp |= (c - 'a' + 10);
                    else if (c >= 'A' && c <= 'F') cp |= (c - 'A' + 10);
                    else throw std::runtime_error("Invalid hex char");
                }
                return cp;
            }

            void append_utf8(std::string& out, uint32_t cp) {
                if (cp < 0x80) out += static_cast<char>(cp);
                else if (cp < 0x800) {
                    out += static_cast<char>(0xC0 | (cp >> 6));
                    out += static_cast<char>(0x80 | (cp & 0x3F));
                } else if (cp < 0x10000) {
                    out += static_cast<char>(0xE0 | (cp >> 12));
                    out += static_cast<char>(0x80 | ((cp >> 6) & 0x3F));
                    out += static_cast<char>(0x80 | (cp & 0x3F));
                } else if (cp < 0x110000) {
                    out += static_cast<char>(0xF0 | (cp >> 18));
                    out += static_cast<char>(0x80 | ((cp >> 12) & 0x3F));
                    out += static_cast<char>(0x80 | ((cp >> 6) & 0x3F));
                    out += static_cast<char>(0x80 | (cp & 0x3F));
                }
            }

            std::string parse_string() {
                expect('"');
                std::string out;
                size_t start = i;

                while (i < s.size()) {
                    char c = s[i];
                    if (c == '"') {
                        out.append(s, start, i - start);
                        ++i;
                        return out;
                    }
                    if (c == '\\') {
                        out.append(s, start, i - start);
                        ++i;
                        if (i >= s.size()) throw std::runtime_error("Unexpected end of escape");
                        char e = s[i++];
                        switch (e) {
                            case '"': out += '"'; break;
                            case '\\': out += '\\'; break;
                            case '/': out += '/'; break;
                            case 'b': out += '\b'; break;
                            case 'f': out += '\f'; break;
                            case 'n': out += '\n'; break;
                            case 'r': out += '\r'; break;
                            case 't': out += '\t'; break;
                            case 'u': {
                                uint32_t cp = parse_hex4();
                                if (cp >= 0xD800 && cp <= 0xDBFF) {
                                    if (i + 2 <= s.size() && s[i] == '\\' && s[i+1] == 'u') {
                                        i += 2;
                                        uint32_t low = parse_hex4();
                                        if (low >= 0xDC00 && low <= 0xDFFF) {
                                            cp = 0x10000 + ((cp - 0xD800) << 10) + (low - 0xDC00);
                                        } else throw std::runtime_error("Invalid low surrogate");
                                    } else throw std::runtime_error("Missing low surrogate");
                                }
                                append_utf8(out, cp);
                                break;
                            }
                            default: throw std::runtime_error(std::string("Invalid escape: \\") + e);
                        }
                        start = i;
                    } else {
                        ++i;
                    }
                }
                throw std::runtime_error("Unterminated string");
            }

            double parse_number() {
                size_t start = i;
                if (i < s.size() && s[i] == '-') ++i;
                if (i < s.size() && s[i] == '0') ++i;
                else if (i < s.size() && s[i] >= '1' && s[i] <= '9') {
                    ++i;
                    while (i < s.size() && s[i] >= '0' && s[i] <= '9') ++i;
                } else throw std::runtime_error("Invalid number");

                if (i < s.size() && s[i] == '.') {
                    ++i;
                    if (i >= s.size() || s[i] < '0' || s[i] > '9') throw std::runtime_error("Invalid fraction");
                    while (i < s.size() && s[i] >= '0' && s[i] <= '9') ++i;
                }
                if (i < s.size() && (s[i] == 'e' || s[i] == 'E')) {
                    ++i;
                    if (i < s.size() && (s[i] == '+' || s[i] == '-')) ++i;
                    if (i >= s.size() || s[i] < '0' || s[i] > '9') throw std::runtime_error("Invalid exponent");
                    while (i < s.size() && s[i] >= '0' && s[i] <= '9') ++i;
                }

                std::istringstream iss(s.substr(start, i - start));
                iss.imbue(std::locale::classic()); // Гарантированно парсит точку, а не запятую
                double val = 0;
                iss >> val;
                return val;
            }

            bool match_word(const char* word) {
                size_t len = std::strlen(word);
                if (i + len > s.size()) return false;
                if (s.compare(i, len, word) == 0) { i += len; return true; }
                return false;
            }

            ValuePtr parse_value() {
                skip_ws();
                if (i >= s.size()) throw std::runtime_error("Unexpected end of JSON");
                char c = s[i];
                auto v = std::make_shared<Value>();

                if (c == '{') {
                    v->type = Type::Obj;
                    ++i;
                    if (try_eat('}')) return v;
                    while (true) {
                        skip_ws();
                        std::string key = parse_string();
                        expect(':');
                        v->obj[std::move(key)] = parse_value();
                        if (try_eat(',')) continue;
                        expect('}');
                        break;
                    }
                    return v;
                }

                if (c == '[') {
                    v->type = Type::Arr;
                    ++i;
                    if (try_eat(']')) return v;
                    while (true) {
                        v->arr.push_back(parse_value());
                        if (try_eat(',')) continue;
                        expect(']');
                        break;
                    }
                    return v;
                }

                if (c == '"') { v->type = Type::Str; v->str = parse_string(); return v; }
                if (c == 't') { if (!match_word("true")) throw std::runtime_error("Invalid token"); v->type = Type::Bool; v->b = true; return v; }
                if (c == 'f') { if (!match_word("false")) throw std::runtime_error("Invalid token"); v->type = Type::Bool; v->b = false; return v; }
                if (c == 'n') { if (!match_word("null")) throw std::runtime_error("Invalid token"); v->type = Type::Null; return v; }
                if (c == '-' || (c >= '0' && c <= '9')) { v->type = Type::Num; v->num = parse_number(); return v; }

                throw std::runtime_error(std::string("Unexpected char: ") + c);
            }
        };

    }

    const ValuePtr& Value::get(const std::string& k) const {
        static const ValuePtr null_v = std::make_shared<Value>();
        auto it = obj.find(k);
        return it == obj.end() ? null_v : it->second;
    }

    std::string Value::as_string(const std::string& k) const {
        auto& v = get(k);
        return (v && v->type == Type::Str) ? v->str : "";
    }

    bool Value::as_bool(const std::string& k) const {
        auto& v = get(k);
        return v && v->type == Type::Bool && v->b;
    }

    ValuePtr parse(const std::string& text) {
        Parser p(text);
        return p.parse_value();
    }

    const std::vector<ValuePtr>& as_list(const ValuePtr& root) {
        static const std::vector<ValuePtr> empty;
        if (!root) return empty;
        if (root->type == Type::Arr) return root->arr;
        if (root->type == Type::Obj) {
            auto h = root->get("history");
            if (h && h->type == Type::Arr) return h->arr;
            for (auto& kv : root->obj) {
                if (kv.second && kv.second->type == Type::Arr) return kv.second->arr;
            }
        }
        return empty;
    }

}