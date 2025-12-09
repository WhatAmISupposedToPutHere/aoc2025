#define ENTS 1000
#define CONNS 1000
	.cpu arm10e
	.arch armv6
	.fpu vfp
	.eabi_attribute 28, 1
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.text
	.global	main
	.syntax unified
	.arm
	.type	main, %function
main:
	push {r4,r5,r6,r7,r8,r10,r11,lr}
	mov r4, #0
	mov r5, #0
.Lread_input:
	ldr r0, .Linput_fmt_p
	ldr r1, .Lpoints_p
	add r1, r1, r4
	add r2, r1, #4
	add r3, r1, #8
	bl scanf
	add r4, r4, #12
	add r5, r5, #1
	cmp r5, #ENTS
	bne .Lread_input


	ldr r2, .Lpoints_p
	ldr r3, .Ldists_p
	mov r0, #0
	mov r11, #0
.Ldist_next_col:
	mov r1, #0
	mov r10, #0

.Ldist_next_row:
	ldr r4, [r2, +r0]
	ldr r5, [r2, +r1]
	subs r5, r5, r4
	rsbmi r5, r5, #0
	umull r6, r7, r5, r5
	add r4, r0, #4
	add r5, r1, #4

	ldr r4, [r2, +r4]
	ldr r5, [r2, +r5]
	subs r5, r5, r4
	rsbmi r5, r5, #0
	umlal r6, r7, r5, r5
	add r4, r0, #8
	add r5, r1, #8

	ldr r4, [r2, +r4]
	ldr r5, [r2, +r5]
	subs r5, r5, r4
	rsbmi r5, r5, #0
	umlal r6, r7, r5, r5

	stmia r3!, {r6, r7}

	add r1, r1, #12
	add r10, r10, #1
	cmp r10, #ENTS
	bne .Ldist_next_row

	add r0, r0, #12
	add r11, r11, #1
	cmp r11, #ENTS
	bne .Ldist_next_col

	ldr r0, .Ladjm_p
	mov r1, #0
	mov r2, #1
.Linit_adjm:
	strb r2, [r0]
	add r0, r0, #ENTS
	add r0, r0, #1
	add r1, r1, #1
	cmp r1, #ENTS
	bne .Linit_adjm

	mov r0, #0
.Lfill_adj_next_loop:
	mov r1, #0
	mov r2, #0
	mvn r3, #0
	mvn r4, #0

	mov r5, #0
.Lfill_adj_next_row:
	mov r6, #0
.Lfill_adj_next_cell:
	ldr r8, .Ldists_p
	mov r7, #ENTS
	mul r7, r7, r5
	add r7, r7, r6
	add r8, r8, r7, LSL #3

	ldr r7, [r8]
	ldr r8, [r8, #4]
	orrs r10, r7, r8
	beq .Lfill_adj_proceed
	cmp r8, r4
	bhi .Lfill_adj_proceed
	cmp r7, r3
	bhi .Lfill_adj_proceed
	mov r4, r8
	mov r3, r7
	mov r1, r5
	mov r2, r6
.Lfill_adj_proceed:
	add r6, r6, #1
	cmp r6, #ENTS
	bne .Lfill_adj_next_cell
	add r5, r5, #1
	cmp r5, #ENTS
	bne .Lfill_adj_next_row

	mov r3, #ENTS
	mul r3, r3, r1
	add r3, r3, r2
	ldr r4, .Ladjm_p
	add r5, r4, r3
	mov r6, #1
	strb r6, [r5]

	mov r3, #ENTS
	mul r3, r3, r2
	add r3, r3, r1
	ldr r4, .Ladjm_p
	add r5, r4, r3
	mov r6, #1
	strb r6, [r5]

	mov r3, #ENTS
	mul r3, r3, r2
	add r3, r3, r1
	ldr r4, .Ldists_p
	add r5, r4, r3, LSL #3
	mov r6, #0
	str r6, [r5]
	str r6, [r5, #4]

	mov r3, #ENTS
	mul r3, r3, r1
	add r3, r3, r2
	ldr r4, .Ldists_p
	add r5, r4, r3, LSL #3
	mov r6, #0
	str r6, [r5]
	str r6, [r5, #4]

	add r0, r0, #1
	cmp r0, #CONNS
	bne .Lfill_adj_next_loop

	mov r4, #0
.Ldfs_call_loop:
	mov r0, r4
	add r1, r0, #1
	bl .Ldfs
	add r4, r4, #1
	cmp r4, #ENTS
	bne .Ldfs_call_loop

	mov r0, #0
	ldr r1, .Lszs_p
	ldr r2, .Llbl_p

.Lszs_loop:
	ldr r3, [r2, +r0, LSL #2]
	sub r3, r3, #1
	ldr r4, [r1, +r3, LSL #2]
	add r4, r4, #1
	str r4, [r1, +r3, LSL #2]
	add r0, r0, #1
	cmp r0, #ENTS
	bne .Lszs_loop

	mov r4, #0
.Ltop_outer_loop:
	mov r0, #0
	mov r1, #0
	mov r3, #0
	ldr r2, .Lszs_p

.Ltop_loop:
	ldr r5, [r2, +r0, LSL 2]
	cmp r1, r5
	bhi .Ltop_proceed
	mov r1, r5
	mov r3, r0
.Ltop_proceed:
	add r0, r0, #1
	cmp r0, #ENTS
	bne .Ltop_loop
	push {r1}
	mov r1, #0
	str r1, [r2, +r3, LSL 2]
	add r4, r4, #1
	cmp r4, 3
	bne .Ltop_outer_loop

	pop {r0, r1, r2}
	mul r2, r2, r0
	mul r1, r1, r2

	ldr r0, .Lout_fmt_p
	bl printf

	mov r0, #0
	pop {r4,r5,r6,r7,r8,r10,r11,pc}

.Ldfs:
	ldr r2, .Llbl_p
	ldr r3, [r2, r0, LSL #2]
	cmp r3, #0
	bxne lr
	push {r4, r5, r6, lr}

	str r1, [r2, r0, LSL #2]

	mov r4, #0
	ldr r5, .Ladjm_p
	mov r2, #ENTS
	mul r2, r2, r0
	add r5, r5, r2
	mov r6, r1
.Ldfs_loop:
	ldrb r0, [r5, +r4]
	cmp r0, #0
	beq .Ldfs_next
	mov r0, r4
	mov r1, r6
	bl .Ldfs
.Ldfs_next:
	add r4, r4, #1
	cmp r4, #ENTS
	bne .Ldfs_loop

	pop {r4, r5, r6, pc}
.Linput_fmt_p:
	.word .Linput_fmt
.Lout_fmt_p:
	.word .Lout_fmt
.Lpoints_p:
	.word .Lpoints
.Ldists_p:
	.word .Ldists
.Ladjm_p:
	.word .Ladjm
.Llbl_p:
	.word .Llbl
.Lszs_p:
	.word .Lszs
	.section	.note.GNU-stack,"",%progbits

	.section .rodata
.Linput_fmt:
	.ascii "%d,%d,%d\000"
.Lout_fmt:
	.ascii "%d\n\000"
	.bss
	.align 4
.Lpoints:
	.space ENTS*4*3
.Ldists:
	.space ENTS*ENTS*8
.Ladjm:
	.space ENTS*ENTS
.Llbl:
	.space ENTS*4
.Lszs:
	.space ENTS*4
