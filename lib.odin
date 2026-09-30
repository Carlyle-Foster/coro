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
    return create_raw(passer, int(0))

    passer :: proc(c: Caller, _: rawptr) {
        f(c)
    }
}
create_1 :: proc($f: proc(Caller, $T1), arg1: T1) -> ^Coroutine {
    return create_raw(passer, arg1)

    passer :: proc(c: Caller, args: rawptr) {
        f(c, (^T1)(args)^)
    }
}
create_2 :: proc($f: proc(Caller, $T1, $T2), arg1: T1, arg2: T2) -> ^Coroutine {
    BUNDLE :: struct {T1, T2}
    
    return create_raw(passer, BUNDLE{arg1, arg2})

    passer :: proc(c: Caller, args: rawptr) {
        f(c, expand_values((^BUNDLE)(args)^))
    }
}
create_3 :: proc($f: proc(Caller, $T1, $T2, $T3), arg1: T1, arg2: T2, arg3: T3) -> ^Coroutine {
    BUNDLE :: struct {T1, T2, T3}

    return create_raw(passer, BUNDLE{arg1, arg2, arg3})

    passer :: proc(c: Caller, args: rawptr) {
        f(c, expand_values((^BUNDLE)(args)^))
    }
}
create_4 :: proc($f: proc(Caller, $T1, $T2, $T3, $T4), arg1: T1, arg2: T2, arg3: T3, arg4: T4) -> ^Coroutine {
    BUNDLE :: struct {T1, T2, T3, T4}

    return create_raw(passer, BUNDLE{arg1, arg2, arg3, arg4})
    
    passer :: proc(c: Caller, args: rawptr) {
        f(c, expand_values((^BUNDLE)(args)^))
    }
}
