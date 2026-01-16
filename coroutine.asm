; this file uses a NASM/intel dialect

; TODO: ARM support

; Linux x86_64 call convention
; %rdi, %rsi, %rdx, %rcx, %r8, and %r9

bits 64

section .note.GNU-stack

section .text

extern __resume
extern __finish

global co_resume
global co_restore_context
global co_finish
global get_context_ptr

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

co_resume:
    save_registers

    mov rdx, rsi
    mov rsi, rsp ; injecting the stack pointer

    jmp [rel __resume wrt ..got]

co_finish:
    pop rdi
    pop rsi
    push 0 ; for alignment
    jmp [rel __finish wrt ..got]


co_restore_context:
    mov rsp, rdi ; switch stacks
    
    restore_registers
    ret

get_context_ptr:
    mov rax, rdi
    ret
