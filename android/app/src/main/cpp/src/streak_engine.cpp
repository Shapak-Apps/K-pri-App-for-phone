#include "streak_engine.h"
#include <algorithm>
#include <vector>

namespace kp {

    namespace {

        [[gnu::const]] static int64_t days_from_civil(int y, int m, int d) noexcept {
            y -= m <= 2;
            const int era = (y >= 0 ? y : y - 399) / 400;
            const unsigned yoe = static_cast<unsigned>(y - era * 400);
            const unsigned doy = (153 * (m + (m > 2 ? -3 : 9)) + 2) / 5 + d - 1;
            const unsigned doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
            return era * 146097 + static_cast<int64_t>(doe) - 719468;
        }

        [[gnu::const]] static int64_t civil_days(int32_t ymd) noexcept {
            return days_from_civil(ymd / 10000, (ymd / 100) % 100, ymd % 100);
        }

        static std::vector<int64_t> sorted_unique_days(const std::vector<int32_t>& ymd) {
            std::vector<int64_t> days;
            days.reserve(ymd.size());

            for (int32_t d : ymd) {
                days.push_back(civil_days(d));
            }

            std::sort(days.begin(), days.end());

            days.erase(std::unique(days.begin(), days.end()), days.end());

            return days;
        }

    }

    [[nodiscard]] int32_t current_streak(const std::vector<int32_t>& ymd, int32_t today_ymd) {
        if (__builtin_expect(ymd.empty(), 0)) return 0;

        const auto days = sorted_unique_days(ymd);
        const int64_t today = civil_days(today_ymd);

        auto it = std::lower_bound(days.begin(), days.end(), today);

        if (it == days.end() || *it != today) {
            if (it == days.begin()) return 0;
            --it;
            if (*it != today - 1) return 0;
        }

        int32_t streak = 0;
        while (true) {
            ++streak;
            if (it == days.begin()) break;
            auto prev = it;
            --prev;
            if (*it - *prev != 1) break;
            it = prev;
        }

        return streak;
    }

    [[nodiscard]] int32_t best_streak(const std::vector<int32_t>& ymd) {
        if (__builtin_expect(ymd.empty(), 0)) return 0;

        const auto days = sorted_unique_days(ymd);

        int32_t best = 1, cur = 1;

        for (size_t i = 1; i < days.size(); ++i) {
            if (days[i] - days[i - 1] == 1) {
                ++cur;
                if (cur > best) best = cur;
            } else {
                cur = 1;
            }
        }

        return best;
    }

}