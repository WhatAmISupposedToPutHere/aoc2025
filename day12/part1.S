#define MODELS 6
#define QUERIES 1000
	.text
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	4
.Lout_fmt:
	.string "%d\n"
	.section	.text.startup,"ax",@progbits
	.literal_position
	.literal .Lsize_p, .Lsize
	.literal .Linput_data_p, input_data
	.literal .Lout_fmt_p, .Lout_fmt
	.align	4
	.global solve
	.type	solve, @function
solve:
	entry sp, 64
	l32r a2, .Linput_data_p
	l32i a2, a2, 0

	movi a8, 0
.Lnext_item:
	movi a3, 0
	addi a2, a2, 3

	movi a7, 3
.Lnext_row:
	movi a6, 3
.Lnext_cell:
	l8ui a4, a2, 0
	movi a5, '#'
	bne a4, a5, .Lempty
	addi a3, a3, 1
.Lempty:
	addi a2, a2, 1
	addi a6, a6, -1
	bnez a6, .Lnext_cell

	addi a7, a7, -1
	addi a2, a2, 1
	bnez a7, .Lnext_row

	l32r a4, .Lsize_p
	addx4 a4, a8, a4
	s32i a3, a4, 0

	addi a8, a8, 1
	movi a3, MODELS
	addi a2, a2, 1
	bne a3, a8, .Lnext_item

	movi a9, 0
	movi a10, QUERIES
.Lnext_query:
	l8ui a3, a2, 0
	addi a3, a3, -'0'
	l8ui a4, a2, 1
	addi a4, a4, -'0'
	movi a5, 10
	mull a3, a3, a5
	add a6, a4, a3

	l8ui a3, a2, 3
	addi a3, a3, -'0'
	l8ui a4, a2, 4
	addi a4, a4, -'0'
	movi a5, 10
	mull a3, a3, a5
	add a5, a4, a3

	mull a3, a5, a6
	addi a2, a2, 7

	movi a4, 0
	movi a8, 0
.Lnext_model_q:
	l8ui a5, a2, 0
	addi a5, a5, -'0'
	l8ui a6, a2, 1
	addi a6, a6, -'0'
	movi a7, 10
	mull a5, a5, a7
	add a5, a5, a6

	l32r a6, .Lsize_p
	addx4 a6, a4, a6
	l32i a6, a6, 0
	mull a5, a5, a6
	add a8, a8, a5

	addi a4, a4, 1
	addi a2, a2, 3

	movi a5, MODELS
	bne a4, a5, .Lnext_model_q

	bltu a3, a8, .Lno_fit
	addi a9, a9, 1
.Lno_fit:
	addi a10, a10, -1
	bnez a10, .Lnext_query

	l32r a10, .Lout_fmt_p
	mov a11, a9
	call8 printf

	retw
	.section	.bss
	.align	4
.Lsize:
	.zero MODELS*4
