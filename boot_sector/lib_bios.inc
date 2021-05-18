; Print string pointed by SI and newline
bios_println:
	call bios_print
; Print newline
bios_print_nl:
	mov si, nl_msg
; Print string pointed by SI
bios_print:
	mov ah, 0x0E
    .loop:
	lodsb
	cmp al, 0
	je .done
	int 0x10
	jmp .loop
    .done:
	ret

nl_msg db 13, 10, 0


; Print DX in hex
bios_print_hex:
	mov ah, 0x0E
	mov cx, 4		; repeat 4 times
    .loop:
	rol dx, 4		; begin with the first nibble
	; convert to ASCII
	mov al, dl
	and al, 0x0F
	add al, '0'
	cmp al, '9'
	jle .skip
	add al, 'A'-'9'-1
    .skip:
	int 0x10
	loop .loop
	ret


; Hide cursor
bios_hide_cursor:
	mov ah, 0x01
	mov ch, 0x3F
	int 0x10
	ret

; Read a key into AL
bios_read_key:
	mov ah, 0x0
	int 0x16
	ret
