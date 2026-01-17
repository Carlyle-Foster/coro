package coroutines

import "base:runtime"

import "core:slice"

Coroutine :: struct {
    rsp: rawptr,
    stack: Stack,
}
Caller :: distinct ^Coroutine

Stack :: distinct []byte

allocate_stack :: proc(size: int) -> (Stack, runtime.Allocator_Error) #optional_allocator_error {
    return _allocate_stack(size)
}

free_stack :: proc(stack: Stack) {
    _free_stack(stack)
}

create :: proc(stack: Stack, f: proc(Caller, rawptr), arg: rawptr, on_finish: proc(^Coroutine, rawptr), on_finish_arg: rawptr) -> ^Coroutine {
    assert(len(stack) % 16 == 0)

    #assert(size_of(Coroutine) % 16 == 8)
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

        rawptr(finish_coroutine),
        rawptr(on_finish),
        on_finish_arg,
        odin_context_ptr,
    }
    rsp := stack[n - size_of(synthetic_registers):]
    copy(slice.reinterpret([]rawptr, ([]byte)(rsp)), synthetic_registers[:])

    coroutine.rsp   = raw_data(rsp)
    coroutine.stack = stack

    return coroutine
}

resume :: proc(coroutine: ^^Coroutine) -> (unfinished: bool) {
    if coroutine^ != nil {
        unfinished = swap_stacks(&(coroutine^).rsp)
        if !unfinished {
            coroutine^ = nil
        }
    }
    return
}

yield :: proc(caller: Caller) {
    swap_stacks(&(^Coroutine)(caller).rsp)
}

unsafe_resume :: proc(coroutine: ^Coroutine) -> (unfinished: bool) {
    return swap_stacks(&coroutine.rsp)
}

when ODIN_ARCH == .amd64 {
    foreign import assembly "impl_amd64.asm"
} else {
    #assert(false, "unsupported architecture")
}
@(private)
foreign assembly {
    get_context_ptr     :: proc "odin" () -> rawptr ---
    swap_stacks         :: proc(rsp: ^rawptr) -> bool ---
    finish_coroutine    :: proc() ---
}
