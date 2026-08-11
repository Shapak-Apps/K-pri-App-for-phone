#include "xp_engine.h"
#include <array>
#include <algorithm>
#include <cmath>

namespace kp {
    namespace {

        constexpr int32_t BASE = 100;
        constexpr double  G    = 1.15;
        constexpr int32_t MAXL = 100;

        struct XpTables {
            std::array<int32_t, MAXL + 2> need{};
            std::array<int32_t, MAXL + 2> pref{};

            XpTables() {
                pref[0] = 0;
                for (int32_t i = 1; i < static_cast<int32_t>(need.size()); ++i) {
                    need[i] = static_cast<int32_t>(std::round(BASE * std::pow(G, i - 1)));
                    pref[i] = pref[i - 1] + need[i];
                }
            }
        };

        const XpTables& tables() {
            static const XpTables t;
            return t;
        }

    } // namespace

    int32_t level(int32_t xp) {
        const auto& t = tables();
        auto first = t.pref.begin() + 1;
        auto last  = t.pref.begin() + MAXL + 1;
        auto it = std::upper_bound(first, last, xp);
        return static_cast<int32_t>(it - t.pref.begin());
    }

    int32_t xp_next(int32_t xp) {
        return tables().pref[level(xp)];
    }

    int32_t xp_current(int32_t xp) {
        const int32_t lvl = level(xp);
        return lvl == 1 ? 0 : tables().pref[lvl - 1];
    }

    double progress(int32_t xp) {
        const int32_t c = xp_current(xp);
        const int32_t n = xp_next(xp);
        const int32_t need = n - c;
        if (need <= 0) return 0.0;
        const double p = static_cast<double>(xp - c) / need;
        return p < 0.0 ? 0.0 : (p > 1.0 ? 1.0 : p);
    }

} // namespace kp