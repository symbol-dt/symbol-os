#ifndef __INIT_H__
#define __INIT_H__
#include <kernel/xdt.h>
#include <kernel/vga.h>

void init_arch(void){
    init_gdt();
    init_idt();
    // init_vga();
}

#endif
