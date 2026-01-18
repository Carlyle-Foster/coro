package coroutines

import "base:runtime"

import "core:slice"
import old_os "core:os"

import "core:sys/linux"

_allocate_stack :: proc(min_size: int) -> (Stack, runtime.Allocator_Error) {
    page_size := old_os.get_page_size()
    size := runtime.align_forward(min_size, page_size)

    stack, err := linux.mmap(0, uint(size), {.WRITE, .READ}, {.PRIVATE, .STACK, .ANONYMOUS, .GROWSDOWN})
    if err == .ENOMEM {
        return nil, .Out_Of_Memory
    }
    assert(err == .NONE)

    return Stack(slice.bytes_from_ptr(stack, size)), .None
}

_free_stack :: proc(stack: Stack) {
    if stack == nil {
        return
    }

    errno := linux.munmap(raw_data(stack), len(stack))
    
    assert(errno == .NONE)
}