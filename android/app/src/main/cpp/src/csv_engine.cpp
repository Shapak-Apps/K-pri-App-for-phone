#include "csv_engine.h"
#include "json_lite.h"

namespace kp {

    static void esc(std::string& out, const std::string& v) {
        out += '"';
        for (char c : v) {
            if (c == '"') out += "\"\"";
            else if (c == '\n' || c == '\r') out += ' ';
            else out += c;
        }
        out += '"';
    }

    std::string json_to_csv(const std::string& json) {
        const auto& list = kj::as_list(kj::parse(json));
        std::string out;
        out.reserve(list.size() * 128 + 64);
        out += "source,result,from,to,starred\n";
        for (const auto& e : list) {
            if (!e || e->type != kj::Type::Obj) continue;
            esc(out, e->as_string("source")); out += ',';
            esc(out, e->as_string("result")); out += ',';
            esc(out, e->as_string("from"));   out += ',';
            esc(out, e->as_string("to"));     out += ',';
            out += e->as_bool("starred") ? "true" : "false";
            out += '\n';
        }
        return out;
    }

    int32_t json_count(const std::string& json) {
        return (int32_t)kj::as_list(kj::parse(json)).size();
    }
}