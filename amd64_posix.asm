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
    push rdx
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov rax, [rdi]
    mov [rdi], rsp

    mov rsp, rax ; switch stacks
%endmacro

%macro postlude 1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    pop rdx

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

    sub rsp, 8 ; align the stack
    call rax   ; run the coroutine f
    add rsp, 8

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
