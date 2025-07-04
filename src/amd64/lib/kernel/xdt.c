#include <stddef.h>
#include <kernel/xdt.h>
#include <kernel/asm.h>

static void set_idt(idt_element_t *idt, void *func, uint8_t type){
    idt->base_low = ((size_t)func) & 0x0000ffff;
    idt->base_mid = (((size_t)func) >> 16) & 0x0000ffff;
    idt->base_high = (((size_t)func) >> 32) & 0xffffffff;
    idt->selector = 0x18;
    idt->type = type;
    idt->ist = 0;
    return ;
}
static void set_gdt(gdt_element_t *gdt, size_t base, size_t limit, uint8_t attr, uint8_t type){
    gdt->base_low = base & 0x0000ffff;
    gdt->base_mid = (base >> 16) & 0x000000ff;
    gdt->base_high = (base >> 32) & 0xffffffff;
    gdt->limit_low = limit & 0x0000ffff;
    gdt->limit_high = (limit >> 16) & 0x000f;
    gdt->type = type & 0xff;
    gdt->attr = (attr >> 4) & 0x0f;
    return ;
}

void init_idt(void){
    dt_info_t *idr_hdr = (dt_info_t *) ADDR_IDT_INFO;
    idt_element_t *idt_item = (idt_element_t *) ADDR_IDT;
    idr_hdr->addr = (size_t)idt_item;
    idr_hdr->size = sizeof(idt_element_t) * 256;
    set_idt(idt_item + 0, devide_error, IDT_TRAP_GATE);
    set_idt(idt_item + 1, debug, IDT_TRAP_GATE);
    set_idt(idt_item + 2, nmi, IDT_INT_GATE);
    set_idt(idt_item + 3, break_point, IDT_SYS_GATE);
    set_idt(idt_item + 4, bounds, IDT_SYS_GATE);
    set_idt(idt_item + 5, over_flow, IDT_SYS_GATE);
    set_idt(idt_item + 6, invalid_opcode, IDT_TRAP_GATE);
    set_idt(idt_item + 7, device_not_available, IDT_TRAP_GATE);
    set_idt(idt_item + 8, double_fault, IDT_TRAP_GATE);
    set_idt(idt_item + 9, coprocessor_segment_overrun, IDT_TRAP_GATE);
    set_idt(idt_item + 10, invalid_tss, IDT_TRAP_GATE);
    set_idt(idt_item + 11, segment_not_available, IDT_TRAP_GATE);
    set_idt(idt_item + 12, stack_segment, IDT_TRAP_GATE);
    set_idt(idt_item + 13, general_protection, IDT_TRAP_GATE);
    set_idt(idt_item + 14, page_fault, IDT_TRAP_GATE);
    set_idt(idt_item + 15, reserved, IDT_TRAP_GATE);
    set_idt(idt_item + 16, coprocessor_error, IDT_TRAP_GATE);
    set_idt(idt_item + 0x80, syscall, IDT_SYS_GATE);
    lidt(idr_hdr);
    return ;
}
void init_gdt(void){
    dt_info_t *gdt_hdr = (dt_info_t *) ADDR_GDT_INFO;
    gdt_element_t *gdt_item = (gdt_element_t *) ADDR_GDT;
    gdt_hdr->addr = (size_t)gdt_item;
    gdt_hdr->size = sizeof(gdt_element_t) * 7;
    set_gdt(gdt_item + 0, 0, 0, 0, 0);
    set_gdt(gdt_item + 1, 0, 0xffffffff, GDT_ATTR_32DEF | GDT_ATTR_LIMITALIGN4KB,
        GDT_TYPE_PROG | GDT_TYPE_PROG_X | GDT_TYPE_PROG_XWR | GDT_TYPE_PRESENT | GDT_TYPE_LEVEL0);
    set_gdt(gdt_item + 2, 0, 0xffffffff, GDT_ATTR_32DEF | GDT_ATTR_LIMITALIGN4KB,
        GDT_TYPE_PROG | GDT_TYPE_PROG_D | GDT_TYPE_PROG_XWR | GDT_TYPE_PRESENT | GDT_TYPE_LEVEL0);
    set_gdt(gdt_item + 3, 0, 0, GDT_ATTR_64DEF,
        GDT_TYPE_PROG | GDT_TYPE_PROG_X | GDT_TYPE_PROG_XWR | GDT_TYPE_PRESENT | GDT_TYPE_LEVEL0);
    set_gdt(gdt_item + 4, 0, 0, 0, 0);
    set_gdt(gdt_item + 5, 0, 0, GDT_ATTR_64DEF,
        GDT_TYPE_PROG | GDT_TYPE_PROG_D | GDT_TYPE_PROG_XWR | GDT_TYPE_PRESENT | GDT_TYPE_LEVEL0);
    set_gdt(gdt_item + 6, 0, 0, 0, 0);
    lgdt(gdt_hdr);
    return ;
}

void do_devide_error(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcxA, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    return ;
}
void do_debug(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    return ;
}
void do_nmi(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    return ;
}
void do_break_point(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
        break_point();
    return ;
}
void do_bounds(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    return ;
}
void do_over_flow(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    return ;
}
void do_invalid_opcode(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    return ;
}
void do_device_not_available(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    return ;
}
void do_double_fault(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    return ;
}
void do_coprocessor_segment_overrun(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    return ;
}
void do_invalid_tss(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    return ;
}
void do_segment_not_available(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    return ;
}
void do_stack_segment(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    return ;
}
void do_general_protection(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    return ;
}
void do_page_fault(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    return ;
}
void do_coprocessor_error(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    return ;
}
void do_syscall(uint64_t rdi, uint64_t rsi,
    uint64_t rdx, uint64_t rcx, uint64_t r8,
    uint64_t r9, uint64_t r10, uint64_t r11,
    uint64_t r12, uint64_t r13, uint64_t r14,
    uint64_t r15, uint64_t rax, uint64_t rbx,
    uint64_t rbp, uint64_t tr, uint64_t ds,
    uint64_t es, uint64_t fs, uint64_t gs,
    uint64_t err, uint64_t rip, uint64_t cs,
    uint64_t rflags, uint64_t rsp, uint64_t ss){
    if(err)
        return ;
    switch(rax){
        case 0:
            break;
        default:
            ;
    }
    return ;
}
