#pragma once
#include <stdint.h>
#include "profile_native.h"

#ifdef __cplusplus
extern "C" {
#endif

KP_EXPORT int32_t srs_review(
        int32_t repetitions,
        double ef,
        int32_t interval_days,
        int32_t quality,
        int64_t now_ms,
        int32_t* out_reps,
        double* out_ef,
        int32_t* out_interval,
        int64_t* out_due_ms);

KP_EXPORT int32_t srs_due_indices(
        const int64_t* due_ms,
        int32_t n,
        int64_t now_ms,
        int32_t limit,
        int32_t* out_indices,
        int32_t out_cap);

#ifdef __cplusplus
}
#endif