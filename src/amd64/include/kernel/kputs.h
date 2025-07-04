#ifndef __KPUTS_H__
#define __KPUTS_H__

#include <stddef.h>
#include <ctype.h>
#include <kernel/asm.h>

#define GMEM ((char*)0xb8000)

static int pos = 0;

void kputc(char c) {
    if(pos >= 80 * 25){
        int i;
        for(i = 0; i < 80 * 24; i++)
            GMEM[i] = GMEM[i + 80];
        for(i = 0; i < 80; i++)
            GMEM[i + 80 * 24] = 0x00;
        pos = 80 * 24;
    }
    if (isgraph(c) || c == ' '){
        GMEM[pos++] = c;
        GMEM[pos++] = 0x0f;
    } else if(c == '\n') {
        pos = (pos + 80) / 80 * 80;
    } else if (c == '\r') {
        pos = pos / 80 * 80;
    } else if (c == '\t') {
        pos = (pos + 8) >> 3 << 3;
    } else {
        GMEM[pos++] = 0x04;
        GMEM[pos++] = 0x8f;
    }
    *(int*)0 = pos;
}

void kputs(char *str) {
    while (*str) kputc(*str++);
}

void kputi(int i) {
    char buf[16];
    int pos = 0, j;
    if (i < 0)
        kputc('-'), i = -i;
    if (i == 0) kputc('0');
    while (i) {
        buf[pos++] = '0' + i % 10;
        i /= 10; 
    }
    for (j = pos - 1; j >= 0; j--) kputc(buf[j]);
}
void kputx(uintptr_t i) {
    char buf[16];
    int pos = 0, j;
    if (i == 0) kputc('0');
    while (i) {
        if((i&15)<10) buf[pos++] = (i&15) + '0';
        else buf[pos++] = (i&15) + ('A' - 10);
        i >>= 4;
    } 
    for (j = pos - 1; j >= 0; j--) kputc(buf[j]);
}

#endif
