package co_def

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