#define GRID_W 1000
#define GRID_H 4
	.text
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lread_fmt:
	.string "%d"
.Lout_fmt:
	.string "%llu\n"
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	move.l %a2,-(%sp)
	move.l %a3,-(%sp)
	move.l %a5,-(%sp)
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	move.l %d4,-(%sp)
	move.l %d5,-(%sp)
	move.l %d6,-(%sp)
	lea (%pc, _GLOBAL_OFFSET_TABLE_@GOTPC), %a5

	move.l #(GRID_W*GRID_H*4),-(%sp)
	bsr.l malloc@PLTPC
	addq.l #4,%sp

	move.l %a0,%a2
	move.l %a0,%a3
	move.l #(GRID_W*GRID_H),%d2

.Lread_loop:
	cmp.l #0,%d2
	jeq .Lread_done
	pea (%a2)
	addq.l #4,%a2
	move.l .Lread_fmt@GOT(%a5),-(%sp)
	bsr.l scanf@PLTPC
	addq.l #8,%sp
	subq.l #1,%d2
	jmp .Lread_loop
.Lread_done:
	move.l #0,%d4
	move.l #0,%d5
	move.l #0,%d6
	movea.l %a3,%a2

.Lnext_cmd:
	bsr.l getchar@PLTPC
	cmp.l #'+',%d0
	jeq .Lexec_sum
	cmp.l #'*',%d0
	jeq .Lexec_prod
	jmp .Lnext_cmd

.Lexec_sum:
	move.l #GRID_H,%d3
	move.l #0,%d0
	move.l #0,%d1
	move.l #0,%d2
	movea.l %a3,%a0
.Lexec_sum_loop:
	cmp.l #0,%d3
	jeq .Lexec_done
	subq.l #1,%d3
	add.l (%a0),%d0
	addx.l %d1,%d2
	adda.l #(GRID_W*4),%a0
	jmp .Lexec_sum_loop

.Lexec_prod:
	move.l #GRID_H,%d3
	move.l #1,%d0
	move.l #0,%d2
	movea.l %a3,%a0
.Lexec_prod_loop:
	cmp.l #0,%d3
	jeq .Lexec_done
	mulu.l (%a0),%d1:%d0
	mulu.l (%a0),%d2
	add.l %d1,%d2
	adda.l #(GRID_W*4),%a0
	subq.l #1,%d3
	jmp .Lexec_prod_loop

.Lexec_done:
	addq.l #1,%d4
	addq.l #4,%a3
	add.l %d0,%d5
	addx.l %d2,%d6
	cmp.l #GRID_W,%d4
	jne .Lnext_cmd

	move.l %d5,-(%sp)
	move.l %d6,-(%sp)
	move.l .Lout_fmt@GOT(%a5),-(%sp)
	bsr.l printf@PLTPC
	adda.l #12,%sp

	move.l %a2,-(%sp)
	bsr.l free@PLTPC
	addq.l #4,%sp

	move.l (%sp)+,%d6
	move.l (%sp)+,%d5
	move.l (%sp)+,%d4
	move.l (%sp)+,%d3
	move.l (%sp)+,%d2
	move.l (%sp)+,%a5
	move.l (%sp)+,%a3
	move.l (%sp)+,%a2
	move.l #0,%d0
	rts

	.section	.note.GNU-stack,"",@progbits
