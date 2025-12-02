	.text
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lin_fmt:
	.string	"%ld-%ld"
.Ltmp_fmt:
	.string "%ld"
.Ldbg_fmt:
	.string "%ld\n"
	.section	.text.startup,"ax",@progbits
	.globl	main
main:
	push %r12
	push %r13
	push %r14
	sub $16, %rsp
	xor %r14, %r14
.Lget_range:
	lea .Lin_fmt(%rip), %rdi
	xor %eax, %eax
	mov %rsp, %rsi
	lea 8(%rsp), %rdx
	call scanf@PLT
	test %eax, %eax
	jz .Lend

	mov (%rsp), %r12
	mov 8(%rsp), %r13
	add $1, %r13
	sub $1, %r12

.Lseek_loop:
	add $1, %r12
	cmp %r12, %r13
	jz .Lget_next

	mov %rsp, %rdi
	lea .Ltmp_fmt(%rip), %rsi
	mov %r12, %rdx
	xor %eax, %eax
	call sprintf@PLT
	test $1, %eax
	jnz .Lseek_loop
	shr $1, %eax
	mov %rsp, %rdi
	mov %rdi, %rsi
	add %rax, %rsi
	mov %rax, %rcx
	repz cmpsb (%rdi), (%rsi)
	jnz .Lseek_loop
	add %r12, %r14
	jmp .Lseek_loop

.Lget_next:
	call getchar@PLT
	cmp $',', %al
	jz .Lget_range

.Lend:
	mov %r14, %rsi
	lea .Ldbg_fmt(%rip), %rdi
	call printf@PLT
	add $16, %rsp
	pop %r14
	pop %r13
	pop %r12
	xor %eax, %eax
	ret

	.section	.note.GNU-stack,"",@progbits
