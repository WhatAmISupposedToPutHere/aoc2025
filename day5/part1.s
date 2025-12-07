uart		equ	$c000
system_stack	equ	$0200
user_stack	equ	$0400
heap_start	equ	$0600
vector_table	equ	$fff0
rom_start	equ	$e000
acia		equ	$c000

n_digits	equ 15
n_entries	equ 182
n_queries	equ 1000

		org $0
got_newline	fcb $0
cmp_result	fcb $0
cmp_hits	fcb $0
cur_ent		fcb $0
cur_query	fdb $0
qrs_valid	fcb $0,$0,$0

		org heap_start
read_tmp	rzb n_digits
cmp_buf		rzb n_digits
entries		rzb (n_digits*2*n_entries)
scratch		rzb n_digits

		org rom_start
handle_reset	lds #system_stack
		ldu #user_stack
		orcc #$50

		ldd #$3030
		std qrs_valid
		sta qrs_valid+2

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


proc_cmp	ldx #cmp_buf
		lda #0
		sta cur_ent
		sta cmp_result
		sta cmp_hits
		jsr read_number
		ldx #entries

proc_cmp_loop	pshu x
		jsr icmp_ge
		pulu x
		leax n_digits,x
		pshu x
		jsr icmp_le
		pulu x
		leax n_digits,x
		lda cmp_result
		cmpa #2
		bne not_hit
		inc cmp_hits
not_hit		lda #0
		sta cmp_result
		lda cur_ent
		adda #1
		sta cur_ent
		cmpa #n_entries
		bne proc_cmp_loop

		lda cmp_hits
		beq not_valid
		jsr inc_valid
not_valid	ldd cur_query
		addd #1
		std cur_query
		cmpd #n_queries
		beq done
		jmp proc_cmp

done		lda qrs_valid
		jsr putchar
		lda qrs_valid+1
		jsr putchar
		lda qrs_valid+2
		jsr putchar
		lda #$0a
		jsr putchar
end		jmp end

inc_valid	lda qrs_valid+2
		inca
		cmpa #$3a
		beq carry1
		sta qrs_valid+2
		rts
carry1		lda #$30
		sta qrs_valid+2

		lda qrs_valid+1
		inca
		cmpa #$3a
		beq carry2
		sta qrs_valid+1
		rts
carry2		lda #$30
		sta qrs_valid+1
		inc qrs_valid
		rts


icmp_ge		ldy #cmp_buf
		ldb #0
ige_loop	incb
		lda ,y+
		cmpa ,x+
		beq ige_proceed
		blo ige_exit
		inc cmp_result
ige_exit	rts
ige_proceed	cmpb #n_digits
		bne ige_loop
		inc cmp_result
		rts

icmp_le		ldy #cmp_buf
		ldb #0
ile_loop	incb
		lda ,y+
		cmpa ,x+
		beq ile_proceed
		bhi ile_exit
		inc cmp_result
ile_exit	rts
ile_proceed	cmpb #n_digits
		bne ile_loop
		inc cmp_result
		rts


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
