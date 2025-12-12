#define ENTS 700
#define SLOTS_PER_ENT 30
#define r0 0
#define r1 1
#define r2 2
#define r3 3
#define r4 4
#define r5 5
#define r6 6
#define r7 7
#define r9 9
#define r10 10
#define r11 11
#define r16 16
#define r17 17
#define r18 18
#define r27 27
#define lr 26
#define rZ 31
	.set noreorder
	.set volatile
	.set noat
	.set nomacro
	.arch ev4
	.text
	.section	.text.startup,"ax",@progbits
	.align 4
	.globl main
	.ent main
main:
	ldah $gp, 0($r27) !gpdisp!1
	lda $gp, 0($gp) !gpdisp!1
	lda $sp, -32($sp)
	stq $r9, 8($sp)
	stq $r10, 16($sp)
	stq $r11, 24($sp)
	stq $lr, 0($sp)
	.prologue 1
	mov $rZ, $r9

$Lread_line:
	lda $r9, 1($r9)
	mov $rZ, $r10

	mov $rZ, $r16
	lda $r17, 32($sp)
	lda $r18, 5($rZ)
	ldq $r27, read($gp) !literal!2
	jsr $lr, ($r27), read !lituse_jsr!2
	ldah $gp, 0($lr) !gpdisp!3
	lda $gp, 0($gp) !gpdisp!3
	subq $r0, 5, $r0
	bne $r0, $Lread_done

	ldl $r1, 32($sp)
	bsr $lr, $Lname2idx

	ldah $r3, $Lindex($gp) !gprelhigh
	lda $r3, $Lindex($r3) !gprellow
	s4addq $r2, $r3, $r3
	stl $r9, 0($r3)

$Lread_adjm_next:
	mov $rZ, $r16
	lda $r17, 32($sp)
	lda $r18, 4($rZ)
	ldq $r27, read($gp) !literal!4
	jsr $lr, ($r27), read !lituse_jsr!4
	ldah $gp, 0($lr) !gpdisp!5
	lda $gp, 0($gp) !gpdisp!5

	ldl $r1, 32($sp)
	mov $r1, $r5

	bsr $lr, $Lname2idx
	ldah $r3, $Ladjm($gp) !gprelhigh
	lda $r3, $Ladjm($r3) !gprellow
	mulq $r9, (SLOTS_PER_ENT+1)*4, $r4
	addq $r3, $r4, $r3
	s4addq $r10, $r3, $r3
	stl $r2, 4($r3)

	lda $r10, 1($r10)

	srl $r5, 24, $r5
	zapnot $r5, 1, $r0
	subq $r0, '\n', $r0
	bne $r0, $Lread_adjm_next
$Lnext_line:
	ldah $r3, $Ladjm($gp) !gprelhigh
	lda $r3, $Ladjm($r3) !gprellow
	mulq $r9, (SLOTS_PER_ENT+1)*4, $r4
	addq $r3, $r4, $r3
	stl $r10, 0($r3)
	br $rZ, $Lread_line

$Lread_done:
	ldah $r1, 0x72($rZ)
	lda $r1, 0x7673($r1)
	bsr $lr, $Lname2idx
	mov $r2, $r4
	ldah $r1, 0x74($rZ)
	lda $r1, 0x6666($r1)
	bsr $lr, $Lname2idx
	mov $r4, $r1
	ldah $r3, $Lmemo($gp) !gprelhigh
	lda $r3, $Lmemo($r3) !gprellow
	ldah $r4, $Lindex($gp) !gprelhigh
	lda $r4, $Lindex($r4) !gprellow
	ldah $r6, $Ladjm($gp) !gprelhigh
	lda $r6, $Ladjm($r6) !gprellow
	bsr $lr, $Lseek
	mov $r0, $r7
	bsr $lr, $Lclr_memo

	ldah $r1, 0x74($rZ)
	lda $r1, 0x6666($r1)
	bsr $lr, $Lname2idx
	mov $r2, $r4
	ldah $r1, 0x63($rZ)
	lda $r1, 0x6164($r1)
	bsr $lr, $Lname2idx
	mov $r4, $r1
	ldah $r3, $Lmemo($gp) !gprelhigh
	lda $r3, $Lmemo($r3) !gprellow
	ldah $r4, $Lindex($gp) !gprelhigh
	lda $r4, $Lindex($r4) !gprellow
	ldah $r6, $Ladjm($gp) !gprelhigh
	lda $r6, $Ladjm($r6) !gprellow
	bsr $lr, $Lseek
	mulq $r0, $r7, $r7
	bsr $lr, $Lclr_memo

	ldah $r1, 0x63($rZ)
	lda $r1, 0x6164($r1)
	bsr $lr, $Lname2idx
	mov $r2, $r4
	ldah $r1, 0x74($rZ)
	lda $r1, 0x756f($r1)
	bsr $lr, $Lname2idx
	mov $r4, $r1
	ldah $r3, $Lmemo($gp) !gprelhigh
	lda $r3, $Lmemo($r3) !gprellow
	ldah $r4, $Lindex($gp) !gprelhigh
	lda $r4, $Lindex($r4) !gprellow
	ldah $r6, $Ladjm($gp) !gprelhigh
	lda $r6, $Ladjm($r6) !gprellow
	bsr $lr, $Lseek
	mulq $r0, $r7, $r7

	ldah $r16, $Lout_fmt($gp) !gprelhigh
	lda $r16, $Lout_fmt($r16) !gprellow
	mov $r7, $r17
	ldq $r27, printf($gp) !literal!6
	jsr $lr, ($r27), printf !lituse_jsr!6


	ldq $lr, 0($sp)
	ldq $r9, 8($sp)
	ldq $r10, 16($sp)
	ldq $r11, 24($sp)
	lda $sp, 32($sp)
	ret $rZ, ($lr), 1

$Lseek:
	subq $r1, $r2, $r0
	bne $r0, $Lseek_not_final
	lda $r0, 1($rZ)
	ret $rZ, ($lr), 0
$Lseek_not_final:
	s4addq $r1, $r4, $r5
	ldl $r5, 0($r5)
	bne $r5, $Lhas_ent
	mov $rZ, $r0
	ret $rZ, ($lr), 0
$Lhas_ent:
	s8addq $r5, $r3, $r0
	ldq $r0, 0($r0)
	beq $r0, $Lseek_calc
	lda $r0, -1($r0)
	ret $rZ, ($lr), 0
$Lseek_calc:
	lda $sp, -48($sp)
	stq $lr, 0($sp)
	stq $r5, 8($sp)
	stq $r9, 16($sp)
	stq $r10, 24($sp)
	stq $r11, 32($sp)

	mov $rZ, $r11

	mulq $r5, (SLOTS_PER_ENT+1)*4, $r0
	addq $r6, $r0, $r9
	ldl $r10, 0($r9)
$Lseek_loop:
	beq $r10, $Lseek_calc_done
	s4addq $r10, $r9, $r0
	ldl $r1, 0($r0)
	bsr $lr, $Lseek
	addq $r0, $r11, $r11
	lda $r10, -1($r10)
	br $rZ, $Lseek_loop

$Lseek_calc_done:
	ldq $r5, 8($sp)
	s8addq $r5, $r3, $r0
	lda $r1, 1($r11)
	stq $r1, 0($r0)

	mov $r11, $r0
	ldq $lr, 0($sp)
	ldq $r9, 16($sp)
	ldq $r10, 24($sp)
	ldq $r11, 32($sp)
	lda $sp, 48($sp)
	ret $rZ, ($lr), 0
$Lname2idx:
	zapnot $r1, 7, $r1
	ldah $r2, 0x61($rZ)
	lda $r2, 0x6161($r2)
	subq $r1, $r2, $r1
	zapnot $r1, 1, $r2
	mulq $r2, 26, $r2
	srl $r1, 8, $r1
	zapnot $r1, 1, $r3
	addq $r2, $r3, $r2
	mulq $r2, 26, $r2
	srl $r1, 8, $r1
	zapnot $r1, 1, $r3
	addq $r2, $r3, $r2
	ret $rZ, ($lr), 0

$Lclr_memo:
	lda $r0, ENTS($rZ)
$Lclr_loop:
	lda $r0, -1($r0)
	s8addq $r0, $r3, $r1
	stq $rZ, 0($r1)
	bne $r0, $Lclr_loop
	ret $rZ, ($lr), 0
	.end main

	.section	.rodata.str1.1,"aMS",@progbits,1
$Lout_fmt:
	.string "%ld\n"
	.section	.sbss,"aw"
	.align 8
$Lindex:
	.zero (26*26*26*4)
$Ladjm:
	.zero (ENTS*(SLOTS_PER_ENT+1)*4)
$Lmemo:
	.zero (ENTS*8)
	.section	.note.GNU-stack,"",@progbits
