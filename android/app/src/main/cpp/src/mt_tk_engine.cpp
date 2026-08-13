#include "mt_tk_engine.h"
#include <android/log.h>
#include <algorithm>
#include <atomic>
#include <chrono>
#include <cstring>
#include <mutex>
#include <string>
#include <unordered_map>
#include <vector>

#define MT_TAG "KOPRI_MT"
#define MT_LOG(...) __android_log_print(ANDROID_LOG_INFO, MT_TAG, __VA_ARGS__)

namespace kp {
    namespace {

        struct Engine {
            std::atomic<bool> loaded{false};
            std::mutex load_mu;
            std::unordered_map<std::string, std::string> ph_ru, ph_en;
            std::vector<std::string> keys_ru, keys_en;
            std::unordered_map<std::string, std::string> w_ru, w_en;
        };

        Engine g;

        uint32_t next_cp(const std::string& t, size_t& i) {
            unsigned char c = (unsigned char)t[i];
            uint32_t cp = 0;
            if (c < 0x80) { cp = c; i += 1; }
            else if ((c >> 5) == 0x6 && i + 1 < t.size()) {
                cp = ((c & 0x1F) << 6) | (t[i + 1] & 0x3F); i += 2;
            } else if ((c >> 4) == 0xE && i + 2 < t.size()) {
                cp = ((c & 0x0F) << 12) | ((t[i + 1] & 0x3F) << 6) | (t[i + 2] & 0x3F); i += 3;
            } else if ((c >> 3) == 0x1E && i + 3 < t.size()) {
                cp = ((c & 0x07) << 18) | ((t[i + 1] & 0x3F) << 12) |
                     ((t[i + 2] & 0x3F) << 6) | (t[i + 3] & 0x3F); i += 4;
            } else { i += 1; return 0; }
            return cp;
        }

        void enc_cp(std::string& out, uint32_t cp) {
            if (cp < 0x80) out += (char)cp;
            else if (cp < 0x800) { out += (char)(0xC0 | (cp >> 6)); out += (char)(0x80 | (cp & 63)); }
            else if (cp < 0x10000) { out += (char)(0xE0 | (cp >> 12)); out += (char)(0x80 | ((cp >> 6) & 63)); out += (char)(0x80 | (cp & 63)); }
            else { out += (char)(0xF0 | (cp >> 18)); out += (char)(0x80 | ((cp >> 12) & 63)); out += (char)(0x80 | ((cp >> 6) & 63)); out += (char)(0x80 | (cp & 63)); }
        }

        uint32_t cp_lower(uint32_t cp) {
            if (cp >= 'A' && cp <= 'Z') return cp + 32;
            if (cp >= 0x410 && cp <= 0x42F) return cp + 0x20;
            if (cp == 0x401) return 0x451;

            if (cp == 0x3C2) return 0x3C3;

            switch (cp) {
                case 0xC4: return 0xE4;   case 0xC7: return 0xE7;
                case 0xD6: return 0xF6;   case 0xDC: return 0xFC;
                case 0xDD: return 0xFD;   case 0x17D: return 0x17E;
                case 0x147: return 0x148; case 0x15E: return 0x15F;
                case 0x11E: return 0x11F;
                case 0x391: return 0x3B1; case 0x392: return 0x3B2;
                case 0x393: return 0x3B3; case 0x394: return 0x3B4;
                case 0x395: return 0x3B5; case 0x396: return 0x3B6;
                case 0x397: return 0x3B7; case 0x398: return 0x3B8;
                case 0x399: return 0x3B9; case 0x39A: return 0x3BA;
                case 0x39B: return 0x3BB; case 0x39C: return 0x3BC;
                case 0x39D: return 0x3BD; case 0x39E: return 0x3BE;
                case 0x39F: return 0x3BF; case 0x3A0: return 0x3C0;
                case 0x3A1: return 0x3C1; case 0x3A3: return 0x3C3;
                case 0x3A4: return 0x3C4; case 0x3A5: return 0x3C5;
                case 0x3A6: return 0x3C6; case 0x3A7: return 0x3C7;
                case 0x3A8: return 0x3C8; case 0x3A9: return 0x3C9;
            }
            return cp;
        }

        bool cp_skip(uint32_t cp) {
            switch (cp) {
                case '.': case ',': case '!': case '?': case ';': case ':':
                case '"': case '\'': case '(': case ')': case '[': case ']':
                case '{': case '}': case 0xAB: case 0xBB: case 0x201C: case 0x201D:
                case 0x2014: case 0x2013: case 0x2026: case '/': case '\\':
                case '|': case '+': case '=': case '*': case '#': case '<': case '>':
                    return true;
            }
            return false;
        }

        bool cp_space(uint32_t cp) {
            return cp == ' ' || cp == '\t' || cp == '\n' || cp == '\r';
        }

        std::string norm_key(const std::string& s) {
            std::string out;
            bool sp = false;
            size_t i = 0;
            while (i < s.size()) {
                uint32_t cp = next_cp(s, i);
                if (cp == 0) continue;
                if (cp_space(cp)) { sp = true; continue; }
                if (cp_skip(cp)) continue;
                if (sp && !out.empty()) out += ' ';
                sp = false;
                enc_cp(out, cp_lower(cp));
            }
            return out;
        }

        std::vector<std::string> tokenize(const std::string& s) {
            std::vector<std::string> toks;
            std::string cur;
            size_t i = 0;
            while (i < s.size()) {
                uint32_t cp = next_cp(s, i);
                if (cp == 0) continue;
                if (cp_space(cp) || cp_skip(cp) || cp == '-') {
                    if (!cur.empty()) { toks.push_back(cur); cur.clear(); }
                    continue;
                }
                enc_cp(cur, cp_lower(cp));
            }
            if (!cur.empty()) toks.push_back(cur);
            return toks;
        }

        int lev_cap(const std::string& a, const std::string& b, int cap) {
            const int m = (int)a.size(), n = (int)b.size();
            if (m - n > cap || n - m > cap) return cap + 1;
            if (n > 255) return cap + 1;

            int prev[256], cur[256];
            for (int j = 0; j <= n; ++j) prev[j] = j;

            for (int i = 1; i <= m; ++i) {
                cur[0] = i;
                int rowmin = cur[0];
                for (int j = 1; j <= n; ++j) {
                    int cost = a[i - 1] == b[j - 1] ? 0 : 1;
                    int v = prev[j] + 1;
                    if (cur[j - 1] + 1 < v) v = cur[j - 1] + 1;
                    if (prev[j - 1] + cost < v) v = prev[j - 1] + cost;
                    cur[j] = v;
                    if (v < rowmin) rowmin = v;
                }
                if (rowmin > cap) return cap + 1;
                std::swap_ranges(prev, prev + n + 1, cur);
            }
            return prev[n];
        }

        void build_words(
                const std::unordered_map<std::string, std::unordered_map<std::string, int32_t>>& cooc,
                const std::unordered_map<std::string, int32_t>& tot,
                std::unordered_map<std::string, std::string>& out) {
            for (auto& kv : tot) {
                const std::string& s = kv.first;
                int32_t t = kv.second;
                if (t <= 0) continue;
                auto it = cooc.find(s);
                if (it == cooc.end()) continue;
                const std::string* best = nullptr;
                int32_t bc = 0;
                for (auto& cw : it->second) {
                    if (cw.second > bc) { bc = cw.second; best = &cw.first; }
                }
                if (best && bc * 2 >= t && t >= 2) out[s] = *best;
            }
        }

    }

    int32_t mt_load(int32_t n, const char** ru, const char** en, const char** tk) {
        std::lock_guard<std::mutex> lk(g.load_mu);
        if (g.loaded.load()) return 0;

        auto t0 = std::chrono::steady_clock::now();
        Engine e;
        std::unordered_map<std::string, std::unordered_map<std::string, int32_t>> cooc_ru, cooc_en;
        std::unordered_map<std::string, int32_t> tot_ru, tot_en;

        for (int32_t i = 0; i < n; ++i) {
            if (!ru[i] || !en[i] || !tk[i]) continue;
            const std::string kt = norm_key(tk[i]);
            if (kt.empty()) continue;

            const std::string kr = norm_key(ru[i]);
            if (!kr.empty() && !e.ph_ru.count(kr)) {
                e.ph_ru[kr] = tk[i];
                e.keys_ru.push_back(kr);
            }
            const std::string ke = norm_key(en[i]);
            if (!ke.empty() && !e.ph_en.count(ke)) {
                e.ph_en[ke] = tk[i];
                e.keys_en.push_back(ke);
            }

            auto tr = tokenize(ru[i]);
            auto te = tokenize(en[i]);
            auto tt = tokenize(tk[i]);
            if (tt.empty()) continue;

            auto feed = [&](std::vector<std::string>& src,
                            std::unordered_map<std::string, std::unordered_map<std::string, int32_t>>& cooc,
                            std::unordered_map<std::string, int32_t>& tot) {
                if (src.empty()) return;
                if (src.size() == 1) {
                    std::string joined;
                    for (size_t j = 0; j < tt.size(); ++j) { if (j) joined += ' '; joined += tt[j]; }
                    cooc[src[0]][joined] += 10;
                    tot[src[0]] += 10;
                    return;
                }
                for (auto& s : src) {
                    tot[s] += 1;
                    for (auto& t : tt) cooc[s][t] += 1;
                }
            };
            feed(tr, cooc_ru, tot_ru);
            feed(te, cooc_en, tot_en);
        }

        build_words(cooc_ru, tot_ru, e.w_ru);
        build_words(cooc_en, tot_en, e.w_en);

        g.ph_ru = std::move(e.ph_ru);
        g.ph_en = std::move(e.ph_en);
        g.keys_ru = std::move(e.keys_ru);
        g.keys_en = std::move(e.keys_en);
        g.w_ru = std::move(e.w_ru);
        g.w_en = std::move(e.w_en);
        g.loaded.store(true);

        auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::steady_clock::now() - t0).count();
        MT_LOG("load n=%d ph_ru=%zu ph_en=%zu w_ru=%zu w_en=%zu in %lld ms",
               (int)n, g.ph_ru.size(), g.ph_en.size(),
               g.w_ru.size(), g.w_en.size(), (long long)ms);
        return 0;
    }

    int32_t mt_translate(const char* text, const char* from,
                         char* out, int32_t out_sz, int32_t* quality) {
        auto t0 = std::chrono::steady_clock::now();
        if (!g.loaded.load() || !text || !from || !out || out_sz <= 0) return -1;
        if (quality) *quality = 0;

        const bool is_ru = std::strcmp(from, "ru") == 0;
        const auto& ph = is_ru ? g.ph_ru : g.ph_en;
        const auto& keys = is_ru ? g.keys_ru : g.keys_en;
        const auto& wd = is_ru ? g.w_ru : g.w_en;

        const std::string k = norm_key(text);
        if (k.empty()) return -1;

        auto put = [&](const std::string& s, int32_t q) {
            if ((int32_t)s.size() + 1 > out_sz) return false;
            std::memcpy(out, s.data(), s.size());
            out[s.size()] = '\0';
            if (quality) *quality = q;
            return true;
        };

        auto it = ph.find(k);
        if (it != ph.end()) {
            if (!put(it->second, 1)) return -1;
            MT_LOG("exact hit");
            return (int32_t)it->second.size();
        }

        const int cap = (int)(k.size() / 4) + 2;
        int best = 0;
        const std::string* best_key = nullptr;
        for (const auto& key : keys) {
            size_t d1 = key.size() > k.size() ? key.size() - k.size() : k.size() - key.size();
            if ((int)d1 > cap) continue; // быстрая фильтрация
            int d = lev_cap(k, key, cap);
            if (d > cap) continue;
            int mx = (int)(key.size() > k.size() ? key.size() : k.size());
            if (mx <= 0) continue;
            int score = 1000 - d * 1000 / mx;
            if (score > best) { best = score; best_key = &key; }
        }
        if (best >= 800 && best_key) {
            auto it2 = ph.find(*best_key);
            if (it2 != ph.end() && put(it2->second, 2)) {
                MT_LOG("fuzzy hit score=%d", best);
                return (int32_t)it2->second.size();
            }
        }

        auto toks = tokenize(text);
        if (toks.empty()) return -1;
        std::string res;
        int matched = 0;
        size_t i = 0;
        while (i < toks.size()) {
            bool done = false;
            for (int len = 3; len >= 1 && !done; --len) {
                if (i + (size_t)len > toks.size()) continue;
                std::string cand;
                for (int j = 0; j < len; ++j) { if (j) cand += ' '; cand += toks[i + j]; }
                auto w = wd.find(cand);
                if (w != wd.end()) {
                    if (!res.empty()) res += ' ';
                    res += w->second;
                    ++matched;
                    i += (size_t)len;
                    done = true;
                }
            }
            if (!done) {
                if (!res.empty()) res += ' ';
                res += toks[i];
                i += 1;
            }
        }
        if (matched == 0) { MT_LOG("miss"); return -1; }
        if (!put(res, 3)) return -1;
        auto us = std::chrono::duration_cast<std::chrono::microseconds>(
                std::chrono::steady_clock::now() - t0).count();
        MT_LOG("rough matched=%d/%zu in %lld µs", matched, toks.size(), (long long)us);
        return (int32_t)res.size();
    }

}