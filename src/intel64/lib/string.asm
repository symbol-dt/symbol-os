bits 64
global memsetw, memcopy

section .text
memsetw:
    mov rcx, rdx
    mov ax, si
    rep stosw
    ret

memcopy:
    mov rcx, rdx
    rep movsb
    ret
