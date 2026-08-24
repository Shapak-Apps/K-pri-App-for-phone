#include "srs_engine.h"
#include <cstdint>
#include <cmath>
#include <vector>
#include <algorithm>

namespace {

    constexpr double kMinEf = 1.3;
    constexpr double kMaxEf = 2.8;
    constexpr double kDefaultEf = 2.5;
    constexpr int32_t kMaxInterval = 36500;
    constexpr int64_t kDayMs = 86400000LL;

    inline double clampd(double v, double lo, double hi) {
        return v < lo ? lo : (v > hi ? hi : v);
    }
    inline int32_t clampi(int32_t v, int32_t lo, int32_t hi) {
        return v < lo ? lo : (v > hi ? hi : v);
    }

} // namespace

extern "C" {

[[maybe_unused]] KP_EXPORT int32_t srs_review(
        int32_t repetitions, double ef, int32_t interval_days,
        int32_t quality, int64_t now_ms,
        int32_t* out_reps, double* out_ef,
        int32_t* out_interval, int64_t* out_due_ms) {

    if (!out_reps || !out_ef || !out_interval || !out_due_ms) return -1;

    int32_t reps = clampi(repetitions, 0, 1000000);
    double e = (std::isfinite(ef) && ef > 0.0)
               ? clampd(ef, kMinEf, kMaxEf)
               : kDefaultEf;
    int32_t interval = clampi(interval_days, 0, kMaxInterval);
    int32_t q = clampi(quality, 0, 5);

    if (q < 3) {
        reps = 0;
        interval = 1;
    } else {
        if (reps == 0) {
            interval = 1;
        } else if (reps == 1) {
            interval = 6;
        } else {
            double next = static_cast<double>(interval) * e;
            if (!std::isfinite(next)) next = static_cast<double>(kMaxInterval);
            interval = clampi(static_cast<int32_t>(std::llround(next)),
                              1, kMaxInterval);
        }
        reps += 1;
    }

    const double delta = 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02);
    e = clampd(e + delta, kMinEf, kMaxEf);

    const int64_t add = static_cast<int64_t>(interval) * kDayMs;
    int64_t due = (add > (INT64_MAX - now_ms)) ? INT64_MAX : now_ms + add;

    *out_reps = reps;
    *out_ef = e;
    *out_interval = interval;
    *out_due_ms = due;
    return 0;
}

[[maybe_unused]] KP_EXPORT int32_t srs_due_indices(
        const int64_t* due_ms, int32_t n, int64_t now_ms,
        int32_t limit, int32_t* out_indices, int32_t out_cap) {

    if (!due_ms || !out_indices || n < 0 || limit <= 0 || out_cap <= 0) return 0;

    const int32_t cap = std::min(limit, out_cap);

    std::vector<std::pair<int64_t, int32_t>> due;
    due.reserve(static_cast<size_t>(n));
    for (int32_t i = 0; i < n; ++i) {
        if (due_ms[i] <= now_ms) due.emplace_back(due_ms[i], i);
    }
    if (due.empty()) return 0;

    const size_t take = std::min(static_cast<size_t>(cap), due.size());
    std::partial_sort(
            due.begin(), due.begin() + static_cast<long>(take), due.end(),
            [](const std::pair<int64_t, int32_t>& a,
               const std::pair<int64_t, int32_t>& b) {
                if (a.first != b.first) return a.first < b.first;
                return a.second < b.second;
            });

    for (size_t k = 0; k < take; ++k) out_indices[k] = due[k].second;
    return static_cast<int32_t>(take);
}

} // extern "C"