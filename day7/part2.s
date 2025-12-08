grid_w equ 141
grid_h equ 142
psect text
global __iob
global _fgets,_printf
global _main
_main:
	ld hl,grid_h
	ld (grid_rem),hl

process_row:
	ld hl,__iob
	push hl
	ld hl,grid_w+3
	push hl
	ld hl,grid_cur
	push hl
	call _fgets
	ld hl,6
	add hl,sp
	ld sp,hl

	ld ix,grid_cur
	ld iy,grid_stat
	ld de,grid_w
	ld hl,grid_nstat

scan_loop:
	ld a,(ix)
	cp 83
	jp nz,not_s
	push ix
	push hl
	pop ix
	ld (ix),1
	ld (ix+1),0
	ld (ix+2),0
	ld (ix+3),0
	ld (ix+4),0
	ld (ix+5),0
	ld (ix+6),0
	ld (ix+7),0
	push ix
	pop hl
	pop ix
	jp scan_proceed
not_s:
	ld a,(ix)
	cp 46
	jp nz,not_dot
	push ix
	push hl
	pop ix
	call add_wide
	push ix
	pop hl
	pop ix
	jp scan_proceed
not_dot:
	push ix
	push hl
	ld bc,8
	scf
	ccf
	sbc hl,bc
	push hl
	pop ix
	call add_wide
	ld bc,16
	add ix,bc
	call add_wide
	pop hl
	pop ix
scan_proceed:
	inc ix
	ld bc,8
	add iy,bc
	add hl,bc
	dec de
	ld a,d
	or e
	jp nz,scan_loop

	ld hl,grid_nstat
	ld de,grid_stat
	ld bc,grid_w*8
	ldir
	ld hl,bzero
	ld de,grid_nstat
	ld bc,grid_w*8
	ldir

	ld hl,(grid_rem)
	dec hl
	ld (grid_rem),hl

	ld a,h
	or l
	jp nz,process_row

	ld ix,sum_buf
	ld iy,grid_stat
	ld de,grid_w

sum_loop:
	call add_wide
	ld bc,8
	add iy,bc
	dec de
	ld a,d
	or e
	jp nz,sum_loop

	ld hl,(sum_buf+2)
	push hl
	ld hl,(sum_buf)
	push hl
	ld hl,(sum_buf+6)
	push hl
	ld hl,(sum_buf+4)
	push hl
	ld hl,out_fmt
	push hl
	call _printf
	ld hl,10
	add hl,sp
	ld sp,hl

	ret

add_wide:
	ld l,(ix)
	ld h,(ix+1)
	ld c,(iy)
	ld b,(iy+1)
	add hl,bc
	ld (ix),l
	ld (ix+1),h

	ld l,(ix+2)
	ld h,(ix+3)
	ld c,(iy+2)
	ld b,(iy+3)
	adc hl,bc
	ld (ix+2),l
	ld (ix+3),h

	ld l,(ix+4)
	ld h,(ix+5)
	ld c,(iy+4)
	ld b,(iy+5)
	adc hl,bc
	ld (ix+4),l
	ld (ix+5),h

	ld l,(ix+6)
	ld h,(ix+7)
	ld c,(iy+6)
	ld b,(iy+7)
	adc hl,bc
	ld (ix+6),l
	ld (ix+7),h

	ret
psect data
out_fmt:
	defb '0','x','%','l','x','%','0','8','l','x',10,0
psect bss
sum_buf:
	defs 8
grid_rem:
	defs 2
grid_stat:
	defs grid_w*8
grid_nstat:
	defs grid_w*8
bzero:
	defs grid_w*8
grid_cur:
	defs grid_w
