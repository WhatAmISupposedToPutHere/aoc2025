	.text
	.section	.rodata.str1.4,"aMS",@progbits,1
.Lout_fmt:
	.string "%d\n"
	.little
	.section	.text.startup,"ax",@progbits
	.align 2
	.global	main
	.type	main, @function
main:
	mov.l r8, @-r15
	mov.l r9, @-r15
	mov.l r10, @-r15
	mov.l r11, @-r15
	sts.l pr, @-r15
	mov #0, r11
.Lmain_loop:
	mov.l .Lgetchar_p, r0
	jsr @r0
	mov #0, r8
	mov #1, r9
	cmp/eq #-1, r0
	bt .Lexit
.Lread_tgt:
	mov.l .Lgetchar_p, r0
	jsr @r0
	nop
	cmp/eq #']', r0
	bt .Lread_coefs

	cmp/eq #'.', r0
	bt .Ltgt_proceed
	or r9, r8

.Ltgt_proceed:
	bra .Lread_tgt
	shll r9

.Lread_coefs:
	mov r15, r10
.Lread_one_coef:
	mov #0, r9
	mov.l .Lgetchar_p, r0
	jsr @r0
	nop

	mov.l .Lgetchar_p, r0
	jsr @r0
	nop

	cmp/eq #'{', r0
	bf .Lread_digit
	bra .Lproc_line
	nop
.Lread_digit:
	mov.l .Lgetchar_p, r0
	jsr @r0
	nop

	mov #'0', r2
	sub r2, r0
	mov #1, r1
	shld r0, r1

	mov.l .Lgetchar_p, r0
	jsr @r0
	or r1, r9

	cmp/eq #')', r0
	bt .Lnext_coef
	bra .Lread_digit
	nop
.Lnext_coef:
	mov.l r9, @-r15
	bra .Lread_one_coef
	nop
.Lproc_line:
	mov r10, r0
	sub r15, r0
	shlr2 r0
	mov r0, r4
	mov #1, r1
	shld r0, r1
	dt r1


	mov #-1, r2
.Ltest_cand:
	mov #0, r3
	mov #0, r5
	mov #0, r6
.Lxor_coefs:
	mov #1, r0
	shld r5, r0
	tst r0, r1
	bt .Lno_xor
	nop
	mov r6, r0
	mov.l @(r0, r15), r0
	xor r0, r3

.Lno_xor:
	add #4, r6
	add #1, r5
	cmp/eq r5, r4
	bt .Lxor_coefs_break
	nop
	bra .Lxor_coefs
	nop
.Lxor_coefs_break:
	cmp/eq r3, r8
	bt .Lnext_cand_sk
	nop
	bra .Lnext_cand
	nop
.Lnext_cand_sk:
	mov #32, r3
	mov #0, r5
	mov r1, r6
.Lpcnt:
	mov r6, r0
	and #1, r0
	add r0, r5
	shlr r6
	dt r3
	bt .Lpcnt_break
	nop
	bra .Lpcnt
	nop
.Lpcnt_break:
	cmp/hi r5, r2
	bf .Lnext_cand
	nop
	mov r5, r2

.Lnext_cand:
	dt r1
	bt .Ltest_cand_break
	nop
	bra .Ltest_cand
	nop
.Ltest_cand_break:
	add r2, r11
	mov r10, r15

.Lflush_nl:
	mov.l .Lgetchar_p, r0
	jsr @r0
	nop
	cmp/eq #-1, r0
	bt .Lexit
	nop
	cmp/eq #'\n', r0
	bt .Lflush_nl_sk
	nop
	bra .Lflush_nl
	nop
.Lflush_nl_sk:
	bra .Lmain_loop
	nop
.Lexit:
	mov.l .Lout_fmt_p, r4
	mov.l .Lprintf_p, r0
	jsr @r0
	mov r11, r5

	lds.l @r15+, pr
	mov.l @r15+, r11
	mov.l @r15+, r10
	mov.l @r15+, r9
	rts
	mov.l @r15+, r8

	.align 2
.Lgetchar_p:
	.long getchar
.Lprintf_p:
	.long printf
.Lout_fmt_p:
	.long .Lout_fmt
	.section	.note.GNU-stack,"",@progbits
