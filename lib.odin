package coroutines

import "base:runtime"

Coroutine :: struct {
    rsp: rawptr,
    stack: Stack,
}
#assert(offset_of(Coroutine, rsp) == 0)

Caller :: distinct ^Coroutine

Stack :: distinct []byte

allocate_stack :: proc(size: int) -> (Stack, runtime.Allocator_Error) #optional_allocator_error {
    return _allocate_stack(size)
}

free_stack :: proc(stack: Stack) {
    _free_stack(stack)
}

start :: proc(stack: Stack, f: proc(Caller, rawptr), arg: rawptr, on_finish: proc(^Coroutine, rawptr), on_finish_arg: rawptr) -> ^Coroutine {
    assert(len(stack) % 16 == 0)

    // this is one byte AFTER the top of the stack
    rsp := raw_data(stack[len(stack) - (size_of(Coroutine)):])

    // this doesn't overlap the stack since it goes upward
    coroutine := cast(^Coroutine)rsp
    coroutine^ = {
        rsp,
        stack,
    }

    if start_coroutine(coroutine, arg, f, on_finish, on_finish_arg) {
        return coroutine
    } else {
        return nil
    }
}

resume :: proc(coroutine: ^^Coroutine) -> (unfinished: bool) {
    if coroutine^ != nil {
        unfinished = swap_stacks(coroutine^)
        if !unfinished {
            coroutine^ = nil
        }
    }
    return
}

yield :: proc(caller: Caller) {
    swap_stacks((^Coroutine)(caller))
}

unsafe_resume :: proc(coroutine: ^Coroutine) -> (unfinished: bool) {
    return swap_stacks(coroutine)
}

when ODIN_OS != .Windows && ODIN_ARCH == .amd64 {
    foreign import assembly "impl_amd64_posix.asm"
} else when ODIN_OS == .Windows && ODIN_ARCH == .amd64 {
    foreign import assembly "impl_amd64_windows.asm"
} else {
    #assert(false, "unsupported architecture")
}
@(private)
foreign assembly {
    start_coroutine :: proc "odin" (^Coroutine, rawptr, proc"odin"(Caller, rawptr), proc"odin"(^Coroutine, rawptr), rawptr) -> bool ---
    swap_stacks     :: proc(^Coroutine) -> bool ---
}
