#include "json_lite.h"
#include <cctype>
#include <cstdlib>

namespace kj {
    namespace {
        struct Parser {
            const std::string& s;
            size_t i = 0;
            explicit Parser(const std::string& t) : s(t) {}

            void skip() { while (i < s.size() && std::isspace((unsigned char)s[i])) ++i; }
            bool eat(char c) { skip(); if (i < s.size() && s[i] == c) { ++i; return true; } return false; }

            std::string parse_str() {
                std::string out;
                ++i;
                while (i < s.size() && s[i] != '"') {
                    char c = s[i++];
                    if (c == '\\' && i < s.size()) {
                        char e = s[i++];
                        switch (e) {
                            case 'n': out += '\n'; break;
                            case 't': out += '\t'; break;
                            case 'r': out += '\r'; break;
                            case 'u':
                                if (i + 4 <= s.size()) {
                                    unsigned code = (unsigned)strtoul(s.substr(i, 4).c_str(), nullptr, 16);
                                    i += 4;
                                    if (code < 0x80) out += (char)code;
                                    else if (code < 0x800) {
                                        out += (char)(0xC0 | (code >> 6));
                                        out += (char)(0x80 | (code & 63));
                                    } else {
                                        out += (char)(0xE0 | (code >> 12));
                                        out += (char)(0x80 | ((code >> 6) & 63));
                                        out += (char)(0x80 | (code & 63));
                                    }
                                }
                                break;
                            default: out += e;
                        }
                    } else out += c;
                }
                if (i < s.size()) ++i;
                return out;
            }

            ValuePtr parse_value() {
                skip();
                if (i >= s.size()) return std::make_shared<Value>();
                char c = s[i];
                if (c == '{') return parse_obj();
                if (c == '[') return parse_arr();
                if (c == '"') { auto v = std::make_shared<Value>(); v->type = Type::Str; v->str = parse_str(); return v; }
                if (c == 't') { i += 4; auto v = std::make_shared<Value>(); v->type = Type::Bool; v->b = true; return v; }
                if (c == 'f') { i += 5; auto v = std::make_shared<Value>(); v->type = Type::Bool; v->b = false; return v; }
                if (c == 'n') { i += 4; return std::make_shared<Value>(); }
                auto v = std::make_shared<Value>();
                v->type = Type::Num;
                char* end = nullptr;
                v->num = strtod(s.c_str() + i, &end);
                i = end ? (size_t)(end - s.c_str()) : i + 1;
                return v;
            }

            ValuePtr parse_arr() {
                auto v = std::make_shared<Value>();
                v->type = Type::Arr;
                ++i;
                if (eat(']')) return v;
                while (i < s.size()) {
                    v->arr.push_back(parse_value());
                    if (eat(',')) continue;
                    eat(']');
                    break;
                }
                return v;
            }

            ValuePtr parse_obj() {
                auto v = std::make_shared<Value>();
                v->type = Type::Obj;
                ++i;
                if (eat('}')) return v;
                while (i < s.size()) {
                    skip();
                    std::string key;
                    if (i < s.size() && s[i] == '"') key = parse_str();
                    else while (i < s.size() && s[i] != ':') ++i;
                    eat(':');
                    v->obj[key] = parse_value();
                    if (eat(',')) continue;
                    eat('}');
                    break;
                }
                return v;
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
            for (auto& kv : root->obj)
                if (kv.second && kv.second->type == Type::Arr) return kv.second->arr;
        }
        return empty;
    }
}