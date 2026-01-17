package co_def

import co "../../coroutines"

Coroutine   :: co.Coroutine
Caller      :: co.Caller
Stack       :: co.Stack

DEFAULT_STACK_CAPACITY  :: 1024 * 16
PER_COROUTINE_STORAGE   :: 128

create_raw :: proc(f: proc(Caller, rawptr), args: $T) -> ^Coroutine where size_of(T) <= PER_COROUTINE_STORAGE {
    stack := co.allocate_stack(DEFAULT_STACK_CAPACITY + PER_COROUTINE_STORAGE)

    arg := cast(^T)raw_data(stack[PER_COROUTINE_STORAGE:])
    arg^ = args
    
    return co.create(stack[:DEFAULT_STACK_CAPACITY], f, arg, on_finish, nil)
}

resume :: co.resume
yield :: co.yield

alternate :: proc(coroutines: ..^Coroutine) {
    for {
        finished := true
        for coroutine in coroutines {
            if !coroutine.finished {
                co.resume(coroutine)
                finished = false
            }
        }
        if finished {
            break
        }
    }
}

@(private)
on_finish :: proc(coroutine: ^Coroutine, _arg: rawptr) {
    co.free_stack(coroutine.stack)
}