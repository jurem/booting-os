CFLAGS := -std=c11 -mno-red-zone -ffreestanding -O0 -static -g
CFLAGS += -Wall -Wextra -nostdlib -nodefaultlibs
CFLAGS += -mno-sse -mno-sse2 -mno-sse3 -mno-sse4 -mno-ssse3 -mno-mmx -mno-3dnow -mno-avx

ARCH ?= 64

ifeq ($(ARCH), 32)
	LD := i686-elf-ld
	CC := i686-elf-gcc
	CFLAGS += -m32
	QEMU := qemu-system-i386
	OBJDUMP := i686-elf-objdump
else
	LD := x86_64-elf-ld
	CC := x86_64-elf-gcc
	CFLAGS += -m64
	QEMU := qemu-system-x86_64
	OBJDUMP := x86_64-elf-objdump
endif

GRUB_MKRESCUE := i386-elf-grub-mkrescue
GRUB_MKIMAGE := i386-elf-grub-mkimage

VPATH = src

.PHONY: all clean iso run trace debug gdb objdump

all: iso

build:
	mkdir -p $@

clean:
	rm -rf build

# compile & link

.PRECIOUS: build/%.o build/%.elf

build/multiboot_%.o: multiboot.asm
	nasm -felf$(ARCH) $< -o $@

build/entry_%.o: entry_%.asm
	nasm -felf$(ARCH) $< -o $@

build/kernel_%.o: kernel.c console.h
	$(CC) $(CFLAGS) -c $< -o $@

build/kernel_%.elf: build/multiboot_%.o build/entry_%.o build/kernel_%.o
	$(LD) -n -T linker.ld -o $@ $^

# ISO image

build/grubfiles_%: build/kernel_%.elf grub.cfg
	mkdir -p $@/boot/grub/
	cp $< $@/boot/kernel.bin
	cp grub.cfg $@/boot/grub/

build/frikos_%.iso: build/grubfiles_%
	$(GRUB_MKRESCUE) -o $@ $<

# Running etc.

iso: build build/frikos_$(ARCH).iso
	@echo -n

floppy: build build/frikos_$(ARCH).flp
	@echo -n

run: build/frikos_$(ARCH).iso
	$(QEMU) -cdrom $<

trace: build/frikos_$(ARCH).iso
	$(QEMU) -d in_asm -cdrom $< -s

debug: build/frikos_$(ARCH).iso
	$(QEMU) -s -S -cdrom $<


gdb: build/frikos_$(ARCH).elf
	gdb -ex "target remote :1234" $<

objdump: build/frikos_$(ARCH).elf
	$(OBJDUMP) -M x86-64,i386,intel-mnemonic -x -d -s -S $<
