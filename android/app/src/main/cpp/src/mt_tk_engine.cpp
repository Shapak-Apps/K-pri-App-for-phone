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
#include <cstdint>
#include <cctype>
#include <initializer_list>
#include <limits>

#define MT_TAG "KOPRI_MT"
#define MT_LOG(...) __android_log_print(ANDROID_LOG_INFO, MT_TAG, __VA_ARGS__)

namespace kp {

    namespace {

        enum ECase { C_NOM, C_GEN, C_DAT, C_ACC, C_LOC, C_ABL };
        enum ETense { T_PRES, T_PAST, T_FUT };
        enum Tag { T_STOP, T_PRON, T_VERB, T_WORD, T_AUX, T_MODAL };

        struct Candidate {
            std::string translation;
            int32_t count = 0;
            int32_t score = 0;
            int8_t pos = 0;
            int8_t role = 0;
        };

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

            std::unordered_map<std::string, std::vector<Candidate>>
                    cand_ru_tk, cand_en_tk, cand_tr_tk,
                    cand_tk_ru, cand_tk_en, cand_tk_tr;

            std::unordered_set<std::string> stop_ru, stop_en, stop_tr, stop_tk;
            std::unordered_set<std::string> neg_ru, neg_en, neg_tr;
            std::unordered_set<std::string> q_words;
            std::unordered_set<std::string> motion;
            std::unordered_set<std::string> past_adv, fut_adv;
            std::unordered_set<std::string> without_pre;
            std::unordered_set<std::string> poss_pron;
            std::unordered_set<std::string> number_words;

            std::unordered_map<std::string, std::string> fn_ru, fn_en, fn_tr;
            std::unordered_map<std::string, std::string> pron_ru, pron_en, pron_tr;
            std::unordered_map<std::string, std::string> poss_det_ru, poss_det_en, poss_det_tr;

            std::unordered_set<std::string> tk_verbs;
            std::unordered_set<std::string> tk_verb_stems;
        };

        Engine g;

        [[gnu::always_inline]] inline uint32_t next_cp(const std::string& t, size_t& i) noexcept {
            unsigned char c = static_cast<unsigned char>(t[i]);
            uint32_t cp = 0;
            if (c < 0x80) {
                cp = c;
                i += 1;
            } else if ((c >> 5) == 0x6 && i + 1 < t.size()) {
                cp = ((c & 0x1F) << 6) | (t[i + 1] & 0x3F);
                i += 2;
            } else if ((c >> 4) == 0xE && i + 2 < t.size()) {
                cp = ((c & 0x0F) << 12) | ((t[i + 1] & 0x3F) << 6) | (t[i + 2] & 0x3F);
                i += 3;
            } else if ((c >> 3) == 0x1E && i + 3 < t.size()) {
                cp = ((c & 0x07) << 18) | ((t[i + 1] & 0x3F) << 12) |
                     ((t[i + 2] & 0x3F) << 6) | (t[i + 3] & 0x3F);
                i += 4;
            } else {
                i += 1;
                return 0;
            }
            return cp;
        }

        [[gnu::always_inline]] inline void enc_cp(std::string& out, uint32_t cp) noexcept {
            if (cp < 0x80) out += static_cast<char>(cp);
            else if (cp < 0x800) {
                out += static_cast<char>(0xC0 | (cp >> 6));
                out += static_cast<char>(0x80 | (cp & 63));
            } else if (cp < 0x10000) {
                out += static_cast<char>(0xE0 | (cp >> 12));
                out += static_cast<char>(0x80 | ((cp >> 6) & 63));
                out += static_cast<char>(0x80 | (cp & 63));
            } else {
                out += static_cast<char>(0xF0 | (cp >> 18));
                out += static_cast<char>(0x80 | ((cp >> 12) & 63));
                out += static_cast<char>(0x80 | ((cp >> 6) & 63));
                out += static_cast<char>(0x80 | (cp & 63));
            }
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
                case 0xC4: return 0xE4;
                case 0xC7: return 0xE7;
                case 0xD6: return 0xF6;
                case 0xDC: return 0xFC;
                case 0xDD: return 0xFD;
                case 0x17D: return 0x17E;
                case 0x147: return 0x148;
                case 0x15E: return 0x15F;
                case 0x11E: return 0x11F;
                case 0x130: return 0x69;
            }
            return cp;
        }

        [[gnu::always_inline]] inline uint32_t cp_upper(uint32_t cp) noexcept {
            if (cp >= 'a' && cp <= 'z') return cp - 32;
            if (cp >= 0x430 && cp <= 0x44F) return cp - 0x20;
            if (cp == 0x451) return 0x401;
            switch (cp) {
                case 0xE4: return 0xC4;
                case 0xE7: return 0xC7;
                case 0xF6: return 0xD6;
                case 0xFC: return 0xDC;
                case 0xFD: return 0xDD;
                case 0x17E: return 0x17D;
                case 0x148: return 0x147;
                case 0x15F: return 0x15E;
                case 0x11F: return 0x11E;
            }
            return cp;
        }

        inline bool cp_punct(uint32_t cp) noexcept {
            switch (cp) {
                case '.': case ',': case '!': case '?': case ';': case ':': case '"': case '\'':
                case '(': case ')': case '[': case ']': case '{': case '}': case 0xAB: case 0xBB:
                case 0x201C: case 0x201D: case 0x2014: case 0x2013: case 0x2026: case '/':
                case '\\': case '|': case '+': case '=': case '*': case '#': case '<': case '>':
                case 0x2018: case 0x2019:
                    return true;
            }
            return false;
        }

        inline bool cp_space(uint32_t cp) noexcept {
            return cp == ' ' || cp == '\t' || cp == '\n' || cp == '\r';
        }

        std::string norm_key(const std::string& s) {
            std::string out;
            bool sp = false;
            size_t i = 0;
            while (i < s.size()) {
                uint32_t cp = next_cp(s, i);
                if (!cp) continue;
                if (cp_space(cp)) {
                    sp = true;
                    continue;
                }
                if (cp_punct(cp) || cp == '-') continue;
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
                if (!cp) continue;
                if (cp_space(cp) || cp_punct(cp) || cp == '-') {
                    if (!cl.empty()) {
                        low.push_back(std::move(cl));
                        raw.push_back(std::move(cr));
                        cl.clear();
                        cr.clear();
                    }
                    continue;
                }
                enc_cp(cr, cp);
                enc_cp(cl, cp_lower(cp));
            }
            if (!cl.empty()) {
                low.push_back(std::move(cl));
                raw.push_back(std::move(cr));
            }
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
            while (i < s.size()) {
                prev = i;
                next_cp(s, i);
            }
            size_t j = prev;
            return next_cp(s, j);
        }

        inline bool tk_vowel(uint32_t cp) {
            return cp == 'a' || cp == 'e' || cp == 'i' || cp == 'o' || cp == 'u' ||
                   cp == 'y' || cp == 0xE4 || cp == 0xF6 || cp == 0xFC || cp == 0xFD;
        }

        inline bool tk_back(uint32_t cp) {
            return cp == 'a' || cp == 'o' || cp == 'u' || cp == 'y';
        }

        inline bool tk_round(uint32_t cp) {
            return cp == 'o' || cp == 'u' || cp == 0xF6 || cp == 0xFC;
        }

        uint32_t last_vowel(const std::string& s) {
            uint32_t v = 'a';
            size_t i = 0;
            while (i < s.size()) {
                uint32_t cp = next_cp(s, i);
                if (tk_vowel(cp)) v = cp;
            }
            return v;
        }

        bool word_back(const std::string& s) {
            return tk_back(last_vowel(s));
        }

        uint32_t harmony_v4(const std::string& w) {
            uint32_t v = last_vowel(w);
            if (tk_back(v)) {
                if (tk_round(v)) return 'u';
                return 'y';
            }
            if (tk_round(v)) return 0xFC;
            return 'i';
        }

        std::string mutate(const std::string& w) {
            if (w.empty()) return w;
            uint32_t lc = last_cp(w), m = 0;
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
            uint32_t lc = last_cp(w), m = 0;
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
            if (tk_vowel(lc)) return w + (word_back(w) ? "a" : "e");
            return mutate(w) + (word_back(w) ? "a" : "e");
        }

        std::string apply_case(const std::string& w, ECase c) {
            if (c == C_NOM || w.empty()) return w;
            bool back = word_back(w);
            uint32_t lc = last_cp(w);
            bool vow = tk_vowel(lc);
            switch (c) {
                case C_DAT:
                    return dative(w);
                case C_GEN:
                    return vow ? w + (back ? "nyň" : "niň") : mutate(w) + (back ? "yň" : "iň");
                case C_ACC:
                    return vow ? w + (back ? "ny" : "ni") : mutate(w) + (back ? "y" : "i");
                case C_LOC:
                    return w + (back ? "da" : "de");
                case C_ABL:
                    return w + (back ? "dan" : "den");
                default:
                    return w;
            }
        }

        std::string poss(const std::string& w, int p) {
            if (w.empty() || p <= 0) return w;
            bool back = word_back(w);
            uint32_t lc = last_cp(w);
            bool vow = tk_vowel(lc);
            std::string vs;
            enc_cp(vs, harmony_v4(w));
            std::string base = vow ? w : mutate(w);
            switch (p) {
                case 1:
                    return base + vs + "m";
                case 2:
                    return base + vs + "ň";
                case 3:
                    return vow ? w + "s" + vs : base + vs;
                case 4:
                    return vow ? w + (back ? "myz" : "miz") : base + vs + (back ? "myz" : "miz");
                case 5:
                    return vow ? w + (back ? "ňyz" : "ňiz") : base + vs + (back ? "ňyz" : "ňiz");
                default:
                    return base + vs + (back ? "lar" : "ler");
            }
        }

        const std::unordered_map<std::string, std::string>& irr_stems() {
            static const std::unordered_map<std::string, std::string> m = {
                    {"git", "gid"},
                    {"et", "ed"},
                    {"gut", "gud"},
                    {"çat", "çad"},
                    {"ýt", "ýd"}
            };
            return m;
        }

        const std::unordered_map<std::string, int>& pron_idx() {
            static const std::unordered_map<std::string, int> m = {
                    {"men", 0},
                    {"sen", 1},
                    {"ol", 2},
                    {"biz", 3},
                    {"siz", 4},
                    {"olar", 5}
            };
            return m;
        }

        std::string conjugate2(const std::string& inf, int person, bool neg, ETense t, bool quest) {
            if (inf.size() < 4) return inf;
            std::string stem = ends_with(inf, "mak") || ends_with(inf, "mek") ? inf.substr(0, inf.size() - 3) : inf;
            auto ii = irr_stems().find(stem);
            if (ii != irr_stems().end()) stem = ii->second;
            bool back = word_back(stem);
            if (person < 0 || person > 5) person = 2;

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

            if (quest) out += (word_back(out) ? "my" : "mi");
            return out;
        }

        std::string future_def(const std::string& inf, bool neg) {
            std::string stem = ends_with(inf, "mak") || ends_with(inf, "mek") ? inf.substr(0, inf.size() - 3) : inf;
            return stem + (neg ? "jek däl" : (word_back(stem) ? "jak" : "jek"));
        }

        std::string lower_str(const std::string& s) {
            std::string o;
            size_t i = 0;
            while (i < s.size()) enc_cp(o, cp_lower(next_cp(s, i)));
            return o;
        }

        void replace_all(std::string& s, const char* from, const char* to) {
            if (!from || !*from) return;
            size_t fl = std::strlen(from);
            size_t tl = std::strlen(to);
            size_t pos = 0;
            while ((pos = s.find(from, pos)) != std::string::npos) {
                s.replace(pos, fl, to);
                pos += tl;
            }
        }

        std::string prepare_input(const std::string& text) {
            std::string s = lower_str(text);
            replace_all(s, "\xE2\x80\x99", "'");
            replace_all(s, "\xE2\x80\x98", "'");
            replace_all(s, "won't", "will not");
            replace_all(s, "cannot", "can not");
            replace_all(s, "can't", "can not");
            replace_all(s, "shan't", "shall not");
            replace_all(s, "don't", "do not");
            replace_all(s, "doesn't", "does not");
            replace_all(s, "didn't", "did not");
            replace_all(s, "isn't", "is not");
            replace_all(s, "aren't", "are not");
            replace_all(s, "wasn't", "was not");
            replace_all(s, "weren't", "were not");
            replace_all(s, "haven't", "have not");
            replace_all(s, "hasn't", "has not");
            replace_all(s, "hadn't", "had not");
            replace_all(s, "wouldn't", "would not");
            replace_all(s, "shouldn't", "should not");
            replace_all(s, "couldn't", "could not");
            replace_all(s, "i'm", "i am");
            replace_all(s, "you're", "you are");
            replace_all(s, "he's", "he is");
            replace_all(s, "she's", "she is");
            replace_all(s, "it's", "it is");
            replace_all(s, "we're", "we are");
            replace_all(s, "they're", "they are");
            replace_all(s, "i've", "i have");
            replace_all(s, "you've", "you have");
            replace_all(s, "we've", "we have");
            replace_all(s, "they've", "they have");
            replace_all(s, "i'll", "i will");
            replace_all(s, "you'll", "you will");
            replace_all(s, "he'll", "he will");
            replace_all(s, "she'll", "she will");
            replace_all(s, "we'll", "we will");
            replace_all(s, "they'll", "they will");
            replace_all(s, "i'd", "i would");
            replace_all(s, "you'd", "you would");
            replace_all(s, "he'd", "he would");
            replace_all(s, "she'd", "she would");
            replace_all(s, "we'd", "we would");
            replace_all(s, "they'd", "they would");
            replace_all(s, "let's", "let us");
            replace_all(s, "'", " ");
            return s;
        }

        const std::unordered_map<std::string, std::string>& adv_map() {
            static const std::unordered_map<std::string, std::string> m = {
                    {"yesterday", "düýn"},
                    {"вчера", "düýn"},
                    {"tomorrow", "ertir"},
                    {"завтра", "ertir"},
                    {"today", "şu gün"},
                    {"сегодня", "şu gün"},
                    {"now", "häzir"},
                    {"сейчас", "häzir"},
                    {"soon", "ýakynda"},
                    {"скоро", "ýakynda"},
                    {"already", "eýýäm"},
                    {"уже", "eýýäm"},
                    {"here", "bu ýerde"},
                    {"здесь", "bu ýerde"},
                    {"there", "ol ýerde"},
                    {"там", "ol ýerde"}
            };
            return m;
        }

        void cap_first(std::string& s) {
            if (s.empty()) return;
            size_t i = 0;
            uint32_t cp = next_cp(s, i);
            uint32_t up = cp_upper(cp);
            if (up == cp) return;
            std::string r;
            enc_cp(r, up);
            r += s.substr(i);
            s.swap(r);
        }

        void restore_punctuation(const std::string& src, std::string& dst) {
            size_t b = src.find_first_not_of(" \t\r\n");
            size_t e = src.find_last_not_of(" \t\r\n");
            if (b == std::string::npos) return;

            std::string lead = src.substr(0, b);
            std::string trail;
            if (e + 1 < src.size()) trail = src.substr(e + 1);

            const char* punct = ",.!?;:";
            size_t last_word = dst.find_last_not_of(" \t\r\n");
            if (last_word != std::string::npos && (trail.empty() || std::strchr(punct, trail[0]))) {
                std::string core = dst.substr(0, last_word + 1);
                bool q = false, ex = false;
                for (char c : trail) {
                    if (c == '?') q = true;
                    if (c == '!') ex = true;
                }
                if (q && core.find('?') == std::string::npos) core += '?';
                else if (ex && core.find('!') == std::string::npos) core += '!';
                else if (!trail.empty() && !q && !ex) core += trail;
                dst.swap(core);
            }

            if (!lead.empty() && dst.compare(0, lead.size(), lead) != 0) dst = lead + dst;
        }

        bool parse_verb_form(const std::string& v, std::string& inf, int& person, bool& neg, ETense& t) {
            struct E {
                const char* s;
                int p;
                bool n;
                bool b;
                ETense tt;
            };

            static const E T[] = {
                    {"maýarsyňyz", 4, true, true, T_PRES}, {"meýärsiňiz", 4, true, false, T_PRES},
                    {"madym", 0, true, true, T_PAST}, {"medim", 0, true, false, T_PAST},
                    {"madyňyz", 4, true, true, T_PAST}, {"mediňiz", 4, true, false, T_PAST},
                    {"madylar", 5, true, true, T_PAST}, {"mediler", 5, true, false, T_PAST},
                    {"madyk", 3, true, true, T_PAST}, {"medik", 3, true, false, T_PAST},
                    {"madyň", 1, true, true, T_PAST}, {"mediň", 1, true, false, T_PAST},
                    {"mady", 2, true, true, T_PAST}, {"medi", 2, true, false, T_PAST},
                    {"dym", 0, false, true, T_PAST}, {"dim", 0, false, false, T_PAST},
                    {"dyňyz", 4, false, true, T_PAST}, {"diňiz", 4, false, false, T_PAST},
                    {"dylar", 5, false, true, T_PAST}, {"diler", 5, false, false, T_PAST},
                    {"dyk", 3, false, true, T_PAST}, {"dik", 3, false, false, T_PAST},
                    {"dyň", 1, false, true, T_PAST}, {"diň", 1, false, false, T_PAST},
                    {"dy", 2, false, true, T_PAST}, {"di", 2, false, false, T_PAST},
                    {"maryn", 0, true, true, T_FUT}, {"merin", 0, true, false, T_FUT},
                    {"marsyň", 1, true, true, T_FUT}, {"mersiň", 1, true, false, T_FUT},
                    {"marys", 3, true, true, T_FUT}, {"meris", 3, true, false, T_FUT},
                    {"marsyňyz", 4, true, true, T_FUT}, {"mersiňiz", 4, true, false, T_FUT},
                    {"marlar", 5, true, true, T_FUT}, {"merler", 5, true, false, T_FUT},
                    {"mar", 2, true, true, T_FUT}, {"mer", 2, true, false, T_FUT},
                    {"maýaryn", 0, true, true, T_PRES}, {"meýärin", 0, true, false, T_PRES},
                    {"maýarsyň", 1, true, true, T_PRES}, {"meýärsiň", 1, true, false, T_PRES},
                    {"maýarys", 3, true, true, T_PRES}, {"meýäris", 3, true, false, T_PRES},
                    {"maýarlar", 5, true, true, T_PRES}, {"meýärler", 5, true, false, T_PRES},
                    {"maýar", 2, true, true, T_PRES}, {"meýär", 2, true, false, T_PRES},
                    {"aryn", 0, false, true, T_FUT}, {"erin", 0, false, false, T_FUT},
                    {"arsyň", 1, false, true, T_FUT}, {"ersiň", 1, false, false, T_FUT},
                    {"arys", 3, false, true, T_FUT}, {"eris", 3, false, false, T_FUT},
                    {"arsyňyz", 4, false, true, T_FUT}, {"ersiňiz", 4, false, false, T_FUT},
                    {"arlar", 5, false, true, T_FUT}, {"erler", 5, false, false, T_FUT},
                    {"ar", 2, false, true, T_FUT}, {"er", 2, false, false, T_FUT},
                    {"ýarsyňyz", 4, false, true, T_PRES}, {"ýärsiňiz", 4, false, false, T_PRES},
                    {"ýaryn", 0, false, true, T_PRES}, {"ýärin", 0, false, false, T_PRES},
                    {"ýarsyň", 1, false, true, T_PRES}, {"ýärsiň", 1, false, false, T_PRES},
                    {"ýarys", 3, false, true, T_PRES}, {"ýäris", 3, false, false, T_PRES},
                    {"ýarlar", 5, false, true, T_PRES}, {"ýärler", 5, false, false, T_PRES},
                    {"ýar", 2, false, true, T_PRES}, {"ýär", 2, false, false, T_PRES}
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
            const int m = static_cast<int>(a.size()), n = static_cast<int>(b.size());
            if (m - n > cap || n - m > cap || n > 255) return cap + 1;
            int prev[256], cur[256];
            for (int j = 0; j <= n; ++j) prev[j] = j;
            for (int i = 1; i <= m; ++i) {
                cur[0] = i;
                int rowmin = cur[0];
                for (int j = 1; j <= n; ++j) {
                    int cost = a[i - 1] == b[j - 1] ? 0 : 1;
                    int v = std::min({prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost});
                    cur[j] = v;
                    rowmin = std::min(rowmin, v);
                }
                if (rowmin > cap) return cap + 1;
                std::swap_ranges(prev, prev + n + 1, cur);
            }
            return prev[n];
        }

        void build_candidates(
                const std::unordered_map<std::string, std::unordered_map<std::string, int32_t>>& cooc,
                const std::unordered_map<std::string, int32_t>& tot_src,
                const std::unordered_map<std::string, int32_t>& tot_tgt,
                const std::unordered_set<std::string>& stop_src,
                const std::unordered_set<std::string>& stop_tgt,
                std::unordered_map<std::string, std::string>& best,
                std::unordered_map<std::string, std::vector<Candidate>>& cand) {
            struct Entry {
                std::string w;
                int32_t c;
                int64_t s;
            };

            for (const auto& kv : tot_src) {
                const std::string& src = kv.first;
                int32_t st = kv.second;
                if (st <= 0) continue;
                if (stop_src.count(src)) continue;

                auto it = cooc.find(src);
                if (it == cooc.end()) continue;

                std::vector<Entry> v;
                v.reserve(it->second.size());

                for (const auto& cw : it->second) {
                    const std::string& tgt = cw.first;
                    int32_t c = cw.second;
                    if (c <= 0) continue;
                    if (stop_tgt.count(tgt)) continue;

                    int32_t tt = c;
                    auto tti = tot_tgt.find(tgt);
                    if (tti != tot_tgt.end() && tti->second > 0) tt = tti->second;

                    if (c == 1 && st > 3 && tt > 3) continue;

                    int64_t denom = static_cast<int64_t>(st) + static_cast<int64_t>(tt);
                    if (denom <= 0) continue;

                    int64_t score = static_cast<int64_t>(c) * 100000 / denom;
                    if (c * 2 >= st) score += 15000;
                    if (c * 2 >= tt) score += 15000;
                    if (st == 1 && c == 1 && tt <= 2) score += 25000;
                    if (score < 8000 && c < 2) continue;

                    v.push_back({tgt, c, score});
                }

                if (v.empty()) continue;

                std::sort(v.begin(), v.end(), [](const Entry& a, const Entry& b) {
                    if (a.s != b.s) return a.s > b.s;
                    if (a.c != b.c) return a.c > b.c;
                    return a.w < b.w;
                });

                auto& out = cand[src];
                out.clear();
                out.reserve(std::min<size_t>(8, v.size()));

                for (size_t i = 0; i < v.size() && i < 8; ++i) {
                    Candidate c;
                    c.translation = v[i].w;
                    c.count = v[i].c;
                    c.score = static_cast<int32_t>(std::min<int64_t>(v[i].s, 1000000));
                    out.push_back(std::move(c));
                }

                const Entry& top = v[0];
                if (top.c >= 2 || st <= 2 || top.s >= 20000) {
                    best[src] = top.w;
                }
            }
        }

        std::vector<std::string> en_stems(const std::string& w) {
            std::vector<std::string> v{w};
            if (w.size() > 4 && ends_with(w, "ies")) v.push_back(w.substr(0, w.size() - 3) + "y");
            if (w.size() > 3 && ends_with(w, "es")) v.push_back(w.substr(0, w.size() - 2));
            if (w.size() > 3 && ends_with(w, "s") && !ends_with(w, "ss")) v.push_back(w.substr(0, w.size() - 1));
            if (w.size() > 5 && ends_with(w, "ing")) {
                std::string b = w.substr(0, w.size() - 3);
                v.push_back(b);
                v.push_back(b + "e");
                if (b.size() >= 2 && b[b.size() - 1] == b[b.size() - 2]) v.push_back(b.substr(0, b.size() - 1));
            }
            if (w.size() > 4 && ends_with(w, "ed")) {
                std::string b = w.substr(0, w.size() - 2);
                v.push_back(b);
                v.push_back(b + "e");
                if (b.size() >= 2 && b[b.size() - 1] == b[b.size() - 2]) v.push_back(b.substr(0, b.size() - 1));
            }
            if (w.size() > 4 && ends_with(w, "ly")) v.push_back(w.substr(0, w.size() - 2));
            if (w.size() > 4 && ends_with(w, "ness")) v.push_back(w.substr(0, w.size() - 4));
            if (w.size() > 5 && ends_with(w, "tion")) v.push_back(w.substr(0, w.size() - 4) + "te");
            return v;
        }

        std::vector<std::string> ru_stems(const std::string& w) {
            std::vector<std::string> v{w};

            static const char* suf[] = {
                    "иями", "ями", "ами", "ого", "его", "ыми", "ими", "ая", "яя", "ое", "ее",
                    "ые", "ие", "ой", "ей", "ий", "ый", "ешь", "ишь", "ает", "яет", "ует",
                    "ют", "ёт", "ит", "ут", "ат", "ят", "ем", "ём", "ете", "ёте", "ите",
                    "ил", "ыл", "ила", "ыла", "или", "ыли", "у", "ю", "а", "я", "ы", "и",
                    "е", "ё", "о", "й", "ь", "ом", "им", "ам", "ям", "ах", "ях", "ев", "ов"
            };

            static const char* add[] = {
                    "а", "я", "о", "е", "й", "ь", "ы", "и", "ть", "ти", "чь", "ать", "ять",
                    "еть", "ить", "ой", "ый", "ий", "ая", "яя", "ое", "ее"
            };

            for (const char* s : suf) {
                size_t n = std::strlen(s);
                if (w.size() <= n + 2 || !ends_with(w, s)) continue;
                std::string b = w.substr(0, w.size() - n);
                v.push_back(b);
                for (const char* a : add) v.push_back(b + a);
            }
            return v;
        }

        std::vector<std::string> tr_stems(const std::string& w) {
            std::vector<std::string> v{w};

            static const char* suf[] = {
                    "yorlar", "yorsunuz", "yoruz", "yorsun", "yorum", "yor", "lardı", "lerdi",
                    "ladı", "ledi", "dığı", "diği", "dı", "di", "ti", "tı", "lar", "ler",
                    "larının", "lerinin", "larında", "lerinde", "larına", "lerine", "larını",
                    "lerini", "nın", "nin", "nun", "nün", "ında", "inde", "ından", "inden",
                    "ına", "ine", "ını", "ini", "dan", "den", "tan", "ten", "da", "de",
                    "ta", "te", "a", "e", "ı", "i", "u", "ü"
            };

            for (const char* s : suf) {
                size_t n = std::strlen(s);
                if (w.size() <= n + 2 || !ends_with(w, s)) continue;
                std::string b = w.substr(0, w.size() - n);
                v.push_back(b);
                v.push_back(b + "mak");
                v.push_back(b + "mek");
                std::string u = unmut(b);
                if (u != b) {
                    v.push_back(u);
                    v.push_back(u + "mak");
                    v.push_back(u + "mek");
                }
            }
            return v;
        }

        std::vector<std::string> tk_stems(const std::string& w) {
            std::vector<std::string> v{w};

            static const char* suf[] = {
                    "laryndan", "lerinden", "laryna", "lerine", "laryny", "lerini", "larynda",
                    "lerinde", "lary", "leri", "syndan", "sinden", "syna", "sine", "syny",
                    "sini", "synda", "sinde", "ndan", "nden", "nda", "nde", "na", "ne",
                    "da", "de", "dan", "den", "ny", "ni", "sy", "si", "ym", "im", "um",
                    "üm", "uň", "üň", "yň", "iň", "a", "e", "y", "i"
            };

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
            if (it != wd.end()) {
                res = it->second;
                return true;
            }

            std::vector<std::string> cands;
            if (lang == 0) cands = ru_stems(tok);
            else if (lang == 1) cands = en_stems(tok);
            else if (lang == 2) cands = tr_stems(tok);
            else cands = tk_stems(tok);

            for (const auto& c : cands) {
                auto i = wd.find(c);
                if (i != wd.end()) {
                    res = i->second;
                    return true;
                }
            }
            return false;
        }

        bool is_digits(const std::string& w) {
            if (w.empty()) return false;
            for (char c : w) if (c < '0' || c > '9') return false;
            return true;
        }

        bool tr_split_case(const std::string& w, std::string& stem, ECase& c) {
            struct S {
                const char* suf;
                ECase cc;
            };

            static const S T[] = {
                    {"dan", C_ABL}, {"den", C_ABL}, {"tan", C_ABL}, {"ten", C_ABL},
                    {"da", C_LOC}, {"de", C_LOC}, {"ta", C_LOC}, {"te", C_LOC},
                    {"nın", C_GEN}, {"nin", C_GEN}, {"nun", C_GEN}, {"nün", C_GEN},
                    {"ı", C_ACC}, {"i", C_ACC}, {"u", C_ACC}, {"ü", C_ACC},
                    {"a", C_DAT}, {"e", C_DAT}
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
            struct S {
                const char* suf;
                ECase cc;
            };

            static const S T[] = {
                    {"dan", C_ABL}, {"den", C_ABL},
                    {"da", C_LOC}, {"de", C_LOC},
                    {"nyň", C_GEN}, {"niň", C_GEN}, {"uň", C_GEN}, {"üň", C_GEN},
                    {"yň", C_GEN}, {"iň", C_GEN},
                    {"ny", C_ACC}, {"ni", C_ACC}, {"y", C_ACC}, {"i", C_ACC},
                    {"na", C_DAT}, {"ne", C_DAT}, {"a", C_DAT}, {"e", C_DAT}
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

        const char* cyr_translit(uint32_t cp) {
            switch (cp) {
                case 0x430: return "a";
                case 0x431: return "b";
                case 0x432: return "w";
                case 0x433: return "g";
                case 0x434: return "d";
                case 0x435: return "e";
                case 0x451: return "ýo";
                case 0x436: return "ž";
                case 0x437: return "z";
                case 0x438: return "i";
                case 0x439: return "ý";
                case 0x43A: return "k";
                case 0x43B: return "l";
                case 0x43C: return "m";
                case 0x43D: return "n";
                case 0x43E: return "o";
                case 0x43F: return "p";
                case 0x440: return "r";
                case 0x441: return "s";
                case 0x442: return "t";
                case 0x443: return "u";
                case 0x444: return "f";
                case 0x445: return "h";
                case 0x446: return "s";
                case 0x447: return "ç";
                case 0x448: return "ş";
                case 0x449: return "ş";
                case 0x44A: return "";
                case 0x44B: return "y";
                case 0x44C: return "";
                case 0x44D: return "e";
                case 0x44E: return "ýu";
                case 0x44F: return "ýa";
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

        void init_sets(Engine& e) {
            e.stop_ru = {
                    "и", "или", "но", "а", "в", "на", "к", "с", "у", "о", "об", "от", "до",
                    "из", "за", "по", "при", "под", "над", "перед", "между", "для", "около",
                    "через", "эта", "этот", "эти", "этом", "этой", "того", "той", "том",
                    "так", "же", "бы", "ли", "вот", "вон", "только", "тоже", "также",
                    "ещё", "уже", "было", "был", "была", "были", "будет", "будут",
                    "является", "являются", "что", "который", "какой", "без", "не"
            };

            e.stop_en = {
                    "the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for",
                    "of", "with", "by", "from", "up", "about", "into", "through", "during",
                    "before", "after", "above", "below", "between", "under", "over", "again",
                    "further", "then", "once", "here", "there", "when", "where", "why", "how",
                    "all", "any", "both", "each", "few", "more", "most", "other", "some",
                    "such", "no", "nor", "only", "own", "same", "so", "than", "too", "very",
                    "can", "will", "just", "should", "now", "am", "is", "are", "was", "were",
                    "be", "been", "being", "have", "has", "had", "having", "do", "does", "did",
                    "doing", "would", "could", "ought", "might", "this", "that", "these",
                    "those", "without", "not"
            };

            e.stop_tr = {
                    "ve", "veya", "ama", "fakat", "ile", "için", "da", "de", "ki", "mi",
                    "mı", "mu", "mü", "bu", "şu", "bir", "çok", "daha", "gibi", "ise",
                    "ancak", "lakin", "çünkü", "eğer", "şayet", "bez"
            };

            e.stop_tk = {
                    "we", "ýa", "emma", "bilen", "üçin", "da", "de", "hem", "bir", "köp",
                    "has", "diýip", "şol", "bu"
            };

            e.neg_ru = {"не"};
            e.neg_en = {"not"};
            e.neg_tr = {"değil"};

            e.q_words = {
                    "kim", "näme", "nirede", "haçan", "nädip", "näçe", "haýsy", "nähili",
                    "why", "where", "what", "who", "how", "when", "howmany",
                    "почему", "где", "как", "что", "кто", "когда", "сколько", "какой", "который"
            };

            e.motion = {
                    "gitmek", "gelmek", "barmak", "uçmak", "sürmek", "ýöremek", "ylgamak",
                    "gaçmak", "almak", "getirmek", "äkirmek", "geçmek"
            };

            e.past_adv = {"yesterday", "düýn", "вчера", "last", "ago", "назад"};
            e.fut_adv = {"tomorrow", "ertir", "завтра", "soon", "ýakynda", "скоро"};
            e.without_pre = {"без", "without", "bez"};
            e.poss_pron = {"meniň", "seniň", "onuň", "biziň", "siziň", "olaryň"};

            e.number_words = {
                    "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
                    "ten", "hundred", "thousand",
                    "один", "два", "три", "четыре", "пять", "шесть", "семь", "восемь",
                    "девять", "десять", "сто", "тысяча",
                    "bir", "iki", "üç", "dört", "bäş", "alty", "ýedi", "sekiz", "dokuz", "on"
            };
        }

        void add_fn_maps(Engine& e) {
            e.fn_ru = {
                    {"и", "we"},
                    {"или", "ýa-da"},
                    {"но", "ýöne"},
                    {"а", "bolsa"},
                    {"в", "LOC"},
                    {"во", "LOC"},
                    {"на", "LOC"},
                    {"к", "DAT"},
                    {"ко", "DAT"},
                    {"с", "ABL"},
                    {"со", "ABL"},
                    {"у", "ýanynda"},
                    {"о", "ABOUT"},
                    {"об", "ABOUT"},
                    {"от", "ABL"},
                    {"до", "çenli"},
                    {"из", "ABL"},
                    {"за", "üçin"},
                    {"по", "boýunça"},
                    {"для", "FOR"},
                    {"без", "WITHOUT"},
                    {"при", "ýanynda"},
                    {"что", "näme"},
                    {"который", "haýsy"},
                    {"эта", "bu"},
                    {"этот", "bu"},
                    {"эти", "bular"},
                    {"это", "bu"},
                    {"же", "hem"},
                    {"тоже", "hem"},
                    {"также", "hem"},
                    {"уже", "eýýäm"},
                    {"ещё", "heniz"}
            };

            e.fn_en = {
                    {"and", "we"},
                    {"or", "ýa-da"},
                    {"but", "ýöne"},
                    {"this", "bu"},
                    {"that", "şol"},
                    {"these", "bular"},
                    {"those", "şolar"},
                    {"also", "hem"},
                    {"too", "hem"},
                    {"very", "örän"},
                    {"more", "has köp"},
                    {"most", "iň"},
                    {"here", "bu ýerde"},
                    {"there", "ol ýerde"},
                    {"because", "sebäbi"},
                    {"if", "eger"},
                    {"than", "-dan"},
                    {"for", "FOR"},
                    {"of", "GEN"},
                    {"to", "DAT"},
                    {"from", "ABL"},
                    {"in", "LOC"},
                    {"on", "LOC"},
                    {"at", "LOC"},
                    {"into", "DAT"},
                    {"onto", "DAT"},
                    {"without", "WITHOUT"},
                    {"with", "WITH"},
                    {"by", "BY"},
                    {"before", "BEFORE"},
                    {"after", "AFTER"},
                    {"why", "näme üçin"},
                    {"where", "nirede"},
                    {"what", "näme"},
                    {"who", "kim"},
                    {"when", "haçan"},
                    {"how", "nädip"},
                    {"which", "haýsy"}
            };

            e.fn_tr = {
                    {"ve", "we"},
                    {"veya", "ýa-da"},
                    {"ama", "ýöne"},
                    {"fakat", "ýöne"},
                    {"için", "FOR"},
                    {"ile", "WITH"},
                    {"bu", "bu"},
                    {"şu", "şu"},
                    {"o", "ol"},
                    {"çünkü", "sebäbi"},
                    {"eğer", "eger"},
                    {"gibi", "ýaly"}
            };

            e.pron_ru = {
                    {"я", "men"}, {"ты", "sen"}, {"он", "ol"}, {"она", "ol"}, {"оно", "ol"},
                    {"мы", "biz"}, {"вы", "siz"}, {"они", "olar"},
                    {"меня", "men"}, {"мне", "men"}, {"мной", "men"},
                    {"тебя", "sen"}, {"тебе", "sen"},
                    {"его", "ol"}, {"ему", "ol"},
                    {"её", "ol"}, {"ей", "ol"},
                    {"нас", "biz"}, {"нам", "biz"},
                    {"вас", "siz"}, {"вам", "siz"},
                    {"их", "olar"}, {"им", "olar"}
            };

            e.pron_en = {
                    {"i", "men"}, {"me", "men"},
                    {"you", "sen"},
                    {"he", "ol"}, {"him", "ol"},
                    {"she", "ol"}, {"her", "ol"},
                    {"it", "ol"},
                    {"we", "biz"}, {"us", "biz"},
                    {"they", "olar"}, {"them", "olar"}
            };

            e.pron_tr = {
                    {"ben", "men"}, {"beni", "men"}, {"bana", "men"},
                    {"sen", "sen"}, {"seni", "sen"}, {"sana", "sen"},
                    {"o", "ol"}, {"onu", "ol"}, {"ona", "ol"},
                    {"biz", "biz"}, {"bizi", "biz"}, {"bize", "biz"},
                    {"siz", "siz"}, {"sizi", "siz"}, {"size", "siz"},
                    {"onlar", "olar"}, {"onları", "olar"}, {"onlara", "olar"}
            };

            e.poss_det_ru = {
                    {"мой", "meniň"}, {"моя", "meniň"}, {"моё", "meniň"}, {"мои", "meniň"},
                    {"твой", "seniň"}, {"твоя", "seniň"}, {"твои", "seniň"},
                    {"его", "onuň"}, {"её", "onuň"},
                    {"наш", "biziň"}, {"наша", "biziň"}, {"наши", "biziň"},
                    {"ваш", "siziň"}, {"ваша", "siziň"}, {"ваши", "siziň"},
                    {"их", "olaryň"}
            };

            e.poss_det_en = {
                    {"my", "meniň"}, {"mine", "meniň"},
                    {"your", "siziň"}, {"yours", "siziň"},
                    {"his", "onuň"}, {"her", "onuň"}, {"its", "onuň"},
                    {"our", "biziň"}, {"ours", "biziň"},
                    {"their", "olaryň"}, {"theirs", "olaryň"}
            };

            e.poss_det_tr = {
                    {"benim", "meniň"},
                    {"senin", "seniň"},
                    {"onun", "onuň"},
                    {"bizim", "biziň"},
                    {"sizin", "siziň"},
                    {"onların", "olaryň"}
            };
        }

        struct Unit {
            Tag tag = T_WORD;
            std::string val;
            std::string raw;
            std::string post;
            int pron = -1;
            ECase cas = C_NOM;
            int possp = 0;
            bool plural = false;
            bool prop = false;
            bool rough = false;
            bool source_object = false;
            bool source_subject = false;
            bool source_adj = false;
            bool phrase = false;
            bool consumed = false;
            int source_index = -1;
        };

        bool is_source_subject_pron(int lang, const std::string& t) {
            if (lang == 0) {
                return t == "я" || t == "ты" || t == "он" || t == "она" || t == "оно" ||
                       t == "мы" || t == "вы" || t == "они";
            }
            if (lang == 1) {
                return t == "i" || t == "you" || t == "he" || t == "she" || t == "it" ||
                       t == "we" || t == "they";
            }
            return t == "ben" || t == "sen" || t == "o" || t == "biz" || t == "siz" || t == "onlar";
        }

        bool is_probably_verb_source(const std::string& t, int lang) {
            if (lang == 1) {
                return ends_with(t, "ing") || ends_with(t, "ed") ||
                       t == "go" || t == "come" || t == "read" || t == "write" || t == "see" ||
                       t == "know" || t == "want" || t == "like" || t == "love" || t == "make" ||
                       t == "take" || t == "give" || t == "get" || t == "say" || t == "tell" ||
                       t == "work" || t == "study" || t == "learn" || t == "speak" || t == "live" ||
                       t == "eat" || t == "drink" || t == "sleep" || t == "need";
            }
            if (lang == 0) {
                return ends_with(t, "ть") || ends_with(t, "ться") || ends_with(t, "ет") ||
                       ends_with(t, "ит") || ends_with(t, "ют") || ends_with(t, "ут") ||
                       ends_with(t, "ят") || ends_with(t, "ат") || ends_with(t, "ил") ||
                       ends_with(t, "ила") || ends_with(t, "или") || ends_with(t, "им") ||
                       ends_with(t, "ишь") || ends_with(t, "ешь");
            }
            return ends_with(t, "yor") || ends_with(t, "di") || ends_with(t, "dı") ||
                   ends_with(t, "ti") || ends_with(t, "tı") || ends_with(t, "acak") ||
                   ends_with(t, "ecek") || ends_with(t, "mak") || ends_with(t, "mek");
        }

        int explicit_person_from_source(int lang, const std::vector<std::string>& toks) {
            for (const auto& t : toks) {
                if (lang == 0) {
                    if (t == "я") return 0;
                    if (t == "ты") return 1;
                    if (t == "он" || t == "она" || t == "оно") return 2;
                    if (t == "мы") return 3;
                    if (t == "вы") return 4;
                    if (t == "они") return 5;
                } else if (lang == 1) {
                    if (t == "i") return 0;
                    if (t == "you") return 1;
                    if (t == "he" || t == "she" || t == "it") return 2;
                    if (t == "we") return 3;
                    if (t == "they") return 5;
                } else {
                    if (t == "ben") return 0;
                    if (t == "sen") return 1;
                    if (t == "o") return 2;
                    if (t == "biz") return 3;
                    if (t == "siz") return 4;
                    if (t == "onlar") return 5;
                }
            }
            return -1;
        }

        bool should_pluralize(size_t i, const std::vector<std::string>& toks,
                              const std::unordered_set<std::string>& numbers) {
            if (i >= toks.size()) return false;
            for (size_t j = 0; j < i; ++j) {
                if (numbers.count(toks[j]) || is_digits(toks[j])) return false;
            }
            return true;
        }

        int case_from_source(const std::string& src, int lang, bool object_hint) {
            if (lang == 1) return object_hint ? C_ACC : C_NOM;
            if (lang == 0) {
                static const std::unordered_set<std::string> acc = {
                        "меня", "тебя", "его", "её", "нас", "вас", "их"
                };
                static const std::unordered_set<std::string> dat = {
                        "мне", "тебе", "ему", "ей", "нам", "вам", "им"
                };
                if (dat.count(src)) return C_DAT;
                if (acc.count(src)) return C_ACC;
                return C_NOM;
            }
            return object_hint ? C_ACC : C_NOM;
        }

        bool source_is_modal(const std::string& t, int lang) {
            if (lang == 1) {
                return t == "can" || t == "could" || t == "should" || t == "must" ||
                       t == "may" || t == "might" || t == "want" || t == "need";
            }
            if (lang == 0) {
                return t == "можешь" || t == "может" || t == "могу" || t == "можно" ||
                       t == "должен" || t == "должна" || t == "должно" || t == "нужно" ||
                       t == "хочу" || t == "хочет";
            }
            return t == "yapabilirsin" || t == "gerek" || t == "zorunda" ||
                   t == "istiyorum" || t == "istiyor";
        }

        std::string modal_to_tk(const std::string& t) {
            if (t == "can" || t == "could" || t == "можешь" || t == "могу" || t == "может") return "bilmek";
            if (t == "must" || t == "должен" || t == "должна" || t == "должно" || t == "нужно") return "gerek";
            if (t == "should") return "gerek";
            if (t == "may" || t == "might") return "mümkin";
            if (t == "want" || t == "хочу" || t == "хочет") return "islemek";
            if (t == "need") return "gerek";
            return {};
        }

        struct LookupResult {
            bool found = false;
            std::string value;
            int score = 0;
            bool rough = false;
        };

        bool has_any(const std::vector<std::string>& toks, size_t i,
                     const std::initializer_list<const char*>& words, int radius) {
            if (toks.empty()) return false;
            size_t b = i > static_cast<size_t>(radius) ? i - static_cast<size_t>(radius) : 0;
            size_t e = std::min(toks.size(), i + static_cast<size_t>(radius) + 1);
            for (size_t j = b; j < e; ++j) {
                for (const char* w : words) {
                    if (toks[j] == w) return true;
                }
            }
            return false;
        }

        bool source_is_adverb(const std::string& t, int lang) {
            if (lang == 1) {
                return t == "quickly" || t == "slowly" || t == "carefully" || t == "usually" ||
                       t == "often" || t == "always" || t == "never" || t == "already" ||
                       t == "still" || t == "only" || t == "really" || t == "very" ||
                       t == "here" || t == "there" || t == "today" || t == "yesterday" ||
                       t == "tomorrow" || t == "now" || t == "soon";
            }
            if (lang == 0) {
                return t == "быстро" || t == "медленно" || t == "осторожно" || t == "обычно" ||
                       t == "часто" || t == "всегда" || t == "никогда" || t == "уже" ||
                       t == "ещё" || t == "только" || t == "действительно" || t == "очень" ||
                       t == "здесь" || t == "там" || t == "сегодня" || t == "вчера" ||
                       t == "завтра" || t == "сейчас" || t == "скоро";
            }
            return false;
        }

        bool source_is_adjective(const std::string& t, int lang) {
            if (lang == 1) {
                static const std::unordered_set<std::string> s = {
                        "good", "bad", "big", "small", "new", "old", "young", "high", "low",
                        "long", "short", "fast", "slow", "easy", "hard", "important",
                        "different", "same", "possible", "impossible", "interesting",
                        "beautiful", "strong", "weak", "right", "wrong", "black", "white",
                        "red", "green", "blue", "first", "last", "next", "main", "local",
                        "public", "private", "free", "full", "empty", "ready", "sure",
                        "happy", "sad", "open", "closed"
                };
                if (s.count(t)) return true;
                return ends_with(t, "ful") || ends_with(t, "less") || ends_with(t, "ous") ||
                       ends_with(t, "ive") || ends_with(t, "al") || ends_with(t, "ic") ||
                       ends_with(t, "able") || ends_with(t, "ible") || ends_with(t, "y");
            }
            if (lang == 0) {
                static const std::unordered_set<std::string> s = {
                        "хороший", "плохой", "большой", "маленький", "новый", "старый",
                        "молодой", "высокий", "низкий", "длинный", "короткий", "быстрый",
                        "медленный", "лёгкий", "легкий", "трудный", "важный", "разный",
                        "одинаковый", "возможный", "невозможный", "интересный", "красивый",
                        "сильный", "слабый", "правый", "левый", "неправильный", "чёрный",
                        "черный", "белый", "красный", "зелёный", "зеленый", "синий",
                        "первый", "последний", "следующий", "главный", "местный",
                        "общественный", "личный", "свободный", "полный", "пустой",
                        "готовый", "счастливый", "грустный", "открытый", "закрытый"
                };
                if (s.count(t)) return true;
                return ends_with(t, "ый") || ends_with(t, "ий") || ends_with(t, "ой") ||
                       ends_with(t, "ая") || ends_with(t, "яя") || ends_with(t, "ое") ||
                       ends_with(t, "ее") || ends_with(t, "ые") || ends_with(t, "ие");
            }
            return false;
        }

        bool source_irregular_verb(const std::string& t, int lang) {
            if (lang != 1) return false;
            static const std::unordered_set<std::string> s = {
                    "am", "is", "are", "was", "were", "be", "been", "being",
                    "go", "goes", "went", "gone", "come", "came",
                    "see", "saw", "seen", "know", "knew", "known",
                    "think", "thought", "take", "took", "taken",
                    "give", "gave", "given", "get", "got", "gotten",
                    "make", "made", "do", "did", "done", "have", "had", "has",
                    "say", "said", "tell", "told", "find", "found", "feel", "felt",
                    "leave", "left", "keep", "kept", "put", "bring", "brought",
                    "buy", "bought", "write", "wrote", "written", "read",
                    "speak", "spoke", "spoken", "eat", "ate", "eaten",
                    "drink", "drank", "drunk", "sleep", "slept", "run", "ran",
                    "begin", "began", "begun", "become", "became",
                    "understand", "understood", "work", "study", "learn", "want",
                    "need", "like", "love", "use", "live", "help", "try", "call",
                    "look", "watch", "play", "open", "close", "start", "finish", "stop"
            };
            return s.count(t) != 0;
        }

        std::string context_override(int lang, const std::vector<std::string>& toks, size_t i) {
            if (lang == 1) {
                const std::string& t = toks[i];

                if (t == "bank") {
                    if (has_any(toks, i, {"river", "sea", "lake", "water", "shore", "coast"}, 3)) return "kenar";
                    return "bank";
                }
                if (t == "spring") {
                    if (has_any(toks, i, {"season", "summer", "winter", "autumn", "fall", "flowers", "warm"}, 3)) return "ýaz";
                    if (has_any(toks, i, {"water", "river", "source", "well"}, 3)) return "çeşme";
                }
                if (t == "right") {
                    if (has_any(toks, i, {"turn", "direction", "left", "road", "side"}, 3)) return "sag";
                    return "dogry";
                }
                if (t == "light") {
                    if (has_any(toks, i, {"lamp", "sun", "dark", "room", "switch", "bright"}, 3)) return "yşyk";
                    if (has_any(toks, i, {"bag", "carry", "heavy", "weight"}, 3)) return "ýeňil";
                }
                if (t == "watch") {
                    if (has_any(toks, i, {"tv", "movie", "video", "game", "carefully"}, 3)) return "synlamak";
                    if (has_any(toks, i, {"time", "wrist", "hand"}, 3)) return "sagat";
                }
                if (t == "left") {
                    if (has_any(toks, i, {"turn", "direction", "right", "road", "side"}, 3)) return "çep";
                }
                if (t == "plant") {
                    if (has_any(toks, i, {"factory", "industry", "company", "production"}, 3)) return "zawod";
                    if (has_any(toks, i, {"tree", "flower", "garden", "soil", "water"}, 3)) return "ösümlik";
                }
                if (t == "mean" || t == "means") {
                    if (has_any(toks, i, {"average", "number", "value"}, 3)) return "ortaça";
                    if (has_any(toks, i, {"intend", "plan", "purpose"}, 3)) return "niýet";
                    return "aňlatmak";
                }
                if (t == "match") {
                    if (has_any(toks, i, {"game", "team", "football", "sport"}, 3)) return "oýun";
                    if (has_any(toks, i, {"fire", "candle", "light"}, 3)) return "kibrit";
                    return "gabat";
                }
                if (t == "case") {
                    if (has_any(toks, i, {"court", "law", "judge", "legal"}, 3)) return "iş";
                    if (has_any(toks, i, {"phone", "computer", "protect", "cover"}, 3)) return "gap";
                    return "ýagdaý";
                }
                if (t == "current") {
                    if (has_any(toks, i, {"electric", "electricity", "voltage", "circuit"}, 3)) return "tok";
                    return "häzirki";
                }
                if (t == "file") {
                    if (has_any(toks, i, {"document", "folder", "computer", "save", "open"}, 3)) return "faýl";
                }
            } else if (lang == 0) {
                const std::string& t = toks[i];

                if (t == "лук") {
                    if (has_any(toks, i, {"стрелять", "оружие", "стрела"}, 2)) return "ýaý";
                    return "sogan";
                }
                if (t == "ключ") {
                    if (has_any(toks, i, {"дверь", "замок", "открыть", "закрыть"}, 3)) return "açar";
                    if (has_any(toks, i, {"вода", "источник", "родник"}, 3)) return "çeşme";
                    return "açar";
                }
                if (t == "мир") {
                    if (has_any(toks, i, {"война", "страна", "люди", "согласие"}, 3)) return "parahatçylyk";
                    return "dünýä";
                }
                if (t == "ручка") {
                    if (has_any(toks, i, {"дверь", "двери", "открыть"}, 3)) return "tutawaç";
                    if (has_any(toks, i, {"писать", "тетрадь", "бумага"}, 3)) return "ruçka";
                }
                if (t == "коса") {
                    if (has_any(toks, i, {"волосы", "волос", "девушка"}, 3)) return "saç";
                    if (has_any(toks, i, {"трава", "поле", "сено"}, 3)) return "orak";
                }
                if (t == "свет") {
                    if (has_any(toks, i, {"лампа", "комната", "темно", "включить", "выключить"}, 3)) return "yşyk";
                    return "ýagty";
                }
                if (t == "правый" || t == "правую" || t == "правой") return "sag";
                if (t == "левый" || t == "левую" || t == "левой") return "çep";
            }
            return {};
        }

        LookupResult lookup_translation(const std::unordered_map<std::string, std::string>& wd,
                                        const std::string& tok, int lang,
                                        const std::unordered_map<std::string, std::string>* piv1,
                                        const std::unordered_map<std::string, std::string>* piv2) {
            LookupResult r;

            auto it = wd.find(tok);
            if (it != wd.end()) {
                r.found = true;
                r.value = it->second;
                r.score = 1000;
                return r;
            }

            std::vector<std::string> cs;
            if (lang == 0) cs = ru_stems(tok);
            else if (lang == 1) cs = en_stems(tok);
            else if (lang == 2) cs = tr_stems(tok);
            else cs = tk_stems(tok);

            int rank = 0;
            for (const auto& c : cs) {
                auto x = wd.find(c);
                if (x != wd.end()) {
                    r.found = true;
                    r.value = x->second;
                    r.score = 960 - rank * 8;
                    return r;
                }
                ++rank;
            }

            if (piv1 && piv2) {
                auto p1 = piv1->find(tok);
                if (p1 == piv1->end()) {
                    for (const auto& c : cs) {
                        auto q = piv1->find(c);
                        if (q != piv1->end()) {
                            p1 = q;
                            break;
                        }
                    }
                }
                if (p1 != piv1->end()) {
                    auto p2 = piv2->find(p1->second);
                    if (p2 != piv2->end()) {
                        r.found = true;
                        r.value = p2->second;
                        r.score = 780;
                        r.rough = true;
                        return r;
                    }
                }
            }

            if (tok.size() >= 4) {
                int best = 0;
                const std::string* bk = nullptr;
                for (const auto& kv : wd) {
                    size_t d1 = kv.first.size() > tok.size() ? kv.first.size() - tok.size() : tok.size() - kv.first.size();
                    if (d1 > 2) continue;
                    int d = lev_cap(tok, kv.first, 2);
                    if (d > 2) continue;
                    int mx = static_cast<int>(std::max(tok.size(), kv.first.size()));
                    if (!mx) continue;
                    int sc = 1000 - d * 1000 / mx;
                    if (sc > best) {
                        best = sc;
                        bk = &kv.first;
                    }
                }
                if (bk && best >= 800) {
                    r.found = true;
                    r.value = wd.find(*bk)->second;
                    r.score = best - 80;
                    r.rough = true;
                    return r;
                }
            }

            r.found = false;
            r.value = tok;
            r.score = 0;
            r.rough = true;
            return r;
        }

        std::string translate_phrase(const std::unordered_map<std::string, std::string>& ph,
                                     const std::vector<std::string>& toks, size_t i,
                                     size_t max_len, size_t& used) {
            size_t best_len = 0;
            std::string best;
            size_t limit = std::min(max_len, toks.size() - i);

            for (size_t len = limit; len >= 2; --len) {
                std::string k;
                for (size_t j = 0; j < len; ++j) {
                    if (j) k += ' ';
                    k += toks[i + j];
                }
                auto it = ph.find(k);
                if (it != ph.end()) {
                    best_len = len;
                    best = it->second;
                    break;
                }
                if (len == 2) break;
            }

            used = best_len;
            return best;
        }

        std::string make_converb(const std::string& inf) {
            if (inf.empty()) return inf;
            std::string stem = inf;
            if (ends_with(stem, "mak") || ends_with(stem, "mek")) stem = stem.substr(0, stem.size() - 3);
            if (stem.empty()) return inf;
            uint32_t lc = last_cp(stem);
            if (tk_vowel(lc)) return stem + "p";
            std::string v;
            enc_cp(v, harmony_v4(stem));
            return mutate(stem) + v + "p";
        }

        std::string make_necessitative(const std::string& inf, int person) {
            std::string stem = inf;
            if (ends_with(stem, "mak") || ends_with(stem, "mek")) stem = stem.substr(0, stem.size() - 3);
            std::string base = mutate(stem);
            std::string out = base + (word_back(stem) ? "maly" : "meli");
            if (person == 0) out += word_back(stem) ? "mýn" : "mi";
            else if (person == 1) out += word_back(stem) ? "syň" : "siň";
            else if (person == 3) out += word_back(stem) ? "s" : "s";
            else if (person == 4) out += word_back(stem) ? "syňyz" : "siňiz";
            else if (person == 5) out += word_back(stem) ? "lar" : "ler";
            return out;
        }

        std::string join_target(const std::vector<std::string>& v) {
            std::string r;
            for (const auto& x : v) {
                if (!x.empty()) {
                    if (!r.empty()) r += ' ';
                    r += x;
                }
            }
            return r;
        }

        bool is_service_token(const std::string& s) {
            return s == "ART" || s == "DEF" || s == "DAT" || s == "LOC" || s == "ABL" ||
                   s == "GEN" || s == "WITHOUT" || s == "WITH" || s == "FOR" || s == "BY" ||
                   s == "BEFORE" || s == "AFTER" || s == "ABOUT";
        }

        std::string pron_nom(int p) {
            static const char* nom[6] = {"men", "sen", "ol", "biz", "siz", "olar"};
            if (p < 0 || p > 5) p = 2;
            return nom[p];
        }

        std::string pron_case(int p, ECase c) {
            if (p < 0 || p > 5) p = 2;
            if (c == C_NOM) return pron_nom(p);

            static const char* gen[6] = {"meniň", "seniň", "onuň", "biziň", "siziň", "olaryň"};
            static const char* dat[6] = {"maňa", "saňa", "oňa", "bize", "size", "olara"};
            static const char* acc[6] = {"meni", "seni", "ony", "bizi", "sizi", "olary"};
            static const char* loc[6] = {"mende", "sende", "onda", "bizde", "sizde", "olarda"};
            static const char* abl[6] = {"menden", "senden", "ondan", "bizden", "sizden", "olardan"};

            switch (c) {
                case C_GEN: return gen[p];
                case C_DAT: return dat[p];
                case C_ACC: return acc[p];
                case C_LOC: return loc[p];
                case C_ABL: return abl[p];
                default: return pron_nom(p);
            }
        }

        bool resolve_ctx(const std::unordered_map<std::string, std::string>& wd,
                         const std::unordered_map<std::string, std::vector<Candidate>>* cand,
                         const std::unordered_map<std::string, std::vector<Candidate>>* rev,
                         const std::string& tok, int lang,
                         const std::vector<std::string>& toks, size_t idx,
                         const std::unordered_set<std::string>& stop,
                         std::string& res) {
            std::string direct;
            auto wit = wd.find(tok);
            if (wit != wd.end()) direct = wit->second;

            std::string chosen_trans;
            int64_t chosen_score = -1;

            auto consider_key = [&](const std::string& key, int base) {
                if (!cand) return;
                auto cit = cand->find(key);
                if (cit == cand->end()) return;

                for (const auto& c : cit->second) {
                    int64_t score = static_cast<int64_t>(base) +
                                    static_cast<int64_t>(c.count) * 25 +
                                    static_cast<int64_t>(c.score) / 20;

                    if (rev) {
                        auto rit = rev->find(c.translation);
                        if (rit != rev->end()) {
                            size_t b = idx > 4 ? idx - 4 : 0;
                            size_t e = std::min(toks.size(), idx + 5);
                            for (size_t j = b; j < e; ++j) {
                                if (j == idx) continue;
                                const std::string& o = toks[j];
                                if (o.empty() || stop.count(o)) continue;

                                for (const auto& rc : rit->second) {
                                    if (rc.translation == o) {
                                        score += static_cast<int64_t>(rc.count) * 40 +
                                                 static_cast<int64_t>(rc.score) / 50;
                                        break;
                                    }
                                }

                                auto ow = wd.find(o);
                                if (ow != wd.end() && ow->second == c.translation) score += 1200;
                            }
                        }
                    }

                    bool cand_verb = ends_with(c.translation, "mak") ||
                                     ends_with(c.translation, "mek") ||
                                     g.tk_verbs.count(c.translation) != 0;

                    if ((is_probably_verb_source(tok, lang) || source_irregular_verb(tok, lang)) && cand_verb) {
                        score += 5000;
                    }
                    if (source_is_adjective(tok, lang) && !cand_verb) score += 800;
                    if (source_is_adverb(tok, lang)) score += 300;
                    if (!direct.empty() && c.translation == direct) score += 1500;

                    if (score > chosen_score) {
                        chosen_score = score;
                        chosen_trans = c.translation;
                    }
                }
            };

            consider_key(tok, 10000);

            if (chosen_score < 9000) {
                std::vector<std::string> stems;
                if (lang == 0) stems = ru_stems(tok);
                else if (lang == 1) stems = en_stems(tok);
                else if (lang == 2) stems = tr_stems(tok);
                else stems = tk_stems(tok);

                int rank = 0;
                for (const auto& st : stems) {
                    if (st == tok) continue;
                    consider_key(st, 8200 - rank * 120);
                    if (direct.empty()) {
                        auto w2 = wd.find(st);
                        if (w2 != wd.end()) direct = w2->second;
                    }
                    ++rank;
                }
            }

            if (!chosen_trans.empty() && (direct.empty() || chosen_score >= 10000)) {
                res = chosen_trans;
                return true;
            }

            if (!direct.empty()) {
                res = direct;
                return true;
            }

            if (!chosen_trans.empty()) {
                res = chosen_trans;
                return true;
            }

            return false;
        }

        void add_builtin_entry(std::unordered_map<std::string, std::string>& best,
                               std::unordered_map<std::string, std::vector<Candidate>>& cand,
                               const char* s, const char* t) {
            if (best.find(s) == best.end()) best[s] = t;

            auto it = cand.find(s);
            Candidate c;
            c.translation = t;
            c.count = 50;
            c.score = 50000;

            if (it == cand.end()) {
                cand[s].push_back(std::move(c));
            } else {
                bool has = false;
                for (auto& x : it->second) {
                    if (x.translation == t) {
                        has = true;
                        if (x.count < 50) x.count = 50;
                        if (x.score < 50000) x.score = 50000;
                        break;
                    }
                }
                if (!has) it->second.insert(it->second.begin(), std::move(c));
            }
        }

        void add_builtins(Engine& e) {
            struct Pair {
                const char* s;
                const char* t;
            };

            static const Pair ru[] = {
                    {"я", "men"}, {"ты", "sen"}, {"он", "ol"}, {"она", "ol"}, {"оно", "ol"},
                    {"мы", "biz"}, {"вы", "siz"}, {"они", "olar"},
                    {"да", "hawa"}, {"нет", "ýok"},
                    {"хорошо", "gowy"}, {"плохо", "erbet"},
                    {"вода", "suw"}, {"хлеб", "çörek"}, {"дом", "öý"}, {"книга", "kitap"},
                    {"школа", "mekdep"}, {"язык", "dil"}, {"слово", "söz"},
                    {"идти", "gitmek"}, {"приходить", "gelmek"}, {"видеть", "görmek"},
                    {"знать", "bilmek"}, {"хотеть", "islemek"}, {"делать", "etmek"},
                    {"сказать", "diýmek"}, {"дать", "bermek"}, {"взять", "almak"},
                    {"работать", "işlemek"}, {"жить", "ýaşamak"}, {"пить", "içmek"},
                    {"читать", "okamak"}, {"писать", "ýazmak"}, {"спать", "uklamak"}
            };

            static const Pair en[] = {
                    {"i", "men"}, {"you", "sen"}, {"he", "ol"}, {"she", "ol"}, {"it", "ol"},
                    {"we", "biz"}, {"they", "olar"},
                    {"yes", "hawa"}, {"no", "ýok"},
                    {"good", "gowy"}, {"bad", "erbet"},
                    {"water", "suw"}, {"bread", "çörek"}, {"house", "öý"}, {"book", "kitap"},
                    {"school", "mekdep"}, {"language", "dil"}, {"word", "söz"},
                    {"go", "gitmek"}, {"come", "gelmek"}, {"see", "görmek"},
                    {"know", "bilmek"}, {"want", "islemek"}, {"say", "diýmek"},
                    {"give", "bermek"}, {"take", "almak"}, {"work", "işlemek"},
                    {"live", "ýaşamak"}, {"eat", "iýmek"}, {"drink", "içmek"},
                    {"read", "okamak"}, {"write", "ýazmak"}, {"sleep", "uklamak"}
            };

            for (const Pair& p : ru) {
                add_builtin_entry(e.w_ru_to_tk, e.cand_ru_tk, p.s, p.t);
                if (ends_with(p.t, "mak") || ends_with(p.t, "mek")) e.tk_verbs.insert(p.t);
            }

            for (const Pair& p : en) {
                add_builtin_entry(e.w_en_to_tk, e.cand_en_tk, p.s, p.t);
                if (ends_with(p.t, "mak") || ends_with(p.t, "mek")) e.tk_verbs.insert(p.t);
            }
        }

        void build_verb_stems(Engine& e) {
            e.tk_verb_stems.clear();
            for (const auto& v : e.tk_verbs) {
                if (ends_with(v, "mak") || ends_with(v, "mek")) {
                    e.tk_verb_stems.insert(v.substr(0, v.size() - 3));
                } else {
                    e.tk_verb_stems.insert(v);
                }
            }
            for (const auto& kv : irr_stems()) {
                e.tk_verb_stems.insert(kv.second);
            }
        }

    }

    int32_t mt_load(int32_t n, const char** ru, const char** en, const char** tk, const char** tr) {
        std::lock_guard<std::mutex> lk(g.load_mu);
        if (g.loaded.load()) return 0;

        auto t0 = std::chrono::steady_clock::now();
        Engine e;

        init_sets(e);
        add_fn_maps(e);

        std::unordered_map<std::string, std::unordered_map<std::string, int32_t>>
                cooc_ru_tk, cooc_en_tk, cooc_tr_tk,
                cooc_tk_en, cooc_tk_ru, cooc_tk_tr;

        std::unordered_map<std::string, int32_t>
                tot_ru, tot_en, tot_tr, tot_tk_en, tot_tk_ru, tot_tk_tr;

        if (n > 0) {
            const size_t est = static_cast<size_t>(n);
            e.ph_to_tk_ru.reserve(est);
            e.ph_to_tk_en.reserve(est);
            e.ph_to_tk_tr.reserve(est);
            e.ph_from_tk_en.reserve(est);
            e.ph_from_tk_ru.reserve(est);
            e.ph_from_tk_tr.reserve(est);
            e.keys_to_tk_ru.reserve(est);
            e.keys_to_tk_en.reserve(est);
            e.keys_to_tk_tr.reserve(est);
            e.keys_from_tk_en.reserve(est);
            e.keys_from_tk_ru.reserve(est);
            e.keys_from_tk_tr.reserve(est);
        }

        for (int32_t i = 0; i < n; ++i) {
            if (!tk[i]) continue;

            const std::string kt = norm_key(tk[i]);
            if (kt.empty()) continue;

            if (ru[i]) {
                const std::string kr = norm_key(ru[i]);
                if (!kr.empty()) {
                    if (!e.ph_to_tk_ru.count(kr)) {
                        e.ph_to_tk_ru[kr] = tk[i];
                        e.keys_to_tk_ru.push_back(kr);
                    }
                    if (!e.ph_from_tk_ru.count(kt)) {
                        e.ph_from_tk_ru[kt] = ru[i];
                        e.keys_from_tk_ru.push_back(kt);
                    }
                }
            }

            if (en[i]) {
                const std::string ke = norm_key(en[i]);
                if (!ke.empty()) {
                    if (!e.ph_to_tk_en.count(ke)) {
                        e.ph_to_tk_en[ke] = tk[i];
                        e.keys_to_tk_en.push_back(ke);
                    }
                    if (!e.ph_from_tk_en.count(kt)) {
                        e.ph_from_tk_en[kt] = en[i];
                        e.keys_from_tk_en.push_back(kt);
                    }
                }
            }

            if (tr[i]) {
                const std::string ktr = norm_key(tr[i]);
                if (!ktr.empty()) {
                    if (!e.ph_to_tk_tr.count(ktr)) {
                        e.ph_to_tk_tr[ktr] = tk[i];
                        e.keys_to_tk_tr.push_back(ktr);
                    }
                    if (!e.ph_from_tk_tr.count(kt)) {
                        e.ph_from_tk_tr[kt] = tr[i];
                        e.keys_from_tk_tr.push_back(kt);
                    }
                }
            }

            auto tt = tokenize_low(tk[i]);
            if (tt.empty()) continue;

            for (const auto& t : tt) {
                if (ends_with(t, "mak") || ends_with(t, "mek")) {
                    e.tk_verbs.insert(t);
                } else {
                    std::string inf;
                    int p;
                    bool negv;
                    ETense tv;
                    if (parse_verb_form(t, inf, p, negv, tv)) {
                        e.tk_verbs.insert(inf);
                    }
                }
            }

            auto feed = [&](const char* src_raw,
                            std::unordered_map<std::string, std::unordered_map<std::string, int32_t>>& fwd,
                            std::unordered_map<std::string, std::unordered_map<std::string, int32_t>>& rev,
                            std::unordered_map<std::string, int32_t>& tf,
                            std::unordered_map<std::string, int32_t>& trv) {
                if (!src_raw) return;
                auto st = tokenize_low(src_raw);
                if (st.empty()) return;

                if (st.size() == 1) {
                    std::string joined = join_target(tt);
                    fwd[st[0]][joined] += 16;
                    tf[st[0]] += 16;
                    for (const auto& x : tt) {
                        rev[x][st[0]] += 16;
                        trv[x] += 16;
                    }
                } else {
                    for (const auto& s : st) {
                        if (s.size() <= 1) continue;
                        tf[s] += 1;
                        for (const auto& x : tt) {
                            fwd[s][x] += 1;
                            rev[x][s] += 1;
                            trv[x] += 1;
                        }
                    }
                }
            };

            feed(ru[i], cooc_ru_tk, cooc_tk_ru, tot_ru, tot_tk_ru);
            feed(en[i], cooc_en_tk, cooc_tk_en, tot_en, tot_tk_en);
            feed(tr[i], cooc_tr_tk, cooc_tk_tr, tot_tr, tot_tk_tr);

            std::vector<std::string> rr, rw, ee, ew, ttk, tw;
            if (ru[i]) tokenize2(ru[i], rr, rw);
            if (en[i]) tokenize2(en[i], ee, ew);
            if (tr[i]) tokenize2(tr[i], ttk, tw);

            if (rr.size() == 1 && ee.size() == 1) {
                if (!e.piv_ru_en.count(rr[0])) e.piv_ru_en[rr[0]] = ee[0];
                if (!e.piv_en_ru.count(ee[0])) e.piv_en_ru[ee[0]] = rr[0];
            }

            if (ttk.size() == 1 && ee.size() == 1) {
                if (!e.piv_tr_en.count(ttk[0])) e.piv_tr_en[ttk[0]] = ee[0];
                if (!e.piv_en_tr.count(ee[0])) e.piv_en_tr[ee[0]] = ttk[0];
            }
        }

        build_candidates(cooc_ru_tk, tot_ru, tot_tk_ru, e.stop_ru, e.stop_tk, e.w_ru_to_tk, e.cand_ru_tk);
        build_candidates(cooc_en_tk, tot_en, tot_tk_en, e.stop_en, e.stop_tk, e.w_en_to_tk, e.cand_en_tk);
        build_candidates(cooc_tr_tk, tot_tr, tot_tk_tr, e.stop_tr, e.stop_tk, e.w_tr_to_tk, e.cand_tr_tk);

        build_candidates(cooc_tk_ru, tot_tk_ru, tot_ru, e.stop_tk, e.stop_ru, e.w_tk_to_ru, e.cand_tk_ru);
        build_candidates(cooc_tk_en, tot_tk_en, tot_en, e.stop_tk, e.stop_en, e.w_tk_to_en, e.cand_tk_en);
        build_candidates(cooc_tk_tr, tot_tk_tr, tot_tr, e.stop_tk, e.stop_tr, e.w_tk_to_tr, e.cand_tk_tr);

        add_builtins(e);
        build_verb_stems(e);

        g.ph_to_tk_ru = std::move(e.ph_to_tk_ru);
        g.ph_to_tk_en = std::move(e.ph_to_tk_en);
        g.ph_to_tk_tr = std::move(e.ph_to_tk_tr);
        g.ph_from_tk_en = std::move(e.ph_from_tk_en);
        g.ph_from_tk_ru = std::move(e.ph_from_tk_ru);
        g.ph_from_tk_tr = std::move(e.ph_from_tk_tr);

        g.keys_to_tk_ru = std::move(e.keys_to_tk_ru);
        g.keys_to_tk_en = std::move(e.keys_to_tk_en);
        g.keys_to_tk_tr = std::move(e.keys_to_tk_tr);
        g.keys_from_tk_en = std::move(e.keys_from_tk_en);
        g.keys_from_tk_ru = std::move(e.keys_from_tk_ru);
        g.keys_from_tk_tr = std::move(e.keys_from_tk_tr);

        g.w_ru_to_tk = std::move(e.w_ru_to_tk);
        g.w_en_to_tk = std::move(e.w_en_to_tk);
        g.w_tr_to_tk = std::move(e.w_tr_to_tk);
        g.w_tk_to_en = std::move(e.w_tk_to_en);
        g.w_tk_to_ru = std::move(e.w_tk_to_ru);
        g.w_tk_to_tr = std::move(e.w_tk_to_tr);

        g.cand_ru_tk = std::move(e.cand_ru_tk);
        g.cand_en_tk = std::move(e.cand_en_tk);
        g.cand_tr_tk = std::move(e.cand_tr_tk);
        g.cand_tk_ru = std::move(e.cand_tk_ru);
        g.cand_tk_en = std::move(e.cand_tk_en);
        g.cand_tk_tr = std::move(e.cand_tk_tr);

        g.piv_ru_en = std::move(e.piv_ru_en);
        g.piv_en_ru = std::move(e.piv_en_ru);
        g.piv_tr_en = std::move(e.piv_tr_en);
        g.piv_en_tr = std::move(e.piv_en_tr);

        g.stop_ru = std::move(e.stop_ru);
        g.stop_en = std::move(e.stop_en);
        g.stop_tr = std::move(e.stop_tr);
        g.stop_tk = std::move(e.stop_tk);

        g.neg_ru = std::move(e.neg_ru);
        g.neg_en = std::move(e.neg_en);
        g.neg_tr = std::move(e.neg_tr);

        g.q_words = std::move(e.q_words);
        g.motion = std::move(e.motion);
        g.past_adv = std::move(e.past_adv);
        g.fut_adv = std::move(e.fut_adv);
        g.without_pre = std::move(e.without_pre);
        g.poss_pron = std::move(e.poss_pron);
        g.number_words = std::move(e.number_words);

        g.fn_ru = std::move(e.fn_ru);
        g.fn_en = std::move(e.fn_en);
        g.fn_tr = std::move(e.fn_tr);

        g.pron_ru = std::move(e.pron_ru);
        g.pron_en = std::move(e.pron_en);
        g.pron_tr = std::move(e.pron_tr);

        g.poss_det_ru = std::move(e.poss_det_ru);
        g.poss_det_en = std::move(e.poss_det_en);
        g.poss_det_tr = std::move(e.poss_det_tr);

        g.tk_verbs = std::move(e.tk_verbs);
        g.tk_verb_stems = std::move(e.tk_verb_stems);

        g.loaded.store(true);

        auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::steady_clock::now() - t0).count();

        MT_LOG("MONSTER load n=%d ph=%zu/%zu/%zu piv=%zu/%zu verbs=%zu in %lld ms",
               static_cast<int>(n),
               g.ph_to_tk_ru.size(),
               g.ph_to_tk_en.size(),
               g.ph_to_tk_tr.size(),
               g.piv_ru_en.size(),
               g.piv_tr_en.size(),
               g.tk_verbs.size(),
               static_cast<long long>(ms));

        return 0;
    }

    int32_t mt_translate(const char* text, const char* from, const char* to,
                         char* out, int32_t out_sz, int32_t* quality) {
        auto t0 = std::chrono::steady_clock::now();

        if (!g.loaded.load() || !text || !from || !to || !out || out_sz <= 0) return -1;
        if (quality) *quality = 0;

        const bool to_tk = std::strcmp(to, "tk") == 0;
        const bool from_tk = std::strcmp(from, "tk") == 0;
        const bool ru = std::strcmp(from, "ru") == 0;
        const bool en = std::strcmp(from, "en") == 0;
        const bool tr = std::strcmp(from, "tr") == 0;
        const int lang = ru ? 0 : (en ? 1 : (tr ? 2 : 3));

        const std::unordered_map<std::string, std::string>* ph = nullptr;
        const std::vector<std::string>* keys = nullptr;
        const std::unordered_map<std::string, std::string>* wd = nullptr;
        const std::unordered_map<std::string, std::string>* piv1 = nullptr;
        const std::unordered_map<std::string, std::string>* piv2 = nullptr;

        const std::unordered_map<std::string, std::vector<Candidate>>* cand = nullptr;
        const std::unordered_map<std::string, std::vector<Candidate>>* rev = nullptr;
        const std::unordered_set<std::string>* stop_src = nullptr;

        if (to_tk) {
            if (ru) {
                ph = &g.ph_to_tk_ru;
                keys = &g.keys_to_tk_ru;
                wd = &g.w_ru_to_tk;
                piv1 = &g.piv_ru_en;
                piv2 = &g.w_en_to_tk;
                cand = &g.cand_ru_tk;
                rev = &g.cand_tk_ru;
                stop_src = &g.stop_ru;
            } else if (tr) {
                ph = &g.ph_to_tk_tr;
                keys = &g.keys_to_tk_tr;
                wd = &g.w_tr_to_tk;
                piv1 = &g.piv_tr_en;
                piv2 = &g.w_en_to_tk;
                cand = &g.cand_tr_tk;
                rev = &g.cand_tk_tr;
                stop_src = &g.stop_tr;
            } else {
                ph = &g.ph_to_tk_en;
                keys = &g.keys_to_tk_en;
                wd = &g.w_en_to_tk;
                piv1 = &g.piv_en_ru;
                piv2 = &g.w_ru_to_tk;
                cand = &g.cand_en_tk;
                rev = &g.cand_tk_en;
                stop_src = &g.stop_en;
            }
        } else if (from_tk) {
            if (std::strcmp(to, "ru") == 0) {
                ph = &g.ph_from_tk_ru;
                keys = &g.keys_from_tk_ru;
                wd = &g.w_tk_to_ru;
                cand = &g.cand_tk_ru;
                rev = &g.cand_ru_tk;
                stop_src = &g.stop_tk;
            } else if (std::strcmp(to, "tr") == 0) {
                ph = &g.ph_from_tk_tr;
                keys = &g.keys_from_tk_tr;
                wd = &g.w_tk_to_tr;
                cand = &g.cand_tk_tr;
                rev = &g.cand_tr_tk;
                stop_src = &g.stop_tk;
            } else {
                ph = &g.ph_from_tk_en;
                keys = &g.keys_from_tk_en;
                wd = &g.w_tk_to_en;
                cand = &g.cand_tk_en;
                rev = &g.cand_en_tk;
                stop_src = &g.stop_tk;
            }
        }

        if (!ph || !keys || !wd || !stop_src) return -1;

        const std::string src_text = prepare_input(text);
        const std::string k = norm_key(src_text);
        if (k.empty()) return -1;

        auto put = [&](const std::string& s, int q) {
            if (static_cast<int32_t>(s.size()) + 1 > out_sz) return false;
            std::memcpy(out, s.data(), s.size());
            out[s.size()] = '\0';
            if (quality) *quality = q;
            return true;
        };

        if (auto it = ph->find(k); it != ph->end()) {
            std::string exact = it->second;
            if (to_tk) {
                cap_first(exact);
                restore_punctuation(text, exact);
            }
            if (!put(exact, 1)) return -1;
            return static_cast<int32_t>(exact.size());
        }

        const int cap = std::min(4, static_cast<int>(k.size() / 5) + 2);
        int best = 0;
        const std::string* best_key = nullptr;

        for (const auto& key : *keys) {
            size_t d1 = key.size() > k.size() ? key.size() - k.size() : k.size() - key.size();
            if (static_cast<int>(d1) > cap) continue;
            int d = lev_cap(k, key, cap);
            if (d > cap) continue;
            int mx = static_cast<int>(std::max(key.size(), k.size()));
            if (!mx) continue;
            int score = 1000 - d * 1000 / mx;
            if (score > best) {
                best = score;
                best_key = &key;
            }
        }

        if (best >= 940 && best_key) {
            auto i = ph->find(*best_key);
            if (i != ph->end()) {
                std::string exact = i->second;
                if (to_tk) {
                    cap_first(exact);
                    restore_punctuation(text, exact);
                }
                if (put(exact, 2)) return static_cast<int32_t>(exact.size());
            }
        }

        std::vector<std::string> toks, raws;
        tokenize2(src_text, toks, raws);
        if (toks.empty()) return -1;

        if (!to_tk) {
            std::vector<std::string> subj, obj, other;
            std::string verb;
            int rough = 0;
            bool neg = false;

            for (size_t i = 0; i < toks.size(); ++i) {
                const std::string& t = toks[i];

                if ((lang == 0 && g.neg_ru.count(t)) ||
                    (lang == 1 && g.neg_en.count(t)) ||
                    (lang == 2 && g.neg_tr.count(t))) {
                    neg = true;
                    continue;
                }

                if (auto av = adv_map().find(t); av != adv_map().end()) {
                    other.push_back(av->second);
                    continue;
                }

                if (lang <= 2) {
                    const auto& pm = lang == 0 ? g.pron_ru : (lang == 1 ? g.pron_en : g.pron_tr);
                    auto pit = pm.find(t);
                    if (pit != pm.end()) {
                        subj.push_back(pit->second);
                        continue;
                    }
                }

                std::string stem;
                ECase cas = C_NOM;
                bool split = tk_split_case(t, stem, cas);

                std::string v;
                LookupResult lr;
                if (split) lr = lookup_translation(*wd, stem, 3, nullptr, nullptr);
                if (!lr.found) lr = lookup_translation(*wd, t, 3, nullptr, nullptr);

                v = lr.value;
                if (!lr.found) rough++;

                if (!verb.empty()) {
                    if (cas == C_DAT || cas == C_ACC) obj.push_back(v);
                    else other.push_back(v);
                } else {
                    std::string inf;
                    int vp = -1;
                    bool vn = false;
                    ETense vt = T_PRES;

                    bool isverb = ends_with(t, "mak") || ends_with(t, "mek") ||
                                  parse_verb_form(t, inf, vp, vn, vt);

                    if (isverb) {
                        if (parse_verb_form(t, inf, vp, vn, vt)) {
                            std::string vm;
                            if (find_word(*wd, inf, 3, vm)) v = vm;
                            else v = inf;
                        }
                        if (verb.empty()) verb = v;
                        else other.push_back(v);
                    } else if (subj.empty()) {
                        subj.push_back(v);
                    } else {
                        obj.push_back(v);
                    }
                }
            }

            if (neg) other.insert(other.begin(), std::strcmp(to, "ru") == 0 ? "не" : "not");

            std::vector<std::string> rv;
            rv.insert(rv.end(), subj.begin(), subj.end());
            if (!verb.empty()) rv.push_back(verb);
            rv.insert(rv.end(), obj.begin(), obj.end());
            rv.insert(rv.end(), other.begin(), other.end());

            std::string rr = join_target(rv);
            if (rr.empty()) return -1;

            cap_first(rr);
            restore_punctuation(text, rr);

            if (!put(rr, rough ? 4 : 3)) return -1;
            return static_cast<int32_t>(rr.size());
        }

        const auto* fn = lang == 0 ? &g.fn_ru : (lang == 1 ? &g.fn_en : &g.fn_tr);
        const auto* pr = lang == 0 ? &g.pron_ru : (lang == 1 ? &g.pron_en : &g.pron_tr);
        const auto* pd = lang == 0 ? &g.poss_det_ru : (lang == 1 ? &g.poss_det_en : &g.poss_det_tr);

        bool quest = src_text.find('?') != std::string::npos;
        bool question_word = false;
        bool neg = false;
        bool future_def_flag = false;
        ETense tense = T_PRES;

        int source_person = explicit_person_from_source(lang, toks);
        int source_verb_index = -1;
        int main_verb_count = 0;

        bool has_progressive = false;
        bool has_perfect = false;
        bool has_modal = false;
        bool copula_present = false;
        int copula_source_index = -1;

        std::string modal_word;
        std::unordered_set<size_t> skip;
        std::unordered_set<size_t> definite_idx;

        for (size_t i = 0; i < toks.size(); ++i) {
            const std::string& t = toks[i];

            if (g.q_words.count(t)) {
                quest = true;
                question_word = true;
            }

            if ((lang == 0 && g.neg_ru.count(t)) ||
                (lang == 1 && g.neg_en.count(t)) ||
                (lang == 2 && g.neg_tr.count(t))) {
                neg = true;
            }

            if (g.past_adv.count(t)) tense = T_PAST;
            if (g.fut_adv.count(t)) tense = T_FUT;

            if (lang == 1) {
                if (t == "will" || t == "shall") {
                    tense = T_FUT;
                    future_def_flag = true;
                    skip.insert(i);
                }
                if (t == "would") {
                    tense = T_FUT;
                    skip.insert(i);
                }
                if (t == "did") {
                    tense = T_PAST;
                    skip.insert(i);
                }
                if (t == "do" || t == "does") skip.insert(i);
                if (t == "had") {
                    tense = T_PAST;
                    has_perfect = true;
                    skip.insert(i);
                }
                if (t == "have" || t == "has") {
                    has_perfect = true;
                    skip.insert(i);
                }
                if (t == "was" || t == "were") {
                    tense = T_PAST;
                    if (i + 1 < toks.size() && ends_with(toks[i + 1], "ing")) has_progressive = true;
                    else copula_present = true;
                    copula_source_index = static_cast<int>(i);
                    skip.insert(i);
                }
                if (t == "am" || t == "is" || t == "are") {
                    if (i + 1 < toks.size() && ends_with(toks[i + 1], "ing")) has_progressive = true;
                    else copula_present = true;
                    copula_source_index = static_cast<int>(i);
                    skip.insert(i);
                }
                if (t == "be" || t == "been" || t == "being") skip.insert(i);
                if (t == "going" && i + 1 < toks.size() && toks[i + 1] == "to") {
                    tense = T_FUT;
                    skip.insert(i);
                    skip.insert(i + 1);
                    future_def_flag = true;
                }
                if (t == "not") neg = true;
                if (t == "the" && i + 1 < toks.size()) definite_idx.insert(i + 1);
            } else if (lang == 0) {
                if (t == "буду" || t == "будешь" || t == "будет" ||
                    t == "будем" || t == "будете" || t == "будут") {
                    tense = T_FUT;
                    future_def_flag = true;
                    skip.insert(i);
                }
                if (t == "бы") skip.insert(i);
                if (t == "был" || t == "была" || t == "было" || t == "были") tense = T_PAST;
            }

            if (source_is_modal(t, lang)) {
                has_modal = true;
                modal_word = t;
            }
        }

        std::vector<Unit> units;
        units.reserve(toks.size());

        std::vector<bool> consumed_src(toks.size(), false);
        int rough_count = 0;
        bool saw_main_verb = false;

        for (size_t i = 0; i < toks.size(); ++i) {
            if (skip.count(i) || consumed_src[i]) continue;

            size_t used = 0;
            std::string phr = translate_phrase(*ph, toks, i, 6, used);

            if (!phr.empty() && used >= 2) {
                Unit u;
                u.tag = T_WORD;
                u.val = lower_str(phr);
                u.raw = raws[i];
                u.source_index = static_cast<int>(i);
                u.phrase = true;

                for (size_t j = 0; j < used; ++j) consumed_src[i + j] = true;

                if (i > 0) {
                    const std::string& p = toks[i - 1];
                    if (p == "to" || p == "к") u.cas = C_DAT;
                    else if (p == "in" || p == "on" || p == "at" || p == "в" || p == "на") u.cas = C_LOC;
                    else if (p == "from" || p == "из" || p == "от" || p == "с") u.cas = C_ABL;
                    else if (p == "of") u.cas = C_GEN;
                }

                units.push_back(std::move(u));
                continue;
            }

            const std::string& t = toks[i];
            Unit u;
            u.raw = raws[i];
            u.source_index = static_cast<int>(i);
            u.val = t;

            auto pit = pr->find(t);
            if (pit != pr->end()) {
                u.tag = T_PRON;
                u.val = pit->second;

                auto pidx = pron_idx().find(u.val);
                if (pidx != pron_idx().end()) u.pron = pidx->second;

                u.source_subject = is_source_subject_pron(lang, t);
                if (lang == 1 && t == "you") {
                    u.source_subject = (source_verb_index < 0 || static_cast<int>(i) < source_verb_index);
                }

                u.source_object = !u.source_subject;
                u.cas = static_cast<ECase>(case_from_source(t, lang, u.source_object));

                units.push_back(std::move(u));
                continue;
            }

            auto pdit = pd->find(t);
            if (pdit != pd->end()) {
                u.tag = T_STOP;
                u.val = pdit->second;
                units.push_back(std::move(u));
                continue;
            }

            if ((lang == 0 && t == "не") || (lang == 1 && t == "not") || (lang == 2 && t == "değil")) {
                neg = true;
                continue;
            }

            if (lang == 1 && (t == "a" || t == "an" || t == "the")) {
                u.tag = T_STOP;
                u.val = (t == "the" ? "DEF" : "ART");
                units.push_back(std::move(u));
                continue;
            }

            if (auto av = adv_map().find(t); av != adv_map().end()) {
                u.tag = T_WORD;
                u.val = av->second;
                units.push_back(std::move(u));
                continue;
            }

            if (is_digits(t)) {
                u.tag = T_WORD;
                u.val = t;
                units.push_back(std::move(u));
                continue;
            }

            if (fn->count(t)) {
                const std::string& fv = fn->at(t);
                u.tag = T_STOP;
                u.val = fv;
                units.push_back(std::move(u));
                continue;
            }

            if (source_is_modal(t, lang)) {
                std::string mv = modal_to_tk(t);
                if (!mv.empty()) {
                    u.tag = T_MODAL;
                    u.val = mv;
                    units.push_back(std::move(u));
                    continue;
                }
            }

            std::string mapped = context_override(lang, toks, i);
            bool found = !mapped.empty();
            bool rough = false;

            if (!found) {
                if (resolve_ctx(*wd, cand, rev, t, lang, toks, i, *stop_src, mapped)) {
                    found = true;
                }
            }

            if (!found) {
                LookupResult lr = lookup_translation(*wd, t, lang, piv1, piv2);
                mapped = lr.value;
                found = lr.found;
                rough = lr.rough;
            }

            ECase cas = C_NOM;
            if (!found && lang == 2) {
                std::string st;
                if (tr_split_case(t, st, cas)) {
                    LookupResult lr = lookup_translation(*wd, st, lang, nullptr, nullptr);
                    if (lr.found) {
                        mapped = lr.value;
                        found = true;
                        rough = lr.rough;
                    }
                }
            }

            if (!found) {
                rough = true;
                mapped = translit(t, lang);
                u.prop = true;
            }

            u.val = lower_str(mapped);
            u.cas = cas;
            u.rough = rough;
            if (rough) rough_count++;

            std::string inf;
            int vp = -1;
            bool vn = false;
            ETense vt = T_PRES;

            bool srcverb = is_probably_verb_source(t, lang) || source_irregular_verb(t, lang);

            if (parse_verb_form(u.val, inf, vp, vn, vt)) {
                u.tag = T_VERB;
                u.val = inf;
                u.pron = vp;
                if (vn) neg = true;
                if (vt != T_PRES) tense = vt;
                saw_main_verb = true;
            } else if (srcverb || ends_with(u.val, "mak") || ends_with(u.val, "mek")) {
                u.tag = T_VERB;

                if (!ends_with(u.val, "mak") && !ends_with(u.val, "mek")) {
                    LookupResult lr = lookup_translation(*wd, t, lang, piv1, piv2);
                    if (lr.found && (ends_with(lr.value, "mak") || ends_with(lr.value, "mek"))) {
                        u.val = lr.value;
                    } else {
                        auto cs = lang == 1 ? en_stems(t) : (lang == 0 ? ru_stems(t) : tr_stems(t));
                        for (const auto& c : cs) {
                            LookupResult x = lookup_translation(*wd, c, lang, piv1, piv2);
                            if (x.found && (ends_with(x.value, "mak") || ends_with(x.value, "mek"))) {
                                u.val = x.value;
                                break;
                            }
                        }
                    }
                }

                saw_main_verb = true;
                if (source_verb_index < 0) source_verb_index = static_cast<int>(i);
                ++main_verb_count;
            } else {
                u.tag = T_WORD;
                u.source_adj = source_is_adjective(t, lang);
                if (source_is_adverb(t, lang)) u.source_adj = false;
            }

            if (u.tag == T_WORD && lang == 1 &&
                ends_with(lower_str(raws[i]), "s") &&
                !ends_with(lower_str(raws[i]), "ss") &&
                should_pluralize(i, toks, g.number_words)) {
                u.plural = true;
            }

            if (u.tag == T_WORD && lang == 0) {
                if (ends_with(t, "ы") || ends_with(t, "и") || ends_with(t, "а") || ends_with(t, "я")) {
                    if (t.size() > 4 && source_is_adjective(t, lang)) u.plural = false;
                }
            }

            if (u.tag == T_WORD) {
                if (i > 0) {
                    const std::string& p = toks[i - 1];
                    if (p == "in" || p == "on" || p == "at" || p == "в" || p == "во" || p == "на") u.cas = C_LOC;
                    else if (p == "to" || p == "к" || p == "ко") u.cas = C_DAT;
                    else if (p == "from" || p == "из" || p == "от" || p == "с") u.cas = C_ABL;
                    else if (p == "of") u.cas = C_GEN;
                    else if (p == "without" || p == "без") u.cas = C_NOM;
                }

                if (source_verb_index >= 0 &&
                    static_cast<int>(i) > source_verb_index &&
                    u.cas == C_NOM &&
                    !source_is_adverb(t, lang) &&
                    !source_is_adjective(t, lang)) {
                    u.source_object = true;
                }

                if (definite_idx.count(i) && u.source_object) u.cas = C_ACC;
            }

            units.push_back(std::move(u));
        }

        for (size_t i = 0; i < units.size(); ++i) {
            if (units[i].tag == T_STOP && units[i].val == "ART") units[i].consumed = true;

            if (units[i].tag == T_STOP && units[i].val == "DEF") {
                size_t head = units.size();

                for (size_t j = i + 1; j < units.size(); ++j) {
                    if (units[j].consumed) continue;
                    if (units[j].tag == T_STOP || units[j].tag == T_AUX || units[j].tag == T_MODAL) break;
                    if (units[j].tag == T_WORD || units[j].tag == T_PRON) head = j;
                    if (units[j].tag == T_VERB) break;
                }

                if (head < units.size()) {
                    units[head].source_object = true;
                    if (units[head].cas == C_NOM && main_verb_count > 0) units[head].cas = C_ACC;
                }

                units[i].consumed = true;
            }
        }

        int person = source_person;
        for (auto& u : units) {
            if (u.tag == T_VERB && u.pron >= 0) {
                person = u.pron;
                break;
            }
        }
        if (person < 0 || person > 5) person = 2;

        bool has_subject = false;
        for (const auto& u : units) {
            if (u.tag == T_PRON && u.source_subject) {
                has_subject = true;
                break;
            }
        }

        bool imperative = (!has_subject && saw_main_verb && std::strchr(text, '!') != nullptr);

        for (size_t i = 0; i < units.size(); ++i) {
            if (units[i].tag != T_STOP || units[i].consumed) continue;

            const std::string& p = units[i].val;
            if (!is_service_token(p)) continue;

            if (p == "WITHOUT") {
                for (size_t j = i + 1; j < units.size(); ++j) {
                    if (units[j].consumed) continue;
                    if (units[j].tag == T_STOP || units[j].tag == T_AUX || units[j].tag == T_MODAL) continue;
                    if (units[j].tag == T_WORD || units[j].tag == T_PRON) {
                        std::string s = "s";
                        enc_cp(s, harmony_v4(units[j].val));
                        s += "z";
                        units[j].val += s;
                        break;
                    }
                }
                units[i].consumed = true;
                continue;
            }

            ECase c = C_NOM;
            bool applies = false;

            if (p == "DAT") {
                c = C_DAT;
                applies = true;
            } else if (p == "LOC") {
                c = C_LOC;
                applies = true;
            } else if (p == "ABL") {
                c = C_ABL;
                applies = true;
            } else if (p == "GEN") {
                c = C_GEN;
                applies = true;
            }

            if (applies) {
                if (c == C_LOC) {
                    bool motion = false;
                    for (const auto& z : units) {
                        if (z.tag == T_VERB && g.motion.count(z.val)) {
                            motion = true;
                            break;
                        }
                    }
                    if (motion) c = C_DAT;
                }

                for (size_t j = i + 1; j < units.size(); ++j) {
                    if (units[j].consumed) continue;
                    if (units[j].tag == T_STOP || units[j].tag == T_AUX || units[j].tag == T_MODAL) continue;
                    if (units[j].tag == T_WORD || units[j].tag == T_PRON) {
                        units[j].cas = c;
                        break;
                    }
                }

                units[i].consumed = true;
                continue;
            }

            if (p == "WITH" || p == "FOR" || p == "BY" || p == "BEFORE" || p == "AFTER" || p == "ABOUT") {
                for (size_t j = i + 1; j < units.size(); ++j) {
                    if (units[j].consumed) continue;
                    if (units[j].tag == T_STOP || units[j].tag == T_AUX || units[j].tag == T_MODAL) continue;
                    if (units[j].tag == T_WORD || units[j].tag == T_PRON) {
                        if (p == "WITH") units[j].post = "bilen";
                        else if (p == "FOR") units[j].post = "üçin";
                        else if (p == "BY") units[j].post = "tarapyndan";
                        else if (p == "BEFORE") units[j].post = "öň";
                        else if (p == "AFTER") units[j].post = "soň";
                        else units[j].post = "hakynda";

                        units[i].consumed = true;
                        break;
                    }
                }
            }
        }

        for (size_t i = 0; i < units.size(); ++i) {
            if (units[i].tag != T_STOP || units[i].consumed) continue;

            int pp = 0;
            if (units[i].val == "meniň") pp = 1;
            else if (units[i].val == "seniň") pp = 2;
            else if (units[i].val == "onuň") pp = 3;
            else if (units[i].val == "biziň") pp = 4;
            else if (units[i].val == "siziň") pp = 5;
            else if (units[i].val == "olaryň") pp = 6;

            if (pp) {
                for (size_t j = i + 1; j < units.size(); ++j) {
                    if (units[j].consumed) continue;
                    if (units[j].tag == T_VERB || units[j].tag == T_MODAL) break;

                    if (units[j].tag == T_WORD) {
                        const int si = units[j].source_index;
                        const bool adj = (si >= 0 && static_cast<size_t>(si) < toks.size())
                                         ? source_is_adjective(toks[static_cast<size_t>(si)], lang)
                                         : units[j].source_adj;

                        if (!adj) {
                            units[j].possp = pp;
                            units[i].consumed = true;
                            break;
                        }
                    }
                }
            }
        }

        std::vector<std::string> subject_parts, modifier_parts, object_parts, predicate_parts;
        std::string modal;
        std::vector<std::string> verbs;

        for (size_t i = 0; i < units.size(); ++i) {
            Unit& u = units[i];
            if (u.consumed) continue;

            if (u.tag == T_MODAL) {
                modal = u.val;
                continue;
            }

            if (u.tag == T_VERB) {
                verbs.push_back(u.val);
                continue;
            }

            if (u.tag == T_STOP) {
                if (!u.val.empty() && !is_service_token(u.val)) modifier_parts.push_back(u.val);
                continue;
            }

            std::string v;

            if (u.tag == T_PRON && u.pron >= 0) {
                v = pron_case(u.pron, u.cas);
            } else {
                v = u.val;
                if (u.possp > 0) v = poss(v, u.possp);
                if (u.plural && !u.phrase) v += word_back(v) ? "lar" : "ler";
                if (u.cas != C_NOM) v = apply_case(v, u.cas);
            }

            if (!u.post.empty()) {
                v += ' ';
                v += u.post;
            }

            if (u.tag == T_PRON && u.source_subject) {
                subject_parts.push_back(v);
                has_subject = true;
                continue;
            }

            if (u.source_object || u.cas != C_NOM) {
                object_parts.push_back(v);
                continue;
            }

            if (!has_subject && !u.source_object && copula_present && u.source_index < copula_source_index) {
                subject_parts.push_back(v);
                has_subject = true;
                continue;
            }

            if (copula_present && u.source_index > copula_source_index && u.source_adj) {
                predicate_parts.push_back(v);
                continue;
            }

            if (!has_subject && u.tag == T_PRON) {
                subject_parts.push_back(v);
                has_subject = true;
                continue;
            }

            modifier_parts.push_back(v);
        }

        if (verbs.empty()) {
            for (const auto& u : units) {
                if (!u.consumed && u.tag == T_WORD &&
                    (ends_with(u.val, "mak") || ends_with(u.val, "mek"))) {
                    verbs.push_back(u.val);
                    break;
                }
            }
        }

        std::string verb_out;

        if (!verbs.empty()) {
            std::string main = verbs.back();

            if (modal == "gerek") {
                verb_out = make_necessitative(main, person);
                if (neg) verb_out += " däl";
            } else if (modal == "bilmek") {
                std::string c = make_converb(main);
                std::string ability = conjugate2("bilmek", person, neg, tense, question_word ? false : quest);
                verb_out = c + " " + ability;
            } else if (modal == "islemek") {
                std::string wish = conjugate2("islemek", person, neg, tense, question_word ? false : quest);
                verb_out = main + " " + wish;
            } else if (modal == "mümkin") {
                verb_out = main + " mümkin";
            } else if (tense == T_FUT && future_def_flag) {
                verb_out = future_def(main, neg);
                if (person != 2) verb_out = conjugate2(main, person, neg, T_FUT, question_word ? false : quest);
            } else if (imperative) {
                std::string st = ends_with(main, "mak") || ends_with(main, "mek")
                                 ? main.substr(0, main.size() - 3)
                                 : main;
                if (neg) st += (word_back(st) ? "ma" : "me");
                verb_out = st;
            } else {
                verb_out = conjugate2(main, person, neg, tense, (!question_word && quest));
            }
        } else if (neg) {
            verb_out = "däl";
        }

        if (has_perfect && !verbs.empty() && tense == T_PRES) {
            std::string main = verbs.back();
            std::string stem = ends_with(main, "mak") || ends_with(main, "mek")
                               ? main.substr(0, main.size() - 3)
                               : main;
            verb_out = stem + (word_back(stem) ? "ip" : "ip") + "dir";
        }

        std::vector<std::string> final_words;

        for (const auto& x : subject_parts) if (!x.empty()) final_words.push_back(x);
        for (const auto& x : modifier_parts) if (!x.empty()) final_words.push_back(x);
        for (const auto& x : object_parts) if (!x.empty()) final_words.push_back(x);
        for (const auto& x : predicate_parts) if (!x.empty()) final_words.push_back(x);
        if (!verb_out.empty()) final_words.push_back(verb_out);

        if (final_words.empty()) return -1;

        if (quest && !question_word && !verb_out.empty() &&
            verb_out.find("my") == std::string::npos &&
            verb_out.find("mi") == std::string::npos) {
            bool already = false;
            for (const auto& x : final_words) {
                if (ends_with(x, "my") || ends_with(x, "mi")) {
                    already = true;
                    break;
                }
            }
            if (!already) {
                final_words.back() += word_back(final_words.back()) ? "my" : "mi";
            }
        }

        std::string res = join_target(final_words);
        cap_first(res);
        restore_punctuation(text, res);

        if (rough_count > static_cast<int>(toks.size() / 2) + 1) return -1;

        const int q = rough_count == 0 ? 5 : (rough_count <= 2 ? 4 : 3);
        if (!put(res, q)) return -1;

        auto us = std::chrono::duration_cast<std::chrono::microseconds>(
                std::chrono::steady_clock::now() - t0).count();

        MT_LOG("MONSTER translate content=%zu rough=%d tense=%d quest=%d imper=%d modal=%d perfect=%d progressive=%d us=%lld",
               final_words.size(),
               rough_count,
               static_cast<int>(tense),
               static_cast<int>(quest),
               static_cast<int>(imperative),
               static_cast<int>(has_modal),
               static_cast<int>(has_perfect),
               static_cast<int>(has_progressive),
               static_cast<long long>(us));

        return static_cast<int32_t>(res.size());
    }

}