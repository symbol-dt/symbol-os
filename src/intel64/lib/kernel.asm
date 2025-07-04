bits 64
global store_registers

section .text
store_registers:
    endbr64
    push rax
    push rbx
    push rcx
    push rdx
    mov ax, cs
    mov bx, ds
    mov cx, es
    mov dx, fs
    mov [rdi + 0], ax
    mov [rdi + 2], bx
    mov [rdi + 4], cx
    mov [rdi + 6], dx
    mov ax, gs
    mov bx, ss
    mov rcx, cr0
    mov rdx, cr2
    mov [rdi + 8], ax
    mov [rdi + 10], bx
    mov [rdi + 12], ecx
    mov [rdi + 16], edx
    mov rax, cr3
    mov rbx, cr4
    mov rcx, cr8
    mov [rdi + 20], eax
    mov [rdi + 24], ebx
    mov [rdi + 28], ecx
    pushfq
    pop qword [rdi + 36]
    pop rdx
    pop rcx
    pop rbx
    pop rax
    mov [rdi + 44], rax
    mov [rdi + 52], rcx
    mov [rdi + 60], rdx
    mov [rdi + 68], rbx
    sgdt [rdi + 76]
    sidt [rdi + 86]
    ret
