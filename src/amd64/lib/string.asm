bits 64

section .text
global memset_byte, memset_long
global memset_see1, memset_see2
global memset_avx2
global strcpy, strcat, strcmp
global strncpy, strncat, strncmp
global strlen

memset_byte:
    mov rcx, rdx
    rep stosb
    ret

memset_long:
    ; 扩展字节
    mov r10, rdi
    mov r11, rdx
    movzx eax, sil
    imul eax, 0x01010101
    mov ecx, eax
    mov rdx, r11
    shl rax, 32
    or rax, rcx
    ; 处理前缀
    xor rcx, rcx
    sub rcx, rdi
    and rcx, 7
    jz .body
    sub rdx, rcx
    lea rsi, [rdi+rcx]
    rep stosb
    mov rdi, rsi
    .body: ; 处理主体
        mov rcx, rdx
        shr rcx, 3
        jz .tail
    .loop:
        rep stosq
    .tail:
        mov rcx, rdx
        and rcx, 7
        jz .return
        rep stosb
    .return:
        mov rax, r10
        ret
memset_see:
    ; 扩展字节
    mov r10, rdi
    mov r11, rdx
    movzx eax, sil
    imul eax, 0x01010101
    mov ecx, eax
    mov rdx, r11
    shl rax, 32
    or rax, rcx
    ; 处理前缀
    xor rcx, rcx
    sub rcx, rdi
    and rcx, 127
    jz .body
    sub rdx, rcx
    lea rsi, [rdi+rcx]
    rep stosb
    mov rdi, rsi
    .body: ; 处理主体
        movq xmm0, rax
        punpcklqdq xmm0, xmm0
        movdqa xmm1, xmm0
        movdqa xmm2, xmm0
        movdqa xmm3, xmm0
        movdqa xmm4, xmm0
        movdqa xmm5, xmm0
        movdqa xmm6, xmm0
        movdqa xmm7, xmm0
        mov rcx, rdx
        shr rcx, 7
        jz .tail
    .loop:
        movdqa [rdi], xmm0
        movdqa [rdi+16], xmm1
        movdqa [rdi+32], xmm2
        movdqa [rdi+48], xmm3
        movdqa [rdi+64], xmm4
        movdqa [rdi+80], xmm5
        movdqa [rdi+96], xmm6
        movdqa [rdi+112], xmm7
        add rdi, 128
        dec rcx
        jnz .loop
    .tail:
        mov rcx, rdx
        and rcx, 127
        jz .return
        rep stosb
    .return:
        mov rax, r10
        ret
memset_see_long:
    ; 扩展字节
    mov r10, rdi
    mov r11, rdx
    movzx eax, sil
    imul eax, 0x01010101
    mov ecx, eax
    mov rdx, r11
    shl rax, 32
    or rax, rcx
    ; 处理前缀
    xor rcx, rcx
    sub rcx, rdi
    and rcx, 255
    jz .body
    sub rdx, rcx
    lea rsi, [rdi+rcx]
    rep stosb
    mov rdi, rsi
    .body: ; 处理主体
        movq xmm0, rax
        punpcklqdq xmm0, xmm0
        movdqa xmm1, xmm0
        movdqa xmm2, xmm0
        movdqa xmm3, xmm0
        movdqa xmm4, xmm0
        movdqa xmm5, xmm0
        movdqa xmm6, xmm0
        movdqa xmm7, xmm0
        movdqa xmm8, xmm0
        movdqa xmm9, xmm0
        movdqa xmm10, xmm0
        movdqa xmm11, xmm0
        movdqa xmm12, xmm0
        movdqa xmm13, xmm0
        movdqa xmm14, xmm0
        movdqa xmm15, xmm0
        mov rcx, rdx
        shr rcx, 8
        jz .tail
    .loop:
        movdqa [rdi], xmm0
        movdqa [rdi+16], xmm1
        movdqa [rdi+32], xmm2
        movdqa [rdi+48], xmm3
        movdqa [rdi+64], xmm4
        movdqa [rdi+80], xmm5
        movdqa [rdi+96], xmm6
        movdqa [rdi+112], xmm7
        movdqa [rdi+128], xmm8
        movdqa [rdi+144], xmm9
        movdqa [rdi+160], xmm10
        movdqa [rdi+176], xmm11
        movdqa [rdi+192], xmm12
        movdqa [rdi+208], xmm13
        movdqa [rdi+224], xmm14
        movdqa [rdi+240], xmm15
        add rdi, 256
        dec rcx
        jnz .loop
    .tail:
        mov rcx, rdx
        and rcx, 255
        jz .return
        rep stosb
    .return:
        mov rax, r10
        ret
memset_avx2:
    ; 扩展字节
    mov r10, rdi
    movzx eax, sil
    imul eax, 0x01010101
    ; 处理前缀
    xor rcx, rcx
    sub rcx, rdi
    and rcx, 511
    jz .body
    sub rdx, rcx
    lea rsi, [rdi+rcx]
    rep stosb
    mov rdi, rsi
    .body: ; 处理主体
        movq xmm0, rax
        punpcklqdq xmm0, xmm0
        vpbroadcastq ymm0, xmm0
        vmovdqa ymm1, ymm0
        vmovdqa ymm2, ymm0
        vmovdqa ymm3, ymm0
        vmovdqa ymm4, ymm0
        vmovdqa ymm5, ymm0
        vmovdqa ymm6, ymm0
        vmovdqa ymm7, ymm0
        vmovdqa ymm8, ymm0
        vmovdqa ymm9, ymm0
        vmovdqa ymm10, ymm0
        vmovdqa ymm11, ymm0
        vmovdqa ymm12, ymm0
        vmovdqa ymm13, ymm0
        vmovdqa ymm14, ymm0
        vmovdqa ymm15, ymm0
        mov rcx, rdx
        shr rcx, 9
        jz .tail
    .loop:
        vmovdqa [rdi], ymm0
        vmovdqa [rdi+32], ymm1
        vmovdqa [rdi+64], ymm2
        vmovdqa [rdi+96], ymm3
        vmovdqa [rdi+128], ymm4
        vmovdqa [rdi+160], ymm5
        vmovdqa [rdi+192], ymm6
        vmovdqa [rdi+224], ymm7
        vmovdqa [rdi+256], ymm8
        vmovdqa [rdi+288], ymm9
        vmovdqa [rdi+320], ymm10
        vmovdqa [rdi+352], ymm11
        vmovdqa [rdi+384], ymm12
        vmovdqa [rdi+416], ymm13
        vmovdqa [rdi+448], ymm14
        vmovdqa [rdi+480], ymm15
        add rdi, 512
        dec rcx
        jnz .loop
    .tail:
        vzeroupper
        mov rcx, rdx
        and rcx, 511
        jz .return
        rep stosb
    .return:
        mov rax, r10
        ret

strcpy:
    cld
    push rdi
    .loop:
	    lodsb
	    stosb
	    test al, al
	    jnz .loop
    pop rax
    ret
strncpy:
    cld
    push rdi
    xchg rcx, rdx
    .loop:
	    dec rcx
        js .ret
        lodsb
	    stosb
	    test al, al
	    jnz .loop
        rep stosb
    .ret:
        pop rax
        ret
strcat:
    cld
    push rdi
    xor al, al
    xor rcx, rcx
    dec rcx
    repnz scasb
    dec rdi
    .loop:
	    lodsb
        stosb
	    test al, al
	    jnz .loop
    pop rax
    ret
strncat:
    cld
    push rdi
    xor al, al
    xchg rcx, rdx
    repnz scasb
    dec rdi
    .loop:
	    dec rcx
        js .ret
	    lodsb
        stosb
	    test al, al
	    jnz .loop
    .ret:
        xor al, al
        stosb
        pop rax
        ret
strcmp:
    cld
    .loop:
        lodsb
        scasb
        jne .retn
        test al, al
        jnz .loop
        xor eax, eax
        ret
    .retn:
        mov eax, 1
        ja .reta
        neg eax
    .reta:
        ret
strncmp:
    cld
    xchg rcx, rdx
    .loop:
        dec rcx
        js .ret
        lodsb
        scasb
        jne .retn
        test al, al
        jnz .loop
    .ret:
        xor eax, eax
        ret
    .retn:
        mov eax, 1
        ja .reta
        neg eax
    .reta:
        ret
strlen:
    cld
    xor al, al
    xor rcx, rcx
    dec rcx
    repnz scasb
    xor rax, rax
    sub rax, rcx
    ret
