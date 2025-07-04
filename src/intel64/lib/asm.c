#include <kernel/asm.h>

void create_gdt(struct gdt *gdt, uint64_t accessed, uint64_t read_write,
                uint64_t conforming, uint64_t executable, uint64_t dpl, uint64_t present) {
    if(present) {
        gdt->programmable = 1;
        gdt->long_mode = 1;
    } else {
        gdt->programmable = 0;
        gdt->long_mode = 0;
    }
    gdt->accessed = accessed;
    gdt->read_write = read_write;
    gdt->conforming = conforming;
    gdt->executable = executable;
    gdt->dpl = dpl;
    gdt->present = present;
    gdt->protected_mode = 0;
    gdt->_reserve_0 = 0;
    gdt->_reserve_1 = 0;
    gdt->_reserve_2 = 0;
}
void create_gdt_tss(struct gdt_tss *gdt, uint64_t length, uint64_t base, uint64_t type,
                uint64_t dpl, uint64_t present){
    gdt->type = type;
    gdt->dpl = dpl;
    gdt->present = present;
    gdt->length_low = length & 0xffff;
    gdt->length_high = (length >> 16) & 0xf;
    gdt->base_low = base & 0xffffff;
    gdt->base_high = (base >> 24) & 0xffffffff;
    gdt->programmable = 0;
    gdt->available = 0;
    gdt->_reserve_0 = 0;
    gdt->_reserve_1 = 0;
}
