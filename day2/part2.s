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

.Lckpat2:
	test $1, %eax
	jnz .Lckpat_as
	mov %rax, %rcx
	shr $1, %rcx
	mov %rsp, %rdi
	mov %rdi, %rsi
	add %rcx, %rsi
	repz cmpsb (%rdi), (%rsi)
	jz .Lpat_matched

.Lckpat_as:
	cmp $1, %eax
	jz .Lckpat_pairs
	mov %rsp, %rdi
	mov %eax, %edx
	mov %eax, %ecx
	mov (%rsp), %al
	repz scasb (%rdi)
	mov %edx, %eax
	jz .Lpat_matched


.Lckpat_pairs:
	test $1, %eax
	jnz .Lckpat_three
	cmp $2, %eax
	jz .Lckpat_three
	mov %rsp, %rdi
	mov %eax, %edx
	mov %eax, %ecx
	mov (%rsp), %ax
	shr $1, %ecx
	repz scasw (%rdi)
	mov %edx, %eax
	jz .Lpat_matched

.Lckpat_three:
	cmp $9, %eax
	jnz .Lseek_loop
	mov (%rsp), %edx
	and $0xFFFFFF, %edx
	mov 3(%rsp), %ecx
	and $0xFFFFFF, %ecx
	cmp %ecx, %edx
	jnz .Lseek_loop
	mov 6(%rsp), %ecx
	and $0xFFFFFF, %ecx
	cmp %ecx, %edx
	jz .Lpat_matched
	jmp .Lseek_loop

.Lpat_matched:
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
