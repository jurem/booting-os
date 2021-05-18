LD := x86_64-elf-ld
OBJDUMP := x86_64-elf-objdump
QEMU := qemu-system-i386

CC := cc
CFLAGS := -m16 -std=c11 -mno-red-zone -ffreestanding -O0 -static -g
CFLAGS += -Wall -Wextra -nostdlib -nostartfiles -nodefaultlibs
CFLAGS += -mno-sse -mno-sse2 -mno-sse3 -mno-sse4 -mno-ssse3 -mno-mmx -mno-3dnow -mno-avx


imgs := $(addprefix build/,os_16.img os_32.img)
bins := $(subst img,bin,$(imgs))

.PHONY: all clean

all: $(imgs)

$(imgs): | build

build:
	mkdir -p $@

clean:
	rm -rf build


# Building and running the image for qemu

.PRECIOUS: build/%.bin

build/%.bin: %.asm
	nasm -f bin -o $@ -l build/$(subst asm,lst,$<) $<

build/%_16.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

build/os_%.img: build/boot_sector.bin build/entry_%.bin build/kernel_%.bin
	cat $^ > $@

run_%: build/os_%.img
	$(QEMU) -drive format=raw,file=$<

trace_%: build/os_%.img
	$(QEMU) -d in_asm -drive format=raw,file=$<

debug_%: build/os_%.img
	$(QEMU) -s -S -drive format=raw,file=$<

gdb_%:
	gdb -q $(GDB_FLAGS) $(GDB_FLAGS_%)


# Source debugging via gdb

GDB_FLAGS_16 := -ex 'set architecture i8086'
GDB_FLAGS_32 := -ex 'set architecture i386'
GDB_FLAGS := -ex 'target remote :1234' \
	-ex 'set disassembly-flavor intel' \
	-ex 'set disassemble-next-line on' \
	-ex 'show disassemble-next-line' \
	-ex 'break *0x7C00'

# comment the org directive in boot_sector.asm
build/%.o: %.asm
	nasm -f elf32 -g3 -F dwarf -o $@ $<

build/%.elf: build/%.o
	$(LD) -Ttext=0x0500 -melf_i386 -o $@ $^

build/%.lst: %.bin
	$(OBJDUMP)

gdbsym_%: build/entry_%.elf
	gdb -q $(GDB_FLAGS) $(GDB_FLAGS_%) $<
