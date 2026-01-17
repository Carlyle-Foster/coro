package coroutines

import "core:slice"

import "core:sys/linux"

_allocate_stack :: proc(size: int) -> Stack {
    ensure(size % 16 == 0)

    stack, err := linux.mmap(0, uint(size), {.WRITE, .READ}, {.PRIVATE, .STACK, .ANONYMOUS, .GROWSDOWN})

    assert(err == nil)

    return Stack(slice.bytes_from_ptr(stack, size))
}

_free_stack :: proc(stack: Stack) {
    if stack == nil {
        return
    }
    
    errno := linux.munmap(raw_data(stack), len(stack))
    
    assert(errno == nil)
}