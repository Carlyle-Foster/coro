; this file uses a NASM/intel dialect

; Linux x86_64 call convention
; %rdi, %rsi, %rdx, %rcx, %r8, and %r9

bits 64

section .note.GNU-stack

section .text

global start_coroutine
global swap_stacks

%define unfinished 1
%define finished   0

%macro prelude 0
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
    movaps rsp[9*16], xmm6
    movaps rsp[8*16], xmm7
    movaps rsp[7*16], xmm8
    movaps rsp[6*16], xmm9
    movaps rsp[5*16], xmm10
    movaps rsp[4*16], xmm11
    movaps rsp[3*16], xmm12
    movaps rsp[2*16], xmm13
    movaps rsp[1*16], xmm14
    movaps rsp[0*16], xmm15

    mov rax, [rdi]
    mov [rdi], rsp

    mov rsp, rax ; switch stacks
%endmacro

%macro postlude 1
    movaps xmm15, rsp[0*16]
    movaps xmm14, rsp[1*16]
    movaps xmm13, rsp[2*16]
    movaps xmm12, rsp[3*16]
    movaps xmm11, rsp[4*16]
    movaps xmm10, rsp[5*16]
    movaps xmm9,  rsp[6*16]
    movaps xmm8,  rsp[7*16]
    movaps xmm7,  rsp[8*16]
    movaps xmm6,  rsp[9*16]
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

    mov rax, %1
    ret
%endmacro

start_coroutine:
    prelude

    push rcx ; save on_finish
    push r8  ; save on_finish_arg
    push r9, ; save odin context pointer

    mov rax, rdx ; save f
    mov rdx, r9  ; shift odin context pointer

    call rax ; run the coroutine f

    ; the coroutine is finished by this point

    ; setup args for on_finish
    pop rdx ; restore odin context pointer
    pop rsi ; restore on_finish_arg
    pop rax ; setup call to on_finish

    ; the Coroutine is now at the top of the stack, thus..
    mov rdi, rsp ; restore ^Coroutine

    mov rsp, [rsp] ; switch stacks

    call rax ; on_finish
    
    postlude finished

swap_stacks:
    prelude

    postlude unfinished
