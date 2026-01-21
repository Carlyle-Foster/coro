package co_def
THREAD_SAFE :: #config(THREAD_SAFE, true)

import "base:runtime"

import "core:sync"
_ :: sync

import co "../../coroutines"

Coroutine   :: co.Coroutine
Caller      :: co.Caller
Stack       :: co.Stack

STACK_CAPACITY  :: 64 * 1024

free_stacks: [dynamic]Stack
when THREAD_SAFE {
    free_stacks_mutex: sync.Mutex

    @(deferred_out=sync.mutex_unlock)
    maybe_guard_mutex :: proc() -> ^sync.Mutex {
        sync.mutex_lock(&free_stacks_mutex)
        return &free_stacks_mutex
    }
} else {
    maybe_guard_mutex :: proc() { /* empty*/ }
}

start_raw :: proc(f: proc(Caller, rawptr), arg: rawptr) -> ^Coroutine {
    stack: Stack
    {
        maybe_guard_mutex()
        if len(free_stacks) > 0 {
            stack = pop(&free_stacks)
        }
    }
    if stack == nil {
        err: runtime.Allocator_Error
        stack, err = co.allocate_stack(STACK_CAPACITY)

        ensure(err == .None)
    }

    return co.start(stack, f, arg, on_finish, nil)

    on_finish :: proc(coroutine: ^Coroutine, _arg: rawptr) {
        err: runtime.Allocator_Error
        { 
            maybe_guard_mutex()
            _, err = append(&free_stacks, coroutine.stack)
        }
        if err != .None {
            co.free_stack(coroutine.stack)
        }
    }
}

resume  :: co.resume

yield   :: co.yield

parallel :: proc(c: Caller, coroutines: ..^Coroutine) {
    coroutines := coroutines

    for parallel_iter(&coroutines) {
        yield(c)
    }
}

parallel_iter :: proc(coroutines: ^[]^ Coroutine) -> (ok: bool) {
    for &coroutine in coroutines {
        if coroutine != nil && co.unsafe_resume(coroutine) {
            ok = true
        } else {
            coroutine = nil
        }
    }
    return
}

start :: proc{
    start_0,
    start_1,
    start_2,
    start_3,
    start_4,
}

create :: proc{
    create_0,
    create_1,
    create_2,
    create_3,
    create_4,
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
    passer :: proc(c: Caller, args: ^$A) {
        f(c, expand_values(args^))
    }
    args := compress_values(arg1, arg2)
    return start_raw(auto_cast intrinsics.procedure_of(passer(nil, &args)), &args)
}
start_3 :: proc($f: proc(Caller, $T1, $T2, $T3), arg1: T1, arg2: T2, arg3: T3) -> ^Coroutine {
    passer :: proc(c: Caller, args: ^$A) {
        f(c, expand_values(args^))
    }
    args := compress_values(arg1, arg2, arg3)
    return start_raw(auto_cast intrinsics.procedure_of(passer(nil, &args)), &args)
}
start_4 :: proc($f: proc(Caller, $T1, $T2, $T3, $T4), arg1: T1, arg2: T2, arg3: T3, arg4: T4) -> ^Coroutine {
    passer :: proc(c: Caller, args: ^$A) {
        f(c, expand_values(args^))
    }
    args := compress_values(arg1, arg2, arg3, arg4)
    return start_raw(auto_cast intrinsics.procedure_of(passer(nil, &args)), &args)
}

create_0 :: proc($f: proc(Caller)) -> ^Coroutine {
    waiter :: proc(c: Caller) {
        yield(c)
        f(c)
    }
    return start(waiter)
}
create_1 :: proc($f: proc(Caller, $T1), arg1: T1) -> ^Coroutine {
    waiter :: proc(c: Caller, arg1: T1) {
        yield(c)
        f(c, arg1)
    }
    return start(waiter, arg1)
}
create_2 :: proc($f: proc(Caller, $T1, $T2), arg1: T1, arg2: T2) -> ^Coroutine {
    waiter :: proc(c: Caller, arg1: T1, arg2: T2) {
        yield(c)
        f(c, arg1, arg2)
    }
    return start(waiter, arg1, arg2)
}
create_3 :: proc($f: proc(Caller, $T1, $T2, $T3), arg1: T1, arg2: T2, arg3: T3) -> ^Coroutine {
    waiter :: proc(c: Caller, arg1: T1, arg2: T2, arg3: T3) {
        yield(c)
        f(c, arg1, arg2, arg3)
    }
    return start(waiter, arg1, arg2, arg3)
}
create_4 :: proc($f: proc(Caller, $T1, $T2, $T3, $T4), arg1: T1, arg2: T2, arg3: T3, arg4: T4) -> ^Coroutine {
    waiter :: proc(c: Caller, arg1: T1, arg2: T2, arg3: T3, arg4: T4) {
        yield(c)
        f(c, arg1, arg2, arg3, arg4)
    }
    return start(waiter, arg1, arg2, arg3, arg4)
}
