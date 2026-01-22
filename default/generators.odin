package co_def

import co "../../coroutines"
_ :: co

GENERATOR_STORAGE_SIZE :: COROUTINE_LOCAL_STORAGE - GENERATOR_STORAGE_OFFFSET

gen :: create_gen

create_gen :: proc {
    create_gen_0,
    create_gen_1,
    create_gen_2,
    create_gen_3,
    create_gen_4,
}

Gen1 :: struct(R1: typeid) {
    using c: ^Coroutine,
}
Gen2 :: struct(R1, R2: typeid) {
    using c: ^Coroutine,
}
Gen3 :: struct(R1, R2, R3: typeid) {
    using c: ^Coroutine,
}
Gen4 :: struct(R1, R2, R3, R4: typeid) {
    using c: ^Coroutine,
}

create_gen_0 :: proc($f: proc($G)) -> G {
    wrapper :: proc(c: Caller) {
        f({ cast(^Coroutine)c })
    }
    return { create(wrapper) }
}
create_gen_1 :: proc($f: proc($G, $T1), arg1: T1) -> G {
    wrapper :: proc(c: Caller, arg1: T1) {
        f({ cast(^Coroutine)c }, arg1)
    }
    return { create(wrapper, arg1) }
}
create_gen_2 :: proc($f: proc($G, $T1, $T2), arg1: T1, arg2: T2) -> G {
    wrapper :: proc(c: Caller, arg1: T1, arg2: T2) {
        f({ cast(^Coroutine)c }, arg1, arg2)
    }
    return { create(wrapper, arg1, arg2) }
}
create_gen_3 :: proc($f: proc($G, $T1, $T2, $T3), arg1: T1, arg2: T2, arg3: T3) -> G {
    wrapper :: proc(c: Caller, arg1: T1, arg2: T2, arg3: T3) {
        f({ cast(^Coroutine)c }, arg1, arg2, arg3)
    }
    return { create(wrapper, arg1, arg2, arg3) }
}
create_gen_4 :: proc($f: proc($G, $T1, $T2, $T3, $T4), arg1: T1, arg2: T2, arg3: T3, arg4: T4) -> G {
    wrapper :: proc(c: Caller, arg1: T1, arg2: T2, arg3: T3, arg4: R4) {
        f({ cast(^Coroutine)c }, arg1, arg2, arg3, arg4)
    }
    return { create(wrapper, arg1, arg2, arg3, arg4) }
}

yield_gen_1 :: proc(g: Gen1($R1), val1: R1) {
    storage := cast(^R1) raw_data(g.stack[STACK_CAPACITY:])[GENERATOR_STORAGE_OFFFSET:]
    storage^ = val1

    co.yield(Caller(g.c))
}
yield_gen_2 :: proc(g: Gen2($R1, $R2), val1: R1, val2: R2) {
    Vals :: struct {
        val1: R1,
        val2: R2,
    }
    storage := cast(^Vals) raw_data(g.stack[STACK_CAPACITY:])[GENERATOR_STORAGE_OFFFSET:]
    storage^ = { val1, val2 }

    co.yield(Caller(g.c))
}
yield_gen_3 :: proc(g: Gen3($R1, $R2, $R3), val1: R1, val2: R2, val3: R3) {
    Vals :: struct {
        val1: R1,
        val2: R2,
        val3: R3,
    }
    storage := cast(^Vals) raw_data(g.stack[STACK_CAPACITY:])[GENERATOR_STORAGE_OFFFSET:]
    storage^ = { val1, val2, val3 }

    co.yield(Caller(g.c))
}
yield_gen_4 :: proc(g: Gen4($R1, $R2, $R3, $R4), val1: R1, val2: R2, val3: R3, val4: R4) {
    Vals :: struct {
        val1: R1,
        val2: R2,
        val3: R3,
        val4: R4,
    }
    storage := cast(^Vals) raw_data(g.stack[STACK_CAPACITY:])[GENERATOR_STORAGE_OFFFSET:]
    storage^ = { val1, val2, val3, val4 }

    co.yield(Caller(g.c))
}

resume_gen_1 :: proc(g: ^Gen1($R1)) -> (R1, bool) {
    #assert(size_of(R1) <= GENERATOR_STORAGE_SIZE)
    if co.resume(g) {
        storage := cast(^R1) raw_data(g.stack[STACK_CAPACITY:])[GENERATOR_STORAGE_OFFFSET:]

        return storage^, true
    }
    return {}, false
}
resume_gen_2 :: proc(g: ^Gen2($R1, $R2)) -> (R1, R2, bool) {
    Vals :: struct {
        val1: R1,
        val2: R2,
    }
    #assert(size_of(Vals) <= GENERATOR_STORAGE_SIZE)
    if co.resume(g) {
        storage := cast(^Vals) raw_data(g.stack[STACK_CAPACITY:])[GENERATOR_STORAGE_OFFFSET:]

        return expand_values(storage^), true
    }
    return {}, {}, false
}
resume_gen_3 :: proc(g: ^Gen3($R1, $R2, $R3)) -> (R1, R2, R3, bool) {
    Vals :: struct {
        val1: R1,
        val2: R2,
        val3: R3,
    }
    #assert(size_of(Vals) <= GENERATOR_STORAGE_SIZE)
    if co.resume(g) {
        storage := cast(^Vals) raw_data(g.stack[STACK_CAPACITY:])[GENERATOR_STORAGE_OFFFSET:]

        return expand_values(storage^), true
    }
    return {}, {}, {}, false
}
resume_gen_4 :: proc(g: ^Gen4($R1, $R2, $R3, $R4)) -> (R1, R2, R3, R4, bool) {
    Vals :: struct {
        val1: R1,
        val2: R2,
        val3: R3,
        val4: R4,
    }
    #assert(size_of(Vals) <= GENERATOR_STORAGE_SIZE)
    if co.resume(g) {
        storage := cast(^Vals) raw_data(g.stack[STACK_CAPACITY:])[GENERATOR_STORAGE_OFFFSET:]

        return expand_values(storage^), true
    }
    return {}, {}, {}, {}, false
}
