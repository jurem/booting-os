stack_addr equ 0xF000			; stack address
kernel_addr equ 0x1000

bits 16

; ********** entry

org 0x0500
boot_entry:
	; initialization
	cli
	mov ax, 0
	mov ds, ax
	mov es, ax
	;mov cs, ax

	; stack
	mov bp, stack_addr
	mov sp, bp

	; message and read a key
	mov si, real_mode_msg
	call bios_println
	mov si, press_key_msg
	call bios_println
	call bios_read_key

    .jump:
	jmp kernel_entry

real_mode_msg db "  welcome to the real mode", 0
press_key_msg db "  press a key", 0


; Include BIOS routines
%include 'lib_bios.inc'


; Pad to align to 0x1000
times 0x1000 - 0x500 - ($ - $$) db 0

kernel_entry:
	mov dx, $

	mov si, msg
	call bios_println
	call bios_print_hex
	call bios_print_nl

	mov dx, $$
	call bios_print_hex
	call bios_print_nl

	call bios_hide_cursor

	hlt

msg db "Frikos.", 0
