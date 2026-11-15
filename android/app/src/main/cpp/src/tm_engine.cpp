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
#include <chrono>
#include <cstdlib>
#include <string_view>
#include "utf8_util.h"

#define TM_TAG "KOPRI_TM"
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
            k.reserve(from.size() + to.size() + src_norm.size() + 2);
            k.append(from);
            k.push_back('>');
            k.append(to);
            k.push_back('|');
            k.append(src_norm);
            return k;
        }


    } // namespace

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
                std::chrono::steady_clock::now() - t0).count();

        TM_LOG("rebuild(n=%d) -> %zu entries, %lld us",
               static_cast<int>(n), g_state->fuzzy.size(), static_cast<long long>(us));

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
                std::chrono::steady_clock::now() - t0).count();

        TM_LOG("add(pair=%s>%s) %lld us", from, to, static_cast<long long>(us));

        return 0;
    }

    int32_t tm_lookup(const char* src, const char* from, const char* to,
                      char* out_dst, int32_t out_sz) {
        if (!src || !from || !to || !out_dst || out_sz <= 0) return 0;

        const auto t0 = std::chrono::steady_clock::now();

        const std::string src_norm = to_lower_ascii(kt::normalize(src));
        if (src_norm.empty()) return 0;

        const std::string key  = make_key(src_norm, from, to);
        const std::string pair = std::string(from) + ">" + to;

        std::string result;
        int32_t score = 0;

        {
            std::lock_guard<std::mutex> lk(g_mu);

            const auto it = g_state->exact.find(key);
            if (it != g_state->exact.end()) {
                result = it->second;
                score  = 1000;
            } else {
                const size_t prefix = pair.size() + 1;

                const std::u32string q = kp::utf8::to_cps(src_norm);
                const int qlen = static_cast<int>(q.size());

                int32_t best = 0;
                const std::string* best_dst = nullptr;

                for (const auto& e : g_state->fuzzy) {
                    if (e.pair != pair) continue;
                    if (e.key.size() <= prefix) continue;

                    const std::string_view e_src(e.key.data() + prefix,
                                                 e.key.size() - prefix);
                    const std::u32string ec = kp::utf8::to_cps(e_src);
                    const int elen = static_cast<int>(ec.size());
                    if (elen == 0) continue;

                    const int mx = std::max(qlen, elen);
                    const int cap = mx / 5;
                    if (std::abs(qlen - elen) > cap) continue;

                    const int dist = kp::utf8::lev_cps_cap(q, ec, cap);
                    if (dist > cap) continue;

                    const int32_t s = 1000 - (dist * 1000) / mx;
                    if (s > best) {
                        best = s;
                        best_dst = &e.dst;
                        if (best == 1000) break;
                    }
                }

                if (best >= 800 && best_dst) {
                    score  = best;
                    result = *best_dst;
                }
            }
        }

        if (score == 0 || result.empty()) {
            TM_LOG("lookup(pair=%s, len=%zu) -> miss", pair.c_str(), src_norm.size());
            return 0;
        }

        if (kp::utf8::copy_checked(result, out_dst, out_sz) < 0) {
            TM_LOG("lookup(pair=%s) -> result does not fit buffer, miss", pair.c_str());
            return 0;
        }

        const auto us = std::chrono::duration_cast<std::chrono::microseconds>(
                std::chrono::steady_clock::now() - t0).count();
        TM_LOG("lookup(pair=%s, len=%zu) -> score=%d, %lld us",
               pair.c_str(), src_norm.size(), static_cast<int>(score),
               static_cast<long long>(us));
        return score;
    }

    int32_t tm_clear() {
        auto t0 = std::chrono::steady_clock::now();

        {
            std::lock_guard<std::mutex> lk(g_mu);
            g_state = std::make_unique<State>();
        }

        auto us = std::chrono::duration_cast<std::chrono::microseconds>(
                std::chrono::steady_clock::now() - t0).count();

        TM_LOG("clear() %lld us", static_cast<long long>(us));

        return 0;
    }

} // namespace kp