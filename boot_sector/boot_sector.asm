stack_addr equ 0x9000			; stack address
image_addr equ 0x0500			; address where to load from disk
image_size equ 6			; size of image [in sectors]

bits 16

; ********** Start of boot sector

org 0x7C00

start:
	cli				; disable interrupts
	mov byte [boot_drive], dl	; store boot drive (stored in DL by BIOS)

	; init stack and BP
	mov bp, stack_addr
	mov sp, bp

	; print initial messages
	call bios_print_nl
	mov dx, 0xFEED
	call bios_print_hex
	mov si, startup_msg
	call bios_println

	; load AL sectors from drive DL to ES:BX = 0x0000:0x9000
	mov bx, image_addr
	mov al, image_size
	mov dl, [boot_drive]
	call bios_disk_read

	; print disk read success
	mov si, disk_read_msg
	call bios_print

	; print what has been read from disk
	mov dx, [image_addr]
	call bios_print_hex
	mov dx, [image_addr + 512]
	call bios_print_hex
	call bios_print_nl
	mov si, entry_msg
	call bios_println

	; jump to the image
	jmp image_addr

	; halt (this should not be executed)
halt_spin:
	hlt
	jmp halt_spin


; Include BIOS routine - not all are needed!
%include 'lib_bios.inc'


; Disk read
;   in: AL - no. of sectors to read, DL - drive, es:bx - buffer
;   out: CF - error, AH - status, AL - sector read count
bios_disk_read:
	push ax
	mov ah, 0x02	; BIOS read sector
	mov ch, 0	; cylinder 0
	mov cl, 2	; sector 2 (boot sector is sector 1)
	mov dh, 0 	; head 0
	int 0x13
	jc disk_error
	pop dx
	cmp al, dl
	jne disk_error
	ret

disk_error:
	pop dx
	mov si, disk_error_msg
	call bios_println
	jmp $

boot_drive db 0
startup_msg db " boot sector based boot loader ...", 0
disk_read_msg db "  disk sectors read success, example content: ", 0
disk_error_msg db "ERR: Disk read", 0
entry_msg db "  entering the image", 0

	times 510 - ($ - $$) db 0
	dw 0xAA55

; End of boot sector
