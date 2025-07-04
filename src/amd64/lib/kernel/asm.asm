bits 64

section .text
global inb, inw, inl, outb, outw, outl
global call, call_far, jump, jump_far
global stc, clc, std, cld, sti, cli
global hlt, nop, step, set_break
global lidt, lgdt, int80
global sto_seg, lod_seg, lod_seg_stack
global has_la57

%macro single_com 1
%1:
    %1
    ret
%endmacro


inb:
    mov rdx, rdi
    xor rax, rax
    in al, dx
    ret
inw:
    mov rdx, rdi
    xor rax, rax
    in ax, dx
    ret
inl:
    mov rdx, rdi
    xor rax, rax
    in eax, dx
    ret
outb:
    mov rdx, rdi
    mov rax, rsi
    out dx, al
    ret
outw:
    mov rdx, rdi
    mov rax, rsi
    out dx, ax
    ret
outl:
    mov rdx, rdi
    mov rax, rsi
    out dx, eax
    ret
call:
    push rdi
    ret
call_far:
    push rdi
    push rsi
    retf
jump:
    push rdi
    ret
jump_far:
    push rdi
    push rsi
    retf
step:
    nop
    jmp .second
    .second nop
    ret
set_break:
    xchg bx, bx
    ret
lidt:
    lidt [rdi]
    ret
lgdt:
    lgdt [rdi]
    ret
int80:
    int 0x80
    ret
sto_seg:
    mov [rdi], cs
    mov [rdi+2], ds
    mov [rdi+4], ss
    mov [rdi+6], es
    mov [rdi+8], fs
    mov [rdi+10], gs
    ret
lod_seg:
    mov ax, [rdi+2]
    mov cx, [rdi+4]
    mov ds, ax
    mov ss, cx
    mov ax, [rdi+6]
    mov cx, [rdi+8]
    mov es, ax
    mov fs, cx
    mov ax, [rdi+10]
    mov cx, [rdi]
    mov gs, ax
    mov rsp, rdx
    mov rbp, rcx
    push rcx
    push rsi
    retf
lod_seg_stack:
    mov ax, [rdi+2]
    mov cx, [rdi+6]
    mov dx, [rdi+8]
    mov ds, ax
    mov es, cx
    mov fs, dx
    mov ax, [rdi+10]
    mov cx, [rdi]
    mov gs, ax
    push rcx
    push rsi
    retf
single_com stc
single_com clc
single_com hlt
single_com nop
single_com std
single_com cld
single_com sti
single_com cli

has_la57:
    mov eax, 7
    xor ecx, ecx
    cpuid
    test ecx, (1<<16)
    xor eax, eax
    setnz al
    ret
