#include "csv_engine.h"
#include "json_lite.h"
#include <cstdint>

#if defined(KP_HAS_ASM_KERNELS)
extern "C" int32_t kp_asm_csv_scan(const uint8_t* p, int32_t n);
#endif

namespace kp {

    namespace {

        static void esc(std::string& out, const std::string& v) {
            out += '"';

#if defined(KP_HAS_ASM_KERNELS)
            const size_t n = v.size();
            size_t start = 0;

            while (start < n) {
                const size_t rem = n - start;
                const size_t adv = static_cast<size_t>(
                        kp_asm_csv_scan(reinterpret_cast<const uint8_t*>(v.data()) + start,
                                        static_cast<int32_t>(rem)));

                if (adv == rem) {
                    out.append(v, start, rem);
                    break;
                }

                out.append(v, start, adv);

                if (v[start + adv] == '"') out += "\"\"";
                else out += '\\';

                start += adv + 1;
            }
#else
            for (char c : v) {
        if (c == '"') out += "\"\"";
        else if (c == '\n' || c == '\r') out += '\\';
        else out += c;
    }
#endif

            out += '"';
        }

    } // namespace

    [[nodiscard]] std::string json_to_csv(const std::string& json) {
        auto root = kj::parse(json);
        const auto& list = kj::as_list(root);

        std::string out;
        out.reserve(list.size() * 128 + 64);
        out += "source,result,from,to,starred\n";

        for (const auto& e : list) {
            if (!e || e->type != kj::Type::Obj) continue;

            esc(out, e->as_string("source"));
            out += ',';
            esc(out, e->as_string("result"));
            out += ',';
            esc(out, e->as_string("from"));
            out += ',';
            esc(out, e->as_string("to"));
            out += ',';
            out += e->as_bool("starred") ? "true" : "false";
            out += '\n';
        }

        return out;
    }

    [[nodiscard]] int32_t json_count(const std::string& json) {
        auto root = kj::parse(json);
        return static_cast<int32_t>(kj::as_list(root).size());
    }

} // namespace kp