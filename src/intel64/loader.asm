%include "boot.inc"

org SEGMENT_LOADER << 4
bits 16

jmp near start
nop

text:
    .endl       db 10, 13, 0
    .sign2      db "02 32 BITS ", 0
    .sign3      db "03 A20 Line ", 0
    .sign4      db "03 CPUID ", 0
    .sign5      db "03 LONG MODE ", 0
    .error16    db 10, 13, "Press Ctrl+Alt+Del to restart.", 0
    .error32    db 10, 13, "Press Power-off to shutdown.", 0

align 16

gdtr32:
    dw (gdt.end - gdt) - 1
    dd ADDRESS_LOADER_GDT
gdtr64:
    dw (gdt.end - gdt) - 1
    dq ADDRESS_LOADER_GDT
idtr32:
    dw 256 * 8 - 1
    dd ADDRESS_LOADER_IDT
idtr64:
    dw 256 * 8 - 1
    dq ADDRESS_LOADER_IDT
gdt:
    gdt64 0
    gdt32 0, 0xfffff, SD_GRAN | SD_PROTECT | SD_PRESENT | (SD_LEVEL * 0) | SD_PROGRAM | SD_RXWD | SD_EXEC
    gdt32 0, 0xfffff, SD_GRAN | SD_PROTECT | SD_PRESENT | (SD_LEVEL * 0) | SD_PROGRAM | SD_RXWD
    gdt64 SD_LONG | SD_PRESENT | (SD_LEVEL * 0) | SD_PROGRAM | SD_RXWD | SD_EXEC
    gdt64 SD_LONG | SD_PRESENT | (SD_LEVEL * 0) | SD_PROGRAM | SD_RXWD
    .end:
pml5    page64 ADDRESS_PAGING_PML4, PG_PRESENT | PG_WRITABLE
pml4    page64 ADDRESS_PAGING_PDPT, PG_PRESENT | PG_WRITABLE
pdpt    page64 ADDRESS_PAGING_PD, PG_PRESENT | PG_WRITABLE
pd:
    page64 0x000000, PG_PRESENT | PG_WRITABLE | PG_HUGE
    page64 0x200000, PG_PRESENT | PG_WRITABLE | PG_HUGE
    page64 0x400000, PG_PRESENT | PG_WRITABLE | PG_HUGE
    page64 0x600000, PG_PRESENT | PG_WRITABLE | PG_HUGE
    page64 0x800000, PG_PRESENT | PG_WRITABLE | PG_HUGE
    page64 0xa00000, PG_PRESENT | PG_WRITABLE | PG_HUGE
    page64 0xc00000, PG_PRESENT | PG_WRITABLE | PG_HUGE
    page64 0xe00000, PG_PRESENT | PG_WRITABLE | PG_HUGE
puts16:
    pushad
    .loop:
        lodsb
        test al, al
        jz short return16
        mov ah, 0x0e
        mov bx, 0x000f
        int 0x10
        jmp short .loop
putx16:
    pushad
    mov cx, 4
    mov dx, ax
    .loop:
        rol dx, 4
        mov al, dl
        and al, 0x0f
        cmp al, 0x0a
        jb short .digit
        add al, 0x27
    .digit:
        add al, 0x30
        mov ah, 0x0e
        mov bx, 0x000f
        int 0x10
        loop .loop
return16:
    popad
    clc
    ret
n32err:
    mov si, text.sign2
    jmp short errtail
na20err:
    mov si, text.sign3
    jmp short errtail
npmerr:
    mov si, text.sign4
errtail:
    call puts16
    call putx16
    mov si, text.error16
    call puts16
die16:
    hlt
    jmp short die16
start:
    mov bp, SEGMENT_STACK << 4
    mov sp, bp
    mov si, text.endl
    call puts16
check32:
    pushf
    .instruction32: ; 检测是否支持 32 位宽指令
        push si
        push di
        mov si, sp
        push sp
        pop di
        mov ax, 0x0001
        cmp si, di
        jne n32err
        cli
        push dword [0]
        push dword [24]
        mov word [0], n32err
        mov word [2], 0
        mov word [24], n32err
        mov word [26], 0
        mov ax, 0x0002
        mov ebx, 0xfefe
        cmp ebx, 0xfefe
        jne n32err
        pop di
        pop si
    .flags:         ; 检测是否允许高位置 0
        pushf
        pop bx
        and bx, 0x0fff
        push bx
        popf
        pushf
        pop bx
        mov ax, 0x0003
        test bx, 0xf000
        jnz n32err
    .cr0_32:        ; 检测是否支持 32 位 CR0
        mov ax, 0x0004
        mov ecx, cr0
        pop dword [24]
        pop dword [0]
    sti
    popf
enable_a20:         ; 启用 A20 地址线
    call .test_a20
    .bios:          ; 通过 BIOS 启用 A20 地址线
        mov ax, 0x2403
        int 0x15
        mov ax, 0x0001
        jc 8042
        test ah, ah
        jnz .8042
        mov ax, 0x2401
        int 0x15
        jc .8042
        test ah, ah
        jnz .8042
        call .test_a20
    .8042:          ; 通过 8042 键盘控制器启用 A20 地址线
        cli
        call .wait_8042_1
        mov al, 0xad
        out 0x64, al
        call .wait_8042_1
        mov al, 0xd0
        out 0x64, al
        call .wait_8042_2
        in al, 0x60
        push ax
        call .wait_8042_1
        mov al, 0xd1
        out 0x64, al
        call .wait_8042_1
        pop ax
        or al, 0x02
        out 0x60, al
        call .wait_8042_1
        mov al, 0xae
        out 0x64, al
        call .wait_8042_1
        call .test_a20
    .port:          ; 通过 0xee 端口启用 A20 地址线
        in al, 0xee
        call .wait_8042_1
    .fast:          ; 通过快速门启用 A20 地址线
        in al, 0x92
        test al, 0x02
        jnz na20err
        or al, 0x02
        and al, 0xfe
        out 0x92, al
        call .wait_8042_1
    .end:
        call .test_a20
        jmp na20err
    .test_a20:      ; 测试 A20 地址线是否启用
        pushad
        push dword [10]
        xor ax, ax
        xor si, si
        mov ds, ax
        mov di, 0x0010
        mov ax, 0xffff
        mov es, ax
        mov word [si], 0x0000
        mov word [di], 0x1145
        mov ax, [si]
        test ax, ax
        pop dword [10]
        popad
        jz init_8259
        ret
   .wait_8042_1:
        push ax
        call .lay2step
        in al, 0x64
        test al, 0x02
        jnz short .wait_8042_1
        pop ax
        ret
   .wait_8042_2:
        push ax
        call .lay2step
        in al, 0x64
        test al, 0x01
        jz short .wait_8042_2
        pop ax
        ret
    .lay2step:
        nop
        ret
init_8259:                 ; 8259 中断控制芯片编程 将硬件中断重定向到 32~47
    mov al, 0x11            ; ICW1 初始化
    out 0x20, al            ; 8259A 主片初始化
    call enable_a20.lay2step
    out 0xa0, al            ; 8259A 从片初始化
    call enable_a20.lay2step
    mov al, 0x20            ; ICW2 设置中断向量起始值为 32
    out 0x21, al            ; 8259A 主片设置起始值
    call enable_a20.lay2step
    mov al, 0x28            ; ICW2 设置中断向量起始值为 40
    out 0xa1, al            ; 8259A 从片设置起始值
    call enable_a20.lay2step
    mov al, 0x04            ; ICW3 设置主片连接从片 (IR2 连接从片 = 00000100)
    out 0x21, al            ; 8259A 主片设置连接从片
    call enable_a20.lay2step
    mov al, 0x02            ; ICW3 设置从片连接主片 (IR2 连接主片 = 2)
    out 0xa1, al            ; 8259A 从片设置连接主片
    call enable_a20.lay2step
    mov al, 0x01            ; ICW4 设置工作方式为 8086 模式
    out 0x21, al            ; 8259A 主片设置工作方式
    call enable_a20.lay2step
    out 0xa1, al            ; 8259A 从片设置工作方式
    call enable_a20.lay2step
    mov al, 0xff            ; 屏蔽所有中断
    out 0x21, al            ; 8259A 主片屏蔽所有中断
    call enable_a20.lay2step
    out 0xa1, al            ; 8259A 从片屏蔽所有中断
    call enable_a20.lay2step
testmem:
    xor ax, ax
    mov es, ax
    mov ds, ax
    mov [ADDRESS_LOADER_MMBM], ax
    .int12:
        clc
        int 0x12
        jc short .int1588
        mov [ADDRESS_LOADER_1200], ax
        or word [ADDRESS_LOADER_MMBM], 1 << 0
    .int1588:
        clc
        mov ah, 0x88
        int 0x15
        jc short .int158a
        test ax, ax
        jz short .int158a
        mov [ADDRESS_LOADER_1588], ax
        or word [ADDRESS_LOADER_MMBM], 1 << 1
    .int158a:
        mov ah, 0x8a
        int 0x15
        jc short .int15da
        mov [ADDRESS_LOADER_158A], ax
        mov [ADDRESS_LOADER_158A + 2], dx
        or word [ADDRESS_LOADER_MMBM], 1 << 2
    .int15da:
        clc
        mov ax, 0xda88
        int 0x15
        jc short .int15e0
        xor ch, ch
        mov [ADDRESS_LOADER_15DA], bx
        mov [ADDRESS_LOADER_15DA + 2], cx
        or word [ADDRESS_LOADER_MMBM], 1 << 4
    .int15e0:
        xor cx, cx
        xor dx, dx
        mov ax, 0xe801
        int 0x15
        jc short .cmos
        cmp ah, 0x86
        je short .cmos
        cmp ah, 0x80
        je short .cmos
        jcxz .int15e0.skip
        mov ax, cx
        mov bx, dx
    .int15e0.skip:
        clc
        mov dx, bx
        shl bx, 6
        shr dx, 10
        xor cx, cx
        add ax, bx
        adc cx, dx
        mov [ADDRESS_LOADER_15E0], ax
        mov [ADDRESS_LOADER_15E0 + 2], cx
        or word [ADDRESS_LOADER_MMBM], 1 << 5
    .cmos:
        mov al, 0x30
        out 0x70, al
        call enable_a20.lay2step
        in al, 0x71
        mov cl, al
        mov al, 0x31
        out 0x70, al
        call enable_a20.lay2step
        in al, 0x71
        mov ch, al
        test cx, cx
        jz .e820
        mov [ADDRESS_LOADER_CMOS], cx
        or word [ADDRESS_LOADER_MMBM], 1 << 6
    .e820:
        clc
        cld
        push es
        mov ax, SEG_LOADER_E820
        mov es, ax
        xor di, di
        xor ebx, ebx
        mov [ADDRESS_LOADER_E8CT], bx
        .e820.loop:
            mov eax, 0xe820
            mov ecx, 24
            mov edx, 'PAMS'
            int 0x15
            jc .int15c7
            cmp eax, "PAMS"
            jne .int15c7
            cmp ecx, 20
            jb .int15c7
            inc word [ADDRESS_LOADER_E8CT]
            add di, 24
        .e820.next:
            test ebx, ebx
            jnz short .e820.loop
        or word [ADDRESS_LOADER_MMBM], 1 << 7
    .int15c7:
        clc
        mov ax, 0xf000
        mov es, ax
        mov di, 0xfff0
        cmp dword [es:di], "6A6"
        je .end
        cmp dword [es:di], "6A6" << 4
        je .end
        cmp dword [es:di], " 6A6"
        je .end
        cmp dword [es:di], "6A6 "
        je .end
        cmp dword [es:di], "ASUS"
        je .end
        cmp dword [es:di], "SUSA"
        je .end
        cmp dword [es:di], "Awar"
        je .int15c7.check2
        cmp dword [es:di], "rawA"
        je .int15c7.check2
        jmp .int15c7.ok
    .int15c7.check2
        cmp dword [es:di + 4], "d"
        je .end
        cmp dword [es:di + 4], "d" << 12
        je .end
        cmp dword [es:di + 4], "d   "
        je .end
    .int15c7.ok:
        mov di, SEGMENT_BOOT << 4
        mov cx, 0x100
        xor ax, ax
        rep stosw
        mov si, SEGMENT_BOOT << 4
        mov ah, 0xc7
        int 0x15
        jc short .end
        or word [ADDRESS_LOADER_MMBM], 1 << 3
    .end:
        pop es
clean:
    xor ax, ax
    mov word [ADDRESS_LOADER_XCNT], 40
    mov word [ADDRESS_LOADER_YCNT], 25
    mov [ADDRESS_LOADER_POS], ax
    int 0x10                ; 设置屏幕 40*25*1 文本模式
    xor bh, bh
    mov ah, 0x01
    mov cx, 0x3f3f
    int 0x10
    mov ax, 0xec00
    mov bl, 2
    int 0x15
    jc short copy32
    or word [ADDRESS_LOADER_MMBM], 1 << 8
copy32:
    cli
    cld
    xor ax, ax
    mov es, ax
    mov ds, ax
    mov si, gdtr32
    mov di, ADDRESS_LOADER_GDTR
    mov cx, 30
    rep movsd
    mov di, ADDRESS_LOADER_IDTR
enter_pm:
    lgdt [ADDRESS_LOADER_GDTR]
    lidt [ADDRESS_LOADER_IDTR]
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax
    jmp 0x0010:start32

bits 32
putc32:
    pushad
    cmp al, 0x20
    jb short .control
    cmp al, 0x7e
    ja short .control
    .print:
        mov ah, 0x07
        movzx ecx, word [ADDRESS_LOADER_POS]
        mov [0x0b8000 + ecx * 2], ax
        inc cx
        mov ax, word [ADDRESS_LOADER_XCNT]
        mul word [ADDRESS_LOADER_YCNT]
        cmp cx, ax
        jb .skip
        mov si, 0x0b8000
        mov di, si
        mov cx, ax
        add si, [ADDRESS_LOADER_XCNT]
        add si, [ADDRESS_LOADER_XCNT]
        sub cx, [ADDRESS_LOADER_XCNT]
        cld
        rep movsw
        mov cx, [ADDRESS_LOADER_XCNT]
        mov bx, ax
        xor ax, ax
        rep stosw
        mov ax, bx
        sub ax, [ADDRESS_LOADER_XCNT]
        mov [ADDRESS_LOADER_POS], ax
    .skip:
        mov [ADDRESS_LOADER_POS], cx
        popad
        ret
    .control:
        cmp al, 0x00
        je short .space
        cmp al, 0x09
        je short .tab
        cmp al, 0x0a
        je short .newline
        cmp al, 0x0d
        je short .return
        mov al, '?'
        jmp .print
    .space:
        mov al, ' '
        jmp .print
    .tab:
        mov bx, [ADDRESS_LOADER_POS]
        mov cx, bx
        shr cx, 2
        inc cx
        shl cx, 2
        sub cx, bx
        mov al, ' '
    .tab_loop:
        call putc32
        loop .tab_loop
        popad
        ret
    .newline:
        add word [ADDRESS_LOADER_POS], 0x40
        popad
        ret
    .return:
        movzx eax, word [ADDRESS_LOADER_POS]
        mov ebx, 0x40
        div ebx
        inc eax
        mul ebx
        mov [ADDRESS_LOADER_POS], eax
return32:
    popad
    ret
puts32:
    pushad
   .loop:
        lodsb
        test al, al
        jz short return32
        call putc32
        jmp short .loop
putx32:
    pushad
    mov ecx, 8
    mov edx, eax
    .loop:
        rol edx, 4
        mov al, dl
        and al, 0x0f
        cmp al, 0x0a
        jb short .digit
        add al, 0x27
   .digit:
        add al, 0x30
        call putc32
        loop .loop
    popad
    ret
ncpuiderr:
    mov esi, text.sign4
    jmp short errtail32
nlongmerr:
    mov esi, text.sign5
errtail32:
    call puts32
    call putx32
    mov esi, text.error32
    call puts32
die32:
    hlt
    jmp short die32
start32:
    cli
    mov ax, 0x0018
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov sp, SEGMENT_STACK << 4
    mov bp, sp
copy64:
    mov edi, ADDRESS_LOADER_PAGE
    mov ecx, 0x1000
    xor eax, eax
    rep stosd
    mov esi, pml5
    mov edi, ADDRESS_PAGING_PML5
    mov cl, 2
    rep movsd
    mov esi, pml4
    mov edi, ADDRESS_PAGING_PML4
    mov cl, 2
    rep movsd
    mov esi, pdpt
    mov edi, ADDRESS_PAGING_PDPT
    mov cl, 2
    rep movsd
    mov esi, pd
    mov edi, ADDRESS_PAGING_PD
    mov cl, 2 * 8
    rep movsd
check_cpuid:
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 1 << 21
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    test eax, ecx
    mov eax, 0x00000008
    mov eax, 0x00000001
    jz ncpuiderr
check_long_mode:
    mov eax, 0x80000000
    cpuid
    mov ebx, eax
    mov eax, 0x00000009
    cmp ebx, 0x80000001
    mov eax, 0x00000002
    jb ncpuiderr
    mov eax, 0x80000001
    cpuid
    mov eax, 0x00000001
    test edx, 1 << 29
    jz nlongmerr
check_la57:
    xor eax, eax
    cpuid
    cmp eax, 7
    jb la48
    mov eax, 7
    xor ecx, ecx
    cpuid
    test ecx, 1 << 16
    jz la48
    or word [ADDRESS_LOADER_MMBM], 1 << 9
la57:
    mov eax, cr0
    and eax, ~(1 << 31)
    mov cr0, eax
    mov eax, cr4
    or eax, (1 << 5) | (1 << 12)
    mov cr4, eax
    mov eax, ADDRESS_PAGING_PML5
    mov cr3, eax
    mov ecx, 0xc0000080
    rdmsr
    or eax, 1 << 8
    wrmsr
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax
    jmp 0x0020:start64
la48:
    mov eax, cr0
    and eax, ~(1 << 31)
    mov cr0, eax
    mov eax, cr4
    or eax, (1 << 5)
    mov cr4, eax
    mov eax, ADDRESS_PAGING_PML4
    mov cr3, eax
    mov ecx, 0xc0000080
    rdmsr
    or eax, 1 << 8
    wrmsr
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax
    jmp dword 0x0020:start64

align 16
bits 64
start64:
    endbr64
    cli
    mov ax, 0x0030
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov rsp, 0x8000
    mov rbp, rsp
    xor rdi, rdi
    xor rsi, rsi
    call SEGMENT_KERNEL << 4
    mov di, 0xff
    test eax, eax
    jnz start64
    mov dx, 0x604
    mov ax, 0x2000
    out dx, ax
    nop
