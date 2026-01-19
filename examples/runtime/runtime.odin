package co_def

import co "../../../coroutines"

Coroutine   :: co.Coroutine
Caller      :: co.Caller

STACK_CAPACITY  :: 64 * 1024

start_raw :: proc(f: proc(Caller, rawptr), arg: rawptr) -> ^Coroutine {
    stack := co.allocate_stack(STACK_CAPACITY)
    
    return co.start(stack, f, arg, on_finish, nil)

    on_finish :: proc(coroutine: ^Coroutine, _arg: rawptr) {
        co.free_stack(coroutine.stack)
    }
}

resume  :: co.resume

yield   :: co.yield

alternate :: proc(coroutines: ..^Coroutine) {
    for finished := false; !finished; {
        finished  = true

        for &coroutine in coroutines {
            if coroutine != nil && co.unsafe_resume(coroutine) {
                finished = false
            } else {
                coroutine = nil
            }
        }
    }
}

start :: proc{
    start_0,
    start_1,
    start_2,
    start_3,
    start_4,
}

start_0 :: proc($f: proc(Caller)) -> ^Coroutine {
    Args :: struct{}
    wrapper :: proc(caller: Caller, _: rawptr) {
        f(caller)
    }
    return start_raw(wrapper, &Args{})
}
start_1 :: proc($f: proc(Caller, $T1), arg1: T1) -> ^Coroutine {
    Args :: struct {
        arg1: T1,
    }    
    wrapper :: proc(caller: Caller, arg: rawptr) {
        using args := (^Args)(arg)
        f(caller, arg1)
    }
    return start_raw(wrapper, &Args{arg1})
}
start_2 :: proc($f: proc(Caller, $T1, $T2), arg1: T1, arg2: T2) -> ^Coroutine {
    Args :: struct {
        arg1: T1,
        arg2: T2,
    }
    wrapper :: proc(caller: Caller, arg: rawptr) {
        using args := (^Args)(arg)
        f(caller, arg1, arg2)
    }
    return start_raw(wrapper, &Args{arg1, arg2})
}
start_3 :: proc($f: proc(Caller, $T1, $T2, $T3), arg1: T1, arg2: T2, arg3: T3) -> ^Coroutine {
    Args :: struct {
        arg1: T1,
        arg2: T2,
        arg3: T3,
    }
    wrapper :: proc(caller: Caller, arg: rawptr) {
        using args := (^Args)(arg)
        f(caller, arg1, arg2, arg3)
    }
    return start_raw(wrapper, &Args{arg1, arg2, arg3})
}
start_4 :: proc($f: proc(Caller, $T1, $T2, $T3, $T4), arg1: T1, arg2: T2, arg3: T3, arg4: T4) -> ^Coroutine {
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
    return start_raw(wrapper, &Args{arg1, arg2, arg3, arg4})
}