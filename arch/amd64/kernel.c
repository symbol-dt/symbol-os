#include <stddef.h>
#include <kernel/asm.h>
#include <kernel/init.h>

void main (void) {
    init_arch();
    for(hlt();;step())set_break();
    return ;
}
