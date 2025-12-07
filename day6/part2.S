#define GRID_W 3753
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
	move.l %a4,-(%sp)
	move.l %a5,-(%sp)
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	move.l %d4,-(%sp)
	move.l %d5,-(%sp)
	move.l %d6,-(%sp)
	move.l %d7,-(%sp)
	lea (%pc, _GLOBAL_OFFSET_TABLE_@GOTPC), %a5

	move.l #(GRID_W*4),-(%sp)
	bsr.l malloc@PLTPC
	move.l %a0,%a4
	move.l #(GRID_W*(GRID_H+1)+2),(%sp)
	bsr.l malloc@PLTPC
	movea.l %a0,%a2
	movea.l %a0,%a3
	addq.l #4,%sp

	move.l #(GRID_H+1),%d2
.Lread_grid:
	move.l stdin@GOT(%a5),%a0
	move.l (%a0),-(%sp)
	move.l #(GRID_W+2),-(%sp)
	move.l %a3,-(%sp)
	bsr.l fgets@PLTPC
	adda.l #12,%sp
	adda.l #GRID_W,%a3
	subq.l #1,%d2
	jne .Lread_grid

	move.l #GRID_W,%d3
	suba.l #(GRID_H+1),%sp
	move.l #0,%d5
	move.l #0,%d6
	move.l #0,%d7

.Lnext_col:
	move.l %sp,%a0
	move.l #GRID_H,%d4
	subq.l #1,%d3
	move.l %a2,%a3
	adda.l %d3,%a3

.Lnext_row:
	subq.l #1,%d4
	move.b (%a3),%d0
	move.b %d0,(%a0)+
	adda.l #GRID_W,%a3
	cmp.l #0,%d4
	jne .Lnext_row

	move.b #0,(%a0)+
	move.l %sp,%a0
	subq.l #4,%sp
	move.l %sp,%a1
	pea (%a1)
	move.l .Lread_fmt@GOT(%a5),-(%sp)
	pea (%a0)
	bsr.l sscanf@PLTPC
	adda.l #12,%sp

	move.l (%sp)+,%d1
	cmp.l #1,%d0
	jne .Ldont_stack
	move.l %d1,(%a4)+
	addq.l #1,%d5

.Ldont_stack:
	move.b (%a3),%d0
	cmp.b #'+',%d0
	jeq .Lexec_sum
	cmp.b #'*',%d0
	jeq .Lexec_prod
.Lnext_cmd:
	cmp.l #0,%d3
	jne .Lnext_col
	jmp .Lexit


.Lexec_sum:
	move.l #0,%d0
	move.l #0,%d1
	move.l #0,%d2
.Lexec_sum_loop:
	cmp.l #0,%d5
	jeq .Lexec_done
	subq.l #1,%d5
	add.l -(%a4),%d0
	addx.l %d1,%d2
	jmp .Lexec_sum_loop

.Lexec_prod:
	move.l #1,%d0
	move.l #0,%d2
.Lexec_prod_loop:
	cmp.l #0,%d5
	jeq .Lexec_done
	mulu.l -(%a4),%d1:%d0
	mulu.l (%a4),%d2
	add.l %d1,%d2
	subq.l #1,%d5
	jmp .Lexec_prod_loop

.Lexec_done:
	add.l %d0,%d6
	addx.l %d2,%d7
	jmp .Lnext_cmd

.Lexit:
	adda.l #(GRID_H+1),%sp

	move.l %d6,-(%sp)
	move.l %d7,-(%sp)
	move.l .Lout_fmt@GOT(%a5),-(%sp)
	bsr.l printf@PLTPC
	adda.l #12,%sp

	move.l %a2,-(%sp)
	bsr.l free@PLTPC
	addq.l #4,%sp

	move.l (%sp)+,%d7
	move.l (%sp)+,%d6
	move.l (%sp)+,%d5
	move.l (%sp)+,%d4
	move.l (%sp)+,%d3
	move.l (%sp)+,%d2
	move.l (%sp)+,%a5
	move.l (%sp)+,%a4
	move.l (%sp)+,%a3
	move.l (%sp)+,%a2
	move.l #0,%d0
	rts

	.section	.note.GNU-stack,"",@progbits
