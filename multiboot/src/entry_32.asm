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

	lgdt [gdt32.descriptor]
	jmp gdt32.code:protected_mode_entry

protected_mode_entry:
	mov ax, gdt32.data
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov ds, ax
	mov gs, ax

	mov ebp, stack_top
	mov esp, ebp

	; call main
	call kernel_main

	; print `OKAY` to the screen
	mov eax, 0x2f4b2f4f
	mov dword [0xB8000], eax
	mov eax, 0x2f592f41
	mov dword [0xB8004], eax
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




section .bss			; Is cleared to zero by GRUB

stack_bottom:
	resb 4096
stack_top:


section .rodata

; GDT - global descriptor table
; code and data segment
align 4
gdt32:
; null descriptor
    .null: equ $ - gdt32
	dd 0
	dd 0
; code descriptor: base=0x0, limit=0xFFFFF, present, code, readable
    .code: equ $ - gdt32
    	dw 0xFFFF	; limit (bits 0-15)
    	dw 0x0		; base (bits 0-15)
    	db 0x0		; base (bits 16-23)
    	db 10011010b	; 1. flags: present:1, privilege:00, type:1, code:1, conforming:0, readable:1, accessed:0
    	db 11001111b	; 2. flags: granularity:1, 32-bit:1, 64-bit:0, AVL:0, limit (bits 16-19)
    	db 0x0		; base (bits 24-31)
; data descriptor: base=0x0, limit=0xFFFFF, present, readable
    .data: equ $ - gdt32
    	dw 0xFFFF	; limit (bits 0-15)
    	dw 0x0		; base (bits 0-15)
    	db 0x0		; base (bits 16-23)
    	db 10010010b	; 1. flags: present:1, privilege:00, type:1, code:0, conforming:0, readable:1, accessed:0
    	db 11001111b	; 2. flags: granularity:1, 32-bit:1, 64-bit:0, AVL:0, limit (bits 16-19)
    	db 0x0		; base (bits 24-31)
    .descriptor:
	dw $ - gdt32 - 1	; length - 1
	dd gdt32		; address of gdt
