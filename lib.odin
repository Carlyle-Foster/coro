package coroutines

import "core:slice"

Coroutine :: struct {
    rsp: rawptr,
    stack: Stack,
    finished: bool,
}
Caller :: distinct ^Coroutine

Stack :: distinct []byte

allocate_stack :: proc(size: int) -> Stack {
    return _allocate_stack(size)
}

free_stack :: proc(stack: Stack) {
    _free_stack(stack)
}

create :: proc(stack: Stack, f: proc(Caller, rawptr), arg: rawptr, on_finish: proc(^Coroutine, rawptr), on_finish_arg: rawptr) -> ^Coroutine {   
    #assert(size_of(Coroutine) % 16 == 0)    
    n := len(stack) - (size_of(Coroutine))

    coroutine := cast(^Coroutine)raw_data(stack[n:])

    odin_context_ptr := get_context_ptr()

    synthetic_registers := [?]rawptr{
        nil, // push r15
        nil, // push r14
        nil, // push r13
        nil, // push r12
        nil, // push rbx
        nil, // push rbp

        odin_context_ptr,   // push rdx
        arg,                // push rsi
        rawptr(coroutine),  // push rdi
        rawptr(f),

        rawptr(co_finish),
        rawptr(coroutine),
        odin_context_ptr,
    }
    rsp := stack[n - size_of(synthetic_registers):]
    copy(slice.reinterpret([]rawptr, ([]byte)(rsp)), synthetic_registers[:])

    coroutine.rsp   = raw_data(rsp)
    coroutine.stack = stack

    return coroutine
}

yield :: proc(caller: Caller) {
    #force_inline co_resume((^Coroutine)(caller))
}

resume :: proc(coroutine: ^Coroutine) {
    #force_inline co_resume(coroutine)
}

foreign import assembly "coroutine.asm"
@(private, default_calling_convention="odin")
foreign assembly {
    co_resume           :: proc(coroutine: ^Coroutine) ---
    co_restore_context  :: proc(rsp: rawptr) ---
    co_finish           :: proc(coroutine: ^Coroutine) ---
    get_context_ptr     :: proc() -> rawptr ---
}

@(private, export)
__resume :: proc(coroutine: ^Coroutine, rsp: rawptr) {
    rsp := rsp

    coroutine.rsp, rsp = rsp, coroutine.rsp

    co_restore_context(rsp)
}

@(private, export)
__finish :: proc(coroutine: ^Coroutine) {
    coroutine.finished = true

    __resume(coroutine, nil)
}
