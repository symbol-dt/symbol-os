bits 64
global load_gdt_switch_cs_ss_ds
global load_tss_switch_tr

section .text
load_gdt_switch_cs_ss_ds:
    endbr64
    push rbp
    mov rbp, rsp
    and rsp, -16
    lgdt [rdi]
    mov ss, dx
    mov ds, cx
    mov es, cx
    mov fs, cx
    mov gs, cx
    push si
    push qword .switch_cs
    retfq
    .switch_cs:
    leave
    ret

load_tss_switch_tr:
    endbr64
    ltr di
    ret
