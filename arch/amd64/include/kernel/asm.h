#ifndef _KERNEL_ASM_H_
#define _KERNEL_ASM_H_
#include <stddef.h>

typedef struct segment_register {
    uint16_t cs, ds, ss, es;
    uint16_t fs, gs;
} segment_register_t;

int inb(uint16_t port);
void outb(uint16_t port, uint8_t data);
void insl(uint16_t port);
void outsl(uint16_t port, uint16_t data);
void insw(uint16_t port);
void outsw(uint16_t port, uint32_t data);
void call(uintptr_t addr);
void call_far(uint16_t seg, uintptr_t addr);
void jump(uintptr_t addr);
void jump_far(uint16_t seg, uintptr_t addr);
void stc(void);
void clc(void);
void std(void);
void cld(void);
void sti(void);
void cli(void);
void hlt(void);
void nop(void);
void step(void);
void set_break(void);
void lidt(void* addr);
void lgdt(void* addr);
void int80(void);
void sto_seg(struct segment_register *reg);
void lod_seg(struct segment_register *reg, uintptr_t addr, size_t stack_size);
void lod_seg_stack(struct segment_register *reg, uintptr_t addr);

#endif
