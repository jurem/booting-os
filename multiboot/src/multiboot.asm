section .multiboot
align 4
header_start:
	; initial tags
	dd 0xE85250D6			; multiboot 2 magic number
	dd 0				; protected mode i386
	dd header_end - header_start	; header length
	dd 0x100000000 - (0xE85250d6 + 0 + (header_end - header_start))	; checksum

	; optional tags

	; end tag
	dw 0	; type
	dw 0	; flags
	dd 8	; size
header_end:
