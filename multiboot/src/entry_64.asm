global start
extern kernel_main

section .text

bits 32
start:
	cli 			; disable interrupts
	mov esp, stack_top	; init stack
	mov edi, ebx		; save the multiboot info pointer to EDI

	call check_multiboot
	call check_cpuid
	call check_long_mode

	call set_up_page_tables
	call enable_paging

	lgdt [gdt64.pointer]
	jmp gdt64.code:long_mode_entry

bits 64
long_mode_entry:
	; call main
	call kernel_main
	; print `OKAY` to the screen
	mov rax, 0x2f592f412f4b2f4f
	mov qword [0xB8000], rax
	jmp halt_spin

bits 32
error:
	mov dword [0xB8000], 0x4F524F45
	mov dword [0xB8004], 0x4F3A4F52
	mov dword [0xB8008], 0x4F204F20
	mov byte  [0xB800A], al

halt_spin:
	hlt
	jmp halt_spin


check_multiboot:
	cmp eax, 0x36D76289
	jne .no_multiboot
	ret
    .no_multiboot:
	mov al, '0'
	jmp error

check_cpuid:
	; Copy FLAGS to EAX and ECX
	pushfd
	pop eax
	mov ecx, eax
	; Flip the ID bit
	xor eax, 1 << 21
	; Copy EAX back to FLAGS
	push eax
	popfd
	; Copy FLAGS to EAX again
	pushfd
	pop eax
	; Restore old FLAGS (from ECX)
	push ecx
	popfd
	;; Compare ECX (old flags) and EAX (with flipped ID bit if CPUID is supported)
	cmp eax, ecx
	je .no_cpuid
	ret
    .no_cpuid:
	mov al, '1'
    	jmp error

check_long_mode:
	; Check if LongMode detection is available
	mov eax, 0x80000000	; argument for cpuid
	cpuid
	cmp eax, 0x80000001
	jb .no_long_mode
	; Check if LongMode is available
	mov eax, 0x80000001	; extended processor info
	cpuid 			; returns info in ecx and edx
	test edx, 1 << 29	; test the LM bit
	jz .no_long_mode
	ret
    .no_long_mode:
	mov al, "2"
    	jmp error

set_up_page_tables:
	; Map the first P4 entry to P3 table
	mov eax, p3_table
	or eax, 0b11		; writable + present
	mov [p4_table], eax
	; Map the first P3 entry to P2 table
	mov eax, p2_table
	or eax, 0b11		; writable + present
	mov [p3_table], eax
	; Map each P2 entry to a huge 2 MiB page
	mov ecx, 0		; counter
     .loop:
	mov eax, 0x200000	; 2 MiB
	mul ecx			; eax = address of ecx-th page
	or eax, 0b10000011	; huge + writable + present
	mov [p2_table + ecx * 8], eax
	inc ecx
	cmp ecx, 512		; if counter == 512 then finish
	jne .loop
	ret

enable_paging:
	; Load P4 address to CR3 register
	mov eax, p4_table
	mov cr3, eax
	; Enable PAE (physical address extension) in CR4
	mov eax, cr4
	or eax, 1 << 5		; PAE bit
	mov cr4, eax
	; Set the LM (long mode) bit in the EFER MSR (model specific register)
	mov ecx, 0xC0000080	; EFER MSR selector
	rdmsr
	or eax, 1 << 8		; LM bit
	wrmsr
	; Enable paging
	mov eax, cr0
	or eax, 1 << 31		; PG bit
	mov cr0, eax
	ret


section .bss			; Is cleared to zero by GRUB

align 4096
p4_table:
	resb 4096
p3_table:
	resb 4096
p2_table:
	resb 4096

stack_bottom:
	resb 64
stack_top:


section .rodata

gdt64:
align 4
    .null: equ $ - gdt64
	dq 0
    .code: equ $ - gdt64
	dq 1<<43 | 1<<44 | 1<<41 | 1<<47 | 1<<53
    .data: equ $ - gdt64
	dq 1<<44 | 1<<47 | 1<<41 | 1<<53
    .pointer:
	dw $ - gdt64 - 1	; length - 1
	dq gdt64		; address of gdt
