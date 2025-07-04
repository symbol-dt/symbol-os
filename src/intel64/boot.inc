%define SEGMENT_BOOT    0x07c0
%define SEGMENT_DATA    0x07e0
%define SEGMENT_STACK   0x0700
%define SEGMENT_LOADER  0x0800
%define SEGMENT_KERNEL  0x0880

%define ADDRESS_BOOT_C_CNT  0x7c00
%define ADDRESS_BOOT_H_CNT  0x7c02
%define ADDRESS_BOOT_S_CNT  0x7c04
%define ADDRESS_BOOT_C_NUM  0x7c06
%define ADDRESS_BOOT_H_NUM  0x7c08
%define ADDRESS_BOOT_S_NUM  0x7c0a
%define ADDRESS_BOOT_OFF    0x7c0c
%define ADDRESS_BOOT_SEG    0x7c0e

%define ADDRESS_BOOT_LABEL  0x7e00
%define ADDRESS_BOOT_DEVICE 0x7e0c
%define ADDRESS_LOADER_MMBM 0x7e0e
%define ADDRESS_LOADER_1200 0x7e10
%define ADDRESS_LOADER_1588 0x7e12
%define ADDRESS_LOADER_158A 0x7e14
%define ADDRESS_LOADER_15C7 0x7c00
%define ADDRESS_LOADER_15DA 0x7e18
%define ADDRESS_LOADER_15E0 0x7e1c
%define ADDRESS_LOADER_CMOS 0x7e20
%define SEG_LOADER_E820 SEGMENT_STACK
%define ADDRESS_LOADER_E8CT 0x7e22
%define ADDRESS_LOADER_XCNT 0x7e24
%define ADDRESS_LOADER_YCNT 0x7e26
%define ADDRESS_LOADER_POS  0x7e28
%define ADDRESS_LOADER_GDTR 0x7e40
%define ADDRESS_LOADER_IDTR 0x7e50
%define ADDRESS_LOADER_GDT  0x7e60
%define ADDRESS_LOADER_PAGE 0x1000
%define ADDRESS_PAGING_PML5 0x1000
%define ADDRESS_PAGING_PML4 0x2000
%define ADDRESS_PAGING_PDPT 0x3000
%define ADDRESS_PAGING_PD   0x4000
%define ADDRESS_LOADER_IDT  0x5000
%define LENGTH_LOADER       64
%define SECTOR_LOADER       16
; mbr

%macro mbr 4
    ; active flag start<lba> length
    dd (((%3)>>32)<<8) | ((%1)&0xff)
    dd (((%4)>>32)<<8) | ((%2)&0xff)
    dd ((%3)&0xffffffff)
    dd ((%4)&0xffffffff)
%endmacro

%macro gdt32 3
    ; base limit flags
    dw (%2)&0xffff
    dw (%1)&0xffff
    db ((%1)>>16)&0xff
    db (%3)&0xff
    db (((%3)>>4)&0xf0)|(((%2)>>16)&0x0f)
    db ((%1)>>24)&0xff
%endmacro

%macro gdt64 1
    ; flags
    gdt32 0, 0, (%1)
    dq 0
%endmacro

%define SD_GRAN     0x800
%define SD_PROTECT  0x400
%define SD_LONG     0x200
%define SD_PRESENT  0x080
%define SD_LEVEL    0x020
%define SD_PROGRAM  0x010
%define SD_EXEC     0x008
%define SD_CXDD     0x004
%define SD_RXWD     0x002
%define SD_ACCESSWD 0x001   ; 如果段表在只读内存，请置位

%macro page64 2
    ; base flags
    dd ((%2)&0x1fff)|((%1)&0xfffff000)
    dd ((%1)>>32)|((%2)>>13)
%endmacro

%define PG_PRESENT  0x00001
%define PG_WRITABLE 0x00002
%define PG_USER     0x00004
%define PG_PWT      0x00008
%define PG_PCD      0x00010
%define PG_ACCESSED 0x00020
%define PG_DIRTY    0x00040
%define PG_HUGE     0x00080
%define PG_GLOBAL   0x00100
%define PG_PATHUGE  0x01000
%define PG_PROTKEY  0x02000
%define PG_XD       0x20000

%macro idt32 2
    ; offset selector flag
    dw (%2)&0xffff
    dw (%1)&0xffff
    db 0, (%3)&0xff
    dw ((%1)>>16)&0xffff
%endmacro

%define IDT_PRESENT  0x80
%define IDT_LEVEL    0x20
%define IDT_INT      0x8e
%define IDT_TRAP     0x8f
