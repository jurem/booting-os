screen_origin equ 0xB8000

; Clear/Fill (EAX=2x fill char + attr) the screen
clear:
	mov eax, 0x00000000
fill:
	mov edi, screen_origin
	mov [screen_cursor], edi	; init cursor
	mov ecx, 1000			; screen size = 2 * 80 * 25 / 4
	rep stosd
	ret

; Print the null-terminated string pointed by esi
print:
	mov ah, 0x1F
	mov edi, [screen_cursor]
	cld
    .loop:
	lodsb
	cmp al, 0
	je .end
	stosw
	jmp .loop
    .end:
	mov [screen_cursor], edi
	ret

print_nl:
	mov eax, dword [screen_cursor]
	add eax, 160
	sub eax, screen_origin
	mov ebx, 160
	div ebx
	mul ebx
	add eax, screen_origin
	mov dword [screen_cursor], eax
	ret

screen_cursor dd screen_origin
