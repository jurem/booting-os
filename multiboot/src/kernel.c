#include "console.h"

int kernel_main() {
    screen_init();
	screen_clear();
    for (int i = 0; i < 30; i++) {
        for (int j = 0; j < i; j++) screen_putchar(' ');
        screen_puts("Frikos...\n");
    }

    printf("%s: %d\n", "Juhu", 42);
    while (1);
	return 0;
}
