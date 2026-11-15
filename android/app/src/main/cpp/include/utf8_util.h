#pragma once

#include <algorithm>
#include <cstdint>
#include <cstring>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

namespace kp::utf8 {

    inline std::u32string to_cps(std::string_view s) {
        std::u32string out;
        out.reserve(s.size());
        const size_t n = s.size();
        size_t i = 0;
        while (i < n) {
            const unsigned char c = static_cast<unsigned char>(s[i]);
            size_t len = 0;
            uint32_t cp = 0;
            if (c < 0x80)                { len = 1; cp = c; }
            else if ((c & 0xE0) == 0xC0) { len = 2; cp = c & 0x1Fu; }
            else if ((c & 0xF0) == 0xE0) { len = 3; cp = c & 0x0Fu; }
            else if ((c & 0xF8) == 0xF0) { len = 4; cp = c & 0x07u; }
            else { out.push_back(0xFFFD); ++i; continue; }

            bool ok = (i + len <= n);
            for (size_t k = 1; ok && k < len; ++k) {
                const unsigned char cc = static_cast<unsigned char>(s[i + k]);
                if ((cc & 0xC0) != 0x80) ok = false;
                else cp = (cp << 6) | (cc & 0x3Fu);
            }
            if (!ok) { out.push_back(0xFFFD); ++i; continue; }
            out.push_back(cp);
            i += len;
        }
        return out;
    }

    inline size_t cp_len(std::string_view s) {
        size_t k = 0;
        for (unsigned char c : s) {
            if ((c & 0xC0) != 0x80) ++k;
        }
        return k;
    }

    inline int32_t copy_checked(std::string_view s, char* out, int32_t out_sz) {
        if (!out || out_sz <= 0) return -1;
        if (static_cast<int64_t>(s.size()) + 1 > out_sz) return -1;
        std::memcpy(out, s.data(), s.size());
        out[s.size()] = '\0';
        return static_cast<int32_t>(s.size());
    }

    inline int lev_cps_cap(const std::u32string& a, const std::u32string& b, int cap) {
        const int m = static_cast<int>(a.size());
        const int n = static_cast<int>(b.size());
        if (cap < 0) return 1;
        if (m - n > cap || n - m > cap) return cap + 1;
        if (m == 0) return n;
        if (n == 0) return m;

        std::vector<int> prev(static_cast<size_t>(n) + 1);
        std::vector<int> cur(static_cast<size_t>(n) + 1);
        for (int j = 0; j <= n; ++j) prev[j] = j;

        for (int i = 1; i <= m; ++i) {
            cur[0] = i;
            int rowmin = i;
            for (int j = 1; j <= n; ++j) {
                const int cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
                const int v = std::min({prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost});
                cur[j] = v;
                if (v < rowmin) rowmin = v;
            }
            if (rowmin > cap) return cap + 1;
            std::swap(prev, cur);
        }
        return prev[n] <= cap ? prev[n] : cap + 1;
    }

} // namespace kp::utf8