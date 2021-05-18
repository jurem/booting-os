#ifndef UTILS_H
#define UTILS_H

// ********** Rust-like integer types

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long u64;

typedef signed char s8;
typedef signed short s16;
typedef signed int s32;
typedef signed long s64;

typedef unsigned int size_t;


// ********** Memmory utils

void memcpy(void* dst, const void* src, size_t count) {
    const char *sp = (const char *) src;
    char* dp = (char *) dst;
    while (count > 0) {
        *dp++ = *sp++;
        count--;
    }
}

void memset(void* dst, u8 val, size_t count) {
    char* dp = (char *) dst;
    while (count > 0) {
        *dp++ = val;
        count--;
    }
}

void memsetw(void* dst, u16 val, size_t count) {
    u16* dp = (unsigned short *) dst;
    while (count > 0) {
        *dp++ = val;
        count--;
    }
}


// ********** String utils

size_t strlen(const char* str) {
    size_t len = 0;
    while (*str++) len++;
    return len;
}

void strcpy(char* dst, const char* src) {
    while (*src) *dst++ = *src++;
    *dst = 0;
}

int strcmp(const char* s, const char* t) {
    while (*s && *t) {
        if (*s == *t) { s++; t++; }
        else return *s - *t;
    }
    if (!*s) return *t;
    if (!*t) return -*s;
    return 0;
}


// ********** Other

void itoa(u32 value, char* str, char base) {
    char* s = str;
    do {
        int rem = value % base;
        *s++ = (rem < 10) ? '0' + rem : 'A' + rem - 10;
    } while (value /= base);
    *s = 0;

    // reverse str
    char* t = str;
    s--;
    while (t < s) {
        char tmp = *t;
        *t = *s;
        *s = tmp;
        t++;
        s--;
    }
}


// ********** I/O ports

u8 inportb(unsigned short _port) {
    u8 data;
    __asm__ __volatile__ ("inb %1, %0" : "=a" (data) : "dN" (_port));
    return data;
}

void outportb(u16 _port, u8 _data) {
    __asm__ __volatile__ ("outb %1, %0" : : "dN" (_port), "a" (_data));
}

u16 inportw(u16 _port) {
    unsigned short data;
    __asm__ __volatile__ ("inw %1, %0" : "=a" (data) : "dN" (_port));
    return data;
}

void outportw(unsigned short _port, unsigned short _data) {
    __asm__ __volatile__ ("outw %1, %0" : : "dN" (_port), "a" (_data));
}

u32 inportl(u16 _port) {
    unsigned short data;
    __asm__ __volatile__ ("inw %1, %0" : "=a" (data) : "dN" (_port));
    return data;
}

/*void outportl(u16 _port, u32 _data) {
    __asm__ __volatile__ ("outw %1, %0" : : "dN" (_port), "a" (_data));
}*/

#endif
