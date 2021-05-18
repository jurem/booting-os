#ifndef CONSOLE_H
#define CONSOLE_H

#include "utils.h"

#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 25
#define SCREEN_SIZE (SCREEN_WIDTH * SCREEN_HEIGHT)
#define SCREEN_ORIGIN 0xB8000

enum ScreenColor {
    BLACK, BLUE, GREEN, CYAN, RED, MAGENTA, BROWN, GRAY,
    DARK_GRAY, BRIGHT_BLUE, BRIGHT_GREEN, BRIGHT_CYAN, BRIGHT_RED, BRIGHT_MAGENTA, BRIGHT_YELLOW, WHITE
};

u16* screen;
u16 screen_pos;
u8 screen_attr;

/* VGA CRT controller */
#define CRT_INDEX   0x03D4
#define CRT_DATA    0x03D5

#define CRS_LOC_HI  0x0E
#define CRS_LOC_LO  0x0F

void screen_update_cursor() {
    outportb(CRT_INDEX, CRS_LOC_HI);
    outportb(CRT_DATA, screen_pos >> 8);
    outportb(CRT_INDEX, CRS_LOC_LO);
    outportb(CRT_DATA, screen_pos);
}

#define ATTR(back, fore) ((back) << 4 | (fore))
#define ATTR_CHAR(attr, ch) ((attr) << 8 | (ch))

void screen_init() {
    screen = (unsigned short*) SCREEN_ORIGIN;
    screen_pos = 0;
    screen_attr = ATTR(BRIGHT_BLUE, WHITE);
}

void screen_fill(unsigned short val) {
    memsetw(screen, val, SCREEN_SIZE);
}

void screen_clear() {
    screen_fill(ATTR_CHAR(screen_attr, ' '));
    screen_pos = 0;
    screen_update_cursor();
}

void screen_scroll_up() {
    memcpy(screen, screen + SCREEN_WIDTH, (SCREEN_SIZE - SCREEN_WIDTH) * sizeof(u16));
    memsetw(&screen[SCREEN_SIZE - SCREEN_WIDTH], ATTR_CHAR(screen_attr, ' '), SCREEN_WIDTH);
}

void screen_putchar(u8 ch) {
    if (ch == '\n')
        screen_pos += SCREEN_WIDTH - (screen_pos % SCREEN_WIDTH);
    else
        screen[screen_pos++] = ATTR_CHAR(screen_attr, ch);
    if (screen_pos >= SCREEN_SIZE) {
        screen_scroll_up();
        screen_pos -= SCREEN_WIDTH;
    }
    screen_update_cursor();
}

void screen_puts(const char* str) {
    while (*str) screen_putchar(*str++);
}


//

void printf(const char *format, ...) {
    char** arg = (char **) &format;
    arg++;
    char c;
    while ((c = *format++)) {
        if (c != '%')
            screen_putchar(c);
        else {
            c = *format++;
            char buf[20];
            char *p;
            char base = 10;
            switch(c) {
                case 'x':
                    base = 16;
                case 'd':
                case 'u':
                    itoa(*((int *) arg++), buf, base);
                    p = buf;
                    goto string;
                    break;
                case 's':
                    p = *arg++;
                    if (!p) p = "(null)";
                string:
                    while (*p) screen_putchar(*p++);
                    break;
                default:
                    screen_putchar(*((int *) arg++));
                    break;
            }
        }
    }
}

#endif
