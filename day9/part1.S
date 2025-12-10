#define ENTS 496
#define sp r30
#define lr r2
	.LEVEL 1.1
	.text
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align 4
.Lread_fmt:
	.stringz	"%d,%d"
.Ldbg_fmt:
	.stringz	"%llu\n"
	.section	.text.startup,"ax",@progbits
	.align 4
.globl main
	.type	main, @function
main:
	stw %lr, -20(%sp)
	ldo 64(%sp), %sp
	stw %r3, -52(%sp)
	stw %r4, -56(%sp)

	ldi ENTS, %r3
	ldil LR'.Lcoords, %r4
	ldo RR'.Lcoords(%r4), %r4

.Lread_loop:
	copy %r4, %r25
	ldil LR'.Lread_fmt, %r26
	ldo RR'.Lread_fmt(%r26), %r26
	bl scanf, %lr
	ldo 4(%r25), %r24

	addib,<> -1, %r3, .Lread_loop
	ldo 8(%r4), %r4

	ldi 0, %r22
	ldi 0, %r23
	ldil LR'.Lcoords, %r21
	ldo RR'.Lcoords(%r21), %r21

	ldi ENTS, %r20
.Lnext_y:
	ldo -1(%r20), %r20
	ldi ENTS, %r19
.Lnext_x:
	ldo -1(%r19), %r19

	sh3add %r19, %r21, %r24
	ldw 0(%r24), %r25
	sh3add %r20, %r21, %r24
	ldw 0(%r24), %r24
	sub,>>= %r25, %r24, %r24
	subi 0, %r24, %r24
	ldo 1(%r24), %r24
	stw %r24, -16(%sp)
	fldws -16(%sp), %fr8L

	sh3add %r19, %r21, %r24
	ldw 4(%r24), %r25
	sh3add %r20, %r21, %r24
	ldw 4(%r24), %r24
	sub,>>= %r25, %r24, %r24
	subi 0, %r24, %r24
	ldo 1(%r24), %r24
	stw %r24, -16(%sp)
	fldw -16(%sp), %fr8R

	xmpyu %fr8L,%fr8R,%fr8

	fstd %fr8, -16(%sp)

	ldw -16(%sp), %r24
	comb,>> %r24, %r23, .Ldo_write
	ldw -12(%sp), %r25
	comb,<< %r24, %r23, .Lcmp_proceed
	nop

	comb,<<,n %r25, %r22, .Lcmp_proceed
.Ldo_write:
	copy %r25, %r22
	copy %r24, %r23

.Lcmp_proceed:
	comib,<> 0, %r19, .Lnext_x
	nop
	comib,<> 0, %r20, .Lnext_y
	nop

	ldil LR'.Ldbg_fmt, %r26
	ldo RR'.Ldbg_fmt(%r26), %r26
	bl printf, %lr
	copy %r22, %r24
	copy %r23, %r24

	ldw -56(%sp), %r4
	ldw -52(%sp), %r3
	ldw -84(%sp), %lr

	bv %r0(%lr)
	ldo -64(%sp), %sp
	.section	.note.GNU-stack,"",@progbits
	.section	.bss
	.align 4
.Lcoords:
	.block ENTS*4*2
