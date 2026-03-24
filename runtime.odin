package co_def

import "base:runtime"

import "core:sync"

import prim "primitives"

_ :: runtime

COROUTINE_LOCAL_STORAGE :: 4*1024
#assert(COROUTINE_LOCAL_STORAGE % 16 == 0)
GENERATOR_STORAGE_OFFFSET :: 3*1024

STACK_CAPACITY  :: 64 * 1024 - COROUTINE_LOCAL_STORAGE

free_stacks: [dynamic]prim.Stack
free_stacks_mutex: sync.Mutex

create_raw :: proc(f: proc(Caller, rawptr), args: $Args) -> ^Coroutine {
    ARG_STORAGE :: GENERATOR_STORAGE_OFFFSET
    #assert(size_of(Args) <= ARG_STORAGE)

    stack: prim.Stack
    {
        when THREAD_SAFE { sync.mutex_guard(&free_stacks_mutex) }
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
            when THREAD_SAFE { sync.mutex_guard(&free_stacks_mutex) }
            _, err = append(&free_stacks, coroutine.stack)
        }
        if err != .None {
            prim.free_stack(coroutine.stack)
        }
    }
}