; this file uses a NASM/intel dialect

; Linux x86_64 call convention
; %rdi, %rsi, %rdx, %rcx, %r8, and %r9

bits 64

section .note.GNU-stack

section .text

global create_coroutine
global swap_stacks

%define finished   0
%define unfinished 1

%macro return 1
    mov rax, %1
    ret
%endmacro

%macro switch 0
    mov rax, [rdi]
    mov [rdi], rsp

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
%endmacro

%macro restore_registers 0
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

create_coroutine:
    switch

    push rcx ; save on_finish
    push r8  ; save on_finish_arg
    push r9, ; save odin context pointer
    push 0   ; for alignment

    push cleanup_coroutine

    push rdx ; setup f

    mov  rdx, r9 ; pose for the picture
    save_registers

    switch
    
    ret

cleanup_coroutine:
    ; setup args for on_finish
    pop r8  ; for alignment
    pop rdx ; restore odin context pointer
    pop rsi ; restore on_finish_arg
    pop rax ; setup call to on_finish

    ; the Coroutine is now at the top of the stack, thus..
    mov rdi, rsp ; restore ^Coroutine

    mov rsp, [rsp] ; switch stacks

    call rax ; on_finish
    
    restore_registers

    return finished

swap_stacks:
    save_registers

    switch

    restore_registers

    return unfinished
