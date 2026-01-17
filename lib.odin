package coroutines

import "base:runtime"

Allocator_Error :: runtime.Allocator_Error

STACK_CAPACITY :: 1024 * 16

Coroutine :: struct {
    rsp: rawptr,
    stack_base: rawptr,
    finished: bool,
    args: rawptr,
}

Caller  :: distinct rawptr
ID      :: distinct int

/*
Starts a coroutine to run the proc `f` with `arg` as it's argument.
It does not start running until you call `resume()` on it.

Inputs:
- f: The proc to run
- arg: An opaque pointer passed to `f`
*/
create_raw :: proc(f: proc(Caller, rawptr), arg: rawptr, allocator := context.allocator) -> (^Coroutine, Allocator_Error) #optional_allocator_error {
    context.allocator = allocator

    coroutine, allocation_err := new(Coroutine)
    if allocation_err != nil {
        return nil, allocation_err
    }
    
    stack_base := allocate_stack(STACK_CAPACITY)
    odin_context_ptr := get_context_ptr()

    synthetic_registers := []rawptr{
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
    rsp := stack_base[len(stack_base)-len(synthetic_registers):]
    copy(rsp, synthetic_registers)

    coroutine.rsp        = raw_data(rsp)
    coroutine.stack_base = raw_data(stack_base)

    return coroutine, nil
}

destroy :: proc(coroutine: ^Coroutine, allocator := context.allocator) {
    free_stack(coroutine.stack_base, STACK_CAPACITY)

    if coroutine.args != nil {
        free(coroutine.args, allocator)
    }

    free(coroutine, allocator)
}

/*
Returns control to the calling coroutine
*/
yield :: proc(caller: Caller) {
    #force_inline resume((^Coroutine)(caller))
}

resume :: proc(coroutine: ^Coroutine) {
    #force_inline co_resume(coroutine)
}

my_id :: proc(caller: Caller) -> ID {
    stack_base := (^Coroutine)(caller).stack_base

    return ID(uintptr(stack_base))
}

alternate :: proc(coroutines: ..^Coroutine) {
    for {
        finished := true

        for coroutine in coroutines {
            if !coroutine.finished {
                resume(coroutine)
                finished = false
            }
        }
        if finished {
            break
        }
    }
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
