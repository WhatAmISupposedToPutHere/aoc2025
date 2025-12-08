grid_w equ 141
grid_h equ 142
psect text
global __iob
global _fgets,_printf
global _main
_main:

	ld hl,__iob
	push hl
	ld hl,grid_w+3
	push hl
	ld hl,grid_prev
	push hl
	call _fgets
	ld hl,6
	add hl,sp
	ld sp,hl

	ld hl,grid_h-1
	ld (grid_rem),hl
	ld hl,0
	ld (hits),hl

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

	ld ix,grid_prev
	ld iy,grid_cur
	ld de,grid_w
	ld hl,(hits)

scan_loop:
	ld a,(ix)
	cp 83
	jp z,prev_good
	cp 124
	jp nz,scan_proceed
prev_good:
	ld a,(iy)
	cp 46
	jp nz,replicate
	ld a,124
	ld (iy),a
	jp scan_proceed
replicate:
	cp 5eh
	jp nz,scan_proceed
	ld a,124
	ld (iy+1),a
	ld (iy-1),a
	inc hl
scan_proceed:
	inc ix
	inc iy
	dec de
	ld a,d
	or e
	jp nz,scan_loop

	ld (hits),hl
	ld hl,grid_cur
	ld de,grid_prev
	ld bc,grid_w
	ldir

	ld hl,(grid_rem)
	dec hl
	ld (grid_rem),hl

	ld a,h
	or l
	jp nz,process_row


	ld hl,(hits)
	push hl
	ld hl,out_fmt
	push hl
	call _printf
	ld hl,4
	add hl,sp
	ld sp,hl

	ret

psect data
out_fmt:
	defb '%','d',10,0
psect bss
hits:
	defs 2
grid_rem:
	defs 2
grid_prev:
	defs grid_w
grid_cur:
	defs grid_w
