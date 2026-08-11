#include "xp_engine.h"
#include <cmath>

namespace kp {
    namespace {
        constexpr int32_t BASE = 100;
        constexpr double  G    = 1.15;
        constexpr int32_t MAXL = 100;
    }

    int32_t level(int32_t xp) {
        int32_t lvl = 1, total = 0;
        while (lvl <= MAXL) {
            const int32_t need = (int32_t)std::round(BASE * std::pow(G, lvl - 1));
            if (total + need > xp) break;
            total += need;
            ++lvl;
        }
        return lvl;
    }

    int32_t xp_next(int32_t xp) {
        const int32_t lvl = level(xp);
        int32_t t = 0;
        for (int32_t i = 1; i <= lvl; ++i)
            t += (int32_t)std::round(BASE * std::pow(G, i - 1));
        return t;
    }

    int32_t xp_current(int32_t xp) {
        const int32_t lvl = level(xp);
        if (lvl == 1) return 0;
        int32_t t = 0;
        for (int32_t i = 1; i < lvl; ++i)
            t += (int32_t)std::round(BASE * std::pow(G, i - 1));
        return t;
    }

    double progress(int32_t xp) {
        const int32_t c = xp_current(xp), n = xp_next(xp), need = n - c;
        if (need <= 0) return 0.0;
        const double p = (double)(xp - c) / need;
        return p < 0 ? 0 : (p > 1 ? 1 : p);
    }
}