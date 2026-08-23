#include "stats_engine.h"
#include <algorithm>
#include <cstdint>
#include <ctime>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

#if defined(KP_HAS_ASM_KERNELS)
extern "C" int64_t kp_asm_sum_i32(const int32_t* p, int32_t n);
#endif

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

        [[gnu::const]] static int64_t epoch_days(int32_t sec) noexcept {
            std::tm tm{};
            time_t t = static_cast<time_t>(sec);
            localtime_r(&t, &tm);
            return days_from_civil(tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday);
        }

    } // namespace

    [[nodiscard]] int32_t peak_hour(const int32_t* epoch, int32_t n) {
        if (__builtin_expect(n <= 0, 0)) return 0;

        int32_t buckets[24] = {0};

        for (int32_t i = 0; i < n; ++i) {
            std::tm tm{};
            time_t t = static_cast<time_t>(epoch[i]);
            localtime_r(&t, &tm);
            ++buckets[tm.tm_hour];
        }

        int32_t peak = 0;
        for (int32_t h = 1; h < 24; ++h) {
            if (buckets[h] > buckets[peak]) peak = h;
        }

        return peak;
    }

    void weekly_counts(const int32_t* epoch, int32_t n, int32_t now_sec, int32_t* out7) {
        for (int i = 0; i < 7; ++i) out7[i] = 0;
        if (__builtin_expect(n <= 0, 0)) return;

        auto slow = [&] {
            const int64_t today = epoch_days(now_sec);
            for (int32_t i = 0; i < n; ++i) {
                const int64_t diff = today - epoch_days(epoch[i]);
                if (diff >= 0 && diff < 7) out7[6 - static_cast<int>(diff)]++;
            }
        };

        if (n < 8) { slow(); return; }

        time_t starts[8];
        bool ok = true;
        time_t now_t = static_cast<time_t>(now_sec);
        std::tm base{};

        if (localtime_r(&now_t, &base) == nullptr) ok = false;

        if (ok) {
            for (int idx = 0; idx < 8; ++idx) {
                std::tm d = base;
                d.tm_mday -= (6 - idx);
                d.tm_hour = 0;
                d.tm_min = 0;
                d.tm_sec = 0;
                d.tm_isdst = -1;
                time_t st = mktime(&d);
                if (st == static_cast<time_t>(-1)) {
                    ok = false;
                    break;
                }
                starts[idx] = st;
            }
        }

        if (ok) {
            for (int i = 1; i < 8; ++i) {
                if (starts[i] <= starts[i - 1]) {
                    ok = false;
                    break;
                }
            }
        }

        if (!ok) {
            slow();
            return;
        }

        for (int32_t i = 0; i < n; ++i) {
            time_t t = static_cast<time_t>(epoch[i]);
            if (t < starts[0] || t >= starts[7]) continue;

            if (t >= starts[6]) ++out7[6];
            else if (t >= starts[5]) ++out7[5];
            else if (t >= starts[4]) ++out7[4];
            else if (t >= starts[3]) ++out7[3];
            else if (t >= starts[2]) ++out7[2];
            else if (t >= starts[1]) ++out7[1];
            else ++out7[0];
        }
    }

    [[nodiscard]] double avg_length(const int32_t* lens, int32_t n) {
        if (__builtin_expect(n <= 0, 0)) return 0.0;

#if defined(KP_HAS_ASM_KERNELS)
        const int64_t sum = kp_asm_sum_i32(lens, n);
#else
        int64_t sum = 0;
    for (int32_t i = 0; i < n; ++i) sum += lens[i];
#endif

        return static_cast<double>(sum) / n;
    }

    [[nodiscard]] std::string top_language(const char** codes, int32_t n) {
        if (__builtin_expect(n <= 0, 0)) return "";

        std::unordered_map<std::string, int32_t> freq;
        freq.max_load_factor(0.7f);
        freq.reserve(static_cast<size_t>(n));

        for (int32_t i = 0; i < n; ++i) {
            if (codes[i]) ++freq[codes[i]];
        }

        std::string best;
        int32_t bv = 0;

        for (const auto& kv : freq) {
            if (kv.second > bv) {
                bv = kv.second;
                best = kv.first;
            }
        }

        return best;
    }

    [[nodiscard]] std::vector<std::string> top_phrases(const char** srcs, int32_t n, int32_t k) {
        std::vector<std::string> out;
        if (__builtin_expect(n <= 0 || k <= 0, 0)) return out;

        std::unordered_map<std::string, int32_t> freq;
        freq.max_load_factor(0.7f);
        freq.reserve(static_cast<size_t>(n));

        for (int32_t i = 0; i < n; ++i) {
            if (srcs[i] && srcs[i][0]) ++freq[srcs[i]];
        }

        std::vector<std::pair<std::string, int32_t>> all;
        all.reserve(freq.size());

        for (auto& kv : freq) {
            all.emplace_back(std::move(kv.first), kv.second);
        }

        std::sort(all.begin(), all.end(),
                  [](const auto& a, const auto& b) { return a.second > b.second; });

        const int32_t lim = std::min(k, static_cast<int32_t>(all.size()));
        out.reserve(lim);

        for (int32_t i = 0; i < lim; ++i) {
            out.emplace_back(std::move(all[i].first));
        }

        return out;
    }

} // namespace kp