#include "profile_native.h"
#include "xp_engine.h"
#include "streak_engine.h"
#include "stats_engine.h"
#include "csv_engine.h"
#include "image_fast.h"
#include "translate_engine.h"
#include "clip_filter.h"
#include "tm_engine.h"
#include "mt_tk_engine.h"
#include <cstring>
#include <string>
#include <vector>
#include <android/log.h>

#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, "KOPRI_CXX", __VA_ARGS__)

extern "C" {

// ═══════════════════════════════════════════════════════════
// XP / LEVEL
// ═══════════════════════════════════════════════════════════

KP_EXPORT int32_t pn_level(int32_t xp) {
    static bool logged = false;
    if (!logged) { LOGI("pn_level CALLED"); logged = true; }
    return kp::level(xp);
}

KP_EXPORT int32_t pn_xp_next(int32_t xp) {
    return kp::xp_next(xp);
}

KP_EXPORT int32_t pn_xp_current(int32_t xp) {
    return kp::xp_current(xp);
}

KP_EXPORT double pn_level_progress(int32_t xp) {
    return kp::progress(xp);
}

// ═══════════════════════════════════════════════════════════
// STREAK
// ═══════════════════════════════════════════════════════════

KP_EXPORT int32_t pn_streak_current(const int32_t* dates, int32_t n, int32_t today) {
    return kp::current_streak(std::vector<int32_t>(dates, dates + n), today);
}

KP_EXPORT int32_t pn_streak_best(const int32_t* dates, int32_t n) {
    return kp::best_streak(std::vector<int32_t>(dates, dates + n));
}

// ═══════════════════════════════════════════════════════════
// STATS
// ═══════════════════════════════════════════════════════════

KP_EXPORT int32_t pn_peak_hour(const int32_t* epoch, int32_t n) {
    return kp::peak_hour(epoch, n);
}

KP_EXPORT void pn_weekly_counts(const int32_t* epoch, int32_t n, int32_t now_sec, int32_t* out7) {
    kp::weekly_counts(epoch, n, now_sec, out7);
}

KP_EXPORT double pn_avg_length(const int32_t* lens, int32_t n) {
    return kp::avg_length(lens, n);
}

KP_EXPORT int32_t pn_top_language(const char** codes, int32_t n, char* out_code, int32_t out_sz) {
    const std::string top = kp::top_language(codes, n);
    if (out_code && out_sz > 0) {
        strncpy(out_code, top.c_str(), (size_t)(out_sz - 1));
        out_code[out_sz - 1] = '\0';
    }
    return (int32_t)top.size();
}

KP_EXPORT int32_t pn_top_phrases(const char** srcs, int32_t n, int32_t k, char* out_buf, int32_t out_sz) {
    const auto tops = kp::top_phrases(srcs, n, k);
    std::string joined;
    for (size_t i = 0; i < tops.size(); ++i) {
        if (i) joined += '\n';
        joined += tops[i];
    }
    if (!out_buf || out_sz <= 0) return -1;
    strncpy(out_buf, joined.c_str(), (size_t)(out_sz - 1));
    out_buf[out_sz - 1] = '\0';
    return (int32_t)tops.size();
}

// ═══════════════════════════════════════════════════════════
// JSON / CSV
// ═══════════════════════════════════════════════════════════

KP_EXPORT int32_t pn_json_to_csv(const char* json, char* out, int32_t out_sz) {
    if (!json || !out || out_sz <= 0) return -1;
    const std::string csv = kp::json_to_csv(json);
    if ((int32_t)csv.size() + 1 > out_sz) return -2;
    memcpy(out, csv.data(), csv.size());
    out[csv.size()] = '\0';
    return (int32_t)csv.size();
}

KP_EXPORT int32_t pn_json_count(const char* json) {
    return json ? kp::json_count(json) : 0;
}

// ═══════════════════════════════════════════════════════════
// IMAGE
// ═══════════════════════════════════════════════════════════

KP_EXPORT int32_t pn_image_resize(const char* src, const char* dst, int32_t max_side, int32_t quality) {
    if (!src || !dst) return -1;
    return kp::resize_image(src, dst, max_side, quality);
}

// ═══════════════════════════════════════════════════════════
// TRANSLATE
// ═══════════════════════════════════════════════════════════

KP_EXPORT int32_t pn_detect_script(const char* text, char* out, int32_t out_sz) {
    if (!text || !out || out_sz <= 0) return -1;
    const std::string r = kt::detect_script(text);
    strncpy(out, r.c_str(), (size_t)(out_sz - 1));
    out[out_sz - 1] = '\0';
    return (int32_t)r.size();
}

KP_EXPORT int32_t pn_normalize(const char* in, char* out, int32_t out_sz) {
    if (!in || !out || out_sz <= 0) return -1;
    const std::string r = kt::normalize(in);
    if ((int32_t)r.size() + 1 > out_sz) return -2;
    memcpy(out, r.data(), r.size());
    out[r.size()] = '\0';
    return (int32_t)r.size();
}

KP_EXPORT int32_t pn_split_chunks(const char* text, int32_t max, char* out, int32_t out_sz) {
    if (!text || !out || out_sz <= 0) return -1;
    const std::string r = kt::split_chunks(text, max);
    if ((int32_t)r.size() + 1 > out_sz) return -2;
    memcpy(out, r.data(), r.size());
    out[r.size()] = '\0';
    return (int32_t)r.size();
}

KP_EXPORT int32_t pn_parse_gtx(const char* json, char* out_text, int32_t text_sz,
                               char* out_det, int32_t det_sz) {
    if (!json || !out_text || text_sz <= 0) return -1;
    std::string txt, det;
    if (!kt::parse_gtx(json, txt, det)) return -3;
    if ((int32_t)txt.size() + 1 > text_sz) return -2;
    memcpy(out_text, txt.data(), txt.size());
    out_text[txt.size()] = '\0';
    if (out_det && det_sz > 0) {
        strncpy(out_det, det.c_str(), (size_t)(det_sz - 1));
        out_det[det_sz - 1] = '\0';
    }
    return (int32_t)txt.size();
}

KP_EXPORT int32_t pn_flag_emoji(const char* cc, char* out, int32_t out_sz) {
    if (!cc || !out || out_sz <= 0) return -1;
    const std::string r = kt::flag_emoji(cc);
    if ((int32_t)r.size() + 1 > out_sz) return -2;
    memcpy(out, r.data(), r.size());
    out[r.size()] = '\0';
    return (int32_t)r.size();
}

// ═══════════════════════════════════════════════════════════
// TRANSLATION MEMORY
// ═══════════════════════════════════════════════════════════

KP_EXPORT int32_t pn_tm_rebuild(int32_t n, const char** srcs, const char** dsts,
                                const char** froms, const char** tos) {
    return kp::tm_rebuild(n, srcs, dsts, froms, tos);
}

KP_EXPORT int32_t pn_tm_add(const char* src, const char* dst,
                            const char* from, const char* to) {
    return kp::tm_add(src, dst, from, to);
}

KP_EXPORT int32_t pn_tm_lookup(const char* src, const char* from, const char* to,
                               char* out_dst, int32_t out_sz) {
    return kp::tm_lookup(src, from, to, out_dst, out_sz);
}

KP_EXPORT int32_t pn_tm_clear() {
    return kp::tm_clear();
}

// ═══════════════════════════════════════════════════════════
// CLIPBOARD FILTER
// ═══════════════════════════════════════════════════════════

KP_EXPORT int32_t pn_clip_classify(const char* text) {
    if (!text) return (int32_t)kp::ClipSkip::EMPTY;
    return (int32_t)kp::classify(text);
}

// ═══ MT TURKMEN CORE ═══
KP_EXPORT int32_t pn_mt_load(int32_t n, const char** ru, const char** en, const char** tk, const char** tr) {
    return kp::mt_load(n, ru, en, tk, tr);
}

KP_EXPORT int32_t pn_mt_translate(const char* text, const char* from,
                                  char* out, int32_t out_sz, int32_t* quality) {
    return kp::mt_translate(text, from, out, out_sz, quality);
}
}