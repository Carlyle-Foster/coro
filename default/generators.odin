package co_def

import "base:intrinsics"

import co "../../coroutines"
_ :: co

gen :: create_gen

Gen1 :: struct(R1: typeid) {
    using c: ^Coroutine,
}
Gen2 :: struct(R1, R2: typeid) {
    using c: ^Coroutine,
}
// Gen3 :: struct(R1, R2, R3: typeid) {
//     using c: Coroutine,
// }
// Gen4 :: struct(R1, R2, R3, R4: typeid) {
//     using _: Coroutine,
// }

create_gen :: proc{
    create_gen_0,
    create_gen_1,
    create_gen_2,
    create_gen_3,
    create_gen_4,
}

create_gen_0 :: proc($f: proc($G)) -> G {
    waiter :: proc(c: Caller) {
        yield(c)
        f({ cast(^Coroutine)c })
    }
    return { start(waiter) }
}
create_gen_1 :: proc($f: proc($G, $T1), arg1: T1) -> G {
    waiter :: proc(c: Caller, arg1: T1) {
        yield(c)
        f(c, arg1)
    }
    return { start(waiter, arg1) }
}
create_gen_2 :: proc($f: proc($G, $T1, $T2), arg1: T1, arg2: T2) -> G {
    waiter :: proc(c: Caller, arg1: T1, arg2: T2) {
        yield(c)
        f({ cast(^Coroutine)c }, arg1, arg2)
    }
    return { start(waiter, arg1, arg2) }
}
create_gen_3 :: proc($f: proc($G, $T1, $T2, $T3), arg1: T1, arg2: T2, arg3: T3) -> G {
    waiter :: proc(c: Caller, arg1: T1, arg2: T2, arg3: T3) {
        yield(c)
        f({ cast(^Coroutine)c }, arg1, arg2, arg3)
    }
    return { start(waiter, arg1, arg2, arg3) }
}
create_gen_4 :: proc($f: proc($G, $T1, $T2, $T3, $T4), arg1: T1, arg2: T2, arg3: T3, arg4: T4) -> G {
    waiter :: proc(c: Caller, arg1: T1, arg2: T2, arg3: T3, arg4: T4) {
        yield(c)
        f({ cast(^Coroutine)c }, arg1, arg2, arg3, arg4)
    }
    return { start(waiter, arg1, arg2, arg3, arg4) }
}

yield_gen_1 :: proc(g: Gen1($R1), val1: R1) {
    storage := cast(^R1) raw_data(g.stack[STACK_CAPACITY:])
    storage^ = val1

    co.yield(Caller(g.c))
}

yield_gen_2 :: proc(g: Gen2($R1, $R2), val1: R1, val2: R2) {
    Vals :: struct {
        val1: R1,
        val2: R2,
    }
    storage := cast(^Vals) raw_data(g.stack[STACK_CAPACITY:])
    storage^ = { val1, val2 }

    co.yield(Caller(g.c))
}

resume_gen_1 :: proc(g: ^Gen1($R1)) -> (R1, bool) {
    if co.resume(g) {
        storage := cast(^R1) raw_data(g.stack[STACK_CAPACITY:])

        return storage^, true
    }
    return {}, false
}

resume_gen_2 :: proc(g: Gen2($R1, $R2)) -> (R1, R2, bool) {
    Vals :: struct {
        val1: R1,
        val2: R2,
    }
    if co.resume(g._coroutine) {
        storage := cast(^Vals) raw_data(g.stack[STACK_CAPACITY:])

        return expand_values(storage^), true
    }
    return {}, {}, false
}