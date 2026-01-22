// a simple runtime that just allocates a new stack for each coroutine
// and frees it on completion, no "pooling" here nosiree
package ex_rt

import "base:intrinsics"

import co "../../../coroutines"

Coroutine   :: co.Coroutine
Caller      :: co.Caller

STACK_CAPACITY  :: 64 * 1024

create_raw :: proc(f: proc(Caller, rawptr), arg: rawptr) -> ^Coroutine {
    stack := co.allocate_stack(STACK_CAPACITY)
    
    return co.create(stack, f, arg, on_finish, nil)

    on_finish :: proc(coroutine: ^Coroutine, _arg: rawptr) {
        co.free_stack(coroutine.stack)
    }
}

resume  :: co.resume

pass    :: co.pass