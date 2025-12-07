uart		equ	$c000
system_stack	equ	$0200
user_stack	equ	$0400
heap_start	equ	$0600
vector_table	equ	$fff0
rom_start	equ	$e000
acia		equ	$c000

n_digits	equ 15
n_entries	equ 182

		org $0
tmp_l1		fdb $0
tmp_l2		fdb $0
tmp1		fcb $0
tmp2		fcb $0
mrg_cur		fcb $0
ents_left	fcb $0
got_newline	fcb $0
cmp_result	fcb $0
sd_root		fcb $0
sd_child	fcb $0
sd_end		fcb $0
hpf_start	fcb $0
hps_end		fcb $0

		org heap_start
read_tmp	rzb n_digits
sum_buf		rzb n_digits
const1		rzb n_digits
ent_swap_tmp	rzb (n_digits*2)
entries		rzb (n_digits*2*n_entries)
scratch		rzb n_digits


		org rom_start
handle_reset	lds #system_stack
		ldu #user_stack
		orcc #$50

		ldx #entries

input_loop	lda #$0
		sta got_newline
input_loop_nc	jsr read_number
		cmpa #$0a
		bne input_loop
		lda got_newline
		bne proc_cmp
		lda #1
		sta got_newline
		jmp input_loop_nc


proc_cmp	jsr heapsort
		jsr merge_all
		jsr add_all
		ldb #n_digits
		ldx #sum_buf
out_loop	lda ,x+
		jsr putchar
		decb
		bne out_loop
end		jmp end

shift_back	sta tmp1
		jsr idx2addr
		tfr d,y
		addd #(n_digits*2)
		tfr d,x
		lda #(n_entries-1)
		suba tmp1
		ldb #n_digits
		mul
		std tmp_l1
shift_loop	ldd ,x++
		std ,y++
		ldd tmp_l1
		subd #1
		std tmp_l1
		bne shift_loop
		rts


dump_grid	ldb #0
		ldx #entries
dumpg_loop	cmpb #n_entries
		beq dumpg_exit
		incb
		pshu b
		jsr dump_number
		lda #$2d
		jsr putchar
		jsr dump_number
		lda #$0a
		jsr putchar
		pulu b
		jmp dumpg_loop
dumpg_exit	rts


dump_number	ldb #0
dumpn_loop	cmpb #n_digits
		beq dumpn_exit
		incb
		lda ,x+
		jsr putchar
		jmp dumpn_loop
dumpn_exit	rts


cpy_entry	ldb #0
cpy_ent_loop	lda ,x+
		sta ,y+
		incb
		cmpb #(n_digits*2)
		bne cpy_ent_loop
		rts

idx2addr	ldb #(n_digits*2)
		mul
		std tmp_l1
		ldd #entries
		addd tmp_l1
		rts

swap_ents	pshu b
		jsr idx2addr
		tfr d,x
		pulu a
		jsr idx2addr
		tfr d,y

		stx tmp_l1
		sty tmp_l2
		ldy #ent_swap_tmp
		jsr cpy_entry
		ldx tmp_l2
		ldy tmp_l1
		jsr cpy_entry
		ldx #ent_swap_tmp
		ldy tmp_l2
		jmp cpy_entry

heapsort	jsr heapify
		lda #n_entries
		sta hps_end
heapsort_loop	lda hps_end
		cmpa #1
		beq heapsort_end
		deca
		sta hps_end
		ldb #0
		jsr swap_ents
		lda #0
		sta sd_root
		lda hps_end
		sta sd_end
		jsr sift_down
		jmp heapsort_loop
heapsort_end	rts

heapify		lda #(((n_entries-1)-1) / 2 + 1)
		sta hpf_start
hpf_loop	lda hpf_start
		beq hpf_exit
		deca
		sta hpf_start
		sta sd_root
		lda #n_entries
		sta sd_end
		jsr sift_down
		jmp hpf_loop
hpf_exit	rts

sift_down	lda sd_root
		lsla
		bcs sift_down_end
		adda #1
		cmpa sd_end
		bge sift_down_end
		sta sd_child
		inca
		cmpa sd_end
		bge sift_down_p2
		tfr a,b
		lda sd_child
		jsr ecmp_lt
		cmpa #0
		beq sift_down_p2
		inc sd_child
sift_down_p2	lda sd_root
		ldb sd_child
		jsr ecmp_lt
		cmpa #0
		beq sift_down_end
		lda sd_root
		ldb sd_child
		jsr swap_ents
		lda sd_child
		sta sd_root
		jmp sift_down
sift_down_end	rts

read_number	ldy #read_tmp
		ldb #0

read_digit	jsr getchar
		cmpa #$0a
		beq next_number
		cmpa #$2d
		beq next_number
		sta ,y+
		incb
		jmp read_digit

next_number	pshu a
		pshu b
		ldy #read_tmp

		lda #$30
padding_loop	cmpb #n_digits
		beq cpy_digits
		sta ,x+
		incb
		jmp padding_loop

cpy_digits	pulu b
cpy_digit_loop	cmpb #0
		beq read_num_exit
		lda ,y+
		sta ,x+
		decb
		jmp cpy_digit_loop

read_num_exit	pulu a
		rts

add_all		lda #(n_digits/2)
		sta tmp1
		ldd #$3030
		ldy #sum_buf
		ldx #const1
clr_loop	std ,y++
		std ,x++
		dec tmp1
		bne clr_loop
		lda #$31
		sta (const1+n_digits-1)
add_loop	dec ents_left
		lda ents_left
		jsr idx2addr
		tfr d,x
		jsr add_one
		ldx #const1
		jsr add_one
		lda ents_left
		bne add_loop
		rts


add_one		leax n_digits,x
		ldy #(sum_buf+n_digits)
		lda #n_digits
		sta tmp2
		lda #0
		sta tmp1

ao_loop		lda ,-y
		adda ,-x
		adda tmp1
		ldb #0
		cmpa #$3a
		ble no_carry
		suba #10
		ldb #1
no_carry	sta ,x
		stb tmp1
		dec tmp2
		bne ao_loop
		rts

ent2range	jsr idx2addr
		tfr d,x
		leax n_digits,x
		leay n_digits,x
		lda #n_digits
		sta tmp2
		lda #0
		sta tmp1

e2r_loop	lda ,-y
		suba ,-x
		suba tmp1
		ldb #0
		cmpa #$30
		bge no_borrow
		adda #10
		ldb #1
no_borrow	sta ,x
		stb tmp1
		dec tmp2
		bne e2r_loop
		rts


merge_all	lda #entries
		sta ents_left
merge_all_loop	lda ents_left
		deca
		cmpa mrg_cur
		blt merge_all_done
		lda mrg_cur
		jsr cmp4merge
		cmpa #0
		bne merge_all_do
		inc mrg_cur
		jmp merge_all_loop
merge_all_do	lda mrg_cur
		jsr do_merge_one
		lda mrg_cur
		jsr shift_back
		dec ents_left
		jmp merge_all_loop
merge_all_done	rts

do_merge_one	jsr idx2addr
		tfr d,x
		leax n_digits,x
		leay (n_digits*2),x
		pshu x
		jsr ilt_loop
		pulu x
		ldb #16
		mul
		leay b,x
		ldb #(n_digits/2)
		stb tmp1
mrg_loop	ldd ,x++
		std ,y++
		dec tmp1
		bne mrg_loop
		rts

cmp4merge	jsr idx2addr
		tfr d,y
		leay n_digits,y
		leax n_digits,y
		jmp ilt_loop

ecmp_lt		pshu b
		jsr idx2addr
		tfr d,y
		pulu a
		jsr idx2addr
		tfr d,x
		ldb #(n_digits*2)
ilt_loop	decb
		lda ,y+
		cmpa ,x+
		beq ilt_proceed
		bhi ilt_exit
		lda #1
		rts
ilt_exit	lda #0
		rts
ilt_proceed	cmpb #0
		bne ilt_loop
		lda #0
		rts


getchar		lda	uart
		bita	#$01
		beq	getchar
		lda	uart+1
		rts

putchar		pshs	a
_putchar1	lda	uart
		bita	#$02
		beq	_putchar1
		puls	a
		sta	uart+1
		rts

handle_int	rti
		org	vector_table
		fdb	handle_int
		fdb	handle_int
		fdb	handle_int
		fdb	handle_int
		fdb	handle_int
		fdb	handle_int
		fdb	handle_int
		fdb	handle_reset

		end	handle_reset
