#ifndef __KERNEL_H__
#define __KERNEL_H__

#include <stdint.h>
#include <string.h>
#include <kernel/asm.h>

struct __boot_info {
    uint8_t code[4];
    uint32_t boot_magic;
    char boot_label[8];
    uint16_t boot_device;
    uint16_t loader_mm_bitmap;
    uint16_t loader_msize_int12;
    uint16_t loader_msize_int15_88;
    uint32_t loader_msize_int15_8a;
    uint32_t loader_msize_int15_e801;
    uint16_t loader_msize_cmos;
    uint16_t loader_msize_int15_e820;
    uint16_t loader_screen_x;
    uint16_t loader_screen_y;
    uint16_t loader_screen_pos;
} __attribute__((aligned(1)));
struct e820 {
    uint64_t base, length;
    uint32_t type, apic;
} __attribute__((aligned(1)));
struct __kernel_info {
    struct idt idt[256];
    struct gdt gdt[16];
    struct tss tss[8];
    struct dtr gdtr, idtr;
    uint32_t boot_magic;
    char boot_label[8];
    uint16_t boot_device;
    uint16_t loader_mm_bitmap;
    uint16_t loader_msize_int12;
    uint16_t loader_msize_int15_88;
    uint32_t loader_msize_int15_8a;
    uint32_t loader_msize_int15_e801;
    uint16_t loader_msize_cmos;
    uint16_t loader_msize_int15_e820;
    uint16_t loader_screen_x;
    uint16_t loader_screen_y;
    uint16_t loader_screen_pos;
    void *video_memory;
    void *kernel_start, *kernel_end;
    void *kernel_text_start, *kernel_text_end;
    void *kernel_rodata_start, *kernel_rodata_end;
    void *kernel_data_start, *kernel_data_end;
    void *kernel_bss_start, *kernel_bss_end;
} __attribute__((aligned(1)));
struct __4k_memory_manager {
    uint64_t attribute;
    uint64_t phy_addr;
    uint32_t age, refrence_count;
    union {
        struct __2m_memory_manager *belong_2m;
        struct __global_memory_manager *belong_global;
    } belong;
    struct __4k_memory_manager *prev, *next;
};
struct __2m_memory_manager {
    uint64_t attribute;
    struct __global_memory_manager *belong;
    union {
        struct {
            uint64_t phy_addr;
            uint32_t age, refrence_count;
        } single;
        struct {
            struct __4k_memory_manager *head_free, *tail_free;
            struct __4k_memory_manager *head_full, *tail_full;
        } multiple;
    } infomation;
    struct __2m_memory_manager *prev, *next;
};
struct __global_memory_manager {
    struct {
        struct __2m_memory_manager *head_free, *tail_free;
        struct __2m_memory_manager *head_busy, *tail_busy;
        struct __2m_memory_manager *head_full, *tail_full;
    } _2m;
    struct {
        struct __4k_memory_manager *head_free, *tail_free;
        struct __4k_memory_manager *head_full, *tail_full;
    } _4k;
};

void kputs(const char *str);
void kputc(char chr);
void kputi(int64_t num);
void kputu(uint64_t num);
void kputx(uint64_t num);
void kputb(uint64_t num);
void kputp(void *ptr);

#endif
