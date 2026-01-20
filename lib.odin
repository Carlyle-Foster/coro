package coroutines

import "base:runtime"

import "core:mem/virtual"
import old_os "core:os"

Coroutine :: struct {
    rsp: rawptr,
    stack: Stack,
}
#assert(offset_of(Coroutine, rsp) == 0)

Caller :: distinct ^Coroutine

Stack :: distinct []byte

allocate_stack :: proc(min_size: int) -> (Stack, runtime.Allocator_Error) #optional_allocator_error {
    page_size := old_os.get_page_size()
    size      := runtime.align_forward(min_size, page_size) + page_size

    stack, err := virtual.reserve_and_commit(uint(size))
    if err != nil {
        return nil, err
    }
    // remove read/write permissions from the guard page
    ensure(virtual.protect(raw_data(stack), uint(page_size), {}))
    // skip past the guard page
    stack = stack[page_size:] 
    
    return Stack(stack), nil
}

free_stack :: proc "contextless" (stack: Stack) {
    context = runtime.default_context()

    page_size := old_os.get_page_size()

    base := rawptr( uintptr(raw_data(stack)) - uintptr(page_size) )

    virtual.decommit(base, uint(page_size))
    virtual.release(base, uint(page_size))
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
    foreign import assembly "amd64_posix.asm"
} else when ODIN_OS == .Windows && ODIN_ARCH == .amd64 {
    foreign import assembly "amd64_windows.asm"
} else {
    #assert(false, "unsupported architecture")
}
@(private)
foreign assembly {
    start_coroutine :: proc "preserve/none" (^Coroutine, rawptr, proc"odin"(Caller, rawptr), proc"odin"(^Coroutine, rawptr), rawptr) -> bool ---
    swap_stacks     :: proc "preserve/none" (^Coroutine) -> bool ---
}
