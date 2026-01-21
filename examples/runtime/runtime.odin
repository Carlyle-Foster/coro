package ex_rt

import "base:intrinsics"

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
    passer :: proc(c: Caller, _: rawptr) {
        f(c)
    }
    return start_raw(passer, nil)
}
start_1 :: proc($f: proc(Caller, $T1), arg1: T1) -> ^Coroutine {
    passer :: proc(c: Caller, arg: ^T1) {
        f(c, arg^)
    }
    arg1 := arg1
    return start_raw(auto_cast passer, &arg1)
}
start_2 :: proc($f: proc(Caller, $T1, $T2), arg1: T1, arg2: T2) -> ^Coroutine {
    args := compress_values(arg1, arg2)
    return start_raw(auto_cast intrinsics.procedure_of(passer(type_of(f), f, nil, &args)), &args)
}
start_3 :: proc($f: proc(Caller, $T1, $T2, $T3), arg1: T1, arg2: T2, arg3: T3) -> ^Coroutine {
    args := compress_values(arg1, arg2, arg3)
    return start_raw(auto_cast intrinsics.procedure_of(passer(type_of(f), f, nil, &args)), &args)

}
start_4 :: proc($f: proc(Caller, $T1, $T2, $T3, $T4), arg1: T1, arg2: T2, arg3: T3, arg4: T4) -> ^Coroutine {
    args := compress_values(arg1, arg2, arg3, arg4)
    return start_raw(auto_cast intrinsics.procedure_of(passer(type_of(f), f, nil, &args)), &args)
}

@(private)
passer :: proc($F: typeid, $f: F, c: Caller, args: ^$A) {
    f(c, expand_values(args^))
}