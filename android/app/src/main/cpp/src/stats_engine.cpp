#include "stats_engine.h"
#include <algorithm>
#include <ctime>
#include <unordered_map>

namespace kp {

    static int64_t days_from_civil(int y, int m, int d) {
        y -= m <= 2;
        const int era = (y >= 0 ? y : y - 399) / 400;
        const unsigned yoe = (unsigned)(y - era * 400);
        const unsigned doy = (153 * (m + (m > 2 ? -3 : 9)) + 2) / 5 + d - 1;
        const unsigned doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
        return era * 146097 + (int64_t)doe - 719468;
    }

// Локальное время устройства (часовой пояс!)
    static int64_t epoch_days(int32_t sec) {
        std::tm tm{};
        time_t t = (time_t)sec;
        localtime_r(&t, &tm);
        return days_from_civil(tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday);
    }

    int32_t peak_hour(const int32_t* epoch, int32_t n) {
        int32_t buckets[24] = {0};
        for (int32_t i = 0; i < n; ++i) {
            std::tm tm{};
            time_t t = (time_t)epoch[i];
            localtime_r(&t, &tm);
            ++buckets[tm.tm_hour];
        }
        int32_t peak = 0;
        for (int32_t h = 1; h < 24; ++h)
            if (buckets[h] > buckets[peak]) peak = h;
        return peak;
    }

// O(n) вместо O(7n) в Dart — график недели мгновенно
    void weekly_counts(const int32_t* epoch, int32_t n, int32_t now_sec, int32_t* out7) {
        for (int i = 0; i < 7; ++i) out7[i] = 0;
        const int64_t today = epoch_days(now_sec);
        for (int32_t i = 0; i < n; ++i) {
            const int64_t diff = today - epoch_days(epoch[i]);
            if (diff >= 0 && diff < 7) out7[6 - (int)diff]++;
        }
    }

    double avg_length(const int32_t* lens, int32_t n) {
        if (n <= 0) return 0.0;
        int64_t sum = 0;
        for (int32_t i = 0; i < n; ++i) sum += lens[i];
        return (double)sum / n;
    }

    std::string top_language(const char** codes, int32_t n) {
        std::unordered_map<std::string, int32_t> freq;
        freq.reserve(n > 0 ? (size_t)n : 1);
        for (int32_t i = 0; i < n; ++i) if (codes[i]) ++freq[codes[i]];
        std::string best;
        int32_t bv = 0;
        for (auto& kv : freq)
            if (kv.second > bv) { bv = kv.second; best = kv.first; }
        return best;
    }

    std::vector<std::string> top_phrases(const char** srcs, int32_t n, int32_t k) {
        std::unordered_map<std::string, int32_t> freq;
        for (int32_t i = 0; i < n; ++i)
            if (srcs[i] && srcs[i][0]) ++freq[srcs[i]];
        std::vector<std::pair<std::string, int32_t>> all(freq.begin(), freq.end());
        std::sort(all.begin(), all.end(),
                  [](const auto& a, const auto& b) { return a.second > b.second; });
        std::vector<std::string> out;
        for (int32_t i = 0; i < k && i < (int32_t)all.size(); ++i)
            out.push_back(all[i].first);
        return out;
    }
}