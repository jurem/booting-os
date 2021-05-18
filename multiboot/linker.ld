ENTRY(start)

SECTIONS {
	/* load address of the first section */
	. = 1M;

	/* the first section must be multiboot */
	.boot : ALIGN(4K) {
		KEEP(*(.multiboot))
	}

	.text : {
		*(.text)
	}

	.data : ALIGN(4K) {
		*(.data)
	}

	.bss : ALIGN(4K) {
		*(.bss)
	}

}
