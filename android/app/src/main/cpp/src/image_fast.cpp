#include "image_fast.h"
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdint>
#include <vector>
#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include <stb_image_write.h>

namespace kp {

    int32_t resize_image(const char* src, const char* dst, int32_t max_side, int32_t quality) {
        int w = 0, h = 0, ch = 0;
        unsigned char* px = stbi_load(src, &w, &h, &ch, 4);
        if (!px) return -1;

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
            if (!resized) { stbi_image_free(px); return -3; }
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
        if (resized) free(resized);
        stbi_image_free(px);
        return ok ? 0 : -2;
    }

}

namespace {

    int ocr_exif_orientation(const char* path) {
        FILE* f = fopen(path, "rb");
        if (!f) return 1;
        static unsigned char buf[65536];
        const size_t n = fread(buf, 1, sizeof(buf), f);
        fclose(f);
        if (n < 4 || buf[0] != 0xFF || buf[1] != 0xD8) return 1;
        size_t i = 2;
        while (i + 4 < n) {
            if (buf[i] != 0xFF) { ++i; continue; }
            const unsigned char m = buf[i + 1];
            if (m == 0xE1) {
                const size_t start = i + 4;
                if (start + 6 < n && std::memcmp(buf + start, "Exif\0\0", 6) == 0) {
                    const size_t t = start + 6;
                    const bool le = buf[t] == 'I' && buf[t + 1] == 'I';
                    auto r16 = [&](size_t p) { return le ? (buf[p] | (buf[p + 1] << 8)) : ((buf[p] << 8) | buf[p + 1]); };
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
        if (!d) return false;
        int W = w, H = h;
        if (orient >= 5) std::swap(W, H);
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
        if (nw <= 0 || nh <= 0) return;
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
        if (w < 3 || h < 3) return;
        std::vector<unsigned char> out(im.px.size());
        unsigned char win[9];
        for (int y = 0; y < h; ++y) {
            const int y0 = y > 0 ? y - 1 : 0;
            const int y1 = y < h - 1 ? y + 1 : h - 1;
            for (int x = 0; x < w; ++x) {
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
                out[(size_t)y * w + x] = win[k / 2];
            }
        }
        im.px = std::move(out);
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
        if (above * 2 < im.px.size()) {
            for (auto& v : im.px) v = (unsigned char)(255 - v);
        }
    }

    void ocr_contrast(OcrImg& im, float contrast) {
        for (auto& v : im.px) {
            const float f = (v - 128.f) * contrast + 128.f;
            v = (unsigned char)std::min(255.f, std::max(0.f, f));
        }
    }

    void ocr_rotate_gray(OcrImg& im, int angle) {
        if (angle == 0) return;
        const int W = im.w, H = im.h;
        if (angle == 180) { std::reverse(im.px.begin(), im.px.end()); return; }
        const int NW = H, NH = W;
        std::vector<unsigned char> out((size_t)NW * NH);
        for (int y = 0; y < H; ++y) {
            for (int x = 0; x < W; ++x) {
                if (angle == 90) out[(size_t)x * NW + (NW - 1 - y)] = im.px[(size_t)y * W + x];
                else             out[(size_t)(W - 1 - x) * NW + y] = im.px[(size_t)y * W + x]; // 270
            }
        }
        im.px = std::move(out);
        im.w = NW; im.h = NH;
    }

}

extern "C" __attribute__((visibility("default"), used))
int32_t pn_ocr_prep(const char* src, const char* dst, int32_t max_side, int32_t contrast_pct) {
    if (!src || !dst) return -1;
    const int orient = ocr_exif_orientation(src);
    OcrImg im;
    if (!ocr_load_gray(src, orient, im)) return -2;

    const int longest = im.w > im.h ? im.w : im.h;
    if (longest > max_side) {
        const float s = (float)max_side / longest;
        ocr_resize_gray(im, (int)(im.w * s), (int)(im.h * s));
    } else if (longest < 1000) {
        float s = 1000.f / longest; if (s > 3.f) s = 3.f;
        ocr_resize_gray(im, (int)(im.w * s), (int)(im.h * s));
    }

    ocr_median3(im);
    ocr_auto_invert(im);
    ocr_contrast(im, contrast_pct / 100.f);

    if (!stbi_write_png(dst, im.w, im.h, 1, im.px.data(), im.w)) return -3;
    return 0;
}

extern "C" __attribute__((visibility("default"), used))
int32_t pn_ocr_rotate(const char* src, const char* dst, int32_t angle) {
    if (!src || !dst) return -1;
    int w, h, c;
    unsigned char* d = stbi_load(src, &w, &h, &c, 1);
    if (!d) return -2;
    OcrImg im;
    im.px.assign(d, d + (size_t)w * h);
    im.w = w; im.h = h;
    stbi_image_free(d);
    ocr_rotate_gray(im, angle);
    if (!stbi_write_png(dst, im.w, im.h, 1, im.px.data(), im.w)) return -3;
    return 0;
}