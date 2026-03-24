; this file uses a NASM/intel dialect

; windows x86_64 call convention
; %rcx, %rdx, %r8, and %r9

bits 64

section .note.GNU-stack

section .text

global asm_init
global asm_swap_stacks

%define finished   0
%define unfinished 1

%macro return 1
    mov rax, %1
    ret
%endmacro

%macro switch 0
    mov rax, [rcx]
    mov [rcx], rsp

    mov rsp, rax
%endmacro

%macro save_registers 0
    push rdi
    push rsi
    push rdx
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 10*16
    movups rsp[9*16], xmm6
    movups rsp[8*16], xmm7
    movups rsp[7*16], xmm8
    movups rsp[6*16], xmm9
    movups rsp[5*16], xmm10
    movups rsp[4*16], xmm11
    movups rsp[3*16], xmm12
    movups rsp[2*16], xmm13
    movups rsp[1*16], xmm14
    movups rsp[0*16], xmm15
%endmacro

%macro restore_registers 0
    movups xmm15, rsp[0*16]
    movups xmm14, rsp[1*16]
    movups xmm13, rsp[2*16]
    movups xmm12, rsp[3*16]
    movups xmm11, rsp[4*16]
    movups xmm10, rsp[5*16]
    movups xmm9,  rsp[6*16]
    movups xmm8,  rsp[7*16]
    movups xmm7,  rsp[8*16]
    movups xmm6,  rsp[9*16]
    add rsp, 10*16
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    pop rdx
    pop rsi
    pop rdi
%endmacro

asm_init:
    mov r10, rsp[5*8]
    mov r11, rsp[6*8]

    switch

    push r9  ; save on_finish
    push r10 ; save on_finish_arg
    push r11 ; save odin context pointer
    push 0   ; for alignment

    sub rsp, 32 ; allocate shadow space

    lea  r10, [rel cleanup_coroutine]
    push r10

    push r8 ; setup f

    mov  r8, r11 ; pose for the picture
    save_registers

    switch
    
    ret

cleanup_coroutine:
    add rsp, 32 ; free shadow space

    ; setup args for on_finish
    pop r10 ; for alignment
    pop r8  ; restore odin context pointer
    pop rdx ; restore on_finish_arg
    pop rax ; setup call to on_finish

    ; the Coroutine is now at the top of the stack, thus..
    mov rcx, rsp ; restore ^Coroutine

    mov rsp, [rsp] ; switch stacks

    ;mov r8, 0
    call rax ; on_finish
    
    restore_registers
    
    return finished

asm_swap_stacks:
    save_registers

    switch

    restore_registers

    return unfinished
