#include "image_fast.h"
#include <cstdlib>
#include <cstring>

#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include <stb_image_write.h>

#define KP_HAS_STB 1

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
            // Nearest-neighbor — максимально быстро для аватара
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