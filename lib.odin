package co_def

import "base:runtime"
import "base:intrinsics"

import "core:sync"

_ :: sync
_ :: runtime
_ :: intrinsics

import prim "primitives"

THREAD_SAFE :: #config(THREAD_SAFE, true)

Coroutine   :: prim.Coroutine
Caller      :: prim.Caller
Stack       :: prim.Stack

Routine     :: ^Coroutine // if u want to be cute about it
routine     :: create

COROUTINE_LOCAL_STORAGE :: 4*1024
#assert(COROUTINE_LOCAL_STORAGE % 16 == 0)
GENERATOR_STORAGE_OFFFSET :: 3*1024

STACK_CAPACITY  :: 64 * 1024 - COROUTINE_LOCAL_STORAGE

free_stacks: [dynamic]Stack
free_stacks_mutex: sync.Mutex

create :: proc{
    create_0,
    create_1,
    create_2,
    create_3,
    create_4,
}

resume:
    proc(coroutine: ^^Coroutine)-> (unfinished: bool) : prim.resume

pass:
    proc(caller: Caller) : prim.pass

unsafe_resume:
    proc(coroutine: ^Coroutine) -> (unfinished: bool) : prim.unsafe_resume

chain :: proc(c: Caller, coroutines: ..^Coroutine) {
    for &coroutine in coroutines {
        if coroutine == nil {
            continue
        }
        for prim.resume(&coroutine) {
            prim.pass(c)
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
        if coroutine != nil && prim.unsafe_resume(coroutine) {
            ok = true
        } else {
            coroutine = nil
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

create_raw :: proc(f: proc(Caller, rawptr), args: $Args) -> ^Coroutine {
    ARG_STORAGE :: GENERATOR_STORAGE_OFFFSET
    #assert(size_of(Args) <= ARG_STORAGE)

    stack: Stack
    {
        maybe_guard_mutex()
        if len(free_stacks) > 0 {
            stack = pop(&free_stacks)
        }
    }
    if stack == nil {
        err: runtime.Allocator_Error
        stack, err = prim.allocate_stack(STACK_CAPACITY + COROUTINE_LOCAL_STORAGE)

        ensure(err == .None)
    }
    storage := cast(^Args)raw_data(stack[STACK_CAPACITY:])
    storage^ = args

    return prim.create(stack[:STACK_CAPACITY], f, storage, on_finish, nil)

    on_finish :: proc(coroutine: ^Coroutine, _arg: rawptr) {
        err: runtime.Allocator_Error
        { 
            maybe_guard_mutex()
            _, err = append(&free_stacks, coroutine.stack)
        }
        if err != .None {
            prim.free_stack(coroutine.stack)
        }
    }
}

when THREAD_SAFE {
    @(deferred_out=sync.mutex_unlock)
    maybe_guard_mutex :: proc() -> ^sync.Mutex {
        sync.mutex_lock(&free_stacks_mutex)
        return &free_stacks_mutex
    }
} else {
    maybe_guard_mutex :: proc() { /* empty*/ }
}
