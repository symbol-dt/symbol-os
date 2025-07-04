#ifndef _KERNEL_IDT_H_
#define _KERNEL_IDT_H_

#include <stddef.h>

#define REG_INT(name) void name(void); void do_##name (uint64_t rdi, uint64_t rsi, \
    uint64_t rdx, uint64_t rcx, uint64_t r8, \
    uint64_t r9, uint64_t r10, uint64_t r11, \
    uint64_t r12, uint64_t r13, uint64_t r14, \
    uint64_t r15, uint64_t rax, uint64_t rbx, \
    uint64_t rbp, uint64_t tr, uint64_t ds, \
    uint64_t es, uint64_t fs, uint64_t gs, \
    uint64_t err, uint64_t rip, uint64_t cs, \
    uint64_t rflags, uint64_t rsp, uint64_t ss);

#define ADDR_IDT_INFO           0x101000
#define ADDR_GDT_INFO           0x101010
#define ADDR_IDT                0x100000
#define ADDR_GDT                0x101020

#define IDT_INT_GATE            0x8e
#define IDT_TRAP_GATE           0x8f
#define IDT_SYS_GATE            0xef

#define PAGE_ATTR_PRESENT       0x80
#define PAGE_ATTR_NOT_PRESENT   0x00
#define PAGE_ATTR_LEVEL0        0x00
#define PAGE_ATTR_LEVEL1        0x20
#define PAGE_ATTR_LEVEL2        0x40
#define PAGE_ATTR_LEVEL3        0x60
#define PAGE_ATTR_PROGRAM       0x10
#define PAGE_ATTR_CODE          0x08
#define PAGE_ATTR_DATA          0x00
#define PAGE_ATTR_AC            0x04
#define PAGE_ATTR_WR_XR         0x02
#define PAGE_ATTR_DIRTY         0x01
#define PAGE_FLAG_4KB           0x8000
#define PAGE_FLAG_32D           0x4000
#define PAGE_FLAG_64D           0x2000

#define GDT_TYPE_PROG           0x10    // 程序段
#define GDT_TYPE_PROG_D         0x00    // 数据段
#define GDT_TYPE_PROG_X         0x08    // 代码段
#define GDT_TYPE_PROG_CD        0x04    // 符合要求的 (代码段)
                                        // 向下展开, 栈 (数据段)
#define GDT_TYPE_PROG_XWR       0x02    // 可读 (代码段)
                                        // 可写 (数据段)
#define GDT_TYPE_PROG_DTY       0x01    // 已访问 (脏)
#define GDT_TYPE_SYS_TSS16      0x01    // 可用的16位TSS
#define GDT_TYPE_SYS_LDT        0x02    // 本地描述符表LDT
#define GDT_TYPE_SYS_TSS16_BUSY 0x03    // 繁忙的16位TSS
#define GDT_TYPE_SYS_CALL_GATE  0x04    // 16位呼叫门
#define GDT_TYPE_SYS_TASK_GATE  0x05    // 任务门/Coum传输
#define GDT_TYPE_SYS_INT_GATE   0x06    // 16位中断门
#define GDT_TYPE_SYS_TRAP_GATE16 0x7    // 16位陷阱门
#define GDT_TYPE_SYS_TSS32      0x09    // 可用的32位TSS
#define GDT_TYPE_SYS_TSS32_BUSY 0x0b    // 繁忙的32位TSS
#define GDT_TYPE_SYS_CALL_GATE32 0xc    // 32位调用门
#define GDT_TYPE_SYS_INT_GATE32 0x0e    // 32位中断门
#define GDT_TYPE_SYS_TRAP_GATE32 0xf    // 32位陷阱门
#define GDT_TYPE_LEVEL0         0x00
#define GDT_TYPE_LEVEL1         0x20
#define GDT_TYPE_LEVEL2         0x40
#define GDT_TYPE_LEVEL3         0x60
#define GDT_TYPE_PRESENT        0x80
#define GDT_TYPE_NOT_PRESENT    0x00
#define GDT_ATTR_32DEF          0x40
#define GDT_ATTR_16DEF          0x00
#define GDT_ATTR_64DEF          0x20
#define GDT_ATTR_LIMITALIGN4KB  0x80

REG_INT(devide_error)
REG_INT(debug)
REG_INT(nmi)
REG_INT(break_point)
REG_INT(over_flow)
REG_INT(bounds)
REG_INT(invalid_opcode)
REG_INT(device_not_available)
REG_INT(double_fault)
REG_INT(coprocessor_segment_overrun)
REG_INT(invalid_tss)
REG_INT(segment_not_available)
REG_INT(stack_segment)
REG_INT(general_protection)
REG_INT(page_fault)
REG_INT(reserved)
REG_INT(coprocessor_error)
REG_INT(syscall)

#undef REG_INT

typedef struct {
    uint16_t base_low;
    uint16_t selector;
    uint8_t ist;
    uint8_t type;
    uint16_t base_mid;
    uint32_t base_high;
} __attribute__((packed)) idt_element_t;

typedef struct {
    uint16_t limit_low;
    uint16_t base_low;
    uint8_t base_mid;
    uint8_t type;
    uint8_t limit_high:4;
    uint8_t attr:4;
    uint8_t base_high;
} __attribute__((packed)) gdt_element_t;

typedef struct {
    uint16_t size;
    uint64_t addr;
} __attribute__((packed)) dt_info_t;

void init_idt(void);
void init_gdt(void);

#endif // __KERNEL_MEMORY_IDT_H__
