global long_mode_start

section .text
bits 64
long_mode_start:

	cli
	; call main
	extern _kernel_main
	call _kernel_main

	; print `OKAY` to screen
	mov rax, 0x2f592f412f4b2f4f
	mov qword [0xB8000], rax

haltspin:
	hlt
	jmp haltspin
