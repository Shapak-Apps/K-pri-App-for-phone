#include "tm_engine.h"
#include "translate_engine.h"
#include <android/log.h>
#include <algorithm>
#include <chrono>
#include <cctype>
#include <cstdint>
#include <cstring>
#include <memory>
#include <mutex>
#include <string>
#include <unordered_map>
#include <vector>

#define TM_TAG  "KOPRI_TM"
#define TM_LOG(fmt, ...) __android_log_print(ANDROID_LOG_INFO, TM_TAG, fmt, ##__VA_ARGS__)

namespace kp {
    namespace {

        struct Entry {
            std::string key;
            std::string dst;
            std::string pair;
        };

        struct State {
            std::unordered_map<std::string, std::string> exact;
            std::vector<Entry> fuzzy;
        };

        std::mutex g_mu;
        std::unique_ptr<State> g_state = std::make_unique<State>();

        constexpr size_t MAX_TOTAL = 10000;

        static std::string to_lower_ascii(const std::string& s) {
            std::string out;
            out.reserve(s.size());
            for (unsigned char c : s) {
                out += static_cast<char>(std::tolower(c));
            }
            return out;
        }

        static std::string make_key(const std::string& src_norm,
                                    const std::string& from,
                                    const std::string& to) {
            std::string k;
            k.reserve(from.size() + 1 + to.size() + 1 + src_norm.size());
            k.append(from);
            k.push_back('>');
            k.append(to);
            k.push_back('|');
            k.append(src_norm);
            return k;
        }

        static int levenshtein(const std::string& a, const std::string& b) {
            const size_t m = a.size();
            const size_t n = b.size();
            if (m == 0) return static_cast<int>(n);
            if (n == 0) return static_cast<int>(m);

            std::vector<int> prev(n + 1), cur(n + 1);
            for (size_t j = 0; j <= n; ++j) prev[j] = static_cast<int>(j);

            for (size_t i = 1; i <= m; ++i) {
                cur[0] = static_cast<int>(i);
                for (size_t j = 1; j <= n; ++j) {
                    const int cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
                    cur[j] = std::min({prev[j] + 1,
                                       cur[j - 1] + 1,
                                       prev[j - 1] + cost});
                }
                std::swap(prev, cur);
            }
            return prev[n];
        }

    }

    int32_t tm_rebuild(int32_t n, const char** srcs, const char** dsts,
                       const char** froms, const char** tos) {
        auto t0 = std::chrono::steady_clock::now();

        auto fresh = std::make_unique<State>();
        if (n > 0 && srcs && dsts && froms && tos) {
            fresh->exact.reserve(static_cast<size_t>(n));
            fresh->fuzzy.reserve(static_cast<size_t>(n));

            for (int32_t i = 0; i < n; ++i) {
                if (!srcs[i] || !dsts[i] || !froms[i] || !tos[i]) continue;

                std::string src_norm = to_lower_ascii(kt::normalize(srcs[i]));
                if (src_norm.empty()) continue;

                std::string key = make_key(src_norm, froms[i], tos[i]);
                std::string pair = std::string(froms[i]) + ">" + tos[i];

                fresh->exact[key] = dsts[i];
                Entry e;
                e.key = std::move(key);
                e.dst = dsts[i];
                e.pair = std::move(pair);
                fresh->fuzzy.push_back(std::move(e));

                if (fresh->fuzzy.size() >= MAX_TOTAL) break;
            }
        }

        {
            std::lock_guard<std::mutex> lk(g_mu);
            g_state = std::move(fresh);
        }

        auto us = std::chrono::duration_cast<std::chrono::microseconds>(
                std::chrono::steady_clock::now() - t0)
                .count();
        TM_LOG("rebuild(n=%d) → %zu entries, %lld µs",
               (int)n, g_state->fuzzy.size(), (long long)us);
        return 0;
    }

    int32_t tm_add(const char* src, const char* dst,
                   const char* from, const char* to) {
        if (!src || !dst || !from || !to) return -1;

        auto t0 = std::chrono::steady_clock::now();

        std::string src_norm = to_lower_ascii(kt::normalize(src));
        if (src_norm.empty()) return -2;

        std::string key = make_key(src_norm, from, to);
        std::string pair = std::string(from) + ">" + to;

        {
            std::lock_guard<std::mutex> lk(g_mu);
            if (g_state->fuzzy.size() >= MAX_TOTAL) {
                TM_LOG("add: at capacity %zu, skipping", g_state->fuzzy.size());
                return 0;
            }
            g_state->exact[key] = dst;
            Entry e;
            e.key = key;
            e.dst = dst;
            e.pair = std::move(pair);
            g_state->fuzzy.push_back(std::move(e));
        }

        auto us = std::chrono::duration_cast<std::chrono::microseconds>(
                std::chrono::steady_clock::now() - t0)
                .count();
        TM_LOG("add(pair=%s>%s) %lld µs", from, to, (long long)us);
        return 0;
    }

    int32_t tm_lookup(const char* src, const char* from, const char* to,
                      char* out_dst, int32_t out_sz) {
        if (!src || !from || !to || !out_dst || out_sz <= 0) return 0;

        auto t0 = std::chrono::steady_clock::now();

        std::string src_norm = to_lower_ascii(kt::normalize(src));
        if (src_norm.empty()) return 0;

        std::string key = make_key(src_norm, from, to);
        std::string pair = std::string(from) + ">" + to;

        const std::string* hit_dst = nullptr;
        int32_t score = 0;

        {
            std::lock_guard<std::mutex> lk(g_mu);

            auto it = g_state->exact.find(key);
            if (it != g_state->exact.end()) {
                hit_dst = &it->second;
                score = 1000;
            } else {
                const size_t slen = src_norm.size();
                const size_t max_delta = (slen * 25) / 100 + 2; // допуск ±25% + 2

                int32_t best = 0;
                const std::string* best_dst = nullptr;

                for (const auto& e : g_state->fuzzy) {
                    if (e.pair != pair) continue;
                    const size_t prefix = pair.size() + 1;
                    if (e.key.size() < prefix) continue;
                    const size_t e_slen = e.key.size() - prefix;

                    if (e_slen > slen + max_delta || slen > e_slen + max_delta) continue;
                    if (e_slen == 0) continue;

                    const std::string e_src = e.key.substr(prefix);
                    const int dist = levenshtein(src_norm, e_src);
                    const int mx = static_cast<int>(std::max(e_src.size(), slen));
                    if (mx == 0) continue;
                    const int32_t s = 1000 - (dist * 1000) / mx;

                    if (s > best) {
                        best = s;
                        best_dst = &e.dst;
                        if (best == 1000) break;
                    }
                }
                if (best >= 800 && best_dst) {
                    score = best;
                    hit_dst = best_dst;
                }
            }
        }

        if (!hit_dst) {
            TM_LOG("lookup(pair=%s, len=%zu) → miss", pair.c_str(), src_norm.size());
            return 0;
        }

        std::strncpy(out_dst, hit_dst->c_str(), static_cast<size_t>(out_sz - 1));
        out_dst[out_sz - 1] = '\0';

        auto us = std::chrono::duration_cast<std::chrono::microseconds>(
                std::chrono::steady_clock::now() - t0)
                .count();
        TM_LOG("lookup(pair=%s, len=%zu) → score=%d, %lld µs",
               pair.c_str(), src_norm.size(), (int)score, (long long)us);
        return score;
    }

    int32_t tm_clear() {
        auto t0 = std::chrono::steady_clock::now();
        {
            std::lock_guard<std::mutex> lk(g_mu);
            g_state = std::make_unique<State>();
        }
        auto us = std::chrono::duration_cast<std::chrono::microseconds>(
                std::chrono::steady_clock::now() - t0)
                .count();
        TM_LOG("clear() %lld µs", (long long)us);
        return 0;
    }

}