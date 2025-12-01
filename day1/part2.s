	.arch i8086,jumps
	.code16
	.att_syntax prefix
#NO_APP
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lout_fmt:
	.string	"%d\n"
	.section	.text.startup,"ax",@progbits
	.global	main
	.type	main, @function
main:
        push %bp
        push %si
        push %di
        mov %sp, %bp

        xor %di, %di
        mov $0x50, %si
        sub $6, %sp

.Lread_loop:
        lea -6(%bp), %cx
        mov $stdin, %ax
        push %ax
        mov $6, %ax
        push %ax
        push %cx
        call fgets
        add $6, %sp
        xor %cx, %cx
        cmp %ax, %cx
        jz .Lexit

        mov -4(%bp), %al
        mov $'\n', %cl
        cmp %cl, %al
        jz .Lparse_1d
        mov -3(%bp), %al
        cmp %cl, %al
        jz .Lparse_2d
        mov -2(%bp), %al
        cmp %cl, %al
        jz .Lparse_3d
        int3

.Lparse_1d:
        mov -5(%bp), %dl
        sub $'0', %dl
        jmp .Lrotate

.Lparse_2d:
        mov -4(%bp), %dl
        mov -5(%bp), %al
        sub $'0', %dl
        sub $'0', %al
        mov $4, %cl
        shl %cl, %al
        or %al, %dl
        jmp .Lrotate

.Lparse_3d:
        mov -5(%bp), %al
        sub $'0', %al
        xor %ah, %ah
        add %ax, %di

        mov -3(%bp), %dl
        mov -4(%bp), %al
        sub $'0', %dl
        sub $'0', %al
        mov $4, %cl
        shl %cl, %al
        or %al, %dl

.Lrotate:
        mov -6(%bp), %al
        cmp $'L', %al
        mov %si, %ax
        jz .Lsub

        add %dl, %al
        daa
        adc $0, %di
        jmp .Lafter_rot
.Lsub:
	test %al, %al
        jnz .Lhack
        sub $1, %di
.Lhack:
        sub %dl, %al
        das
        adc $0, %di
        test %al, %al
        jnz .Lafter_rot
        add $1, %di

.Lafter_rot:
        xor %ah, %ah
        mov %ax, %si

        jmp .Lread_loop

.Lexit:
        push %di
        mov $.Lout_fmt, %ax
        push %ax
        call printf

        mov %bp, %sp
        pop %di
        pop %si
        pop %bp
        xor %ax, %ax
        ret
