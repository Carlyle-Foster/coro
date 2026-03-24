package co_def

import "base:runtime"
import "base:intrinsics"

import prim "primitives"

_ :: runtime
_ :: intrinsics

THREAD_SAFE :: #config(THREAD_SAFE, true)

Coroutine   :: prim.Coroutine
Caller      :: prim.Caller

Routine     :: ^Coroutine // if u want to be cute about it
routine     :: create

create :: proc{
    create_0,
    create_1,
    create_2,
    create_3,
    create_4,
}

resume :: proc(coroutine: ^^Coroutine) -> (unfinished: bool) {
    if coroutine^ != nil {
        unfinished = prim.swap_stacks(coroutine^)
        if !unfinished {
            coroutine^ = nil
        }
    }
    return
}

pass :: proc(caller: Caller) {
    prim.swap_stacks((^Coroutine)(caller))
}

unsafe_resume :: proc(coroutine: ^Coroutine) -> (unfinished: bool) {
    return prim.swap_stacks(coroutine)
}

chain :: proc(c: Caller, coroutines: ..^Coroutine) {
    for &coroutine in coroutines {
        for resume(&coroutine) {
            pass(c)
        }
    }
}

parallel :: proc(c: Caller, coroutines: ..^Coroutine) {
    coroutines := coroutines

    for parallel_iter(&coroutines) {
        pass(c)
    }
}

parallel_iter :: proc(coroutines: ^[]^ Coroutine) -> (ok: bool) {
    for &coroutine in coroutines {
        if resume(&coroutine) {
            ok = true
        }
    }
    return
}

create_0 :: proc($f: proc(Caller)) -> ^Coroutine {
    passer :: proc(c: Caller, _: rawptr) {
        f(c)
    }
    return create_raw(passer, int(0))
}
create_1 :: proc($f: proc(Caller, $T1), arg1: T1) -> ^Coroutine {
    passer :: proc(c: Caller, arg: ^T1) {
        f(c, arg^)
    }
    arg1 := arg1
    return create_raw(auto_cast passer, arg1)
}
create_2 :: proc($f: proc(Caller, $T1, $T2), arg1: T1, arg2: T2) -> ^Coroutine {
    args := compress_values(arg1, arg2)
    return create_raw(auto_cast intrinsics.procedure_of(passer(type_of(f), f, nil, &args)), args)
}
create_3 :: proc($f: proc(Caller, $T1, $T2, $T3), arg1: T1, arg2: T2, arg3: T3) -> ^Coroutine {
    args := compress_values(arg1, arg2, arg3)
    return create_raw(auto_cast intrinsics.procedure_of(passer(type_of(f), f, nil, &args)), args)
}
create_4 :: proc($f: proc(Caller, $T1, $T2, $T3, $T4), arg1: T1, arg2: T2, arg3: T3, arg4: T4) -> ^Coroutine {
    args := compress_values(arg1, arg2, arg3, arg4)
    return create_raw(auto_cast intrinsics.procedure_of(passer(type_of(f), f, nil, &args)), args)
}

@(private)
passer :: proc($F: typeid, $f: F, c: Caller, args: ^$A) {
    f(c, expand_values(args^))
}
