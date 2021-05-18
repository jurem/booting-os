stack_addr equ 0xF000			; stack address
kernel_addr equ 0x1000


; ********** boot entry - real mode 16 bit code

bits 16
org 0x0500

boot_entry:
	; initialization
	;cli
	;mov ax, 0
	;mov ds, eax
	;mov es, eax
	;mov cs, ax

	; stack
	;mov bp, stack_addr
	;mov sp, bp

	; print
	mov si, real_mode_msg
	call bios_println
	mov si, press_key_msg
	call bios_println
	call bios_read_key
	call bios_hide_cursor

load_gdt:
	; load GDT register
	lgdt [gdt32.descriptor]
	; init protected mode
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax
	; far jump, PM switch
	jmp gdt32.code:protected_mode_entry

real_mode_msg db "  welcome to the real mode", 0
press_key_msg db "  press a key", 0

; Include BIOS routines
%include 'lib_bios.inc'


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


; ********** protected mode

bits 32

protected_mode_entry:
	mov ax, gdt32.data
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov ds, ax
	mov gs, ax

	mov ebp, stack_addr
	mov esp, ebp

    .jump:
	jmp kernel_entry






; Pad to align to 0x1000
times 0x1000 - 0x500 - ($ - $$) db 0

kernel_entry:
	call clear
	mov eax, 0x1F201F20
	call fill

	mov esi, msg
	call print
	call print_nl
	mov esi, protected_mode_msg
	call print

	hlt
	jmp $

protected_mode_msg db "  entering protected mode", 0

msg db "Frikos.", 0

; Include VGA printing routines
%include 'inc_vga_print.asm'
