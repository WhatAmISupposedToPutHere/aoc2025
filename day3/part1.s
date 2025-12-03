#NO_APP
	.text
.Lout_fmt:
	.string "%d\n"
	.align 1
.globl main
main:
	.word 0x1c
	subl2 $4,%sp
	subl2 $128,%sp
	movl $0, %r8
.Lloop:
	movl %sp, %r0
	pushab __sF
	pushl $128
	pushl %r0
	calls $3,fgets
	cmpl %r0, $0
	beql .Ldone

	movl $0, %r0
	movl $0, %r1
	movl $48, %r6
	movl $48, %r7

.Lscan_first:
	cmpb $10, 1(%sp)[%r1]
	beql .Lgo_second

	cmpb %r6, (%sp)[%r1]
	bgeq .Lnext_first
	movb (%sp)[%r1], %r6
	movl %r1, %r0
.Lnext_first:
	addl2 $1, %r1
	jmp .Lscan_first

.Lgo_second:
	addl3 $1, %r0, %r1
.Lscan_second:
	cmpb $10, (%sp)[%r1]
	beql .Lgot_newline

	cmpb %r7, (%sp)[%r1]
	bgeq .Lnext_second
	movb (%sp)[%r1], %r7
	movl %r1, %r0
.Lnext_second:
	addl2 $1, %r1
	jmp .Lscan_second

.Lgot_newline:
	subl2 $48, %r6
	subl2 $48, %r7
	mull2 $10, %r6
	addl2 %r6, %r8
	addl2 %r7, %r8
	jmp .Lloop
.Ldone:
	pushl %r8
	pushab .Lout_fmt
	calls $2,printf
	ret
