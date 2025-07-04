#ifndef __KPUTS_H__
#define __KPUTS_H__

#include <stddef.h>
#include <ctype.h>
#include <kernel/asm.h>

#define GMEM ((char*)0xa0000)

static int pos = 0;

void kputc(char c) {
    set_break();
    if (isgraph(c)){
        GMEM[pos++] = c;
        GMEM[pos++] = 0x0f;
    } else if(c == '\n') {
        pos = (pos + 160) / 160 * 160;
    } else if (c == '\r') {
        pos = pos / 160 * 160;
    } else if (c == '\t') {
        pos = (pos + 8) >> 3 << 3;
    } else {
        GMEM[pos++] = '?';
        GMEM[pos++] = 0x0f;
    }
    *(int*)0 = pos;
}

void kputs(char *str) {
    while (*str) kputc(*str++);
}

void kputi(int i) {
    char buf[16];
    int pos = 0;
    if (i < 0)
        kputc('-'), i = -i;
    if (i == 0) kputc('0');
    while (i) {
        buf[pos++] = '0' + i % 10;
        i /= 10; 
    }
    for (int j = pos - 1; j >= 0; j--) kputc(buf[j]);
}
void kputx(uintptr_t i) {
    char buf[16];
    int pos = 0;
    if (i == 0) kputc('0');
    while (i) {
        buf[pos++] = '0' + i % 16;
        i /= 16;
    } 
    for (int j = pos - 1; j >= 0; j--) kputc(buf[j]);
}

#endif
