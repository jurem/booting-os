#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 25
#define SCREEN_SIZE	(SCREEN_WIDTH * SCREEN_HEIGHT)
#define SCREEN_ADDRESS 0xB8000

static unsigned short *screen;
static unsigned int screenOffset;

void clear_screen() {
	for (int i = 0; i < 10; i++)
    	screen[i] = 0x2020;
}

int kernel_main() {
	screen = (unsigned short*) SCREEN_ADDRESS;
	screenOffset = 0;
	for (int i = 0; i < SCREEN_SIZE; i++)
    	screen[i] = 0x1020;

//	clear_screen();
	return 0;
}
