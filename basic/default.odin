package co_def

import co "../../coroutines"

Coroutine   :: co.Coroutine
Caller      :: co.Caller
Stack       :: co.Stack

PER_COROUTINE_STORAGE   :: 128
DEFAULT_STACK_CAPACITY  :: 1024 * 16 - PER_COROUTINE_STORAGE 

create_raw :: proc(f: proc(Caller, rawptr), args: $T) -> ^Coroutine where size_of(T) <= PER_COROUTINE_STORAGE {
    stack := co.allocate_stack(DEFAULT_STACK_CAPACITY + PER_COROUTINE_STORAGE)

    arg := cast(^T)raw_data(stack[PER_COROUTINE_STORAGE:])
    arg^ = args
    
    return co.create(stack[:DEFAULT_STACK_CAPACITY], f, arg, on_finish, nil)

    on_finish :: proc(coroutine: ^Coroutine, _arg: rawptr) {
        co.free_stack(coroutine.stack)
    }
}

resume  :: co.resume

yield   :: co.yield

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

create :: proc{
    create_0,
    create_1,
    create_2,
    create_3,
    create_4,
}

create_0 :: proc($f: proc(Caller)) -> ^Coroutine {
    Args :: struct{}
    wrapper :: proc(caller: Caller, _: rawptr) {
        f(caller)
    }
    return create_raw(wrapper, Args{})
}
create_1 :: proc($f: proc(Caller, $T1), arg1: T1) -> ^Coroutine {
    Args :: struct {
        arg1: T1,
    }    
    wrapper :: proc(caller: Caller, arg: rawptr) {
        using args := (^Args)(arg)
        f(caller, arg1)
    }
    return create_raw(wrapper, Args{arg1})
}
create_2 :: proc($f: proc(Caller, $T1, $T2), arg1: T1, arg2: T2) -> ^Coroutine {
    Args :: struct {
        arg1: T1,
        arg2: T2,
    }
    wrapper :: proc(caller: Caller, arg: rawptr) {
        using args := (^Args)(arg)
        f(caller, arg1, arg2)
    }
    return create_raw(wrapper, Args{arg1, arg2})
}
create_3 :: proc($f: proc(Caller, $T1, $T2, $T3), arg1: T1, arg2: T2, arg3: T3) -> ^Coroutine {
    Args :: struct {
        arg1: T1,
        arg2: T2,
        arg3: T3,
    }
    wrapper :: proc(caller: Caller, arg: rawptr) {
        using args := (^Args)(arg)
        f(caller, arg1, arg2, arg3)
    }
    return create_raw(wrapper, Args{arg1, arg2, arg3})
}
create_4 :: proc($f: proc(Caller, $T1, $T2, $T3, $T4), arg1: T1, arg2: T2, arg3: T3, arg4: T4) -> ^Coroutine {
    Args :: struct {
        arg1: T1,
        arg2: T2,
        arg3: T3,
        arg4: T4,
    }
    wrapper :: proc(caller: Caller, arg: rawptr) {
        using args := (^Args)(arg)
        f(caller, arg1, arg2, arg3, arg4)
    }
    return create_raw(wrapper, Args{arg1, arg2, arg3, arg4})
}