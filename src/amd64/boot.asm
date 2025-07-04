%include "define.inc"
org ADDR_SEG_BOOT<<4
bits 16

jmp start
nop

ident:
    .name       db "symbol-os", 0
    .version    db 0x03, 0x01, 0x01
dap:
    .size       dw 0x0010
    .count      dw 0x0001
    .offset     dw 0x0000
    .segment    dw ADDR_SEG_LOAD
    .address    dq 0x0000000000000001
text:
    .head       db "(BOOT) Error#", 0
    .hello      db "Booting..."
    .tail       db 10, 13, 0
    .hexbuffer  times 5 db 0

align 16

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, ADDR_SEG_BOOT<<4
    mov bp, sp
    sti
    cld
save_data:
    xor dh, dh
    mov [(ADDR_SEG_DATA<<4)+0], dx
    mov cx, 13
    mov si, ident
    mov di, (ADDR_SEG_DATA<<4)+2
    cld
    rep movsb
    mov si, ident.name
    call puts
    mov si, text.tail
    call puts
    mov si, text.hello
    call puts
read_loader:
    mov si, dap
    mov dx, [(ADDR_SEG_DATA<<4)+0]
    call read_disk
    mov cx, [(ADDR_SEG_LOAD<<4)+0]
    mov bx, [(ADDR_SEG_LOAD<<4)+2]
    mov ax, 0x0002
    cmp cx, "SD"
    jne error
    cmp bx, "MP"
    jne error
    mov di, dap.address
    mov si, (ADDR_SEG_LOAD<<4)+16
    mov cx, 4
    cld
    rep movsw
    mov bx, [(ADDR_SEG_LOAD<<4)+10]
    mov cx, [(ADDR_SEG_LOAD<<4)+12]
    mov dx, [(ADDR_SEG_LOAD<<4)+14]
    mov ax, cx
    shl dx, 12
    shr ax, 4
    or ax, dx
    and cx, 0x000f
    mov [dap.count], bx
    mov [dap.offset], cx
    mov [dap.segment], ax
    mov si, dap
    mov dx, [(ADDR_SEG_DATA<<4)+0]
    xchg bx, bx
    call read_disk
    push word [dap.segment]
    push word [dap.offset]
    retf
puts:
    pushad
    .putloop:
        lodsb
        test al, al
        jz return
        mov ah, 0x0e
        mov bx, 0x000f
        int 0x10
        jmp .putloop
putx:
    pushad
    cld
    push ds
    pop es
    mov di, text.hexbuffer
    mov dx, ax
    mov cx, 4
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
    call puts
return:
    popad
    ret
read_disk:
    pushad
    mov ah, 0x41
    mov bx, 0x55aa
    int 0x13
    jc return
    cmp bx, 0xaa55
    jne return
read_lba:
    popad
    pushad
    mov ah, 0x42
    int 0x13
    jnc return
error:
    mov si, text.head
    call puts
    call putx
    mov si, text.tail
    call puts
die:
    hlt
    jmp die

times (510-64)-($-$$) db 0x00
dvt mbr_null
times (512-2)-($-$$) db 0x00
dw 0xaa55

; SDMP头
db "SDMP"                   ; 魔数
dw 0x0002                   ; 版本 0.2
dw 0x0010                   ; 头长度 16 扇区
dw 0x0003                   ; 分区总数 3
dw 0x0040                   ; 可引导扇区数 64 (32KB)
dd ADDR_SEG_LOAD<<4         ; 引导加载位置 0x8000
dq 0x00000010               ; 可引导扇区号 16
times (512*2)-($-$$) db 0

db "        "               ; 分区名称
dw 0xffff                   ; 分区类型
db 0xff, 0x00               ; 分区状态
dd 0x00000000               ; 分区标识
dq 0x0000000000000000       ; 分区起始扇区
dq 0x0000000000000010       ; 分区扇区长度
db "SYM KNL "
dw 0x005a
db 0x5a, 0x00
dd 0x3683445a
dq 0x0000000000000010
dq 0x0000000000000040

times (512*16)-($-$$) db 0
