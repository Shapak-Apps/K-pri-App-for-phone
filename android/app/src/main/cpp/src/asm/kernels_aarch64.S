.text
.p2align 4
.globl kp_asm_gray_rgb888
.type  kp_asm_gray_rgb888, %function
kp_asm_gray_rgb888:
movi    v16.16b, #77
movi    v17.16b, #150
movi    v18.16b, #29
sxtw    x2, w2
cmp     x2, #8
b.lt    .Lg_tail
.Lg_loop:
ld3     {v0.8b, v1.8b, v2.8b}, [x1], #24
umull   v4.8h, v0.8b, v16.8b
umull   v5.8h, v1.8b, v17.8b
umull   v6.8h, v2.8b, v18.8b
add     v4.8h, v4.8h, v5.8h
add     v4.8h, v4.8h, v6.8h
shrn    v4.8b, v4.8h, #8
st1     {v4.8b}, [x0], #8
subs    x2, x2, #8
cmp     x2, #8
b.ge    .Lg_loop
.Lg_tail:
cmp     x2, #0
b.le    .Lg_done
.Lg_tail_loop:
mov     w7, #77
ldrb    w4, [x1], #1
mul     w4, w4, w7
mov     w7, #150
ldrb    w5, [x1], #1
madd    w4, w5, w7, w4
mov     w7, #29
ldrb    w5, [x1], #1
madd    w4, w5, w7, w4
lsr     w4, w4, #8
strb    w4, [x0], #1
subs    x2, x2, #1
b.gt    .Lg_tail_loop
.Lg_done:
ret
.size kp_asm_gray_rgb888, .-kp_asm_gray_rgb888

.p2align 4
.globl kp_asm_contrast_u8
.type  kp_asm_contrast_u8, %function
kp_asm_contrast_u8:
movi    v16.8h, #128
dup     v17.8h, w3
sxtw    x2, w2
cmp     x2, #16
b.lt    .Lc_tail
.Lc_loop:
ld1     {v0.16b}, [x1], #16
uxtl    v1.8h,  v0.8b
uxtl2   v2.8h,  v0.16b
sub     v1.8h, v1.8h, v16.8h
sub     v2.8h, v2.8h, v16.8h
mul     v1.8h, v1.8h, v17.8h
mul     v2.8h, v2.8h, v17.8h
srshr   v1.8h, v1.8h, #8
srshr   v2.8h, v2.8h, #8
add     v1.8h, v1.8h, v16.8h
add     v2.8h, v2.8h, v16.8h
sqxtun  v0.8b,  v1.8h
sqxtun2 v0.16b, v2.8h
st1     {v0.16b}, [x0], #16
subs    x2, x2, #16
cmp     x2, #16
b.ge    .Lc_loop
.Lc_tail:
cmp     x2, #0
b.le    .Lc_done
.Lc_tail_loop:
ldrb    w4, [x1], #1
sub     w4, w4, #128
mul     w4, w4, w3
add     w4, w4, #128
asr     w4, w4, #8
add     w4, w4, #128
cmp     w4, #255
mov     w5, #255
csel    w4, w5, w4, gt
cmp     w4, #0
csel    w4, wzr, w4, lt
strb    w4, [x0], #1
subs    x2, x2, #1
b.gt    .Lc_tail_loop
.Lc_done:
ret
.size kp_asm_contrast_u8, .-kp_asm_contrast_u8

.p2align 4
.globl kp_asm_median3_row
.type  kp_asm_median3_row, %function
kp_asm_median3_row:
mov     w5, w4
cmp     w4, #16
b.lt    .Lm_done
.Lm_loop:
ld1     {v16.16b}, [x1]
add     x6, x1, #1
ld1     {v17.16b}, [x6]
add     x6, x1, #2
ld1     {v18.16b}, [x6]
ld1     {v19.16b}, [x2]
add     x6, x2, #1
ld1     {v20.16b}, [x6]
add     x6, x2, #2
ld1     {v21.16b}, [x6]
ld1     {v22.16b}, [x3]
add     x6, x3, #1
ld1     {v23.16b}, [x6]
add     x6, x3, #2
ld1     {v24.16b}, [x6]
add     x1, x1, #16
add     x2, x2, #16
add     x3, x3, #16
umin    v25.16b, v16.16b, v17.16b
umax    v26.16b, v16.16b, v17.16b
umin    v27.16b, v25.16b, v18.16b
umax    v28.16b, v26.16b, v18.16b
umax    v25.16b, v25.16b, v18.16b
umin    v25.16b, v25.16b, v26.16b
mov     v16.16b, v27.16b
mov     v17.16b, v25.16b
mov     v18.16b, v28.16b
umin    v25.16b, v16.16b, v19.16b
umax    v28.16b, v18.16b, v19.16b
umax    v26.16b, v16.16b, v19.16b
umin    v26.16b, v26.16b, v17.16b
umax    v27.16b, v17.16b, v19.16b
umin    v27.16b, v27.16b, v18.16b
mov     v16.16b, v25.16b
mov     v17.16b, v26.16b
mov     v18.16b, v27.16b
mov     v19.16b, v28.16b
umin    v25.16b, v16.16b, v20.16b
umax    v29.16b, v19.16b, v20.16b
umax    v26.16b, v16.16b, v20.16b
umin    v26.16b, v26.16b, v17.16b
umax    v27.16b, v17.16b, v20.16b
umin    v27.16b, v27.16b, v18.16b
umax    v28.16b, v18.16b, v20.16b
umin    v28.16b, v28.16b, v19.16b
mov     v16.16b, v25.16b
mov     v17.16b, v26.16b
mov     v18.16b, v27.16b
mov     v19.16b, v28.16b
mov     v20.16b, v29.16b
umin    v25.16b, v16.16b, v21.16b
umax    v30.16b, v20.16b, v21.16b
umax    v26.16b, v16.16b, v21.16b
umin    v26.16b, v26.16b, v17.16b
umax    v27.16b, v17.16b, v21.16b
umin    v27.16b, v27.16b, v18.16b
umax    v28.16b, v18.16b, v21.16b
umin    v28.16b, v28.16b, v19.16b
umax    v29.16b, v19.16b, v21.16b
umin    v29.16b, v29.16b, v20.16b
mov     v16.16b, v25.16b
mov     v17.16b, v26.16b
mov     v18.16b, v27.16b
mov     v19.16b, v28.16b
mov     v20.16b, v29.16b
mov     v21.16b, v30.16b
umax    v25.16b, v16.16b, v22.16b
umax    v26.16b, v17.16b, v22.16b
umax    v27.16b, v18.16b, v22.16b
umax    v28.16b, v19.16b, v22.16b
umax    v29.16b, v20.16b, v22.16b
umax    v30.16b, v21.16b, v22.16b
umin    v31.16b, v16.16b, v22.16b
umin    v25.16b, v25.16b, v17.16b
umin    v26.16b, v26.16b, v18.16b
umin    v27.16b, v27.16b, v19.16b
umin    v28.16b, v28.16b, v20.16b
umin    v29.16b, v29.16b, v21.16b
mov     v16.16b, v31.16b
mov     v17.16b, v25.16b
mov     v18.16b, v26.16b
mov     v19.16b, v27.16b
mov     v20.16b, v28.16b
mov     v21.16b, v29.16b
mov     v22.16b, v30.16b
umax    v25.16b, v16.16b, v23.16b
umax    v26.16b, v17.16b, v23.16b
umax    v27.16b, v18.16b, v23.16b
umax    v28.16b, v19.16b, v23.16b
umax    v29.16b, v20.16b, v23.16b
umax    v30.16b, v21.16b, v23.16b
umax    v31.16b, v22.16b, v23.16b
umin    v16.16b, v16.16b, v23.16b
umin    v25.16b, v25.16b, v17.16b
umin    v26.16b, v26.16b, v18.16b
umin    v27.16b, v27.16b, v19.16b
umin    v28.16b, v28.16b, v20.16b
umin    v29.16b, v29.16b, v21.16b
umin    v30.16b, v30.16b, v22.16b
mov     v17.16b, v25.16b
mov     v18.16b, v26.16b
mov     v19.16b, v27.16b
mov     v20.16b, v28.16b
mov     v21.16b, v29.16b
mov     v22.16b, v30.16b
mov     v23.16b, v31.16b
umax    v25.16b, v16.16b, v24.16b
umax    v26.16b, v17.16b, v24.16b
umax    v27.16b, v18.16b, v24.16b
umax    v28.16b, v19.16b, v24.16b
umax    v29.16b, v20.16b, v24.16b
umax    v30.16b, v21.16b, v24.16b
umax    v31.16b, v22.16b, v24.16b
umin    v31.16b, v31.16b, v23.16b
umax    v23.16b, v23.16b, v24.16b
umin    v16.16b, v16.16b, v24.16b
umin    v25.16b, v25.16b, v17.16b
umin    v26.16b, v26.16b, v18.16b
umin    v27.16b, v27.16b, v19.16b
umin    v28.16b, v28.16b, v20.16b
umin    v29.16b, v29.16b, v21.16b
umin    v30.16b, v30.16b, v22.16b
mov     v17.16b, v25.16b
mov     v18.16b, v26.16b
mov     v19.16b, v27.16b
mov     v20.16b, v28.16b
mov     v21.16b, v29.16b
mov     v22.16b, v30.16b
st1     {v20.16b}, [x0], #16
subs    w4, w4, #16
cmp     w4, #16
b.ge    .Lm_loop
.Lm_done:
sub     w0, w5, w4
ret
.size kp_asm_median3_row, .-kp_asm_median3_row

.p2align 4
.globl kp_asm_json_scan
.type  kp_asm_json_scan, %function
kp_asm_json_scan:
mov     x5, x0
mov     w6, w1
mov     w7, #0x22
dup     v1.16b, w7
mov     w7, #0x5C
dup     v2.16b, w7
.Ljs_loop:
cmp     w6, #16
b.lt    .Ljs_tail
ld1     {v0.16b}, [x5], #16
cmeq    v3.16b, v0.16b, v1.16b
cmeq    v4.16b, v0.16b, v2.16b
orr     v3.16b, v3.16b, v4.16b
umaxv   b3, v3.16b
umov    w7, v3.b[0]
tbnz    w7, #0, .Ljs_found
sub     w6, w6, #16
b       .Ljs_loop
.Ljs_found:
sub     x5, x5, #16
.Ljs_tail:
cbz     w6, .Ljs_none
.Ljs_tail_loop:
ldrb    w7, [x5], #1
cmp     w7, #0x22
b.eq    .Ljs_hit
cmp     w7, #0x5C
b.eq    .Ljs_hit
subs    w6, w6, #1
b.ne    .Ljs_tail_loop
.Ljs_none:
mov     w0, w1
ret
.Ljs_hit:
sub     x5, x5, #1
sub     x0, x5, x0
ret
.size kp_asm_json_scan, .-kp_asm_json_scan

.p2align 4
.globl kp_asm_json_ws
.type  kp_asm_json_ws, %function
kp_asm_json_ws:
mov     x5, x0
mov     w6, w1
mov     w7, #0x20
dup     v1.16b, w7
mov     w7, #0x09
dup     v2.16b, w7
mov     w7, #0x0D
dup     v3.16b, w7
.Ljw_loop:
cmp     w6, #16
b.lt    .Ljw_tail
ld1     {v0.16b}, [x5], #16
cmeq    v4.16b, v0.16b, v1.16b
cmge    v5.16b, v0.16b, v2.16b
cmge    v6.16b, v3.16b, v0.16b
and     v5.16b, v5.16b, v6.16b
orr     v4.16b, v4.16b, v5.16b
mvn     v4.16b, v4.16b
umaxv   b4, v4.16b
umov    w7, v4.b[0]
tbnz    w7, #0, .Ljw_found
sub     w6, w6, #16
b       .Ljw_loop
.Ljw_found:
sub     x5, x5, #16
.Ljw_tail:
cbz     w6, .Ljw_none
.Ljw_tail_loop:
ldrb    w7, [x5], #1
cmp     w7, #0x20
b.eq    .Ljw_next
cmp     w7, #0x09
b.lo    .Ljw_hit
cmp     w7, #0x0D
b.le    .Ljw_next
.Ljw_hit:
sub     x5, x5, #1
sub     x0, x5, x0
ret
.Ljw_next:
subs    w6, w6, #1
b.ne    .Ljw_tail_loop
.Ljw_none:
mov     w0, w1
ret
.size kp_asm_json_ws, .-kp_asm_json_ws

.p2align 4
.globl kp_asm_csv_scan
.type  kp_asm_csv_scan, %function
kp_asm_csv_scan:
mov     x5, x0
mov     w6, w1
mov     w7, #0x22
dup     v1.16b, w7
mov     w7, #0x0A
dup     v2.16b, w7
mov     w7, #0x0D
dup     v3.16b, w7
.Lcs_loop:
cmp     w6, #16
b.lt    .Lcs_tail
ld1     {v0.16b}, [x5], #16
cmeq    v4.16b, v0.16b, v1.16b
cmeq    v5.16b, v0.16b, v2.16b
cmeq    v6.16b, v0.16b, v3.16b
orr     v4.16b, v4.16b, v5.16b
orr     v4.16b, v4.16b, v6.16b
umaxv   b4, v4.16b
umov    w7, v4.b[0]
tbnz    w7, #0, .Lcs_found
sub     w6, w6, #16
b       .Lcs_loop
.Lcs_found:
sub     x5, x5, #16
.Lcs_tail:
cbz     w6, .Lcs_none
.Lcs_tail_loop:
ldrb    w7, [x5], #1
cmp     w7, #0x22
b.eq    .Lcs_hit
cmp     w7, #0x0A
b.eq    .Lcs_hit
cmp     w7, #0x0D
b.eq    .Lcs_hit
subs    w6, w6, #1
b.ne    .Lcs_tail_loop
.Lcs_none:
mov     w0, w1
ret
.Lcs_hit:
sub     x5, x5, #1
sub     x0, x5, x0
ret
.size kp_asm_csv_scan, .-kp_asm_csv_scan

.p2align 4
.globl kp_asm_clip_stats
.type  kp_asm_clip_stats, %function
kp_asm_clip_stats:
movi    v16.8h, #0
movi    v17.8h, #0
movi    v18.8h, #0
movi    v19.8h, #0
movi    v20.8h, #0
movi    v21.8h, #0
movi    v22.8h, #0
movi    v23.8h, #0
adrp    x5, .Lclip_tbl
add     x5, x5, :lo12:.Lclip_tbl
ld1     {v0.16b}, [x5]
mov     w6, #'a'
dup     v2.16b, w6
mov     w6, #'z'
dup     v3.16b, w6
mov     w6, #'0'
dup     v4.16b, w6
mov     w6, #'9'
dup     v5.16b, w6
mov     w6, #' '
dup     v6.16b, w6
mov     w6, #'\t'
dup     v7.16b, w6
.Lcl_loop:
cmp     w1, #16
b.lt    .Lcl_tail
ld1     {v24.16b}, [x0], #16
movi    v25.16b, #0x20
orr     v25.16b, v24.16b, v25.16b
cmge    v26.16b, v25.16b, v2.16b
cmge    v27.16b, v3.16b, v25.16b
and     v26.16b, v26.16b, v27.16b
cmge    v27.16b, v24.16b, v4.16b
cmge    v28.16b, v5.16b, v24.16b
and     v27.16b, v27.16b, v28.16b
cmeq    v28.16b, v24.16b, v6.16b
cmeq    v29.16b, v24.16b, v7.16b
orr     v28.16b, v28.16b, v29.16b
movi    v29.16b, #0x0F
and     v29.16b, v24.16b, v29.16b
ushr    v30.16b, v24.16b, #4
tbl     v31.16b, {v0.16b}, v29.16b
neg     v30.16b, v30.16b
sshl    v31.16b, v31.16b, v30.16b
movi    v30.16b, #1
and     v31.16b, v31.16b, v30.16b
ushr    v26.16b, v26.16b, #7
ushr    v27.16b, v27.16b, #7
ushr    v28.16b, v28.16b, #7
uaddw   v16.8h, v16.8h, v26.8b
uaddw2  v17.8h, v17.8h, v26.16b
uaddw   v18.8h, v18.8h, v27.8b
uaddw2  v19.8h, v19.8h, v27.16b
uaddw   v20.8h, v20.8h, v28.8b
uaddw2  v21.8h, v21.8h, v28.16b
uaddw   v22.8h, v22.8h, v31.8b
uaddw2  v23.8h, v23.8h, v31.16b
sub     w1, w1, #16
b       .Lcl_loop
.Lcl_tail:
cbz     w1, .Lcl_done
.Lcl_tail_loop:
ldrb    w5, [x0], #1
orr     w7, w5, #0x20
cmp     w7, #'a'
b.lo    .Lcl_t1
cmp     w7, #'z'
b.hi    .Lcl_t1
ldr     w8, [x2]
add     w8, w8, #1
str     w8, [x2]
.Lcl_t1:
cmp     w5, #'0'
b.lo    .Lcl_t2
cmp     w5, #'9'
b.hi    .Lcl_t2
ldr     w8, [x2, #4]
add     w8, w8, #1
str     w8, [x2, #4]
.Lcl_t2:
cmp     w5, #' '
b.eq    .Lcl_sp
cmp     w5, #'\t'
b.ne    .Lcl_t3
.Lcl_sp:
ldr     w8, [x2, #8]
add     w8, w8, #1
str     w8, [x2, #8]
.Lcl_t3:
adrp    x7, .Lclip_tbl
add     x7, x7, :lo12:.Lclip_tbl
and     w8, w5, #0x0F
lsr     w9, w5, #4
ldrb    w8, [x7, w8, uxtw]
lsr     w8, w8, w9
and     w8, w8, #1
ldr     w9, [x2, #12]
add     w9, w9, w8
str     w9, [x2, #12]
subs    w1, w1, #1
b.ne    .Lcl_tail_loop
.Lcl_done:
add     v16.8h, v16.8h, v17.8h
add     v18.8h, v18.8h, v19.8h
add     v20.8h, v20.8h, v21.8h
add     v22.8h, v22.8h, v23.8h
addv    h16, v16.8h
addv    h18, v18.8h
addv    h20, v20.8h
addv    h22, v22.8h
umov    w5, v16.h[0]
str     w5, [x2]
umov    w5, v18.h[0]
str     w5, [x2, #4]
umov    w5, v20.h[0]
str     w5, [x2, #8]
umov    w5, v22.h[0]
str     w5, [x2, #12]
ret
.size kp_asm_clip_stats, .-kp_asm_clip_stats

.p2align 4
.globl kp_asm_sum_i32
.type  kp_asm_sum_i32, %function
kp_asm_sum_i32:
movi    v0.2d, #0
movi    v1.2d, #0
mov     x6, #0
.Ls_loop:
cmp     w1, #4
b.lt    .Ls_tail
ld1     {v2.4s}, [x0], #16
sxtl    v3.2d, v2.2s
sxtl2   v4.2d, v2.4s
add     v0.2d, v0.2d, v3.2d
add     v1.2d, v1.2d, v4.2d
sub     w1, w1, #4
b       .Ls_loop
.Ls_tail:
cbz     w1, .Ls_done
ldr     w5, [x0], #4
sxtw    x5, w5
add     x6, x6, x5
subs    w1, w1, #1
b.ne    .Ls_tail
.Ls_done:
add     v0.2d, v0.2d, v1.2d
umov    x0, v0.d[0]
umov    x1, v0.d[1]
add     x0, x0, x1
add     x0, x0, x6
ret
.size kp_asm_sum_i32, .-kp_asm_sum_i32

.p2align 4
.globl kp_asm_sin_f4
.type  kp_asm_sin_f4, %function
kp_asm_sin_f4:
adrp    x3, .Lsin_c
add     x3, x3, :lo12:.Lsin_c
ld1     {v1.4s, v2.4s, v3.4s, v4.4s}, [x3], #64
ld1     {v5.4s}, [x3]
.Lsin_loop:
cmp     w2, #4
b.lt    .Lsin_done
ld1     {v0.4s}, [x0], #16
fmul    v6.4s, v0.4s, v0.4s
fmul    v7.4s, v6.4s, v5.4s
fadd    v7.4s, v7.4s, v4.4s
fmul    v7.4s, v7.4s, v6.4s
fadd    v7.4s, v7.4s, v3.4s
fmul    v7.4s, v7.4s, v6.4s
fadd    v7.4s, v7.4s, v2.4s
fmul    v7.4s, v7.4s, v6.4s
fadd    v7.4s, v7.4s, v1.4s
fmul    v7.4s, v7.4s, v0.4s
st1     {v7.4s}, [x1], #16
sub     w2, w2, #4
b       .Lsin_loop
.Lsin_done:
ret
.size kp_asm_sin_f4, .-kp_asm_sin_f4

.p2align 4
.Lclip_tbl:
.byte 0x40,0x00,0x00,0x04,0x00,0x00,0x04,0x00,0x04,0x04,0x04,0xAC,0x88,0xAC,0xA8,0x24
.p2align 4
.Lsin_c:
.float 1.0, 1.0, 1.0, 1.0
.float -0.16666667, -0.16666667, -0.16666667, -0.16666667
.float 0.00833333, 0.00833333, 0.00833333, 0.00833333
.float -0.00019841, -0.00019841, -0.00019841, -0.00019841
.float 0.00000276, 0.00000276, 0.00000276, 0.00000276
.section .note.GNU-stack,"",%progbits