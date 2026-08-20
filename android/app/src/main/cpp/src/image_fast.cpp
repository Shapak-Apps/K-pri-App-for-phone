#include "image_fast.h"
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdint>
#include <vector>

#ifdef __ANDROID__
#include <android/log.h>
#define LOG_TAG "KpNative"

#ifndef NDEBUG
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,  LOG_TAG, __VA_ARGS__)
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN,  LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#else
#define LOGI(...) do {} while(0)
#define LOGW(...) do {} while(0)
#define LOGE(...) do {} while(0)
#define LOGD(...) do {} while(0)
#endif

#else
#ifndef NDEBUG
#define LOGI(...) do { fprintf(stderr, "[I] "); fprintf(stderr, __VA_ARGS__); fprintf(stderr, "\n"); } while(0)
#define LOGW(...) do { fprintf(stderr, "[W] "); fprintf(stderr, __VA_ARGS__); fprintf(stderr, "\n"); } while(0)
#define LOGE(...) do { fprintf(stderr, "[E] "); fprintf(stderr, __VA_ARGS__); fprintf(stderr, "\n"); } while(0)
#define LOGD(...) do { fprintf(stderr, "[D] "); fprintf(stderr, __VA_ARGS__); fprintf(stderr, "\n"); } while(0)
#else
#define LOGI(...) do {} while(0)
#define LOGW(...) do {} while(0)
#define LOGE(...) do {} while(0)
#define LOGD(...) do {} while(0)
#endif
#endif

#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include <stb_image_write.h>


#if defined(KP_HAS_ASM_KERNELS)
extern "C" void kp_asm_gray_rgb888(uint8_t* dst, const uint8_t* src, int32_t n);
extern "C" void kp_asm_contrast_u8(uint8_t* dst, const uint8_t* src, int32_t n, int32_t scale_q8);
#endif

static constexpr int64_t HARD_PIXEL_LIMIT = 40'000'000LL;

static void* aligned_malloc(size_t size, size_t alignment = 16) {
    void* ptr = nullptr;
#ifdef _WIN32
    ptr = _aligned_malloc(size, alignment);
#else
    if (posix_memalign(&ptr, alignment, size) != 0) ptr = nullptr;
#endif
    return ptr;
}

static void aligned_free(void* ptr) {
#ifdef _WIN32
    _aligned_free(ptr);
#else
    free(ptr);
#endif
}

namespace kp {
    int32_t resize_image(const char* src, const char* dst, int32_t max_side, int32_t quality) {
        LOGI("resize_image enter: src=%s max_side=%d q=%d", src ? src : "(null)", max_side, quality);
        if (!src || !dst) { LOGE("resize_image: null args"); return -1; }
        if (max_side < 1) max_side = 1;
        if (quality < 1) quality = 1;
        if (quality > 100) quality = 100;

        int w = 0, h = 0, ch = 0;
        unsigned char* px = stbi_load(src, &w, &h, &ch, 4);
        if (!px) { LOGE("resize_image: stbi_load failed"); return -1; }
        LOGD("resize_image: loaded %dx%d ch=%d", w, h, ch);

        if ((int64_t)w * h > HARD_PIXEL_LIMIT) {
            LOGW("resize_image: too large %dx%d, clamping", w, h);
            double factor = std::sqrt((double)HARD_PIXEL_LIMIT / ((int64_t)w * h));
            int ns = (int)(std::max(w, h) * factor);
            if (ns < max_side) max_side = ns;
        }

        int nw = w, nh = h;
        if (w > max_side || h > max_side) {
            if (w > h) { nw = max_side; nh = (int)((double)h * max_side / w); }
            else       { nh = max_side; nw = (int)((double)w * max_side / h); }
        }
        if (nw < 1) nw = 1;
        if (nh < 1) nh = 1;

        unsigned char* out = px;
        unsigned char* resized = nullptr;
        if (nw != w || nh != h) {
            resized = (unsigned char*)malloc((size_t)nw * nh * 4);
            if (!resized) { LOGE("resize_image: malloc failed"); stbi_image_free(px); return -3; }
            for (int y = 0; y < nh; ++y) {
                const int sy = (int)((double)y * h / nh);
                for (int x = 0; x < nw; ++x) {
                    const int sx = (int)((double)x * w / nw);
                    memcpy(resized + ((size_t)y * nw + x) * 4,
                           px + ((size_t)sy * w + sx) * 4, 4);
                }
            }
            out = resized;
        }
        const int ok = stbi_write_jpg(dst, nw, nh, 4, out, quality);
        LOGD("resize_image: stbi_write_jpg -> %d", ok);
        if (resized) free(resized);
        stbi_image_free(px);
        return ok ? 0 : -2;
    }
}

namespace {

    int ocr_exif_orientation(const char* path) {
        if (!path) return 1;
        FILE* f = fopen(path, "rb");
        if (!f) { LOGW("exif: cannot open %s", path); return 1; }

        std::vector<unsigned char> buf(65536);
        const size_t n = fread(buf.data(), 1, buf.size(), f);
        fclose(f);

        if (n < 4 || buf[0] != 0xFF || buf[1] != 0xD8) return 1;
        size_t i = 2;
        while (i + 4 < n) {
            if (buf[i] != 0xFF) { ++i; continue; }
            const unsigned char m = buf[i + 1];
            if (m == 0xE1) {
                const size_t start = i + 4;
                if (start + 6 < n && std::memcmp(buf.data() + start, "Exif\0\0", 6) == 0) {
                    const size_t t = start + 6;
                    const bool le = buf[t] == 'I' && buf[t + 1] == 'I';
                    auto r16 = [&](size_t p) {
                        return le ? (buf[p] | (buf[p + 1] << 8)) : ((buf[p] << 8) | buf[p + 1]);
                    };
                    auto r32 = [&](size_t p) {
                        return le ? (buf[p] | (buf[p + 1] << 8) | (buf[p + 2] << 16) | ((size_t)buf[p + 3] << 24))
                                  : (((size_t)buf[p] << 24) | (buf[p + 1] << 16) | (buf[p + 2] << 8) | buf[p + 3]);
                    };
                    if (t + 8 < n) {
                        const size_t ifd = t + r32(t + 4);
                        if (ifd + 2 < n) {
                            const int cnt = r16(ifd);
                            for (int e = 0; e < cnt; ++e) {
                                const size_t p = ifd + 2 + (size_t)e * 12;
                                if (p + 12 >= n) break;
                                if (r16(p) == 0x0112) {
                                    const int v = r16(p + 8);
                                    return (v >= 1 && v <= 8) ? v : 1;
                                }
                            }
                        }
                    }
                }
                break;
            }
            if (m == 0xDA) break;
            if (i + 3 >= n) break;
            i += 2 + ((buf[i + 2] << 8) | buf[i + 3]);
        }
        return 1;
    }

    struct OcrImg {
        std::vector<unsigned char> px;
        int w = 0, h = 0;
    };

    bool ocr_load_gray(const char* path, int orient, OcrImg& out) {
        int w, h, c;
        unsigned char* d = stbi_load(path, &w, &h, &c, 3);
        if (!d) { LOGE("ocr_load_gray: stbi_load failed for %s", path ? path : "(null)"); return false; }
        LOGD("ocr_load_gray: loaded %dx%d c=%d orient=%d", w, h, c, orient);

        int W = w, H = h;
        if (orient >= 5) std::swap(W, H);

        const int64_t total_pixels = (int64_t)W * H;
        if (total_pixels > HARD_PIXEL_LIMIT || total_pixels <= 0) {
            LOGW("ocr_load_gray: too large %lld pixels, using scalar", total_pixels);
        } else {
            std::vector<unsigned char> g((size_t)total_pixels);

#if defined(KP_HAS_ASM_KERNELS)
            if (orient == 1 && W == w && H == h) {
                // ⚡ ПРОВЕРКА ВЫРАВНИВАНИЯ
                const uintptr_t dst_addr = reinterpret_cast<uintptr_t>(g.data());
                const uintptr_t src_addr = reinterpret_cast<uintptr_t>(d);
                const bool dst_aligned = (dst_addr % 8) == 0;
                const bool src_aligned = (src_addr % 8) == 0;

                LOGD("ocr_load_gray: dst_aligned=%d src_aligned=%d pixels=%lld",
                     dst_aligned, src_aligned, total_pixels);

                if (dst_aligned && src_aligned) {
                    LOGD("ocr_load_gray: using ASM kernel for %lld pixels", total_pixels);
                    kp_asm_gray_rgb888(g.data(), d, (int32_t)total_pixels);
                    stbi_image_free(d);
                    out.px = std::move(g);
                    out.w = W; out.h = H;
                    return true;
                } else {
                    LOGW("ocr_load_gray: pointers not aligned, using scalar");
                }
            }
#endif
        }

        LOGD("ocr_load_gray: using scalar path orient=%d", orient);
        std::vector<unsigned char> g((size_t)W * H);
        for (int y = 0; y < H; ++y) {
            for (int x = 0; x < W; ++x) {
                int sx = x, sy = y;
                switch (orient) {
                    case 2: sx = w - 1 - x; sy = y; break;
                    case 3: sx = w - 1 - x; sy = h - 1 - y; break;
                    case 4: sx = x; sy = h - 1 - y; break;
                    case 5: sx = y; sy = x; break;
                    case 6: sx = h - 1 - y; sy = x; break;
                    case 7: sx = h - 1 - y; sy = w - 1 - x; break;
                    case 8: sx = y; sy = w - 1 - x; break;
                    default: break;
                }
                const unsigned char* p = d + ((size_t)sy * w + sx) * 3;
                const float yv = 0.299f * p[0] + 0.587f * p[1] + 0.114f * p[2];
                g[(size_t)y * W + x] = (unsigned char)std::min(255.f, std::max(0.f, yv));
            }
        }
        stbi_image_free(d);
        out.px = std::move(g);
        out.w = W; out.h = H;
        return true;
    }

    void ocr_resize_gray(OcrImg& im, int nw, int nh) {
        if (nw <= 0 || nh <= 0) { LOGW("ocr_resize_gray: invalid size %dx%d", nw, nh); return; }
        if ((int64_t)nw * nh > HARD_PIXEL_LIMIT) { LOGW("ocr_resize_gray: too large, skip"); return; }
        LOGD("ocr_resize_gray: %dx%d -> %dx%d", im.w, im.h, nw, nh);

        std::vector<unsigned char> out((size_t)nw * nh);
        const float xr = (float)im.w / nw, yr = (float)im.h / nh;
        for (int y = 0; y < nh; ++y) {
            const float fy = (y + 0.5f) * yr - 0.5f;
            int y0 = (int)std::floor(fy);
            if (y0 < 0) y0 = 0; if (y0 > im.h - 1) y0 = im.h - 1;
            const int y1 = y0 + 1 < im.h ? y0 + 1 : im.h - 1;
            const float ty = fy - y0;
            for (int x = 0; x < nw; ++x) {
                const float fx = (x + 0.5f) * xr - 0.5f;
                int x0 = (int)std::floor(fx);
                if (x0 < 0) x0 = 0; if (x0 > im.w - 1) x0 = im.w - 1;
                const int x1 = x0 + 1 < im.w ? x0 + 1 : im.w - 1;
                const float tx = fx - x0;
                const float v =
                        im.px[(size_t)y0 * im.w + x0] * (1 - tx) * (1 - ty) +
                        im.px[(size_t)y0 * im.w + x1] * tx * (1 - ty) +
                        im.px[(size_t)y1 * im.w + x0] * (1 - tx) * ty +
                        im.px[(size_t)y1 * im.w + x1] * tx * ty;
                out[(size_t)y * nw + x] = (unsigned char)v;
            }
        }
        im.px = std::move(out);
        im.w = nw; im.h = nh;
    }

    void ocr_median3(OcrImg& im) {
        const int w = im.w, h = im.h;
        if (w < 3 || h < 3) { LOGD("ocr_median3: skip (too small)"); return; }
        if ((int64_t)w * h > HARD_PIXEL_LIMIT) { LOGW("ocr_median3: too large, skip"); return; }
        LOGD("ocr_median3: start %dx%d", w, h);
        std::vector<unsigned char> out(im.px.size());
        auto med_at = [&](int y, int x) {
            unsigned char win[9];
            const int y0 = y > 0 ? y - 1 : 0;
            const int y1 = y < h - 1 ? y + 1 : h - 1;
            const int x0 = x > 0 ? x - 1 : 0;
            const int x1 = x < w - 1 ? x + 1 : w - 1;
            int k = 0;
            for (int yy = y0; yy <= y1; ++yy)
                for (int xx = x0; xx <= x1; ++xx)
                    win[k++] = im.px[(size_t)yy * w + xx];
            for (int i = 1; i < k; ++i) {
                const unsigned char v = win[i];
                int j = i - 1;
                while (j >= 0 && win[j] > v) { win[j + 1] = win[j]; --j; }
                win[j + 1] = v;
            }
            return win[k / 2];
        };
        for (int y = 0; y < h; ++y)
            for (int x = 0; x < w; ++x)
                out[(size_t)y * w + x] = (unsigned char)med_at(y, x);
        im.px = std::move(out);
        LOGD("ocr_median3: done");
    }

    int ocr_otsu(const OcrImg& im) {
        size_t hist[256];
        std::memset(hist, 0, sizeof(hist));
        for (unsigned char v : im.px) hist[v]++;
        const size_t total = im.px.size();
        if (total == 0) return 127;
        double sum = 0;
        for (int i = 0; i < 256; ++i) sum += (double)i * hist[i];
        double sumB = 0; size_t wB = 0; double best = -1.0; int thr = 127;
        for (int i = 0; i < 256; ++i) {
            wB += hist[i];
            if (wB == 0) continue;
            const size_t wF = total - wB;
            if (wF == 0) break;
            sumB += (double)i * hist[i];
            const double mB = sumB / (double)wB;
            const double mF = (sum - sumB) / (double)wF;
            const double between = (double)wB * (double)wF * (mB - mF) * (mB - mF);
            if (between > best) { best = between; thr = i; }
        }
        return thr;
    }

    void ocr_auto_invert(OcrImg& im) {
        const int thr = ocr_otsu(im);
        size_t above = 0;
        for (unsigned char v : im.px) if (v > (unsigned char)thr) ++above;
        LOGD("ocr_auto_invert: thr=%d above=%zu/%zu", thr, above, im.px.size());
        if (above * 2 < im.px.size()) {
            LOGD("ocr_auto_invert: INVERTING");
            for (auto& v : im.px) v = (unsigned char)(255 - v);
        }
    }

    void ocr_contrast(OcrImg& im, float contrast) {
        LOGD("ocr_contrast: factor=%.3f size=%d", contrast, (int)im.px.size());
#if defined(KP_HAS_ASM_KERNELS)
        const int32_t scale_q8 = (int32_t)std::lrintf(contrast * 256.0f);
        if (scale_q8 > 0 && scale_q8 < 258 && im.px.size() > 0) {
            const uintptr_t ptr_addr = reinterpret_cast<uintptr_t>(im.px.data());
            const bool is_aligned = (ptr_addr % 16) == 0;

            LOGD("ocr_contrast: aligned=%d scale_q8=%d", is_aligned, scale_q8);

            if (is_aligned) {
                LOGD("ocr_contrast: using ASM");
                kp_asm_contrast_u8(im.px.data(), im.px.data(), (int32_t)im.px.size(), scale_q8);
                LOGD("ocr_contrast: ASM done");
                return;
            } else {
                LOGW("ocr_contrast: not aligned, using scalar");
            }
        }
#endif
        for (auto& v : im.px) {
            const float f = (v - 128.f) * contrast + 128.f;
            v = (unsigned char)std::min(255.f, std::max(0.f, f));
        }
        LOGD("ocr_contrast: scalar done");
    }

    void ocr_rotate_gray(OcrImg& im, int angle) {
        if (angle == 0) return;
        const int W = im.w, H = im.h;
        LOGD("ocr_rotate_gray: %dx%d angle=%d", W, H, angle);
        if (angle == 180) { std::reverse(im.px.begin(), im.px.end()); return; }
        const int NW = H, NH = W;
        std::vector<unsigned char> out((size_t)NW * NH);
        for (int y = 0; y < H; ++y) {
            for (int x = 0; x < W; ++x) {
                if (angle == 90) out[(size_t)x * NW + (NW - 1 - y)] = im.px[(size_t)y * W + x];
                else             out[(size_t)(W - 1 - x) * NW + y] = im.px[(size_t)y * W + x];
            }
        }
        im.px = std::move(out);
        im.w = NW; im.h = NH;
    }

}

extern "C" __attribute__((visibility("default"), used))
int32_t pn_ocr_prep(const char* src, const char* dst, int32_t max_side, int32_t contrast_pct) {
    LOGI("▶ pn_ocr_prep: src=%s max_side=%d contrast_pct=%d",
         src ? src : "(null)", max_side, contrast_pct);

    if (!src || !dst) { LOGE("pn_ocr_prep: null args"); return -1; }

    if (max_side < 100) max_side = 100;
    if (max_side > 8000) max_side = 8000;
    if (contrast_pct < 0) contrast_pct = 0;
    if (contrast_pct > 500) contrast_pct = 500;

    {
        int tw = 0, th = 0, tc = 0;
        if (stbi_info(src, &tw, &th, &tc)) {
            LOGD("stbi_info: %dx%d c=%d", tw, th, tc);
            int64_t px = (int64_t)tw * th;
            if (px > HARD_PIXEL_LIMIT) {
                LOGW("⚠ image too large (%lld px), forcing downscale", (long long)px);
                double factor = std::sqrt((double)HARD_PIXEL_LIMIT / px);
                int ns = (int)(std::max(tw, th) * factor);
                if (ns < max_side) max_side = ns;
            }
        }
    }

    const int orient = ocr_exif_orientation(src);
    LOGD("orient=%d", orient);

    OcrImg im;
    if (!ocr_load_gray(src, orient, im)) { LOGE("ocr_load_gray failed"); return -2; }
    LOGD("loaded %dx%d", im.w, im.h);

    const int longest = im.w > im.h ? im.w : im.h;
    if (longest > max_side) {
        const float s = (float)max_side / longest;
        int nw = std::max(1, (int)(im.w * s));
        int nh = std::max(1, (int)(im.h * s));
        ocr_resize_gray(im, nw, nh);
    } else if (longest < 1000) {
        float s = 1000.f / longest;
        if (s > 3.f) s = 3.f;
        int nw = std::max(1, (int)(im.w * s));
        int nh = std::max(1, (int)(im.h * s));
        int64_t np = (int64_t)nw * nh;
        if (np > HARD_PIXEL_LIMIT) {
            double factor = std::sqrt((double)HARD_PIXEL_LIMIT / np);
            nw = std::max(1, (int)(nw * factor));
            nh = std::max(1, (int)(nh * factor));
        }
        ocr_resize_gray(im, nw, nh);
    }

    ocr_median3(im);
    ocr_auto_invert(im);
    ocr_contrast(im, contrast_pct / 100.f);

    LOGD("writing PNG %dx%d", im.w, im.h);
    const int ok = stbi_write_png(dst, im.w, im.h, 1, im.px.data(), im.w);
    if (!ok) { LOGE("❌ stbi_write_png FAILED"); return -3; }

    LOGI("✅ pn_ocr_prep OK");
    return 0;
}

extern "C" __attribute__((visibility("default"), used))
int32_t pn_ocr_rotate(const char* src, const char* dst, int32_t angle) {
    LOGI("▶ pn_ocr_rotate: src=%s angle=%d", src ? src : "(null)", angle);

    if (!src || !dst) { LOGE("pn_ocr_rotate: null args"); return -1; }
    if (angle != 0 && angle != 90 && angle != 180 && angle != 270) {
        LOGE("bad angle %d", angle);
        return -4;
    }

    int w, h, c;
    unsigned char* d = stbi_load(src, &w, &h, &c, 1);
    if (!d) { LOGE("stbi_load failed"); return -2; }
    LOGD("loaded %dx%d c=%d", w, h, c);

    if ((int64_t)w * h > HARD_PIXEL_LIMIT) {
        LOGE("❌ image too large %dx%d", w, h);
        stbi_image_free(d);
        return -5;
    }

    OcrImg im;
    im.px.assign(d, d + (size_t)w * h);
    im.w = w; im.h = h;
    stbi_image_free(d);

    ocr_rotate_gray(im, angle);

    const int ok = stbi_write_png(dst, im.w, im.h, 1, im.px.data(), im.w);
    if (!ok) { LOGE("❌ stbi_write_png FAILED"); return -3; }

    LOGI("✅ pn_ocr_rotate OK");
    return 0;
}