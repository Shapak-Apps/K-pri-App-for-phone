#pragma once
#include <stdint.h>

#if defined(__GNUC__) || defined(__clang__)
#define KP_EXPORT __attribute__((visibility("default"), used))
#else
#define KP_EXPORT
#endif

#ifdef __cplusplus
extern "C" {
#endif

// XP
KP_EXPORT int32_t pn_level(int32_t xp);
KP_EXPORT int32_t pn_xp_next(int32_t xp);
KP_EXPORT int32_t pn_xp_current(int32_t xp);
KP_EXPORT double  pn_level_progress(int32_t xp);

// Streak
KP_EXPORT int32_t pn_streak_current(const int32_t* dates, int32_t n, int32_t today);
KP_EXPORT int32_t pn_streak_best(const int32_t* dates, int32_t n);

// Stats
KP_EXPORT int32_t pn_peak_hour(const int32_t* epoch, int32_t n);
KP_EXPORT void    pn_weekly_counts(const int32_t* epoch, int32_t n, int32_t now_sec, int32_t* out7);
KP_EXPORT double  pn_avg_length(const int32_t* lens, int32_t n);
KP_EXPORT int32_t pn_top_language(const char** codes, int32_t n, char* out_code, int32_t out_sz);
KP_EXPORT int32_t pn_top_phrases(const char** srcs, int32_t n, int32_t k, char* out_buf, int32_t out_sz);

// JSON/CSV
KP_EXPORT int32_t pn_json_to_csv(const char* json, char* out, int32_t out_sz);
KP_EXPORT int32_t pn_json_count(const char* json);

// Image
KP_EXPORT int32_t pn_image_resize(const char* src, const char* dst, int32_t max_side, int32_t quality);

// Translate
KP_EXPORT int32_t pn_detect_script(const char* text, char* out, int32_t out_sz);
KP_EXPORT int32_t pn_normalize(const char* in, char* out, int32_t out_sz);
KP_EXPORT int32_t pn_split_chunks(const char* text, int32_t max, char* out, int32_t out_sz);
KP_EXPORT int32_t pn_parse_gtx(const char* json, char* out_text, int32_t text_sz, char* out_det, int32_t det_sz);
KP_EXPORT int32_t pn_flag_emoji(const char* cc, char* out, int32_t out_sz);

#ifdef __cplusplus
}
#endif