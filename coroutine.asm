; this file uses a NASM/intel dialect

; TODO: ARM support

; Linux x86_64 call convention
; %rdi, %rsi, %rdx, %rcx, %r8, and %r9

bits 64

section .note.GNU-stack

section .text

global get_context_ptr
global swap_stacks
global finish_coroutine

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

get_context_ptr:
    mov rax, rdi
    ret

swap_stacks:
    save_registers

    mov rax, [rdi]
    mov [rdi], rsp

    mov rsp, rax ; switch stacks
    
    restore_registers
    mov rax, 1 ; unfinished = true
    ret

finish_coroutine:
    ; setup args for on_finish
    pop rax ; on_finish
    pop rsi ; arg
    pop rdx ; odin context ptr
    mov rdi, rsp ; ^Coroutine

    pop rsp ; switch stacks

    call rax ; on_finish
    
    restore_registers
    mov rax, 0 ; unfinished = false
    ret
