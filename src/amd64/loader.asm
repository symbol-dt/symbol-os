%include "define.inc"
org ADDR_SEG_LOAD<<4
bits 16
jmp start16
text:
    .head16     db "(Setup 16) Error#", 0
    .data16     db "With 0x", 0
    .head32     db "(Setup 32) Error#", 0
    .head64     db "(Setup 64) Error#", 0
    .stup       db " bits environment setting up..."
    .tail       db 10, 13, 0
    .hexbuffer  times 9 db 0
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
        stf_code | stf_wa_ra | stf_level0 | stf_present | stf_32def | stf_limitalign4kb
    ; 32位程序数据段, 内核级, 平坦模式
    .data   gdt_segment 0x00000000, 0xffffffff,\
        stf_data | stf_wa_ra | stf_level0 | stf_present | stf_32def | stf_limitalign4kb
    ; 64位程序代码段, 内核级, 平坦模式
    .code64 gdt_segment 0, 0,\
        stf_code | stf_wa_ra | stf_level0 | stf_present | stf_64def
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
    .pdend

start16:
    mov ax, 0x5307
    int 0x15

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, ADDR_SEG_STACK<<4
    mov bp, sp
    cli
    cld
    clc
    mov ax, 0x16
    call ADDR_SEG_LOAD:putx16-(ADDR_SEG_LOAD<<4)
    mov si, text.stup
    call ADDR_SEG_LOAD:puts16-(ADDR_SEG_LOAD<<4)
    jmp enable_A20
puts16:
    pushad
    .putloop:
        lodsb
        test al, al
        jz return16
        mov ah, 0x0e
        mov bx, 0x000f
        int 0x10
        jmp .putloop
putx16:
    pushad
    cld
    push ds
    pop es
    mov di, text.hexbuffer
    mov cx, 4
    mov dx, ax
    .putloop:
        rol dx, 4
        mov al, dl
        and al, 0x0f
        cmp al, 0x0a
        jb .putdigit
        add al, 0x07
   .putdigit:
        add al, 0x30
        stosb
        loop .putloop
    mov si, text.hexbuffer
    call ADDR_SEG_LOAD:puts16-(ADDR_SEG_LOAD<<4)
return16:
    popad
    retf
error16:
    and ax, 0x00ff
    mov si, text.head16
    call ADDR_SEG_LOAD:puts16-(ADDR_SEG_LOAD<<4)
    call ADDR_SEG_LOAD:putx16-(ADDR_SEG_LOAD<<4)
    mov si, text.tail
    call ADDR_SEG_LOAD:puts16-(ADDR_SEG_LOAD<<4)
die16:
    hlt
    jmp $
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
        call ADDR_SEG_LOAD:error16-(ADDR_SEG_LOAD<<4)
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
    mov ax, 0x0000
    int 0x10                ; 设置屏幕 40*25*1 文本模式
    xor bh, bh
    mov ah, 0x01
    mov cx, 0x3f3f
    int 0x10                ; 隐藏光标
    .testmem:
        mov [(ADDR_SEG_DATA<<4)+0x12], word 0
        .testmem.int0x12:
            clc
            int 0x12
            mov [(ADDR_SEG_DATA<<4)+0x14], ax
            jc .testmem.int0x15_88
            or [(ADDR_SEG_DATA<<4)+0x12], word 1<<0
        .testmem.int0x15_88:
            clc
            mov ah, 0x88
            int 0x12
            mov [(ADDR_SEG_DATA<<4)+0x16], ax
            jc .testmem.int0x15_8a
            test ax, ax
            jz .testmem.int0x15_8a
            or [(ADDR_SEG_DATA<<4)+0x12], word 1<<1
        .testmem.int0x15_8a:
            mov ah, 0x8a
            int 0x12
            mov [(ADDR_SEG_DATA<<4)+0x18], ax
            mov [(ADDR_SEG_DATA<<4)+0x1a], dx
            jc .testmem.cmos
            or [(ADDR_SEG_DATA<<4)+0x12], word 1<<2
        .testmem.cmos:
            mov al, 0x31
            out 0x70, al
            in al, 0x71
            xchg al, ah
            mov al, 0x30
            out 0x70, al
            in al, 0x71
            mov [(ADDR_SEG_DATA<<4)+0x1c], ax
            test ax, ax
            jz .testmem.int0x15_da88
            or [(ADDR_SEG_DATA<<4)+0x12], word 1<<3
        .testmem.int0x15_da88:
            clc
            mov ax, 0xda88
            int 0x15
            jc .testmem.int0x15_e801
            xor ch, ch
            mov [(ADDR_SEG_DATA<<4)+0x1e], bx
            mov [(ADDR_SEG_DATA<<4)+0x20], cx
            or [(ADDR_SEG_DATA<<4)+0x12], word 1<<4
        .testmem.int0x15_e801:
            xor cx, cx
            xor dx, dx
            mov ax, 0xe801
            int 0x15
            jc .testmem.e820
            cmp ah, 0x86
            je .testmem.e820
            cmp ah, 0x80
            jne .testmem.e820
            jcxz .testmem.int0x15_e801.set
            mov ax, cx
            mov bx, dx
        .testmem.int0x15_e801.set:
            mov [(ADDR_SEG_DATA<<4)+0x22], ax
            mov [(ADDR_SEG_DATA<<4)+0x24], bx
            or [(ADDR_SEG_DATA<<4)+0x12], word 1<<5
       .testmem.e820:
            xor ebx, ebx
            mov di, ADDR_SEG_STACK<<4
            .e820.loop:
                mov eax, 0x0000e820
                mov edx, "SMAP"
                mov eax, 20
                int 0x15
                jc .testmem.endmem
                cmp eax, "SMAP"
                jne .testmem.endmem
                inc byte [(ADDR_SEG_DATA<<4)+0x26]
                or [(ADDR_SEG_DATA<<4)+0x12], word 1<<6
                add di, 20
                test ebx, ebx
                jnz .e820.loop
        .testmem.endmem:
            xor ax, ax
            mov ds, ax
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
    mov [0x000a0000+ecx*2], ax
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
puts32:
    pushad
    .putloop:
        lodsb
        test al, al
        jz return16
        call putc32
        jmp .putloop
putx32:
    pushad
    cld
    push ds
    pop es
    mov di, text.hexbuffer
    mov cx, 8
    mov edx, eax
    .putloop:
        rol edx, 4
        mov al, dl
        and al, 0x0f
        cmp al, 0x0a
        jb .putdigit
        add al, 0x07
   .putdigit:
        add al, 0x30
        stosb
        loop .putloop
    mov si, text.hexbuffer
    call puts32
return32:
    popad
    ret
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
    mov esp, ADDR_SEG_STACK<<4
    mov ebp, esp
copy:
    cli
    cld
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
    mov ecx, (pagings.pdend-pagings.pd)>>2
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
    mov eax, 0x00000008
    jz error32
check_long_mode:
    mov eax, 0x80000000
    cpuid
    mov ebx, eax
    mov eax, 0x00000009
    cmp ebx, 0x80000001
    jb error32
    mov eax, 0x80000001
    cpuid
    test edx, (1 << 29)
    mov eax, 0x0000000a
    jz error32
enter64:
    mov eax, ADDR_PML4
    mov cr3, eax

    mov eax, cr4
    or eax, (1 << 5)
    mov cr4, eax

    xor edx, edx
    mov eax, ADDR_SEG_LOAD << 4
    mov ecx, 0xc0000080
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
    mov rsp, ADDR_SEG_STACK<<4
    mov rbp, rsp
    xor rdi, rdi
    xor rsi, rsi

calc:
    xor eax, eax
    xor ebx, ebx
    mov ax, [(ADDR_SEG_DATA<<4)+0x22]
    mov bx, [(ADDR_SEG_DATA<<4)+0x24]
    shl ebx, 6
    add eax, ebx
    mov [(ADDR_SEG_DATA<<4)+0x22], eax

    call qword (ADDR_SEG_LOAD<<4)+0x800
    mov dx, 0x604
    mov ax, 0x2000
    out dx, ax
    jmp $
