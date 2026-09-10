#include "mt_tk_engine.h"
#include <android/log.h>
#include <algorithm>
#include <atomic>
#include <chrono>
#include <cstring>
#include <mutex>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#define MT_TAG "KOPRI_MT"
#define MT_LOG(...) __android_log_print(ANDROID_LOG_INFO, MT_TAG, __VA_ARGS__)

namespace kp {

    namespace {

        enum ECase { C_NOM, C_GEN, C_DAT, C_ACC, C_LOC, C_ABL };
        enum ETense { T_PRES, T_PAST, T_FUT };

        struct Engine {
            std::atomic<bool> loaded{false};
            std::mutex load_mu;
            std::unordered_map<std::string, std::string> ph_to_tk_ru, ph_to_tk_en, ph_to_tk_tr;
            std::unordered_map<std::string, std::string> ph_from_tk_en, ph_from_tk_ru, ph_from_tk_tr;
            std::vector<std::string> keys_to_tk_ru, keys_to_tk_en, keys_to_tk_tr;
            std::vector<std::string> keys_from_tk_en, keys_from_tk_ru, keys_from_tk_tr;
            std::unordered_map<std::string, std::string> w_ru_to_tk, w_en_to_tk, w_tr_to_tk;
            std::unordered_map<std::string, std::string> w_tk_to_en, w_tk_to_ru, w_tk_to_tr;
            std::unordered_map<std::string, std::string> piv_ru_en, piv_en_ru, piv_tr_en, piv_en_tr;
            std::unordered_set<std::string> stop_ru, stop_en, stop_tr, stop_tk;
            std::unordered_set<std::string> neg_ru, neg_en, neg_tr;
            std::unordered_set<std::string> q_words;
            std::unordered_set<std::string> motion;
            std::unordered_set<std::string> past_adv, fut_adv;
            std::unordered_set<std::string> without_pre;
            std::unordered_set<std::string> poss_pron;
        };

        Engine g;

        [[gnu::always_inline]] inline uint32_t next_cp(const std::string& t, size_t& i) noexcept {
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

        [[gnu::always_inline]] inline void enc_cp(std::string& out, uint32_t cp) noexcept {
            if (cp < 0x80) out += (char)cp;
            else if (cp < 0x800) { out += (char)(0xC0 | (cp >> 6)); out += (char)(0x80 | (cp & 63)); }
            else if (cp < 0x10000) { out += (char)(0xE0 | (cp >> 12)); out += (char)(0x80 | ((cp >> 6) & 63)); out += (char)(0x80 | (cp & 63)); }
            else { out += (char)(0xF0 | (cp >> 18)); out += (char)(0x80 | ((cp >> 12) & 63)); out += (char)(0x80 | ((cp >> 6) & 63)); out += (char)(0x80 | (cp & 63)); }
        }

        inline size_t cp_len(uint32_t cp) noexcept {
            if (cp < 0x80) return 1;
            if (cp < 0x800) return 2;
            if (cp < 0x10000) return 3;
            return 4;
        }

        [[gnu::always_inline]] inline uint32_t cp_lower(uint32_t cp) noexcept {
            if (cp >= 'A' && cp <= 'Z') return cp + 32;
            if (cp >= 0x410 && cp <= 0x42F) return cp + 0x20;
            if (cp == 0x401) return 0x451;
            if (cp == 0x3C2) return 0x3C3;
            switch (cp) {
                case 0xC4: return 0xE4; case 0xC7: return 0xE7;
                case 0xD6: return 0xF6; case 0xDC: return 0xFC;
                case 0xDD: return 0xFD; case 0x17D: return 0x17E;
                case 0x147: return 0x148; case 0x15E: return 0x15F;
                case 0x11E: return 0x11F; case 0x130: return 0x69;
            }
            return cp;
        }

        [[gnu::always_inline]] inline bool cp_skip(uint32_t cp) noexcept {
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

        [[gnu::always_inline]] inline bool cp_space(uint32_t cp) noexcept {
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

        void tokenize2(const std::string& s, std::vector<std::string>& low, std::vector<std::string>& raw) {
            std::string cl, cr;
            size_t i = 0;
            while (i < s.size()) {
                uint32_t cp = next_cp(s, i);
                if (cp == 0) continue;
                if (cp_space(cp) || cp_skip(cp) || cp == '-') {
                    if (!cl.empty()) { low.push_back(std::move(cl)); raw.push_back(std::move(cr)); cl.clear(); cr.clear(); }
                    continue;
                }
                enc_cp(cr, cp);
                enc_cp(cl, cp_lower(cp));
            }
            if (!cl.empty()) { low.push_back(std::move(cl)); raw.push_back(std::move(cr)); }
        }

        std::vector<std::string> tokenize_low(const std::string& s) {
            std::vector<std::string> low, raw;
            tokenize2(s, low, raw);
            return low;
        }

        inline bool ends_with(const std::string& s, const char* suf) {
            size_t n = std::strlen(suf);
            return s.size() >= n && std::memcmp(s.data() + s.size() - n, suf, n) == 0;
        }

        uint32_t last_cp(const std::string& s) {
            size_t i = 0, prev = 0;
            while (i < s.size()) { prev = i; next_cp(s, i); }
            size_t j = prev;
            return next_cp(s, j);
        }

        inline bool tk_vowel(uint32_t cp) {
            return cp == 'a' || cp == 'e' || cp == 'i' || cp == 'o' || cp == 'u' ||
                   cp == 'y' || cp == 0xE4 || cp == 0xF6 || cp == 0xFC || cp == 0xFD;
        }

        inline bool tk_back(uint32_t cp) { return cp == 'a' || cp == 'o' || cp == 'u' || cp == 'y'; }
        inline bool tk_round(uint32_t cp) { return cp == 'o' || cp == 'u' || cp == 0xF6 || cp == 0xFC; }

        bool word_back(const std::string& s) {
            bool back = true;
            size_t i = 0;
            while (i < s.size()) { uint32_t cp = next_cp(s, i); if (tk_vowel(cp)) back = tk_back(cp); }
            return back;
        }

        uint32_t harmony_v4(const std::string& w) {
            bool back = true, round = false;
            size_t i = 0;
            while (i < w.size()) {
                uint32_t cp = next_cp(w, i);
                if (tk_vowel(cp)) { back = tk_back(cp); round = tk_round(cp); }
            }
            if (back && round) return 'u';
            if (back) return 'y';
            if (round) return 0xFC;
            return 'i';
        }

        std::string mutate(const std::string& w) {
            if (w.empty()) return w;
            uint32_t lc = last_cp(w);
            uint32_t m = 0;
            if (lc == 'p') m = 'b';
            else if (lc == 't') m = 'd';
            else if (lc == 'k') m = 'g';
            else if (lc == 0xE7) m = 'j';
            if (!m) return w;
            std::string u = w.substr(0, w.size() - cp_len(lc));
            enc_cp(u, m);
            return u;
        }

        std::string unmut(const std::string& w) {
            if (w.empty()) return w;
            uint32_t lc = last_cp(w);
            uint32_t m = 0;
            if (lc == 'b') m = 'p';
            else if (lc == 'd') m = 't';
            else if (lc == 'g') m = 'k';
            else if (lc == 'j') m = 0xE7;
            if (!m) return w;
            std::string u = w.substr(0, w.size() - cp_len(lc));
            enc_cp(u, m);
            return u;
        }

        std::string dative(const std::string& w) {
            if (w.empty()) return w;
            uint32_t lc = last_cp(w);
            bool back = word_back(w);
            if (tk_vowel(lc)) return w + (back ? "na" : "ne");
            return mutate(w) + (back ? "a" : "e");
        }

        std::string apply_case(const std::string& w, ECase c) {
            if (c == C_NOM || w.empty()) return w;
            bool back = word_back(w);
            uint32_t lc = last_cp(w);
            bool vow = tk_vowel(lc);
            switch (c) {
                case C_DAT: return dative(w);
                case C_GEN:
                    if (vow) return w + (back ? "nyň" : "niň");
                    return mutate(w) + (back ? "yň" : "iň");
                case C_ACC:
                    if (vow) return w + (back ? "ny" : "ni");
                    return mutate(w) + (back ? "y" : "i");
                case C_LOC: return w + (back ? "da" : "de");
                case C_ABL: return w + (back ? "dan" : "den");
                default: return w;
            }
        }

        std::string poss(const std::string& w, int p) {
            if (w.empty() || p <= 0) return w;
            bool back = word_back(w);
            uint32_t lc = last_cp(w);
            bool vow = tk_vowel(lc);
            std::string vs;
            enc_cp(vs, harmony_v4(w));
            std::string base = mutate(w);
            switch (p) {
                case 1: return base + vs + "m";
                case 2: return base + vs + "ň";
                case 3: return vow ? w + "s" + vs : base + vs;
                case 4: return vow ? w + (back ? "myz" : "miz") : base + vs + (back ? "myz" : "miz");
                case 5: return vow ? w + (back ? "ňyz" : "ňiz") : base + vs + (back ? "ňyz" : "ňiz");
                default: return base + vs + (back ? "lar" : "ler");
            }
        }

        const std::unordered_map<std::string, std::string>& irr_stems() {
            static const std::unordered_map<std::string, std::string> m = {
                    {"git", "gid"}, {"et", "ed"}, {"gut", "gud"}, {"çat", "çad"},
            };
            return m;
        }

        const std::unordered_map<std::string, int>& pron_idx() {
            static const std::unordered_map<std::string, int> m = {
                    {"men", 0}, {"sen", 1}, {"ol", 2}, {"biz", 3}, {"siz", 4}, {"olar", 5},
            };
            return m;
        }

        std::string conjugate2(const std::string& inf, int person, bool neg, ETense t, bool quest) {
            if (inf.size() < 4) return inf;
            std::string stem = inf.substr(0, inf.size() - 3);
            auto it = irr_stems().find(stem);
            if (it != irr_stems().end()) stem = it->second;
            bool back = word_back(stem);
            if (person < 0) person = 2;
            if (person > 5) person = 2;
            static const char* PB[6] = {"ýaryn", "ýarsyň", "ýar", "ýarys", "ýarsyňyz", "ýarlar"};
            static const char* PF[6] = {"ýärin", "ýärsiň", "ýär", "ýäris", "ýärsiňiz", "ýärler"};
            static const char* NB[6] = {"maýaryn", "maýarsyň", "maýar", "maýarys", "maýarsyňyz", "maýarlar"};
            static const char* NF[6] = {"meýärin", "meýärsiň", "meýär", "meýäris", "meýärsiňiz", "meýärler"};
            static const char* DB[6] = {"dym", "dyň", "dy", "dyk", "dyňyz", "dylar"};
            static const char* DF[6] = {"dim", "diň", "di", "dik", "diňiz", "diler"};
            static const char* NDB[6] = {"madym", "madyň", "mady", "madyk", "madyňyz", "madylar"};
            static const char* NDF[6] = {"medim", "mediň", "medi", "medik", "mediňiz", "mediler"};
            static const char* FB[6] = {"aryn", "arsyň", "ar", "arys", "arsyňyz", "arlar"};
            static const char* FF[6] = {"erin", "ersiň", "er", "eris", "ersiňiz", "erler"};
            static const char* NFB[6] = {"maryn", "marsyň", "mar", "marys", "marsyňyz", "marlar"};
            static const char* NFF[6] = {"merin", "mersiň", "mer", "meris", "mersiňiz", "merler"};
            std::string out;
            if (t == T_PRES) out = stem + (neg ? (back ? NB[person] : NF[person]) : (back ? PB[person] : PF[person]));
            else if (t == T_PAST) out = stem + (neg ? (back ? NDB[person] : NDF[person]) : (back ? DB[person] : DF[person]));
            else out = stem + (neg ? (back ? NFB[person] : NFF[person]) : (back ? FB[person] : FF[person]));
            if (quest) out += (back ? "my" : "mi");
            return out;
        }

        std::string lower_str(const std::string& s) {
            std::string o;
            size_t i = 0;
            while (i < s.size()) enc_cp(o, cp_lower(next_cp(s, i)));
            return o;
        }

        const std::unordered_map<std::string, std::string>& adv_map() {
            static const std::unordered_map<std::string, std::string> m = {
                    {"yesterday","düýn"},{"вчера","düýн"},{"tomorrow","ertir"},{"завтра","ertir"},
                    {"today","şu gün"},{"сегодня","şu gün"},{"now","häzir"},{"сейчас","häzir"},
            };
            return m;
        }

        void cap_first(std::string& s) {
            if (s.empty()) return;
            size_t i = 0;
            uint32_t cp = next_cp(s, i);
            uint32_t up = cp;
            if (cp >= 'a' && cp <= 'z') up = cp - 32;
            else if (cp >= 0x430 && cp <= 0x44F) up = cp - 0x20;
            else if (cp == 0x451) up = 0x401;
            if (up == cp) return;
            std::string r;
            enc_cp(r, up);
            r += s.substr(i);
            s = r;
        }

        bool parse_verb_form(const std::string& v, std::string& inf, int& person, bool& neg, ETense& t) {
            struct E { const char* s; int p; bool n; bool b; ETense tt; };
            static const E T[] = {
                    {"maýarsyňyz",4,true,true,T_PRES},{"meýärsiňiz",4,true,false,T_PRES},
                    {"madym",0,true,true,T_PAST},{"medim",0,true,false,T_PAST},
                    {"madyňyz",4,true,true,T_PAST},{"mediňiz",4,true,false,T_PAST},
                    {"madylar",5,true,true,T_PAST},{"mediler",5,true,false,T_PAST},
                    {"madyk",3,true,true,T_PAST},{"medik",3,true,false,T_PAST},
                    {"madyň",1,true,true,T_PAST},{"mediň",1,true,false,T_PAST},
                    {"mady",2,true,true,T_PAST},{"medi",2,true,false,T_PAST},
                    {"dym",0,false,true,T_PAST},{"dim",0,false,false,T_PAST},
                    {"dyňyz",4,false,true,T_PAST},{"diňiz",4,false,false,T_PAST},
                    {"dylar",5,false,true,T_PAST},{"diler",5,false,false,T_PAST},
                    {"dyk",3,false,true,T_PAST},{"dik",3,false,false,T_PAST},
                    {"dyň",1,false,true,T_PAST},{"diň",1,false,false,T_PAST},
                    {"dy",2,false,true,T_PAST},{"di",2,false,false,T_PAST},
                    {"maryn",0,true,true,T_FUT},{"merin",0,true,false,T_FUT},
                    {"marsyň",1,true,true,T_FUT},{"mersiň",1,true,false,T_FUT},
                    {"marys",3,true,true,T_FUT},{"meris",3,true,false,T_FUT},
                    {"marsyňyz",4,true,true,T_FUT},{"mersiňiz",4,true,false,T_FUT},
                    {"marlar",5,true,true,T_FUT},{"merler",5,true,false,T_FUT},
                    {"mar",2,true,true,T_FUT},{"mer",2,true,false,T_FUT},
                    {"maýaryn",0,true,true,T_PRES},{"meýärin",0,true,false,T_PRES},
                    {"maýarsyň",1,true,true,T_PRES},{"meýärsiň",1,true,false,T_PRES},
                    {"maýarys",3,true,true,T_PRES},{"meýäris",3,true,false,T_PRES},
                    {"maýarlar",5,true,true,T_PRES},{"meýärler",5,true,false,T_PRES},
                    {"maýar",2,true,true,T_PRES},{"meýär",2,true,false,T_PRES},
                    {"aryn",0,false,true,T_FUT},{"erin",0,false,false,T_FUT},
                    {"arsyň",1,false,true,T_FUT},{"ersiň",1,false,false,T_FUT},
                    {"arys",3,false,true,T_FUT},{"eris",3,false,false,T_FUT},
                    {"arsyňyz",4,false,true,T_FUT},{"ersiňiz",4,false,false,T_FUT},
                    {"arlar",5,false,true,T_FUT},{"erler",5,false,false,T_FUT},
                    {"ar",2,false,true,T_FUT},{"er",2,false,false,T_FUT},
                    {"ýarsyňyz",4,false,true,T_PRES},{"ýärsiňiz",4,false,false,T_PRES},
                    {"ýaryn",0,false,true,T_PRES},{"ýärin",0,false,false,T_PRES},
                    {"ýarsyň",1,false,true,T_PRES},{"ýärsiň",1,false,false,T_PRES},
                    {"ýarys",3,false,true,T_PRES},{"ýäris",3,false,false,T_PRES},
                    {"ýarlar",5,false,true,T_PRES},{"ýärler",5,false,false,T_PRES},
                    {"ýar",2,false,true,T_PRES},{"ýär",2,false,false,T_PRES},
            };
            for (const E& e : T) {
                size_t n = std::strlen(e.s);
                if (v.size() > n + 1 && ends_with(v, e.s)) {
                    inf = v.substr(0, v.size() - n) + (e.b ? "mak" : "mek");
                    person = e.p;
                    neg = e.n;
                    t = e.tt;
                    return true;
                }
            }
            return false;
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
                std::unordered_map<std::string, std::string>& out,
                const std::unordered_set<std::string>& stop) {
            for (const auto& kv : tot) {
                const std::string& s = kv.first;
                if (stop.count(s)) continue;
                int32_t t = kv.second;
                if (t <= 0) continue;
                auto it = cooc.find(s);
                if (it == cooc.end()) continue;
                const std::string* best = nullptr;
                int32_t bc = 0;
                for (const auto& cw : it->second) {
                    if (cw.second > bc || (cw.second == bc && best && cw.first < *best)) { bc = cw.second; best = &cw.first; }
                }
                if (best && bc * 5 >= t * 3 && t >= 2) out[s] = *best;
            }
        }

        void init_sets() {
            g.stop_ru = {"и","или","но","а","в","на","к","с","у","о","об","от","до","из","за","по","при","под","над","перед","между","для","около","через","эта","этот","эти","этом","этой","того","той","том","так","же","бы","ли","вот","вон","только","тоже","также","ещё","уже","было","был","была","были","будет","будут","является","являются","что","который","какой","без"};
            g.stop_en = {"the","a","an","and","or","but","in","on","at","to","for","of","with","by","from","up","about","into","through","during","before","after","above","below","between","under","over","again","further","then","once","here","there","when","where","why","how","all","any","both","each","few","more","most","other","some","such","no","nor","only","own","same","so","than","too","very","can","will","just","should","now","am","is","are","was","were","be","been","being","have","has","had","having","do","does","did","doing","would","could","ought","might","this","that","these","those","without"};
            g.stop_tr = {"ve","veya","ama","fakat","ile","için","da","de","ki","mi","mı","mu","mü","bu","şu","bir","çok","daha","gibi","ise","ancak","lakin","çünkü","eğer","şayet","bez"};
            g.stop_tk = {"we","ýa","emma","bilen","üçin","da","de","hem","bir","köp","has","diýip","şol","bu"};
            g.neg_ru = {"не"};
            g.neg_en = {"not"};
            g.neg_tr = {"değil"};
            g.q_words = {"kim","näme","nirede","haçan","nädip","näçe","haýsy","why","where","what","who","how","when","почему","где","как","что","кто","когда","сколько","какой","который"};
            g.motion = {"gitmek","gelmek","barmak","uçmak","sürmek","ýöremek","ylgamak","gaçmak"};
            g.past_adv = {"yesterday","düýn","вчера","last"};
            g.fut_adv = {"tomorrow","ertir","завтра","soon"};
            g.without_pre = {"без","without","bez"};
            g.poss_pron = {"meniň","seniň","onuň","biziň","siziň","olaryň"};
        }

        std::vector<std::string> en_stems(const std::string& w) {
            std::vector<std::string> v;
            v.push_back(w);
            if (w.size() > 4 && ends_with(w, "ies")) v.push_back(w.substr(0, w.size() - 3) + "y");
            if (w.size() > 3 && ends_with(w, "es")) v.push_back(w.substr(0, w.size() - 2));
            if (w.size() > 3 && ends_with(w, "s") && !ends_with(w, "ss")) v.push_back(w.substr(0, w.size() - 1));
            if (w.size() > 5 && ends_with(w, "ing")) {
                std::string b = w.substr(0, w.size() - 3);
                v.push_back(b); v.push_back(b + "e");
                if (b.size() >= 2 && b[b.size() - 1] == b[b.size() - 2]) v.push_back(b.substr(0, b.size() - 1));
            }
            if (w.size() > 4 && ends_with(w, "ed")) {
                std::string b = w.substr(0, w.size() - 2);
                v.push_back(b); v.push_back(b + "e");
                if (b.size() >= 2 && b[b.size() - 1] == b[b.size() - 2]) v.push_back(b.substr(0, b.size() - 1));
            }
            if (w.size() > 4 && ends_with(w, "ly")) v.push_back(w.substr(0, w.size() - 2));
            if (w.size() > 4 && ends_with(w, "ness")) v.push_back(w.substr(0, w.size() - 4));
            if (w.size() > 5 && ends_with(w, "tion")) v.push_back(w.substr(0, w.size() - 4) + "te");
            return v;
        }

        std::vector<std::string> ru_stems(const std::string& w) {
            std::vector<std::string> v;
            v.push_back(w);
            static const char* suf[] = {"иями","ями","ами","ого","его","ыми","ими","ая","яя","ое","ее","ые","ие","ой","ей","ий","ый","ешь","ишь","ает","яет","ует","ют","ёт","ит","ут","ат","ят","ем","ём","ете","ёте","ите","ил","ыл","ила","ыла","или","ыли","у","ю","а","я","ы","и","е","ё","о","й","ь","ом","им","ам","ям","ах","ях","ев","ов"};
            static const char* add[] = {"а","я","о","е","й","ь","ы","и","ть","ти","чь","ать","ять","еть","ить","ой","ый","ий","ая","яя","ое","ее"};
            for (const char* s : suf) {
                size_t n = std::strlen(s);
                if (w.size() <= n + 3 || !ends_with(w, s)) continue;
                std::string b = w.substr(0, w.size() - n);
                v.push_back(b);
                for (const char* a : add) v.push_back(b + a);
            }
            return v;
        }

        std::vector<std::string> tr_stems(const std::string& w) {
            std::vector<std::string> v;
            v.push_back(w);
            static const char* suf[] = {"yorlar","yorsunuz","yoruz","yorsun","yorum","yor","lardı","lerdi","ladı","ledi","dı","di","ti","tı","lar","ler","larının","lerinin","larında","lerinde","larına","lerine","larını","lerini","nın","nin","nun","nün","ında","inde","ından","inden","ına","ine","ını","ini","dan","den","tan","ten","da","de","ta","te","a","e","ı","i","u","ü"};
            for (const char* s : suf) {
                size_t n = std::strlen(s);
                if (w.size() <= n + 2 || !ends_with(w, s)) continue;
                std::string b = w.substr(0, w.size() - n);
                v.push_back(b); v.push_back(b + "mak"); v.push_back(b + "mek");
                std::string u = unmut(b);
                if (u != b) { v.push_back(u); v.push_back(u + "mak"); v.push_back(u + "mek"); }
            }
            return v;
        }

        std::vector<std::string> tk_stems(const std::string& w) {
            std::vector<std::string> v;
            v.push_back(w);
            static const char* suf[] = {"laryndan","lerinden","laryna","lerine","laryny","lerini","larynda","lerinde","lary","leri","syndan","sinden","syna","sine","syny","sini","synda","sinde","ndan","nden","nda","nde","na","ne","da","de","dan","den","ny","ni","sy","si","ym","im","um","üm","uň","üň","yň","iň","a","e","y","i"};
            for (const char* s : suf) {
                size_t n = std::strlen(s);
                if (w.size() <= n + 2 || !ends_with(w, s)) continue;
                std::string b = w.substr(0, w.size() - n);
                v.push_back(b);
                std::string u = unmut(b);
                if (u != b) v.push_back(u);
            }
            return v;
        }

        bool find_word(const std::unordered_map<std::string, std::string>& wd,
                       const std::string& tok, int lang, std::string& res) {
            auto it = wd.find(tok);
            if (it != wd.end()) { res = it->second; return true; }
            std::vector<std::string> cands;
            if (lang == 0) cands = ru_stems(tok);
            else if (lang == 1) cands = en_stems(tok);
            else if (lang == 2) cands = tr_stems(tok);
            else cands = tk_stems(tok);
            for (const auto& c : cands) {
                auto it2 = wd.find(c);
                if (it2 != wd.end()) { res = it2->second; return true; }
            }
            return false;
        }

        const char* cyr_translit(uint32_t cp) {
            switch (cp) {
                case 0x430: return "a"; case 0x431: return "b"; case 0x432: return "w";
                case 0x433: return "g"; case 0x434: return "d"; case 0x435: return "e";
                case 0x451: return "ýo"; case 0x436: return "ž"; case 0x437: return "z";
                case 0x438: return "i"; case 0x439: return "ý"; case 0x43A: return "k";
                case 0x43B: return "l"; case 0x43C: return "m"; case 0x43D: return "n";
                case 0x43E: return "o"; case 0x43F: return "p"; case 0x440: return "r";
                case 0x441: return "s"; case 0x442: return "t"; case 0x443: return "u";
                case 0x444: return "f"; case 0x445: return "h"; case 0x446: return "s";
                case 0x447: return "ç"; case 0x448: return "ş"; case 0x449: return "ş";
                case 0x44A: return ""; case 0x44B: return "y"; case 0x44C: return "";
                case 0x44D: return "e"; case 0x44E: return "ýu"; case 0x44F: return "ýa";
                default: return nullptr;
            }
        }

        std::string translit(const std::string& w, int lang) {
            std::string out;
            size_t i = 0;
            if (lang == 0) {
                while (i < w.size()) {
                    uint32_t cp = next_cp(w, i);
                    const char* t = cyr_translit(cp_lower(cp));
                    if (t) out += t;
                    else enc_cp(out, cp_lower(cp));
                }
                return out;
            }
            while (i < w.size()) {
                uint32_t cp = next_cp(w, i);
                if (cp == 'c') out += "k";
                else if (cp == 'q') out += "k";
                else if (cp == 'x') out += "ks";
                else enc_cp(out, cp_lower(cp));
            }
            return out;
        }

        bool is_digits(const std::string& w) {
            if (w.empty()) return false;
            for (char c : w) if (c < '0' || c > '9') return false;
            return true;
        }

        bool tr_split_case(const std::string& w, std::string& stem, ECase& c) {
            struct S { const char* suf; ECase cc; };
            static const S T[] = {
                    {"dan", C_ABL}, {"den", C_ABL}, {"tan", C_ABL}, {"ten", C_ABL},
                    {"da", C_LOC}, {"de", C_LOC}, {"ta", C_LOC}, {"te", C_LOC},
                    {"nın", C_GEN}, {"nin", C_GEN}, {"nun", C_GEN}, {"nün", C_GEN},
                    {"ı", C_ACC}, {"i", C_ACC}, {"u", C_ACC}, {"ü", C_ACC},
                    {"a", C_DAT}, {"e", C_DAT},
            };
            for (const S& s : T) {
                size_t n = std::strlen(s.suf);
                if (w.size() > n + 2 && ends_with(w, s.suf)) {
                    stem = unmut(w.substr(0, w.size() - n));
                    c = s.cc;
                    return true;
                }
            }
            return false;
        }

        bool tk_split_case(const std::string& w, std::string& stem, ECase& c) {
            struct S { const char* suf; ECase cc; };
            static const S T[] = {
                    {"dan", C_ABL}, {"den", C_ABL},
                    {"da", C_LOC}, {"de", C_LOC},
                    {"nyň", C_GEN}, {"niň", C_GEN}, {"uň", C_GEN}, {"üň", C_GEN}, {"yň", C_GEN}, {"iň", C_GEN},
                    {"ny", C_ACC}, {"ni", C_ACC}, {"y", C_ACC}, {"i", C_ACC},
                    {"na", C_DAT}, {"ne", C_DAT}, {"a", C_DAT}, {"e", C_DAT},
            };
            for (const S& s : T) {
                size_t n = std::strlen(s.suf);
                if (w.size() > n + 2 && ends_with(w, s.suf)) {
                    stem = unmut(w.substr(0, w.size() - n));
                    c = s.cc;
                    return true;
                }
            }
            return false;
        }

        enum Tag { T_STOP, T_PRON, T_VERB, T_WORD };

        struct Unit {
            Tag tag;
            std::string val;
            std::string raw;
            int pron;
            ECase cas;
            int possp;
            bool plural;
            bool prop;
            bool rough;
        };

    }

    int32_t mt_load(int32_t n, const char** ru, const char** en, const char** tk, const char** tr) {
        std::lock_guard<std::mutex> lk(g.load_mu);
        if (g.loaded.load()) return 0;

        auto t0 = std::chrono::steady_clock::now();
        Engine e;
        init_sets();

        std::unordered_map<std::string, std::unordered_map<std::string, int32_t>>
                cooc_ru_tk, cooc_en_tk, cooc_tr_tk,
                cooc_tk_en, cooc_tk_ru, cooc_tk_tr;
        std::unordered_map<std::string, int32_t>
                tot_ru, tot_en, tot_tr, tot_tk_en, tot_tk_ru, tot_tk_tr;

        if (n > 0) {
            const size_t est = static_cast<size_t>(n);
            e.ph_to_tk_ru.reserve(est); e.ph_to_tk_en.reserve(est); e.ph_to_tk_tr.reserve(est);
            e.ph_from_tk_en.reserve(est); e.ph_from_tk_ru.reserve(est); e.ph_from_tk_tr.reserve(est);
            e.keys_to_tk_ru.reserve(est); e.keys_to_tk_en.reserve(est); e.keys_to_tk_tr.reserve(est);
            e.keys_from_tk_en.reserve(est); e.keys_from_tk_ru.reserve(est); e.keys_from_tk_tr.reserve(est);
        }

        for (int32_t i = 0; i < n; ++i) {
            if (!tk[i]) continue;
            const std::string kt = norm_key(tk[i]);
            if (kt.empty()) continue;

            if (ru[i]) {
                const std::string kr = norm_key(ru[i]);
                if (!kr.empty()) {
                    if (!e.ph_to_tk_ru.count(kr)) { e.ph_to_tk_ru[kr] = tk[i]; e.keys_to_tk_ru.push_back(kr); }
                    if (!e.ph_from_tk_ru.count(kt)) { e.ph_from_tk_ru[kt] = ru[i]; e.keys_from_tk_ru.push_back(kt); }
                }
            }
            if (en[i]) {
                const std::string ke = norm_key(en[i]);
                if (!ke.empty()) {
                    if (!e.ph_to_tk_en.count(ke)) { e.ph_to_tk_en[ke] = tk[i]; e.keys_to_tk_en.push_back(ke); }
                    if (!e.ph_from_tk_en.count(kt)) { e.ph_from_tk_en[kt] = en[i]; e.keys_from_tk_en.push_back(kt); }
                }
            }
            if (tr[i]) {
                const std::string ktr = norm_key(tr[i]);
                if (!ktr.empty()) {
                    if (!e.ph_to_tk_tr.count(ktr)) { e.ph_to_tk_tr[ktr] = tk[i]; e.keys_to_tk_tr.push_back(ktr); }
                    if (!e.ph_from_tk_tr.count(kt)) { e.ph_from_tk_tr[kt] = tr[i]; e.keys_from_tk_tr.push_back(kt); }
                }
            }

            auto tt = tokenize_low(tk[i]);
            if (tt.empty()) continue;

            auto feed = [&](const char* src_raw,
                            std::unordered_map<std::string, std::unordered_map<std::string, int32_t>>& cooc_fwd,
                            std::unordered_map<std::string, std::unordered_map<std::string, int32_t>>& cooc_rev,
                            std::unordered_map<std::string, int32_t>& tot_fwd,
                            std::unordered_map<std::string, int32_t>& tot_rev) {
                if (!src_raw) return;
                auto src_toks = tokenize_low(src_raw);
                if (src_toks.empty()) return;
                if (src_toks.size() == 1) {
                    std::string joined;
                    for (size_t j = 0; j < tt.size(); ++j) { if (j) joined += ' '; joined += tt[j]; }
                    cooc_fwd[src_toks[0]][joined] += 10;
                    tot_fwd[src_toks[0]] += 10;
                    for (auto& t : tt) { cooc_rev[t][src_toks[0]] += 10; tot_rev[t] += 10; }
                    return;
                }
                for (auto& s : src_toks) {
                    tot_fwd[s] += 1;
                    for (auto& t : tt) { cooc_fwd[s][t] += 1; cooc_rev[t][s] += 1; tot_rev[t] += 1; }
                }
            };

            feed(ru[i], cooc_ru_tk, cooc_tk_ru, tot_ru, tot_tk_ru);
            feed(en[i], cooc_en_tk, cooc_tk_en, tot_en, tot_tk_en);
            feed(tr[i], cooc_tr_tk, cooc_tk_tr, tot_tr, tot_tk_tr);

            std::vector<std::string> rr, rw, ee, ew, ttr, tw;
            if (ru[i]) tokenize2(ru[i], rr, rw);
            if (en[i]) tokenize2(en[i], ee, ew);
            if (tr[i]) tokenize2(tr[i], ttr, tw);
            if (rr.size() == 1 && ee.size() == 1) {
                if (!e.piv_ru_en.count(rr[0])) e.piv_ru_en[rr[0]] = ee[0];
                if (!e.piv_en_ru.count(ee[0])) e.piv_en_ru[ee[0]] = rr[0];
            }
            if (ttr.size() == 1 && ee.size() == 1) {
                if (!e.piv_tr_en.count(ttr[0])) e.piv_tr_en[ttr[0]] = ee[0];
                if (!e.piv_en_tr.count(ee[0])) e.piv_en_tr[ee[0]] = ttr[0];
            }
        }

        build_words(cooc_ru_tk, tot_ru, e.w_ru_to_tk, e.stop_ru);
        build_words(cooc_en_tk, tot_en, e.w_en_to_tk, e.stop_en);
        build_words(cooc_tr_tk, tot_tr, e.w_tr_to_tk, e.stop_tr);
        build_words(cooc_tk_en, tot_tk_en, e.w_tk_to_en, e.stop_tk);
        build_words(cooc_tk_ru, tot_tk_ru, e.w_tk_to_ru, e.stop_tk);
        build_words(cooc_tk_tr, tot_tk_tr, e.w_tk_to_tr, e.stop_tk);

        e.neg_ru = g.neg_ru; e.neg_en = g.neg_en; e.neg_tr = g.neg_tr;
        e.q_words = g.q_words; e.motion = g.motion;
        e.past_adv = g.past_adv; e.fut_adv = g.fut_adv;
        e.without_pre = g.without_pre; e.poss_pron = g.poss_pron;

        g.ph_to_tk_ru = std::move(e.ph_to_tk_ru); g.ph_to_tk_en = std::move(e.ph_to_tk_en); g.ph_to_tk_tr = std::move(e.ph_to_tk_tr);
        g.ph_from_tk_en = std::move(e.ph_from_tk_en); g.ph_from_tk_ru = std::move(e.ph_from_tk_ru); g.ph_from_tk_tr = std::move(e.ph_from_tk_tr);
        g.keys_to_tk_ru = std::move(e.keys_to_tk_ru); g.keys_to_tk_en = std::move(e.keys_to_tk_en); g.keys_to_tk_tr = std::move(e.keys_to_tk_tr);
        g.keys_from_tk_en = std::move(e.keys_from_tk_en); g.keys_from_tk_ru = std::move(e.keys_from_tk_ru); g.keys_from_tk_tr = std::move(e.keys_from_tk_tr);
        g.w_ru_to_tk = std::move(e.w_ru_to_tk); g.w_en_to_tk = std::move(e.w_en_to_tk); g.w_tr_to_tk = std::move(e.w_tr_to_tk);
        g.w_tk_to_en = std::move(e.w_tk_to_en); g.w_tk_to_ru = std::move(e.w_tk_to_ru); g.w_tk_to_tr = std::move(e.w_tk_to_tr);
        g.piv_ru_en = std::move(e.piv_ru_en); g.piv_en_ru = std::move(e.piv_en_ru);
        g.piv_tr_en = std::move(e.piv_tr_en); g.piv_en_tr = std::move(e.piv_en_tr);
        g.stop_ru = std::move(e.stop_ru); g.stop_en = std::move(e.stop_en);
        g.stop_tr = std::move(e.stop_tr); g.stop_tk = std::move(e.stop_tk);
        g.neg_ru = std::move(e.neg_ru); g.neg_en = std::move(e.neg_en); g.neg_tr = std::move(e.neg_tr);
        g.q_words = std::move(e.q_words); g.motion = std::move(e.motion);
        g.past_adv = std::move(e.past_adv); g.fut_adv = std::move(e.fut_adv);
        g.without_pre = std::move(e.without_pre); g.poss_pron = std::move(e.poss_pron);
        g.loaded.store(true);

        auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::steady_clock::now() - t0).count();
        MT_LOG("MONSTER load n=%d ph=%zu/%zu/%zu piv=%zu/%zu in %lld ms",
               (int)n, g.ph_to_tk_ru.size(), g.ph_to_tk_en.size(), g.ph_to_tk_tr.size(),
               g.piv_ru_en.size(), g.piv_tr_en.size(), (long long)ms);
        return 0;
    }

    int32_t mt_translate(const char* text, const char* from, const char* to,
                         char* out, int32_t out_sz, int32_t* quality) {
        auto t0 = std::chrono::steady_clock::now();
        if (!g.loaded.load() || !text || !from || !to || !out || out_sz <= 0) return -1;
        if (quality) *quality = 0;

        const bool to_tk = std::strcmp(to, "tk") == 0;
        const bool from_tk = std::strcmp(from, "tk") == 0;

        const std::unordered_map<std::string, std::string>* ph = nullptr;
        const std::vector<std::string>* keys = nullptr;
        const std::unordered_map<std::string, std::string>* wd = nullptr;
        const std::unordered_map<std::string, std::string>* piv1 = nullptr;
        const std::unordered_map<std::string, std::string>* piv2 = nullptr;
        int lang = 1;

        if (to_tk) {
            if (std::strcmp(from, "ru") == 0) { ph = &g.ph_to_tk_ru; keys = &g.keys_to_tk_ru; wd = &g.w_ru_to_tk; piv1 = &g.piv_ru_en; piv2 = &g.w_en_to_tk; lang = 0; }
            else if (std::strcmp(from, "tr") == 0) { ph = &g.ph_to_tk_tr; keys = &g.keys_to_tk_tr; wd = &g.w_tr_to_tk; piv1 = &g.piv_tr_en; piv2 = &g.w_en_to_tk; lang = 2; }
            else { ph = &g.ph_to_tk_en; keys = &g.keys_to_tk_en; wd = &g.w_en_to_tk; piv1 = &g.piv_en_ru; piv2 = &g.w_ru_to_tk; lang = 1; }
        } else if (from_tk) {
            if (std::strcmp(to, "ru") == 0) { ph = &g.ph_from_tk_ru; keys = &g.keys_from_tk_ru; wd = &g.w_tk_to_ru; lang = 3; }
            else if (std::strcmp(to, "tr") == 0) { ph = &g.ph_from_tk_tr; keys = &g.keys_from_tk_tr; wd = &g.w_tk_to_tr; lang = 3; }
            else { ph = &g.ph_from_tk_en; keys = &g.keys_from_tk_en; wd = &g.w_tk_to_en; lang = 3; }
        }

        if (!ph || !keys || !wd) return -1;

        const std::string k = norm_key(text);
        if (k.empty()) return -1;

        auto put = [&](const std::string& s, int q) {
            if ((int32_t)s.size() + 1 > out_sz) return false;
            std::memcpy(out, s.data(), s.size());
            out[s.size()] = '\0';
            if (quality) *quality = q;
            return true;
        };

        auto it = ph->find(k);
        if (it != ph->end()) {
            if (!put(it->second, 1)) return -1;
            return (int32_t)it->second.size();
        }

        const int cap = (int)(k.size() / 4) + 2;
        int best = 0;
        const std::string* best_key = nullptr;
        for (const auto& key : *keys) {
            size_t d1 = key.size() > k.size() ? key.size() - k.size() : k.size() - key.size();
            if ((int)d1 > cap) continue;
            int d = lev_cap(k, key, cap);
            if (d > cap) continue;
            int mx = (int)(key.size() > k.size() ? key.size() : k.size());
            if (mx <= 0) continue;
            int score = 1000 - d * 1000 / mx;
            if (score > best) { best = score; best_key = &key; }
        }
        if (best >= 850 && best_key) {
            auto it2 = ph->find(*best_key);
            if (it2 != ph->end() && put(it2->second, 2)) return (int32_t)it2->second.size();
        }

        std::vector<std::string> toks, raws;
        tokenize2(text, toks, raws);
        if (toks.empty()) return -1;

        const std::unordered_set<std::string>& stop = to_tk ?
                                                      (lang == 0 ? g.stop_ru : (lang == 2 ? g.stop_tr : g.stop_en)) : g.stop_tk;
        const std::unordered_set<std::string>& neg = lang == 0 ? g.neg_ru : (lang == 2 ? g.neg_tr : g.neg_en);

        bool quest = std::strchr(text, '?') != nullptr;
        for (const auto& t : toks) {
            if (g.q_words.count(t)) { quest = false; break; }
        }

        ETense tense = T_PRES;
        for (const auto& t : toks) {
            if (g.past_adv.count(t)) tense = T_PAST;
            else if (g.fut_adv.count(t)) tense = T_FUT;
        }

        bool neg_flag = false;
        bool imper = false;
        {
            std::string s = text;
            size_t p = s.find_last_not_of(" \t\r\n");
            bool bang = (p != std::string::npos && s[p] == '!');
            if (bang && to_tk) {
                bool has_subj = false;
                for (const auto& t : toks) {
                    std::string m;
                    if (find_word(*wd, t, lang, m)) {
                        if (pron_idx().count(lower_str(m))) { has_subj = true; break; }
                    }
                }
                if (!has_subj) imper = true;
            }
        }

        std::vector<Unit> units;
        units.reserve(toks.size());
        int rough_count = 0;

        for (size_t i = 0; i < toks.size(); ++i) {
            const std::string& tkn = toks[i];
            if (tkn.empty()) continue;
            if (to_tk && neg.count(tkn)) { neg_flag = true; continue; }
            if (is_digits(tkn)) {
                Unit u{}; u.tag = T_WORD; u.val = tkn; u.raw = raws[i]; u.pron = -1; u.cas = C_NOM; u.possp = 0; u.plural = false; u.prop = false; u.rough = false;
                units.push_back(std::move(u));
                continue;
            }
            if (stop.count(tkn)) {
                Unit u{}; u.tag = T_STOP; u.val = tkn; u.raw = raws[i]; u.pron = -1; u.cas = C_NOM; u.possp = 0; u.plural = false; u.prop = false; u.rough = false;
                units.push_back(std::move(u));
                continue;
            }
            auto av = adv_map().find(tkn);
            if (av != adv_map().end()) {
                Unit u{}; u.tag = T_WORD; u.val = av->second; u.raw = raws[i]; u.pron = -1; u.cas = C_NOM; u.possp = 0; u.plural = false; u.prop = false; u.rough = false;
                units.push_back(std::move(u));
                continue;
            }
            std::string mapped;
            bool found = false;
            bool rough = false;
            for (int len = 4; len >= 1 && !found; --len) {
                if (i + (size_t)len > toks.size()) continue;
                std::string cand;
                for (int j = 0; j < len; ++j) { if (j) cand += ' '; cand += toks[i + j]; }
                auto w = wd->find(cand);
                if (w != wd->end()) {
                    mapped = w->second; found = true;
                    for (int j = 1; j < len; ++j) toks[i + j].clear();
                }
            }
            if (!found) found = find_word(*wd, tkn, lang, mapped);
            if (!found && piv1 && piv2) {
                auto p1 = piv1->find(tkn);
                if (p1 == piv1->end()) {
                    std::vector<std::string> cs = (lang == 0) ? ru_stems(tkn) : ((lang == 2) ? tr_stems(tkn) : en_stems(tkn));
                    for (const auto& c : cs) { auto q = piv1->find(c); if (q != piv1->end()) { p1 = q; break; } }
                }
                if (p1 != piv1->end()) {
                    auto p2 = piv2->find(p1->second);
                    if (p2 != piv2->end()) { mapped = p2->second; found = true; }
                }
            }
            ECase cas = C_NOM;
            std::string stem_tk;
            if (!found && lang == 2 && tr_split_case(tkn, stem_tk, cas)) {
                found = find_word(*wd, stem_tk, lang, mapped);
            }
            if (!found && lang == 3) {
                std::string inf; int vp; bool vn; ETense vt;
                if (parse_verb_form(tkn, inf, vp, vn, vt)) {
                    if (find_word(*wd, inf, lang, mapped)) found = true;
                }
            }
            if (!found && to_tk) {
                int bs = 0;
                const std::string* bk = nullptr;
                for (const auto& kv : *wd) {
                    size_t d1 = kv.first.size() > tkn.size() ? kv.first.size() - tkn.size() : tkn.size() - kv.first.size();
                    if (d1 > 2) continue;
                    int d = lev_cap(tkn, kv.first, 2);
                    if (d > 2) continue;
                    int mx = (int)(kv.first.size() > tkn.size() ? kv.first.size() : tkn.size());
                    if (mx <= 0) continue;
                    int sc = 1000 - d * 1000 / mx;
                    if (sc > bs) { bs = sc; bk = &kv.first; }
                }
                if (bs >= 700 && bk) {
                    mapped = wd->find(*bk)->second;
                    found = true;
                    rough = true;
                }
            }
            bool prop = false;
            if (!found) {
                mapped = translit(tkn, lang);
                found = true;
                prop = true;
                rough = true;
            }
            if (rough) rough_count++;

            Unit u{};
            u.raw = raws[i];
            u.val = lower_str(mapped);
            u.cas = cas;
            u.possp = 0;
            u.plural = false;
            u.prop = prop;
            u.rough = rough;
            u.pron = -1;
            std::string low = u.val;
            std::string inf;
            int vp = -1;
            bool vn = false;
            ETense vt = T_PRES;
            auto pi = pron_idx().find(low);
            if (pi != pron_idx().end()) { u.tag = T_PRON; u.pron = pi->second; }
            else if (to_tk && parse_verb_form(low, inf, vp, vn, vt)) { u.tag = T_VERB; u.val = inf; u.pron = vp; if (vn) neg_flag = true; if (vt != T_PRES) tense = vt; }
            else if (to_tk && (ends_with(low, "mak") || ends_with(low, "mek"))) { u.tag = T_VERB; u.val = low; }
            else { u.tag = T_WORD; }
            if (u.tag == T_WORD && lang == 1 && !raws[i].empty() && ends_with(raws[i], "s") && !ends_with(raws[i], "ss")) u.plural = true;
            if (u.tag == T_WORD && lang == 2 && (ends_with(tkn, "lar") || ends_with(tkn, "ler"))) u.plural = true;
            units.push_back(std::move(u));
        }

        int content = 0, verbs = 0;
        for (const auto& u : units) {
            if (u.tag != T_STOP) content++;
            if (u.tag == T_VERB) verbs++;
        }
        if (content == 0) return -1;
        if (!to_tk && rough_count > 0) return -1;

        std::string res;
        res.reserve(std::strlen(text) + 32);
        auto append = [&](const std::string& s) {
            if (!res.empty()) res += ' ';
            res += s;
        };

        if (to_tk) {
            bool motion_ctx = false;
            for (const auto& u : units) if (u.tag == T_VERB && g.motion.count(u.val)) motion_ctx = true;

            for (size_t i = 0; i < units.size(); ++i) {
                if (units[i].tag != T_STOP) continue;
                const std::string& p = units[i].val;
                if (g.without_pre.count(p)) {
                    for (size_t j = i + 1; j < units.size(); ++j) {
                        if (units[j].tag == T_STOP) continue;
                        if (units[j].tag != T_WORD) break;
                        std::string suf = "s";
                        enc_cp(suf, harmony_v4(units[j].val));
                        suf += "z";
                        units[j].val += suf;
                        break;
                    }
                    continue;
                }
                for (size_t j = i + 1; j < units.size(); ++j) {
                    if (units[j].tag == T_STOP) continue;
                    if (units[j].tag != T_WORD) break;
                    if (p == "to" || p == "к") units[j].cas = C_DAT;
                    else if (p == "in" || p == "at" || p == "on" || p == "в" || p == "на" || p == "о" || p == "об")
                        units[j].cas = motion_ctx ? C_DAT : C_LOC;
                    else if (p == "from" || p == "из" || p == "от" || p == "с") units[j].cas = C_ABL;
                    else if (p == "of") units[j].cas = C_GEN;
                    break;
                }
            }

            for (size_t i = 0; i + 1 < units.size(); ++i) {
                if (units[i].tag == T_WORD && g.poss_pron.count(units[i].val)) {
                    int pp = 1;
                    if (units[i].val == "seniň") pp = 2;
                    else if (units[i].val == "onuň") pp = 3;
                    else if (units[i].val == "biziň") pp = 4;
                    else if (units[i].val == "siziň") pp = 5;
                    else if (units[i].val == "olaryň") pp = 6;
                    for (size_t j = i + 1; j < units.size(); ++j) {
                        if (units[j].tag == T_STOP) continue;
                        if (units[j].tag == T_WORD && units[j].possp == 0) units[j].possp = pp;
                        break;
                    }
                }
            }

            int person = -1;
            const Unit* verb = nullptr;
            for (const auto& u : units) {
                if (u.tag == T_PRON && person < 0) person = u.pron;
                if (u.tag == T_VERB) verb = &u;
            }
            if (person < 0 && verb) person = verb->pron;
            if (person < 0) person = 2;

            bool subj_done = false;
            for (const auto& u : units) {
                if (u.tag == T_STOP) continue;
                if (u.tag == T_VERB) continue;
                if (u.tag == T_PRON) {
                    if (!subj_done && !imper) { append(u.val); subj_done = true; }
                    continue;
                }
                std::string v = u.val;
                if (u.plural) v = v + (word_back(v) ? "lar" : "ler");
                if (u.possp > 0 && u.possp < 6) v = poss(v, u.possp);
                if (u.possp == 6) { v = v + (word_back(v) ? "lar" : "ler"); v = poss(v, 3); }
                if (u.cas != C_NOM) v = apply_case(v, u.cas);
                append(v);
            }

            if (verb) {
                if (imper) {
                    std::string st = verb->val.substr(0, verb->val.size() - 3);
                    if (neg_flag) st += (word_back(st) ? "ma" : "me");
                    append(st);
                } else {
                    append(conjugate2(verb->val, person, neg_flag, tense, quest));
                }
            } else if (quest && !res.empty()) {
                res += (word_back(res) ? "my" : "mi");
            }
        } else {
            if (neg_flag) return -1;
            std::string subj, verbw;
            std::vector<std::string> others;
            for (const auto& u : units) {
                if (u.tag == T_STOP) continue;
                std::string v = u.val;
                std::string src = lower_str(u.raw);
                std::string stem;
                ECase cas = C_NOM;
                if (tk_split_case(src, stem, cas) && cas != C_NOM) {
                    std::string lem;
                    if (find_word(*wd, stem, 3, lem)) v = lem;
                    const char* prep = nullptr;
                    if (std::strcmp(to, "ru") == 0) {
                        if (cas == C_DAT) prep = "к";
                        else if (cas == C_LOC) prep = "в";
                        else if (cas == C_ABL) prep = "из";
                    } else if (std::strcmp(to, "tr") != 0) {
                        if (cas == C_DAT) prep = "to";
                        else if (cas == C_LOC) prep = "in";
                        else if (cas == C_ABL) prep = "from";
                        else if (cas == C_GEN) prep = "of";
                    }
                    if (prep && prep[0]) others.push_back(prep);
                } else {
                    std::string inf;
                    int vp; bool vn; ETense vt;
                    if (parse_verb_form(src, inf, vp, vn, vt)) {
                        std::string lem;
                        if (find_word(*wd, inf, 3, lem)) v = lem;
                        else v = inf;
                        if (verbw.empty()) { verbw = v; continue; }
                    }
                }
                if (u.tag == T_PRON && subj.empty()) subj = v;
                else others.push_back(v);
            }
            if (!subj.empty()) append(subj);
            if (!verbw.empty()) append(verbw);
            for (const auto& o : others) append(o);
            if (res.empty()) return -1;
        }

        if (res.empty()) return -1;
        cap_first(res);
        if (!put(res, rough_count > 0 ? 4 : 3)) return -1;

        auto us = std::chrono::duration_cast<std::chrono::microseconds>(
                std::chrono::steady_clock::now() - t0).count();
        MT_LOG("MONSTER translate content=%d verbs=%d rough=%d tense=%d quest=%d imper=%d in %lld us",
               content, verbs, rough_count, (int)tense, (int)quest, (int)imper, (long long)us);
        return (int32_t)res.size();
    }

}