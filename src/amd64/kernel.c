#include <stddef.h>
#include <stdio.h>
#include <kernel/asm.h>
#include <kernel/init.h>
#include <kernel/kputs.h>

static void show_mem(void){
    if((1<<0)&(*(uint16_t*)0x07e12)){
        kputs("i12      ");
        kputi(*(uint16_t*)0x07e14);
        kputs(" KB\n");
    }
    if((1<<1)&(*(uint16_t*)0x07e12)){
        kputs("i15   88 ");
        kputi(*(uint16_t*)0x07e16);
        kputs(" KB\n");
    }
    if((1<<2)&(*(uint16_t*)0x07e12)){
        kputs("i15   8a ");
        kputi(*(uint32_t*)0x07e18);
        kputs(" KB\n");
    }
    if((1<<3)&(*(uint16_t*)0x07e12)){
        kputs("cmos     ");
        kputi(*(uint16_t*)0x07e1c);
        kputs(" KB\n");
    }
    if((1<<4)&(*(uint16_t*)0x07e12)){
        kputs("i15 da88 ");
        kputi(*(uint32_t*)0x07e1e);
        kputs(" KB\n");
    }
    if((1<<5)&(*(uint16_t*)0x07e12)){
        kputs("i15 e801 ");
        kputi(*(uint32_t*)0x07e22);
        kputs(" KB\n");
    }
}

void main (void) {
    int i;
    init_arch();
    kputs("Hello world!\n\n");
    show_mem();
    for(hlt();;step()) set_break();
    return ;
}
