%include "boot.inc"

org SEGMENT_BOOT << 4
bits 16

jmp near start
nop

label:
    .ident  dd 998244353
    .name   db "SYMOS 3", 0
text:
    .sign1  db "01 DEVICE ", 0
    .error  db 10, 13, "Press Ctrl+Alt+Del to restart.", 0
    .endl   db 10, 13, 0
dap:
    .size       dw 0x0010
    .count      dw LENGTH_LOADER
    .offset     dw SEGMENT_LOADER << 4
    .segment    dw 0x0000
    .address    dq SECTOR_LOADER

; 代码段开始
read:
    mov si, dap
    mov dx, [ADDRESS_BOOT_DEVICE]
    pushad
    mov bx, 0x55aa
    mov ah, 0x41
    int 0x13
    jc short read_chs
    cmp bx, 0xaa55
    jne short read_chs
    popad
read_lba:
    pushad
    mov ah, 0x42
    int 0x13
    jnc return
read_chs:
    popad
    pushad
    mov ah, 0x08
    int 0x13
    jc int13err
    mov ax, cx
    shr al, 6
    xchg ah, al
    and cx, 0x3f
    movzx dx, dh
    inc dx
    inc ax
    mov [ADDRESS_BOOT_C_CNT], ax
    mov [ADDRESS_BOOT_S_CNT], cx
    mov [ADDRESS_BOOT_H_CNT], dx
    .clac:
        mov ax, [dap.address]
        mov dx, [dap.address + 2]
        div word [ADDRESS_BOOT_S_CNT]
        inc dx
        mov [ADDRESS_BOOT_S_NUM], dx
        xor dx, dx
        div word [ADDRESS_BOOT_H_CNT]
        mov [ADDRESS_BOOT_H_NUM], dx
        mov [ADDRESS_BOOT_C_NUM], ax
        mov ax, [dap.segment]
        mov cx, [dap.offset]
        mov bx, [dap.count]
        mov [ADDRESS_BOOT_SEG], ax
        mov [ADDRESS_BOOT_OFF], cx
        mov [dap.size], bx
    .loop:
        cmp word [dap.size], 0
        je short .return
        mov cx, [ADDRESS_BOOT_S_NUM]
        mov dx, [ADDRESS_BOOT_H_NUM]
        mov bx, [ADDRESS_BOOT_C_NUM]
        
        shl bh, 6
        or cl, bh
        mov ch, bl
        mov dh, dl
        mov dl, [ADDRESS_BOOT_DEVICE]
        les bx, [ADDRESS_BOOT_OFF]
        mov ax, 0x0201
        int 0x13
        jc int13err
    .next_sector:
        mov dx, [ADDRESS_BOOT_S_NUM]
        mov cx, [ADDRESS_BOOT_H_NUM]
        mov ax, [ADDRESS_BOOT_C_NUM]
        inc dx
        cmp dx, [ADDRESS_BOOT_S_CNT]
        jng short .next_head
        mov dx, 1
        inc cx
    .next_head:
        mov bx, [ADDRESS_BOOT_H_CNT]
        dec bx
        cmp cx, bx
        jng short .next_cylinder
        xor cx, cx
        inc ax
    .next_cylinder:
        mov [ADDRESS_BOOT_S_NUM], dx
        mov [ADDRESS_BOOT_H_NUM], cx
        mov [ADDRESS_BOOT_C_NUM], ax
        add word [ADDRESS_BOOT_SEG], 0x20
        dec word [dap.size]
        jmp short .loop
    .return:
        mov [dap.size], word 0x10
return:
    popad
    clc
    ret
puts:
    pushad
    .loop:
        lodsb
        test al, al
        jz short return
        mov ah, 0x07
        mov bx, 0x000f
        int 0x10
        jmp short .loop
putx:
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
    popad
    ret
int13err:
    mov si, text.sign1
    call puts
    call putx
errtail:
    mov si, text.error
    call puts
die:
    hlt
    jmp short die

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, SEGMENT_BOOT << 4
    mov bp, sp
save:
    cld
    mov [ADDRESS_BOOT_DEVICE], dx
    mov cx, 0x0c
    mov si, label
    mov di, ADDRESS_BOOT_LABEL
    rep movsb

    mov si, ADDRESS_BOOT_LABEL
    call puts

    call read
    ; jmp $
    les bx, [dap.offset]
    push es
    push bx
    ; jmp $

    retf
    jmp short $


times (512 - 2 - 64) - ($ - $$) db 0
mbr 0x00, 0xee, 0, 0xffffffffffffff
mbr 0x80, 0x5a, SECTOR_LOADER, LENGTH_LOADER
mbr 0x00, 0x00, 0, 0
mbr 0x00, 0x00, 0, 0
dw 0xaa55