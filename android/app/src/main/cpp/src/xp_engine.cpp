#include "xp_engine.h"
#include <array>
#include <algorithm>
#include <cmath>
#include <cstdint>

namespace kp {
    namespace {

        constexpr int64_t BASE = 200;
        constexpr double G = 1.25;
        constexpr int32_t MAXL = 100;

        struct XpTables {
            std::array<int64_t, MAXL + 2> need{};
            std::array<int64_t, MAXL + 2> pref{};

            XpTables() {
                pref[0] = 0;
                for (int32_t i = 1; i < static_cast<int32_t>(need.size()); ++i) {
                    need[i] = static_cast<int64_t>(std::round(BASE * std::pow(G, i - 1)));
                    pref[i] = pref[i - 1] + need[i];
                }
            }
        };

        const XpTables& tables() {
            static const XpTables t;
            return t;
        }

        [[gnu::const]] int64_t clamp_i32(int64_t v) noexcept {
            return v > 2147483647LL ? 2147483647LL : v;
        }

    } // namespace

    int32_t level(int32_t xp) {
        if (xp <= 0) return 1;
        const auto& t = tables();
        auto first = t.pref.begin() + 1;
        auto last = t.pref.begin() + MAXL + 1;
        auto it = std::upper_bound(first, last, static_cast<int64_t>(xp));
        int32_t lvl = static_cast<int32_t>(it - t.pref.begin());
        if (lvl < 1) lvl = 1;
        if (lvl > MAXL) lvl = MAXL;
        return lvl;
    }

    int32_t xp_next(int32_t xp) {
        const int32_t lvl = level(xp);
        return static_cast<int32_t>(clamp_i32(tables().pref[lvl]));
    }

    int32_t xp_current(int32_t xp) {
        const int32_t lvl = level(xp);
        if (lvl == 1) return 0;
        return static_cast<int32_t>(clamp_i32(tables().pref[lvl - 1]));
    }

    double progress(int32_t xp) {
        if (xp <= 0) return 0.0;
        const int32_t c = xp_current(xp);
        const int32_t n = xp_next(xp);
        const int64_t need = static_cast<int64_t>(n) - static_cast<int64_t>(c);
        if (need <= 0) return 1.0;
        const double p = static_cast<double>(static_cast<int64_t>(xp) - c) / static_cast<double>(need);
        return p < 0.0 ? 0.0 : (p > 1.0 ? 1.0 : p);
    }

} // namespace kp