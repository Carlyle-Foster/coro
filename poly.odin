package coroutines

create :: proc{
    create_1,
    create_2,
    create_3,
    create_4,
}

create_1 :: proc($f: proc(Caller, $T1), arg1: T1, allocator := context.allocator) -> (^Coroutine, Allocator_Error) #optional_allocator_error {
    Args :: struct {
        arg1: T1,
    }
    wrapper :: proc(caller: Caller, arg: rawptr) {
        using args := (^Args)(arg)
        f(caller, arg1)
    }
    args := new(Args, allocator)
    args.arg1 = arg1

    coroutine, allocation_err := create_raw(wrapper, args, allocator)
    if allocation_err != nil {
        return nil, allocation_err
    }
    coroutine.args = args

    return coroutine, nil
}
create_2 :: proc($f: proc(Caller, $T1, $T2), arg1: T1, arg2: T2, allocator := context.allocator) -> (^Coroutine, Allocator_Error) #optional_allocator_error {
    Args :: struct {
        arg1: T1,
        arg2: T2,
    }
    wrapper :: proc(caller: Caller, arg: rawptr) {
        using args := (^Args)(arg)
        f(caller, arg1, arg2)
    }
    args := new(Args, allocator)
    args.arg1 = arg1
    args.arg2 = arg2

    coroutine, allocation_err := create_raw(wrapper, args, allocator)
    if allocation_err != nil {
        return nil, allocation_err
    }
    coroutine.args = args

    return coroutine, nil
}
create_3 :: proc($f: proc(Caller, $T1, $T2, $T3), arg1: T1, arg2: T2, arg3: T3, allocator := context.allocator) -> (^Coroutine, Allocator_Error) #optional_allocator_error {
    Args :: struct {
        arg1: T1,
        arg2: T2,
        arg3: T3,
    }
    wrapper :: proc(caller: Caller, arg: rawptr) {
        using args := (^Args)(arg)
        f(caller, arg1, arg2, arg3)
    }
    args := new(Args, allocator)
    args.arg1 = arg1
    args.arg2 = arg2
    args.arg3 = arg3

    coroutine, allocation_err := create_raw(wrapper, args, allocator)
    if allocation_err != nil {
        return nil, allocation_err
    }
    coroutine.args = args

    return coroutine, nil
}
create_4 :: proc($f: proc(Caller, $T1, $T2, $T3, $T4), arg1: T1, arg2: T2, arg3: T3, arg4: T4, allocator := context.allocator) -> (^Coroutine, Allocator_Error) #optional_allocator_error {
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
    args := new(Args, allocator)
    args.arg1 = arg1
    args.arg2 = arg2
    args.arg3 = arg3
    args.arg4 = arg4

    coroutine, allocation_err := create_raw(wrapper, args, allocator)
    if allocation_err != nil {
        return nil, allocation_err
    }
    coroutine.args = args

    return coroutine, nil
}