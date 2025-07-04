#include <kernel/kernel.h>
#define PAGESIZE 0x1000

struct __kernel_info *kernel_info = (struct __kernel_info *)0x20000;
extern void kernel_start, kernel_end;
extern void kernel_text_start, kernel_text_end;
extern void kernel_rodata_start, kernel_rodata_end;
extern void kernel_data_start, kernel_data_end;
extern void kernel_bss_start, kernel_bss_end;

static void show_registers(void) {
    struct registers r;
    store_registers(&r);
    kputs(" ======= Registers ======="), kputs("\n\r\t");
    kputs("RAX: "), kputx(r.rax), kputs("\n\r\t");
    kputs("RBX: "), kputx(r.rbx), kputs("\n\r\t");
    kputs("RCX: "), kputx(r.rcx), kputs("\n\r\t");
    kputs("RDX: "), kputx(r.rdx), kputs("\n\r\t");
    kputs("CS : "), kputx(r.cs),  kputs("\n\r\t");
    kputs("DS : "), kputx(r.ds),  kputs("\n\r\t");
    kputs("ES : "), kputx(r.es),  kputs("\n\r\t");
    kputs("FS : "), kputx(r.fs),  kputs("\n\r\t");
    kputs("GS : "), kputx(r.gs),  kputs("\n\r\t");
    kputs("SS : "), kputx(r.ss),  kputs("\n\r\t");
    kputs("CR0: "), kputx(r.cr0), kputs("\n\r\t");
    kputs("CR2: "), kputx(r.cr2), kputs("\n\r\t");
    kputs("CR3: "), kputx(r.cr3), kputs("\n\r\t");
    kputs("CR4: "), kputx(r.cr4), kputs("\n\r\t");
    kputs("CR8: "), kputx(r.cr8), kputs("\n\r\t");
    kputs("RFLAGS: "), kputx(r.rflags), kputs("\n\r");
    breakpoint();
    return ;
}

static inline void copy_kernel_info(void) {
    struct __boot_info *boot_info = (struct __boot_info*)0x7e00;
    kernel_info->gdtr.base = (uint64_t)&kernel_info->gdt;
    kernel_info->idtr.base = (uint64_t)&kernel_info->idt;
    kernel_info->gdtr.limit = sizeof(kernel_info->gdt) - 1;
    kernel_info->idtr.limit = sizeof(kernel_info->idt) - 1;
    kernel_info->kernel_start = &kernel_start;
    kernel_info->kernel_end = &kernel_end;
    kernel_info->kernel_text_start = &kernel_text_start;
    kernel_info->kernel_text_end = &kernel_text_end;
    kernel_info->kernel_rodata_start = &kernel_rodata_start;
    kernel_info->kernel_rodata_end = &kernel_rodata_end;
    kernel_info->kernel_data_start = &kernel_data_start;
    kernel_info->kernel_data_end = &kernel_data_end;
    kernel_info->kernel_bss_start = &kernel_bss_start;
    kernel_info->kernel_bss_end = &kernel_bss_end;
    kernel_info->boot_magic = boot_info->boot_magic;
    *(uint64_t*)&kernel_info->boot_label = *(uint64_t*)&boot_info->boot_label;
    kernel_info->boot_device = boot_info->boot_device;
    kernel_info->loader_mm_bitmap = boot_info->loader_mm_bitmap;
    kernel_info->loader_msize_int12 = boot_info->loader_msize_int12;
    kernel_info->loader_msize_int15_88 = boot_info->loader_msize_int15_88;
    kernel_info->loader_msize_int15_8a = boot_info->loader_msize_int15_8a;
    kernel_info->loader_msize_int15_e801 = boot_info->loader_msize_int15_e801;
    kernel_info->loader_msize_cmos = boot_info->loader_msize_cmos;
    kernel_info->loader_msize_int15_e820 = boot_info->loader_msize_int15_e820;
    kernel_info->loader_screen_x = boot_info->loader_screen_x;
    kernel_info->loader_screen_y = boot_info->loader_screen_y;
    kernel_info->loader_screen_pos = boot_info->loader_screen_pos;
    kernel_info->video_memory = (void *)0xb8000;

    create_gdt(kernel_info->gdt + 0, 0, 0, 0, 0, 0, 0); // Null Segment
    create_gdt(kernel_info->gdt + 4, 0, 1, 0, 1, 0, 1); // SCode Segment
    create_gdt(kernel_info->gdt + 5, 0, 1, 0, 0, 0, 1); // SData Segment
    create_gdt(kernel_info->gdt + 6, 0, 1, 0, 1, 3, 1); // UCode Segment
    create_gdt(kernel_info->gdt + 7, 0, 1, 0, 0, 3, 1); // UData Segment
    create_gdt_tss(kernel_info->gdt + 8, sizeof(struct tss) - 1, (uint64_t)&kernel_info->tss[0], 0x9a, 0, 1); // TSS Segment 0
    create_gdt_tss(kernel_info->gdt + 10, sizeof(struct tss) - 1, (uint64_t)&kernel_info->tss[1], 0x9a, 3, 1); // TSS Segment 1
    load_gdt_switch_cs_ss_ds(&kernel_info->gdtr, 32, 40, 40);
    breakpoint();
    load_tss_switch_tr(64);
    return ;
}

int main (int restart) {
    if(!restart) {
        copy_kernel_info();
        kputx(sizeof(struct __kernel_info) + 0x20000), kputs("\n\r");
    }
    // 0x30000
    breakpoint();
    for(; ; ) ;
    return 0;
}
