#include <kernel/kernel.h>
#include <stdarg.h>

const static char digits[] = "0123456789abcdef";
static char buffer[72];

void kputs(const char *str){
    while(*str) kputc(*(str++));
}

extern struct __kernel_info *kernel_info;

void kputc(char chr){
    switch(chr){
        case ' ' ... '~':{
            normal_putc:
            ((uint16_t*)kernel_info->video_memory)[kernel_info->loader_screen_pos] = (uint16_t)chr | 0x0700;
            kernel_info->loader_screen_pos++;
            break;
        } case '\n':{
            kernel_info->loader_screen_pos += 40;
            break; 
        } case '\r':{
            kernel_info->loader_screen_pos = (kernel_info->loader_screen_pos / 40) * 40;
            break; 
        } case '\t':{
            kernel_info->loader_screen_pos = ((kernel_info->loader_screen_pos >> 3) + 1) << 3;
            break;
        } default:{
           chr = '?';
           goto normal_putc;
        }
    }
    if(kernel_info->loader_screen_pos >= 40 * 25){
        memcopy(kernel_info->video_memory, kernel_info->video_memory + 80, 40 * 24 * 2);
        memsetw(kernel_info->video_memory + 80 * 24, ' ' | 0x0700, 40);
        kernel_info->loader_screen_pos -= 40;
    }
}
void kputi(int64_t num){
    if(num < 0){
        kputc('-');
        num = -num; 
    }
    return kputu(num);
}
void kputu(uint64_t num){
    if(num == 0){
        kputc('0');
        return; 
    }
    register int i = 0;
    while(num)
        if(i % 5 == 4) buffer[i++] = ',';
        else buffer[i++] = digits[num % 10], num /= 10;
    while(i--) kputc(buffer[i]);
}
void kputx(uint64_t num){
    if(num == 0){
        kputc('0');
        return; 
    }
    register int i = 0;
    while(num)
        if(i % 5 == 4) buffer[i++] = '_';
        else buffer[i++] = digits[num & 15], num >>= 4;
    while(i--) kputc(buffer[i]);
}
void kputb(uint64_t num){
    if(num == 0){
        kputc('0');
        return; 
    }
    register int i = 0;
    while(num)
        if(i % 9 == 8) buffer[i++] = '_';
        else buffer[i++] = digits[num & 1], num >>= 1;
    while(i--) kputc(buffer[i]);
}

void kputp(void *ptr){
    register uint64_t num = (uint64_t)ptr;
    for(int shift = 64; shift > 0; shift -= 4)
        kputc(digits[(num >> (shift - 4)) & 0xf]);
}