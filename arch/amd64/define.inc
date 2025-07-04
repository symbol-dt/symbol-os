; 地址
%define ADDR_SEG_BOOT       0x007c0
%define ADDR_SEG_DATA       0x007e0
%define ADDR_SEG_LOAD       0x00800
%define ADDR_IDT            0x100000
%define ADDR_IDT_INFO       0x101000
%define ADDR_GDT_INFO       0x101010
%define ADDR_GDT            0x101020
%define ADDR_PML5           0x102000
%define ADDR_PML4           0x103000
%define ADDR_PDPT           0x104000
%define ADDR_PD             0x105000
%define ADDR_FREE           0x106000

; 引导储存数据
;   7e00    启动驱动器号
;   7e02    系统名称
;   7e0c    系统版本
;   7e10    光标位置/char
;   7e12    reserved
;   7e20    CPUID 80000001 EAX
;   7e24    CPUID 80000001 ECX
;   7e28    CPUID 80000001 EDX
;   7e2c    CPUID 80000001 EBX
;   7e30    RSDP 拷贝
; 100000    IDT
; 101000    IDT INFO
;           GDT INFO
;           GDT
; 102000    PML5 (000ff800_00000000)
; 103000    PML4 (000007fc_00000000)
; 104000    PDPT (00000003_fe000000)
; 105000    PD   (00000000_01ff0000) BIG

; MBR 磁盘结构
%macro mbr_null 0
    db 0x00, 0x00
    dw 0x02
    db 0x5b, 0xff
    dw 0xffff
    dd 0x00000001
    dd 0xffffffff
%endmacro
; 分区类型
;   0000 未知
;   0001 FAT12
;   0002 XENIX /
;   0003 XENIX /usr/
;   0004 FAT16 (小于32MB)
;   0005 DOS Extended
;   0006 FAT16
;   0007 HPFS/NTFS/ExFAT
;   0008 AIX
;   0009 AIX Boot
;   000a OS/2 Boot
;   000b Windows 95 FAT32
;   000c Windows 95 FAT32 LBA
;   000e Windows 95 FAT16
;   000f Windows 95(DOS) Extended LBA (大于 8GB)
;   0010 OPUS
;   0011 Hidden FAT12
;   0012 EISA隐藏分区 (Compaq Diagonstics使用)
;   0014 Hidden FAT16 (小于32MB) or Maverick OS Omega FS
;   0016 Hidden FAT16
;   0017 Hidden HPFS/NTFS
;   0018 AST Windows Swap
;   001b Hidden FAT32
;   001c Hidden FAT32 LBA
;   001e Hidden LBA VFAT
;   0024 NEC MS-DOS 3.x
;   0027 Mcrosoft recovery partition
;   0035 OS/2 JFS
;   0038 THEOS V3 2GB
;   0039 THEOS V4 spanned
;   003a THEOS V4 4GB
;   003b THEOS V4 extended
;   003c PartitionMagic recovery
;   003d Novell Netware(Hidden)
;   0040 VENIX 286
;   0041 PPC PreP Boot or Linux/MINIX (sharing with DRDOS)
;   0042 SFS or RAID
;   0043 Linux native (sharing with DRDOS)
;   0045 Boot-US
;   004c Oberon
;   004d QNX 4.2 Primary
;   004e QNX 4.2 Secondary
;   004f QNX 4.2 Tertiary
;   0050 DM (Disk Danager)
;   0051 Novell (or DM6 Aux1)
;   0052 CP/M or Microport SysV/AT
;   0053 DM6 Aux3 (Disk Danager)
;   0054 DM6 Aux3 (Disk Danager)
;   0055 EZ-Drive (Disk Manager)
;   0056 Golden Bow (Disk Manager)
;   0057 DrivePro
;   005a Symbol FS
;   005b Symbol Disk Manager Part
;   005c Priam Edisk (DiskManager)
;   0061 SpeedStor
;   0063 Unix, System V/386, GNU HURD or Mach
;   0064 Novell Netware/286 2.xx
;   0065 Novell Netware/386 3.xx
;   0066 Novell Netware/286 2.xx
;   0067 Novell Netware/286 2.xx
;   0068 Novell Netware/286 2.xx
;   0069 Novell Netware/286 2.xx
;   0070 DiskSecure Multi-Boot
;   0074 Scramdisk
;   0075 PC/IX
;   0077 QNX 4.x
;   0078 QNX 4.x 2nd
;   0079 QNX 4.x 3rd
;   0080 Minix until 1.4a
;   0081 Early Linux, or Minix since 1.4b
;   0082 Linux swap
;   0083 Linux
;   0084 OS/2 Hidden C:
;   0085 Linux Extended
;   0086 FAT16 Volume
;   0087 NTFS Volume
;   008b FAT32 Volume
;   008c FAT32 LBA Volume
;   0093 Amoeda
;   0094 Amoeda Bad Blocks Table
;   009f BSD/OS
;   00a0 Hibernation
;   00a1 Hibernation
;   00a0 IBM Thinkpad Hidden
;   00a5 FreeBSD/NetBSD/386BSD
;   00a6 OpenBSD
;   00a7 NextStep
;   00a9 NetBSD
;   00aa Olivetti FAT12
;   00ac IBM JFS
;   00b7 BSDI BSD/386
;   00b8 BSDI BSD/386 swap
;   00be Solaris Boot
;   00c0 DR-DOS/Novell DOS Secured
;   00c1 DRDOS/sec FAT12
;   00c4 DRDOS/sec FAT16
;   00c6 Corrupted FAT16
;   00c7 Corrupted NTFS
;   00d8 CP/M-86
;   00db CP/M, Concurrent DOS or CTOS
;   00df BootIt
;   00e1 DOS access FAT12
;   00e3 DOS R/0 or SpeedStor
;   00e4 SpeedStor FAT16
;   00eb BeOS FS
;   00ee Protected MBR
;   00ef EFI System Partition
;   00f1 SpeedStor
;   00f2 DOS 3.3+ 2nd
;   00f4 SpeedStor Large
;   00fb VMware VMFS
;   00fc VMware swap
;   00fd Linux RAID
;   00fe LAN STEP
;   00ff Bad Blocks Table
;   ff?? 保留
;   fffd MBR扇区
;   fffe GPT扇区
;   ffff 磁盘头
; 分区状态
;   00 空的
;   5a 可引导的
;   80 正常的
;   fd 坏的
;   fe 保留
;   ff 保护

; 分段项
%macro gdt_segment 4
    ; gdt_segment (base, limit, type, attribute)
    dw %2 & 0xffff
    dw %1 & 0xffff
    db (%1 >> 16) & 0xff
    db %3 & 0xff
    db (%4 & 0xf0) | ((%2 >> 14) & 0x0f)
    db (%1 >> 24) & 0xff
%endmacro
%macro gdt_null 0
    gdt_segment 0, 0, 0, 0
%endmacro

; 程序段类型
%define sta_prog            0x10    ; 程序段
%define sta_prog_d          0x00    ; 数据段
%define sta_prog_x          0x08    ; 代码段
%define sta_prog_cd         0x04    ; 符合要求的 (代码段)
                                    ; 向下展开, 栈 (数据段)
%define sta_prog_xwr        0x02    ; 可读 (代码段)
                                    ; 可写 (数据段)
%define sta_prog_dt         0x01    ; 已访问 (脏)
; 系统段类型
%define sta_sys_tss16       0x01     ; 可用的16位TSS
%define sta_sys_ldt         0x02     ; 本地描述符表LDT
%define sta_sys_tss16_buzy  0x03     ; 繁忙的16位TSS
%define sta_sys_callgate16  0x04     ; 16位呼叫门
%define sta_sys_taskgate    0x05     ; 任务门/Coum传输
%define sta_sys_intgate16   0x06     ; 16位中断门
%define sta_sys_trapgate16  0x07     ; 16位陷阱门
%define sta_sys_tss32       0x09     ; 可用的32位TSS
%define sta_sys_tss32_buzy  0x0b     ; 繁忙的32位TSS
%define sta_sys_callgate32  0x0c     ; 32位调用门
%define sta_sys_intgate32   0x0e     ; 32位中断门
%define sta_sys_trapgate32  0x0f     ; 32位陷阱门
; 段类型
%define sta_level0          0x00
%define sta_level1          0x20
%define sta_level2          0x40
%define sta_level3          0x60
%define sta_present         0x80
%define sta_non_present     0x00
; 段选项
%define stt_32def           0x40
%define stt_32c16           0x00
%define stt_64def           0x20
%define stt_limitalign4kb   0x80

; 64位页表项
%macro paging 3
    ; page (base, attribute, prot)
    db %2 & 0xff
    db ((%2 >> 8) & 0x0f) | ((%1 >> 8) & 0xf0)
    dd (%1 >> 16) & 0xffffffff
    dw ((%1 >> 48) & 0x0f) | (%3)
%endmacro
%define pag_present         0x001
%define pag_non_present     0x000
%define pag_writable        0x002
%define pag_usermode        0x004
%define pag_caching         0x008
%define pag_discachable     0x010
%define pag_accessed        0x020
%define pag_dirty           0x040
%define pag_huge            0x080
%define pag_global          0x100
%define pag_level           0x0400
%define pag_noexecute       0x8000

; 错误号
; 0000  没有错误                    R
; 0001  无法读取硬盘                R
; 0002  非法的 SDMP                 R
; 0003  无法开启 A20                16
; 0004  没有 CPUID 指令             32
; 0005  CPUID 不支持 0x80000001     32
; 0006  不支持 Long Mode            32
