# Notes

## Compiling

### MacOSX

* brew install x86_64-elf-binutils
* brew install x86_64-elf-gcc
* brew install i386-elf-grub
* brew install xorriso

# Hardware

## 8086 Memory map

* https://wiki.osdev.org/Memory_Map_(x86)

	; First 1/2 MiB
	0x00000	Interrupt vector table (1 KiB)
	0x00400 BIOS data area (256 bytes)
	0x00500 Free space (510 KiB + 768 B)
	; Second 1/2 MiB
	0x80000 Extended BIOS data area (128 KiB)
	0xA0000 Video display memory (128 KiB)
	0xC0000 Video BIOS (32 KiB)
	0xC8000 BIOS expansions (160 KiB)
	0xF0000 Motherboard BIOS (64 KiB)

# Frikos

## 16 bit

	We use the first 64 KiB
	0x0500	kernel entry
	0x1000	kernel
	0xF000  stack (grows downward)
