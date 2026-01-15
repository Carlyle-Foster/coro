package coroutines

import "core:sys/linux"

allocate_stack :: proc(size: int) -> rawptr {
    stack, err := linux.mmap(0, uint(size), {.WRITE, .READ}, {.PRIVATE, .STACK, .ANONYMOUS, .GROWSDOWN})
    assert(err == nil)
    return stack
}

free_stack :: proc(stack: rawptr, size: int) {
    if stack == nil {
        return
    }
    
    errno := linux.munmap(stack, uint(size))
    
    assert(errno == nil)
}