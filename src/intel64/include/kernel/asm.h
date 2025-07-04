#ifndef __ASM_H__
#define __ASM_H__

#include <stdint.h>

#define IDT_INTR_GATE 0x8e
#define IDT_TRAP_GATE 0x8f
#define IDT_SYSI_GATE 0xee
#define IDT_SYST_GATE 0xef

#define breakpoint() __asm__ __volatile__("xchgw %bx, %bx\n\t")
#define cli() __asm__ __volatile__("cli\n\t")
#define sti() __asm__ __volatile__("sti\n\t")
#define clc() __asm__ __volatile__("clc\n\t")
#define stc() __asm__ __volatile__("stc\n\t")
#define cld() __asm__ __volatile__("cld\n\t")
#define std() __asm__ __volatile__("std\n\t")
#define clz() __asm__ __volatile__("clz\n\t")
#define stz() __asm__ __volatile__("stz\n\t")

#define nop() __asm__ __volatile__("nop\n\t")
#define hlt() __asm__ __volatile__("hlt\n\t")

#define inb(port) ({ \
    uint8_t _v; \
    __asm__ __volatile__("inb %1, %0\n\t" : "=a"(_v) : "dI"(port)); \
    _v; })
#define inw(port) ({ \
    uint16_t _v; \
    __asm__ __volatile__("inw %1, %0\n\t" : "=a"(_v) : "dI"(port)); \
    _v; })
#define inl(port) ({ \
    uint32_t _v; \
    __asm__ __volatile__("inl %1, %0\n\t" : "=a"(_v) : "dI"(port)); \
    _v; })
#define outb(port, value) __asm__ __volatile__("outb %0, %1\n\t" : : "a"(value), "dI"(port))
#define outw(port, value) __asm__ __volatile__("outw %0, %1\n\t" : : "a"(value), "dI"(port))
#define outl(port, value) __asm__ __volatile__("outl %0, %1\n\t" : : "a"(value), "dI"(port))

#define read_rflags() ({ \
    uint64_t _v; \
    __asm__ __volatile__("pushfq; pop %0\n\t" : "=r"(_v)); \
    _v; })
#define write_rflags(value) __asm__ __volatile__("push %0; popfq\n\t" : : "r"(value))

#define lgdt(ptr) __asm__ __volatile__("lgdt %0\n\t" : : "m"(*ptr))
#define lidt(ptr) __asm__ __volatile__("lidt %0\n\t" : : "m"(*ptr))
#define ltr(selector) __asm__ __volatile__("ltr %0\n\t" : : "r"(selector))
#define lldt(selector) __asm__ __volatile__("lldt %0\n\t" : : "r"(selector))

#define cpuid(leaf, subleaf, eax, ebx, ecx, edx) \
    __asm__ __volatile__("cpuid" : "=a"(eax), "=b"(ebx), "=c"(ecx), "=d"(edx) : "a"(leaf), "c"(subleaf))

#define read_msr(msr, eax, edx) \
    __asm__ __volatile__("rdmsr" : "=a"(eax), "=d"(edx) : "c"(msr))
#define write_msr(msr, eax, edx) \
    __asm__ __volatile__("wrmsr" : : "a"(eax), "d"(edx), "c"(msr))
#define switch_ds(selector) __asm__ __volatile__("mov %%ax, %%ds\n\t" :: "aI"(selector))
#define switch_es(selector) __asm__ __volatile__("mov %%ax, %%es\n\t" :: "aI"(selector))
#define switch_fs(selector) __asm__ __volatile__("mov %%ax, %%fs\n\t" :: "aI"(selector))
#define switch_gs(selector) __asm__ __volatile__("mov %%ax, %%gs\n\t" :: "aI"(selector))
#define switch_ss(selector) __asm__ __volatile__("mov %%ax, %%ss\n\t" :: "aI"(selector))

struct registers {
    uint16_t cs, ds, es, fs, gs, ss;
    uint32_t cr0, cr2, cr3, cr4, cr8;
    uint64_t rflags, rax, rcx, rdx, rbx;
    uint16_t gdt_size;
    uint64_t gdt_addr;
    uint16_t idt_size;
    uint64_t idt_addr;
} __attribute__((aligned(2)));

struct gdt {
    uint64_t _reserve_0:40;
    uint64_t accessed:1;
    uint64_t read_write:1;
    uint64_t conforming:1;
    uint64_t executable:1;
    uint64_t programmable:1;
    uint64_t dpl:2;
    uint64_t present:1;
    uint64_t _reserve_1:5;
    uint64_t long_mode:1;
    uint64_t protected_mode:1;
    uint64_t _reserve_2:9;
} __attribute__((packed));
struct gdt_tss {
    uint64_t length_low:16;
    uint64_t base_low:24;
    uint64_t type:4;
    uint64_t programmable:1;
    uint64_t dpl:2;
    uint64_t present:1;
    uint64_t length_high:4;
    uint64_t available:1;
    uint64_t _reserve_0:3;
    uint64_t base_high:40;
    uint64_t _reserve_1:32;
} __attribute__((packed));
struct gdt_callgate {
    uint64_t offset_low:16;
    uint64_t selector:16;
    uint64_t _reserve_0:8;
    uint64_t type:4;
    uint64_t programmable:1;
    uint64_t dpl:2;
    uint64_t present:1;
    uint64_t offset_mid:48;
    uint64_t _reserve_1:32;
} __attribute__((packed));
struct idt {
    uint64_t offset_low:16;
    uint64_t selector:16;
    uint64_t ist:3;
    uint64_t _reserve_0:5;
    uint64_t type:4;
    uint64_t programmable:1;
    uint64_t dpl:2;
    uint64_t present:1;
    uint64_t offset_high:48;
    uint64_t _reserve_1:32;
} __attribute__((packed));
struct dtr {
    uint16_t limit;
    uint64_t base;
} __attribute__((packed));
struct tss {
    uint32_t _reserve_0;
    uint64_t rsp0, rsp1, rsp2;
    uint64_t _reserve_1;
    uint64_t ist1, ist2, ist3, ist4, ist5, ist6, ist7;
    uint64_t _reserve_2;
    uint16_t _reserve_3, iomap_base;
} __attribute__((packed));

void store_registers(struct registers *regs);
void load_gdt(struct dtr *gdtr);
void load_gdt_switch_cs(struct dtr *gdtr, uint16_t cs);
void load_gdt_switch_cs_address(struct dtr *gdtr, uint16_t cs, uint64_t address);
void load_gdt_switch_ss(struct dtr *gdtr, uint16_t ss);
void load_gdt_switch_cs_ss(struct dtr *gdtr, uint16_t cs, uint16_t ss);
void load_gdt_switch_cs_ss_ds(struct dtr *gdtr, uint16_t cs, uint16_t ss, uint16_t ds);
void load_gdt_switch_cs_ss_address(struct dtr *gdtr, uint16_t cs, uint16_t ss, uint64_t address);
void load_idt(struct dtr *idtr);
void load_page_table(uint64_t *page_table);
void load_page_table_switch_address(uint64_t *page_table, uint64_t address);
void load_tss_switch_tr(uint16_t tr);

void create_gdt(struct gdt *gdt, uint64_t accessed, uint64_t read_write,
                uint64_t conforming, uint64_t executable, uint64_t dpl, uint64_t present);
void create_gdt_tss(struct gdt_tss *gdt, uint64_t length, uint64_t base, uint64_t type,
                uint64_t dpl, uint64_t present);
#endif
