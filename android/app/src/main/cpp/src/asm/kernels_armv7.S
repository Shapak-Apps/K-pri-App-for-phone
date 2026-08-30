.syntax unified
.arch armv7-a
.fpu neon
.arm
.text
.p2align 4
.globl kp_asm_gray_rgb888
.type  kp_asm_gray_rgb888, %function
kp_asm_gray_rgb888:
vmov.i8     d18, #77
vmov.i8     d20, #150
vmov.i8     d22, #29
cmp         r2, #8
blt         .Lg_tail
.Lg_loop:
vld3.8      {d0, d1, d2}, [r1]!
vmull.u8    q2, d0, d18
vmull.u8    q3, d1, d20
vmull.u8    q4, d2, d22
vadd.i16    q2, q2, q3
vadd.i16    q2, q2, q4
vshrn.u16   d6, q2, #8
vst1.8      {d6}, [r0]!
subs        r2, r2, #8
cmp         r2, #8
bge         .Lg_loop
.Lg_tail:
cmp         r2, #0
ble         .Lg_done
.Lg_tail_loop:
ldrb        r4, [r1], #1
ldrb        r5, [r1], #1
ldrb        r6, [r1], #1
mov         r7, #77
mul         r4, r4, r7
mov         r7, #150
mla         r4, r5, r7, r4
mov         r7, #29
mla         r4, r6, r7, r4
lsr         r4, r4, #8
strb        r4, [r0], #1
subs        r2, r2, #1
bgt         .Lg_tail_loop
.Lg_done:
bx          lr
.size kp_asm_gray_rgb888, .-kp_asm_gray_rgb888

.p2align 4
.globl kp_asm_contrast_u8
.type  kp_asm_contrast_u8, %function
kp_asm_contrast_u8:
vmov.i16    q8, #128
vdup.16     q9, r3
cmp         r2, #16
blt         .Lc_tail
.Lc_loop:
vld1.8      {q0}, [r1]!
vmovl.u8    q1, d0
vmovl.u8    q2, d1
vsub.i16    q1, q1, q8
vsub.i16    q2, q2, q8
vmul.i16    q1, q1, q9
vmul.i16    q2, q2, q9
vrshr.s16   q1, q1, #8
vrshr.s16   q2, q2, #8
vadd.i16    q1, q1, q8
vadd.i16    q2, q2, q8
vqmovun.s16 d0, q1
vqmovun.s16 d1, q2
vst1.8      {q0}, [r0]!
subs        r2, r2, #16
cmp         r2, #16
bge         .Lc_loop
.Lc_tail:
cmp         r2, #0
ble         .Lc_done
.Lc_tail_loop:
ldrb        r4, [r1], #1
sub         r4, r4, #128
mul         r4, r4, r3
add         r4, r4, #128
asr         r4, r4, #8
add         r4, r4, #128
cmp         r4, #255
movgt       r4, #255
cmp         r4, #0
movlt       r4, #0
strb        r4, [r0], #1
subs        r2, r2, #1
bgt         .Lc_tail_loop
.Lc_done:
bx          lr
.size kp_asm_contrast_u8, .-kp_asm_contrast_u8

.p2align 4
.globl kp_asm_median3_row
.type  kp_asm_median3_row, %function
kp_asm_median3_row:
push        {r4, lr}
ldr         r4, [sp, #8]
cmp         r4, #8
blt         .Lm_done
.Lm_loop:
vld1.8      {d16}, [r1]
add         r12, r1, #1
vld1.8      {d17}, [r12]
add         r12, r1, #2
vld1.8      {d18}, [r12]
vld1.8      {d19}, [r2]
add         r12, r2, #1
vld1.8      {d20}, [r12]
add         r12, r2, #2
vld1.8      {d21}, [r12]
vld1.8      {d22}, [r3]
add         r12, r3, #1
vld1.8      {d23}, [r12]
add         r12, r3, #2
vld1.8      {d24}, [r12]
add         r1, r1, #8
add         r2, r2, #8
add         r3, r3, #8
vmin.u8     d25, d16, d17
vmax.u8     d26, d16, d17
vmin.u8     d27, d25, d18
vmax.u8     d28, d26, d18
vmax.u8     d25, d25, d18
vmin.u8     d25, d25, d26
vmov        d16, d27
vmov        d17, d25
vmov        d18, d28
vmin.u8     d25, d16, d19
vmax.u8     d28, d18, d19
vmax.u8     d26, d16, d19
vmin.u8     d26, d26, d17
vmax.u8     d27, d17, d19
vmin.u8     d27, d27, d18
vmov        d16, d25
vmov        d17, d26
vmov        d18, d27
vmov        d19, d28
vmin.u8     d25, d16, d20
vmax.u8     d29, d19, d20
vmax.u8     d26, d16, d20
vmin.u8     d26, d26, d17
vmax.u8     d27, d17, d20
vmin.u8     d27, d27, d18
vmax.u8     d28, d18, d20
vmin.u8     d28, d28, d19
vmov        d16, d25
vmov        d17, d26
vmov        d18, d27
vmov        d19, d28
vmov        d20, d29
vmin.u8     d25, d16, d21
vmax.u8     d30, d20, d21
vmax.u8     d26, d16, d21
vmin.u8     d26, d26, d17
vmax.u8     d27, d17, d21
vmin.u8     d27, d27, d18
vmax.u8     d28, d18, d21
vmin.u8     d28, d28, d19
vmax.u8     d29, d19, d21
vmin.u8     d29, d29, d20
vmov        d16, d25
vmov        d17, d26
vmov        d18, d27
vmov        d19, d28
vmov        d20, d29
vmov        d21, d30
vmax.u8     d25, d16, d22
vmax.u8     d26, d17, d22
vmax.u8     d27, d18, d22
vmax.u8     d28, d19, d22
vmax.u8     d29, d20, d22
vmax.u8     d30, d21, d22
vmin.u8     d31, d16, d22
vmin.u8     d25, d25, d17
vmin.u8     d26, d26, d18
vmin.u8     d27, d27, d19
vmin.u8     d28, d28, d20
vmin.u8     d29, d29, d21
vmov        d16, d31
vmov        d17, d25
vmov        d18, d26
vmov        d19, d27
vmov        d20, d28
vmov        d21, d29
vmov        d22, d30
vmax.u8     d25, d16, d23
vmax.u8     d26, d17, d23
vmax.u8     d27, d18, d23
vmax.u8     d28, d19, d23
vmax.u8     d29, d20, d23
vmax.u8     d30, d21, d23
vmax.u8     d31, d22, d23
vmin.u8     d16, d16, d23
vmin.u8     d25, d25, d17
vmin.u8     d26, d26, d18
vmin.u8     d27, d27, d19
vmin.u8     d28, d28, d20
vmin.u8     d29, d29, d21
vmin.u8     d30, d30, d22
vmov        d17, d25
vmov        d18, d26
vmov        d19, d27
vmov        d20, d28
vmov        d21, d29
vmov        d22, d30
vmov        d23, d31
vmax.u8     d25, d16, d24
vmax.u8     d26, d17, d24
vmax.u8     d27, d18, d24
vmax.u8     d28, d19, d24
vmax.u8     d29, d20, d24
vmax.u8     d30, d21, d24
vmax.u8     d31, d22, d24
vmin.u8     d31, d31, d23
vmax.u8     d23, d23, d24
vmin.u8     d16, d16, d24
vmin.u8     d25, d25, d17
vmin.u8     d26, d26, d18
vmin.u8     d27, d27, d19
vmin.u8     d28, d28, d20
vmin.u8     d29, d29, d21
vmin.u8     d30, d30, d22
vmov        d17, d25
vmov        d18, d26
vmov        d19, d27
vmov        d20, d28
vmov        d21, d29
vmov        d22, d30
vst1.8      {d20}, [r0]!
subs        r4, r4, #8
cmp         r4, #8
bge         .Lm_loop
.Lm_done:
ldr         r0, [sp, #8]
sub         r0, r0, r4
pop         {r4, lr}
bx          lr
.size kp_asm_median3_row, .-kp_asm_median3_row

.p2align 4
.globl kp_asm_json_scan
.type  kp_asm_json_scan, %function
kp_asm_json_scan:
mov         r12, r1
mov         r2, r0
mov         r3, #0x22
vdup.8      d4, r3
mov         r3, #0x5C
vdup.8      d5, r3
.Ljs_loop:
cmp         r1, #16
blt         .Ljs_tail
vld1.8      {q0}, [r0]!
vceq.i8     d6, d0, d4
vceq.i8     d7, d1, d4
vceq.i8     d8, d0, d5
vceq.i8     d9, d1, d5
vorr        d6, d6, d8
vorr        d7, d7, d9
vorr        d6, d6, d7
vpmax.u8    d6, d6, d6
vpmax.u8    d6, d6, d6
vpmax.u8    d6, d6, d6
vmov.32     r3, d6[0]
cmp         r3, #0
bne         .Ljs_found
sub         r1, r1, #16
b           .Ljs_loop
.Ljs_found:
sub         r0, r0, #16
.Ljs_tail:
cmp         r1, #0
beq         .Ljs_none
.Ljs_tail_loop:
ldrb        r3, [r0], #1
cmp         r3, #0x22
beq         .Ljs_hit
cmp         r3, #0x5C
beq         .Ljs_hit
subs        r1, r1, #1
bne         .Ljs_tail_loop
.Ljs_none:
mov         r0, r12
bx          lr
.Ljs_hit:
sub         r0, r0, #1
sub         r0, r0, r2
bx          lr
.size kp_asm_json_scan, .-kp_asm_json_scan

.p2align 4
.globl kp_asm_json_ws
.type  kp_asm_json_ws, %function
kp_asm_json_ws:
mov         r12, r1
mov         r2, r0
mov         r3, #0x20
vdup.8      d4, r3
mov         r3, #0x09
vdup.8      d5, r3
mov         r3, #0x0D
vdup.8      d6, r3
.Ljw_loop:
cmp         r1, #16
blt         .Ljw_tail
vld1.8      {q0}, [r2]!
vceq.i8     d7, d0, d4
vceq.i8     d8, d1, d4
vcge.u8     d9, d0, d5
vcge.u8     d10, d6, d0
vcge.u8     d11, d1, d5
vcge.u8     d12, d6, d1
vand        d9, d9, d10
vand        d11, d11, d12
vorr        d7, d7, d9
vorr        d8, d8, d11
vmvn        d7, d7
vmvn        d8, d8
vpmax.u8    d7, d7, d8
vpmax.u8    d7, d7, d7
vpmax.u8    d7, d7, d7
vpmax.u8    d7, d7, d7
vmov.32     r3, d7[0]
cmp         r3, #0
bne         .Ljw_found
sub         r1, r1, #16
b           .Ljw_loop
.Ljw_found:
sub         r2, r2, #16
.Ljw_tail:
cmp         r1, #0
beq         .Ljw_none
.Ljw_tail_loop:
ldrb        r3, [r2], #1
cmp         r3, #0x20
beq         .Ljw_next
cmp         r3, #0x09
blo         .Ljw_hit
cmp         r3, #0x0D
ble         .Ljw_next
.Ljw_hit:
sub         r2, r2, #1
sub         r0, r2, r0
bx          lr
.Ljw_next:
subs        r1, r1, #1
bne         .Ljw_tail_loop
.Ljw_none:
mov         r0, r12
bx          lr
.size kp_asm_json_ws, .-kp_asm_json_ws

.p2align 4
.globl kp_asm_csv_scan
.type  kp_asm_csv_scan, %function
kp_asm_csv_scan:
mov         r12, r1
mov         r2, r0
mov         r3, #0x22
vdup.8      d4, r3
mov         r3, #0x0A
vdup.8      d5, r3
mov         r3, #0x0D
vdup.8      d6, r3
.Lcs_loop:
cmp         r1, #16
blt         .Lcs_tail
vld1.8      {q0}, [r0]!
vceq.i8     d7, d0, d4
vceq.i8     d8, d1, d4
vceq.i8     d9, d0, d5
vceq.i8     d10, d1, d5
vceq.i8     d11, d0, d6
vceq.i8     d12, d1, d6
vorr        d7, d7, d9
vorr        d8, d8, d10
vorr        d7, d7, d11
vorr        d8, d8, d12
vpmax.u8    d7, d7, d8
vpmax.u8    d7, d7, d7
vpmax.u8    d7, d7, d7
vmov.32     r3, d7[0]
cmp         r3, #0
bne         .Lcs_found
sub         r1, r1, #16
b           .Lcs_loop
.Lcs_found:
sub         r0, r0, #16
.Lcs_tail:
cmp         r1, #0
beq         .Lcs_none
.Lcs_tail_loop:
ldrb        r3, [r0], #1
cmp         r3, #0x22
beq         .Lcs_hit
cmp         r3, #0x0A
beq         .Lcs_hit
cmp         r3, #0x0D
beq         .Lcs_hit
subs        r1, r1, #1
bne         .Lcs_tail_loop
.Lcs_none:
mov         r0, r12
bx          lr
.Lcs_hit:
sub         r0, r0, #1
sub         r0, r0, r2
bx          lr
.size kp_asm_csv_scan, .-kp_asm_csv_scan

.p2align 4
.globl kp_asm_clip_stats
.type  kp_asm_clip_stats, %function
kp_asm_clip_stats:
push        {r4, r5, r6, r7, lr}
vpush       {d8, d9, d10, d11, d12, d13, d14, d15}
vmov.i16    q4, #0
vmov.i16    q5, #0
vmov.i16    q6, #0
vmov.i16    q7, #0
adr         r5, .Lclip_tbl
vld1.8      {d16}, [r5]
mov         r3, #'a'
vdup.8      d17, r3
mov         r3, #'z'
vdup.8      d18, r3
mov         r3, #'0'
vdup.8      d19, r3
mov         r3, #'9'
vdup.8      d20, r3
mov         r3, #' '
vdup.8      d21, r3
mov         r3, #'\t'
vdup.8      d22, r3
.Lcl_loop:
cmp         r1, #8
blt         .Lcl_tail
vld1.8      {d0}, [r0]!
vmov.i8     d23, #0x20
vorr        d2, d0, d23
vcge.u8     d4, d2, d17
vcge.u8     d5, d18, d2
vand        d4, d4, d5
vcge.u8     d5, d0, d19
vcge.u8     d6, d20, d0
vand        d5, d5, d6
vceq.i8     d6, d0, d21
vceq.i8     d7, d0, d22
vorr        d6, d6, d7
vmov.i8     d23, #0x0F
vand        d2, d0, d23
vshr.u8     d3, d0, #4
vtbl.8      d7, {d16}, d2
vneg.s8     d3, d3
vshl.s8     d7, d7, d3
vmov.i8     d23, #1
vand        d7, d7, d23
vshr.u8     d4, d4, #7
vshr.u8     d5, d5, #7
vshr.u8     d6, d6, #7
vaddw.u8    q4, q4, d4
vaddw.u8    q5, q5, d5
vaddw.u8    q6, q6, d6
vaddw.u8    q7, q7, d7
sub         r1, r1, #8
b           .Lcl_loop
.Lcl_tail:
cmp         r1, #0
beq         .Lcl_done
.Lcl_tail_loop:
ldrb        r5, [r0], #1
orr         r7, r5, #0x20
cmp         r7, #'a'
blo         .Lcl_t1
cmp         r7, #'z'
bhi         .Lcl_t1
ldr         r6, [r2]
add         r6, r6, #1
str         r6, [r2]
.Lcl_t1:
cmp         r5, #'0'
blo         .Lcl_t2
cmp         r5, #'9'
bhi         .Lcl_t2
ldr         r6, [r2, #4]
add         r6, r6, #1
str         r6, [r2, #4]
.Lcl_t2:
cmp         r5, #' '
beq         .Lcl_sp
cmp         r5, #'\t'
bne         .Lcl_t3
.Lcl_sp:
ldr         r6, [r2, #8]
add         r6, r6, #1
str         r6, [r2, #8]
.Lcl_t3:
adr         r7, .Lclip_tbl
and         r6, r5, #0x0F
lsr         r4, r5, #4
ldrb        r6, [r7, r6]
lsr         r6, r6, r4
and         r6, r6, #1
ldr         r4, [r2, #12]
add         r4, r4, r6
str         r4, [r2, #12]
subs        r1, r1, #1
bne         .Lcl_tail_loop
.Lcl_done:
vadd.u16    d8, d8, d9
vadd.u16    d10, d10, d11
vadd.u16    d12, d12, d13
vadd.u16    d14, d14, d15
vpaddl.u16  d8, d8
vpaddl.u16  d10, d10
vpaddl.u16  d12, d12
vpaddl.u16  d14, d14
vpadd.u32   d8, d8, d8
vpadd.u32   d10, d10, d10
vpadd.u32   d12, d12, d12
vpadd.u32   d14, d14, d14
ldr         r5, [r2]
vmov.32     r6, d8[0]
add         r5, r5, r6
str         r5, [r2]
ldr         r5, [r2, #4]
vmov.32     r6, d10[0]
add         r5, r5, r6
str         r5, [r2, #4]
ldr         r5, [r2, #8]
vmov.32     r6, d12[0]
add         r5, r5, r6
str         r5, [r2, #8]
ldr         r5, [r2, #12]
vmov.32     r6, d14[0]
add         r5, r5, r6
str         r5, [r2, #12]
vpop        {d8, d9, d10, d11, d12, d13, d14, d15}
pop         {r4, r5, r6, r7, lr}
bx          lr
.size kp_asm_clip_stats, .-kp_asm_clip_stats

.p2align 4
.globl kp_asm_sum_i32
.type  kp_asm_sum_i32, %function
kp_asm_sum_i32:
push        {r4, r5, r6, lr}
vmov.i64    q8, #0
vmov.i64    q9, #0
mov         r4, #0
mov         r5, #0
.Ls_loop:
cmp         r1, #4
blt         .Ls_tail
vld1.32     {d0, d1}, [r0]!
vmovl.s32   q1, d0
vmovl.s32   q2, d1
vadd.s64    q8, q8, q1
vadd.s64    q9, q9, q2
sub         r1, r1, #4
b           .Ls_loop
.Ls_tail:
cmp         r1, #0
beq         .Ls_done
ldr         r6, [r0], #4
adds        r4, r4, r6
adc         r5, r5, r6, asr #31
subs        r1, r1, #1
bne         .Ls_tail
.Ls_done:
vadd.s64    q8, q8, q9
vmov        r0, r1, d16
vmov        r2, r3, d17
adds        r0, r0, r2
adc         r1, r1, r3
adds        r0, r0, r4
adc         r1, r1, r5
pop         {r4, r5, r6, lr}
bx          lr
.size kp_asm_sum_i32, .-kp_asm_sum_i32

.p2align 4
.globl kp_asm_sin_f4
.type  kp_asm_sin_f4, %function
kp_asm_sin_f4:
adr         r3, .Lsin_c
vld1.32     {q8, q9}, [r3]!
vld1.32     {q10, q11}, [r3]!
vld1.32     {q12}, [r3]
.Lsin_loop:
cmp         r2, #4
blt         .Lsin_done
vld1.32     {q0}, [r0]!
vmul.f32    q1, q0, q0
vmul.f32    q2, q1, q12
vadd.f32    q2, q2, q11
vmul.f32    q2, q2, q1
vadd.f32    q2, q2, q10
vmul.f32    q2, q2, q1
vadd.f32    q2, q2, q9
vmul.f32    q2, q2, q1
vadd.f32    q2, q2, q8
vmul.f32    q2, q2, q0
vst1.32     {q2}, [r1]!
sub         r2, r2, #4
b           .Lsin_loop
.Lsin_done:
bx          lr
.size kp_asm_sin_f4, .-kp_asm_sin_f4

.p2align 2
.Lclip_tbl:
.byte 0x40,0x00,0x00,0x04,0x00,0x00,0x04,0x00,0x04,0x04,0x04,0xAC,0x88,0xAC,0xA8,0x24
.p2align 2
.Lsin_c:
.float 1.0, 1.0, 1.0, 1.0
.float -0.16666667, -0.16666667, -0.16666667, -0.16666667
.float 0.00833333, 0.00833333, 0.00833333, 0.00833333
.float -0.00019841, -0.00019841, -0.00019841, -0.00019841
.float 0.00000276, 0.00000276, 0.00000276, 0.00000276
.section .note.GNU-stack,"",%progbits