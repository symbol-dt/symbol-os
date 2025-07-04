%include "define.inc"
org ADDR_SEG_LOAD<<4
bits 16

jmp start16
text:
    .head16     db "(LOAD16) Error#", 0
    .head32     db "(LOAD32) Error#", 0
    .head64     db "(LOAD64) Error#", 0
    .hello      db "Loading..."
    .tail       db 10, 13, 0
idt_info:                   ; 空中断门描述符表标识
    dw 0
    dq 0
gdt_info:                   ; 全局段描述符表标识
    dw gdt.end - gdt
    dq gdt
align 16
gdt:
    .null   gdt_null
    ; 32位程序代码段, 内核级, 平坦模式
    .code   gdt_segment 0x00000000, 0xffffffff,\
        sta_prog | sta_prog_x | sta_prog_xwr | sta_level0 | sta_present,\
        stt_32def | stt_limitalign4kb
    ; 32位程序数据段, 内核级, 平坦模式
    .data   gdt_segment 0x00000000, 0xffffffff,\
        sta_prog | sta_prog_d | sta_prog_xwr | sta_level0 | sta_present,\
        stt_32def | stt_limitalign4kb
    ; 64位程序代码段
    .code64 gdt_segment 0, 0,\
        sta_prog | sta_prog_x | sta_prog_xwr | sta_level0 | sta_present,\
        stt_64def
        gdt_null
    .end:
pagings:
    .pml5   paging ADDR_PML4, pag_present | pag_writable, 0             ; 5级分页
    .pml4   paging ADDR_PDPT, pag_present | pag_writable, 0             ; 4级分页
    .pdpt   paging ADDR_PD, pag_present | pag_writable, 0               ; 3级分页
    .pd:    ; 2级大分页 2MB 映射低 16mb
        paging 0x000000, pag_present | pag_writable | pag_huge, 0
        paging 0x200000, pag_present | pag_writable | pag_huge, 0
        paging 0x400000, pag_present | pag_writable | pag_huge, 0
        paging 0x600000, pag_present | pag_writable | pag_huge, 0
        paging 0x800000, pag_present | pag_writable | pag_huge, 0
        paging 0xa00000, pag_present | pag_writable | pag_huge, 0
        paging 0xc00000, pag_present | pag_writable | pag_huge, 0
        paging 0xe00000, pag_present | pag_writable | pag_huge, 0

start16:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, ADDR_SEG_DATA<<4
    mov bp, sp
    cli
    cld
    clc
    mov si, text.hello
    call puts16
enable_A20:                 ; 开启 A20
    call .test_A20
    .bios:                  ; 通过 BIOS 开启
        ; 检查是否支持开启 A20
        mov ax, 0x2403
        int 0x15
        jb .no_A20
        test ah, ah
        jnz .no_A20
        ; 尝试开启 A20
        mov ax, 0x2402
        int 0x15
        jb .8042
        test ah, ah
        jnz .8042
        ; 检查是否开启成功
        cmp al, 1
        jz .int15
        mov ax, 0x2401
        int 0x15
        jb .8042
        test ah, ah
        jnz .8042
    .int15:
        call .test_A20
    .8042:                  ; 方法 2: 鍵盤控制器 8042
        call .wait_8042_2
        mov al, 0xad
        out 0x64, al
        call .wait_8042_2
        mov al, 0xd0
        out 0x64, al
        call .wait_8042_1
        in al, 0x60
        push ax
        call .wait_8042_2
        mov al, 0xd1
        out 0x64, al
        call .wait_8042_2
        pop ax
        or al, 2
        out 0x60, al
        call .wait_8042_2
        mov al, 0xae
        out 0x64, al
        call .wait_8042_2
        sti
        call .test_A20
    .port:                  ; 方法 3: 0xee 端口
        in al, 0xee
        call .test_A20
    .fast:                  ; 方法 4: 快速 A20 門
        in al, 0x92
        test al, 2
        jnz .no_A20
        or al, 2
        and al, 0xfe
        out 0x92, al
    .no_A20:                ; 无法开启 A20, 报错
        call .test_A20
        mov ax, 0x0003
        call error16
    .wait_8042_1:           ; 等待函数 1
        push ax
        call .step2
        in al, 0x64
        test al, 1
        jnz .wait_8042_1
        pop ax
        ret
    .wait_8042_2:           ; 等待函数 2
        push ax
        call .step2
        in al, 0x64
        test al, 2
        jz .wait_8042_2
        pop ax
        ret
    .step2:                 ; 等待函数 3
        nop
        ret
    .test_A20:              ; 测试 A20 尝试写 1M 位置
        pusha
        xor ax, ax
        xor si, si
        mov ds, ax
        mov ax, 0xffff
        mov di, 0x0010
        mov es, ax
        mov word [si], 0x0000
        mov word [di], 0x1145
        mov ax, [si]
        test ax, ax
        popa
        jz clean_8259
        ret
putc16:
    pushad
    mov ah, 0x0f
    mov bx, 0x000f
    int 0x10
return16:
    popad
    ret
putx16:
    pushad
    mov cx, 4
    .putloop:
        push ax
        shr ax, 12
        add al, '0'
        cmp al, '9'
        jb .skip
        add al, ('a'-'0'-10)
    .skip:
        call putc16
        pop ax
        shl ax, 4
        loop .putloop
    jmp return16
puts16:
    pushad
    .putloop:
        lodsb
        test al, al
        jz return16
        call putc16
        jmp .putloop
error16:
    mov si, text.head16
    call puts16
    call putx16
    mov si, text.tail
    call puts16
die16:
    sti
    hlt
    jmp $
clean_8259:                 ; 8259 中断控制芯片编程 将硬件中断重定向到 32~47
    mov al, 0x11            ; ICW1 初始化
    out 0x20, al            ; 8259A 主片初始化
    call enable_A20.step2
    out 0xa0, al            ; 8259A 从片初始化
    call enable_A20.step2
    mov al, 0x20            ; ICW2 设置中断向量起始值为 32
    out 0x21, al            ; 8259A 主片设置起始值
    call enable_A20.step2
    mov al, 0x28            ; ICW2 设置中断向量起始值为 40
    out 0xa1, al            ; 8259A 从片设置起始值
    call enable_A20.step2
    mov al, 0x04            ; ICW3 设置主片连接从片 (IR2 连接从片 = 00000100)
    out 0x21, al            ; 8259A 主片设置连接从片
    call enable_A20.step2
    mov al, 0x02            ; ICW3 设置从片连接主片 (IR2 连接主片 = 2)
    out 0xa1, al            ; 8259A 从片设置连接主片
    call enable_A20.step2
    mov al, 0x01            ; ICW4 设置工作方式为 8086 模式
    out 0x21, al            ; 8259A 主片设置工作方式
    call enable_A20.step2
    out 0xa1, al            ; 8259A 从片设置工作方式
    call enable_A20.step2
    mov al, 0xff            ; 屏蔽所有中断
    out 0x21, al            ; 8259A 主片屏蔽所有中断
    call enable_A20.step2
    out 0xa1, al            ; 8259A 从片屏蔽所有中断
    call enable_A20.step2
save_data:                  ; 保存数据
    mov ax, 0x0007
    int 0x10                ; 设置屏幕 80*25*1 文本模式
    xor bh, bh
    mov ah, 0x01
    mov cx, 0x3f3f
    int 0x10                ; 隐藏光标
    mov [(ADDR_SEG_DATA<<4)+0x10], word 0
set_gdt:                    ; 设置 GDT
    lgdt [gdt_info]
    lidt [idt_info]
enter32:                    ; 进入保护模式
    mov eax, cr0
    or eax, 0x00000001      ; 置PE位
    mov cr0, eax
    jmp dword 0x0008:start32
        ; 刷新流水线并跳转到32位代码

align 16
bits 32

putc32:
    pushad
    cmp al, 32
    jb .control
    mov ah, 0x0f
    mov bx, [(ADDR_SEG_DATA<<4)+0x10]
    movzx ecx, bx
    mov [0x000b0000+ecx*2], ax
    inc bx
    mov [(ADDR_SEG_DATA<<4)+0x10], bx
    jmp return32
    .control:
        mov cx, ax
        xor dx, dx
        mov ax, [(ADDR_SEG_DATA<<4)+0x10]
        cmp cl, 9
        je .tab
        mov bx, 80
        div bx
        cmp cl, 13
        je .return
        cmp cl, 10
        jne return32
        inc ax
    .return:
        mul bx
        jmp .newline
    .tab:
        shr ax, 2
        inc ax
        shl ax, 2
    .newline:
        mov [(ADDR_SEG_DATA<<4)+0x10], ax
return32:
    popad
    ret
puts32:
    pushad
   .putloop:
        lodsb
        test al, al
        jz return32
        call putc32
        jmp .putloop
putx32:
    pushad
    mov cx, 8
    .putloop:
        push eax
        shr eax, 28
        add al, '0'
        cmp al, '9'
        jb .skip
        add al, ('a'-'0'-10)
    .skip:
        call putc32
        pop eax
        shl eax, 4
        loop .putloop
    jmp return32
error32:
    mov si, text.head32
    call puts32
    call putx32
    mov si, text.tail
    call puts32
die32:
    sti
    hlt
    jmp $
start32:
    mov ax, 0x0010
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, ADDR_SEG_DATA<<4
    mov ebp, esp
copy:
    cli
    xor eax, eax
    mov edi, ADDR_IDT
    mov ecx, (ADDR_FREE-ADDR_IDT)/4
    rep stosd
    mov esi, gdt
    mov edi, ADDR_GDT
    mov ecx, (gdt.end-gdt)/4
    rep movsd
    mov esi, pagings.pml5
    mov edi, ADDR_PML5
    mov ecx, 2
    rep movsd
    mov esi, pagings.pml4
    mov edi, ADDR_PML4
    mov ecx, 2
    rep movsd
    mov esi, pagings.pdpt
    mov edi, ADDR_PDPT
    mov ecx, 2
    rep movsd
    mov esi, pagings.pd
    mov edi, ADDR_PD
    mov ecx, 2
    rep movsd
    mov esi, idt_info
    mov edi, ADDR_IDT_INFO
    mov ecx, 5
    rep movsw
    mov esi, gdt_info
    mov edi, ADDR_GDT_INFO
    mov ecx, 5
    rep movsw
    mov dword [ADDR_IDT_INFO+2], ADDR_IDT
    mov dword [ADDR_GDT_INFO+2], ADDR_GDT
    lgdt [ADDR_GDT_INFO]
    lidt [ADDR_IDT_INFO]
check_cpuid:
    pushfd
    pop eax
    mov ecx, eax
    xor eax, (1 << 21)
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    test eax, ecx
    mov eax, 0x00000004
    jz error32
check_long_mode:
    mov eax, 0x80000000
    cpuid
    mov ebx, eax
    mov eax, 0x00000005
    cmp ebx, 0x80000001
    jb error32
    mov eax, 0x80000001
    cpuid
    mov [(ADDR_SEG_DATA<<4)+0x20], eax
    mov [(ADDR_SEG_DATA<<4)+0x24], ecx
    mov [(ADDR_SEG_DATA<<4)+0x28], edx
    mov [(ADDR_SEG_DATA<<4)+0x2c], ebx
    test edx, (1 << 29)
    mov eax, 0x00000006
    jz error32
enter64:
    mov eax, cr4
    mov ebx, ADDR_PML4
    mov ecx, 0xc0000080
    or eax, 0x00000120
    mov cr4, eax
    mov cr3, ebx
    rdmsr
    or eax, 0x00000100
    wrmsr
    mov eax, cr0
    or eax, 0x80000001
    mov cr0, eax
    jmp dword 0x0018:start64    ; 刷新流水线

align 16
bits 64

start64:
    mov ax, 0x10
    mov gs, ax
    mov fs, ax
    mov es, ax
    mov ds, ax
    mov ss, ax
    mov rsp, ADDR_SEG_DATA<<4
    mov rbp, rsp
    xor rdi, rdi
    xor rsi, rsi
    call qword (ADDR_SEG_LOAD<<4)+0x800
    mov dx, 0x604
    mov ax, 0x2000
    out dx, ax
    jmp $
