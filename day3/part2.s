#NO_APP
	.section .bss,"aw",@nobits
.Linner_digits:
	.zero 12
.Ltotal:
	.zero 32
.Ltotal_rev:
	.zero 33
	.text
.Lout_fmt:
	.string "%s\n"
	.align 1
.globl main
main:
	.word 0x1c
	subl2 $4,%sp
	subl2 $128,%sp
.Lloop:
	movl %sp, %r0
	pushab __sF
	pushl $128
	pushl %r0
	calls $3,fgets
	cmpl %r0, $0

	bneq .Lnot_done
	jmp .Ldone
.Lnot_done:
	movl $11, %r7
	movl $0, %r1
	movl $0, %r0
.Lsearch_inner_init:
	movl $48, %r6

.Lsearch_inner_loop:
	addl3 %sp, %r1, %r8
	addl2 %r7, %r8
	cmpb $10, (%r8)
	beql .Lsearch_inner_fini

	cmpb %r6, (%sp)[%r1]
	bgeq .Lnext_inner_loop
	movb (%sp)[%r1], %r6
	movl %r1, %r0
.Lnext_inner_loop:
	addl2 $1, %r1
	jmp .Lsearch_inner_loop

.Lsearch_inner_fini:
	movb %r6, .Linner_digits[%r7]
	addl3 $1, %r0, %r1
	cmpl $0, %r7
	beql .Ladd_subtotal
	subl2 $1, %r7
	jmp .Lsearch_inner_init

.Ladd_subtotal:
	movl $2, %r0
.Lcvt_digit_loop:
	subl2 $0x30303030, .Linner_digits[%r0]
	sobgeq %r0, .Lcvt_digit_loop

	movl $0, %r6
	movl $0, %r7

.Ladd_loop:
	addb3 .Linner_digits[%r6], .Ltotal[%r6], %r0
	addb2 %r7, %r0
	movl $0, %r7
	cmpb %r0, $10
	blss .Lno_carry
	movl $1, %r7
	subb2 $10, %r0
.Lno_carry:
	movb %r0, .Ltotal[%r6]
	aoblss $12, %r6, .Ladd_loop
	addb2 %r7, .Ltotal+12
	cmpb .Ltotal+12, $10
	blss .Lproceed
	subb2 $10, .Ltotal+12
	addb2 $1, .Ltotal+13
	cmpb .Ltotal+13, $10
	blss .Lproceed
	subb2 $10, .Ltotal+13
	addb2 $1, .Ltotal+14
.Lproceed:
	jmp .Lloop
.Ldone:
	movl $7, %r0
.Lcvt_total_loop:
	addl2 $0x30303030, .Ltotal[%r0]
	sobgeq %r0, .Lcvt_total_loop

	movl $31, %r0
.Ltotal_rev_loop:
	subl3 %r0, $31, %r1
	movb .Ltotal[%r0], .Ltotal_rev[%r1]
	sobgeq %r0, .Ltotal_rev_loop

	movl $0, %r0
.Lfind_sig_digit:
	cmpb $48, .Ltotal_rev[%r0]
	bneq .Lprint
	addl2 $1, %r0
	jmp .Lfind_sig_digit
.Lprint:
	pushab .Ltotal_rev[%r0]
	pushab .Lout_fmt
	calls $2,printf
	ret
