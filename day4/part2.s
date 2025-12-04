	.setcpu		"6502"
	.smart		on
	.autoimport	on
	.case		on
	.importzp	sp, sreg, regsave, regbank
	.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4
	.forceimport	__STARTUP__
	.import		_stdin
	.import		_fgets
	.import		_puts
	.export		_main
	.feature string_escapes
	.macpack generic
GRID_COLS = 139
.zeropage
_grid_ptr:
	.res 2
_counter:
	.res 2, $0000
_adj_counter:
	.res 1, $00
_cur_row:
	.res 1, $00
_cur_col:
	.res 1, $00
_did_something:
	.res 1, $00
_grid_action:
	.res 1, $00
.data
_grid:
	.res	(GRID_COLS + 2),$21
	.res	((GRID_COLS + 2) * GRID_COLS),$00
	.res	(GRID_COLS + 2),$21

.rodata
_dot:
	.asciiz "%d\n"

.code
.proc _main: near
	jsr _reset_gptr

Lread_loop:
	lda _grid_ptr
	ldx _grid_ptr+1
	jsr pushax
	ldx #0
	lda #(GRID_COLS+2)
	jsr pushax
	lda _stdin
	ldx _stdin+1
	jsr _fgets
	stx tmp1
	ora tmp1
	pha

	lda #1
	jsr _sub_gptr
	ldy #0
	lda #$21
	sta (_grid_ptr),y
	ldy #(GRID_COLS+1)
	sta (_grid_ptr),y
	lda #1
	jsr _add_gptr
	pla
	beq Ldone_reading
	lda #(GRID_COLS+2)
	jsr _add_gptr
	jmp Lread_loop

Ldone_reading:
	lda #0
	sta _counter
	sta _counter+1
Lstep_loop:
	lda #0
	sta _grid_action
	jsr _process_grid
	lda _did_something
	beq Lproc_done
	lda #1
	sta _grid_action
	jsr _process_grid
	jmp Lstep_loop
Lproc_done:
	lda #<(_dot)
	ldx #>(_dot)
	jsr pushax
	lda _counter
	ldx _counter+1
	jsr pushax
	ldy #4
	jsr _printf
	lda #$0
	ldx #$0
	rts

.endproc

.proc _process_grid: near
	jsr _reset_gptr
	lda #0
	sta _cur_row
	sta _cur_col
	sta _did_something
Lprocess_row:
	lda _cur_row
	cmp #GRID_COLS
	beq Lproc_done
Lprocess_cell:
	lda _cur_col
	cmp #GRID_COLS
	beq Lnext_row
	jsr _process_cur
	inc _cur_col
	lda #1
	jsr _add_gptr
	jmp Lprocess_cell
Lnext_row:
	lda #0
	sta _cur_col
	inc _cur_row
	lda #2
	jsr _add_gptr
	jmp Lprocess_row
Lproc_done:
	rts
.endproc

.proc _inc_counter: near
	lda #1
	add _counter
	sta _counter
	lda _counter+1
	adc #0
	sta _counter+1
	rts
.endproc
.proc _reset_gptr: near
	lda #<(_grid)
	sta _grid_ptr
	lda #>(_grid)
	sta _grid_ptr+1
	lda #(GRID_COLS+3)
	jsr _add_gptr
	rts
.endproc

.proc _add_gptr: near
	add _grid_ptr
	sta _grid_ptr
	lda _grid_ptr+1
	adc #0
	sta _grid_ptr+1
	rts
.endproc
.proc _sub_gptr: near
	sta tmp1
	lda _grid_ptr
	sub tmp1
	sta _grid_ptr
	lda _grid_ptr+1
	sbc #0
	sta _grid_ptr+1
	rts
.endproc

.proc _check_nb: near
	lda (_grid_ptr),y
	cmp #$40
	beq Lchk_nb_add
	cmp #$24
	beq Lchk_nb_add
	rts
Lchk_nb_add:
	inc _adj_counter
	rts
.endproc

.proc _process_cur: near
	lda _grid_action
	bne Lact_reset_grid
	jmp _find_free
Lact_reset_grid:
	jmp _reset_grid
.endproc

.proc _reset_grid: near
	ldy #0
	lda (_grid_ptr),y
	cmp #$24
	bne Lreset_out
	lda #$2e
	sta (_grid_ptr),y
Lreset_out:
	rts
.endproc

.proc _find_free: near
	ldy #0
	lda (_grid_ptr),y
	cmp #$40
	bne Lproc_cur_out

	lda #0
	sta _adj_counter
	lda _grid_ptr
	pha
	lda _grid_ptr+1
	pha

	lda #(GRID_COLS+3)
	jsr _sub_gptr

	ldy #0
	jsr _check_nb
	ldy #1
	jsr _check_nb
	ldy #2
	jsr _check_nb

	lda #(GRID_COLS+2)
	jsr _add_gptr

	ldy #0
	jsr _check_nb
	ldy #2
	jsr _check_nb

	lda #(GRID_COLS+2)
	jsr _add_gptr

	ldy #0
	jsr _check_nb
	ldy #1
	jsr _check_nb
	ldy #2
	jsr _check_nb

	pla
	sta _grid_ptr+1
	pla
	sta _grid_ptr

	lda #4
	cmp _adj_counter
	bcc Lproc_cur_out
	beq Lproc_cur_out

	lda #1
	sta _did_something
	lda #$24
	ldy #0
	sta (_grid_ptr),y

	jsr _inc_counter
Lproc_cur_out:
	rts
.endproc
