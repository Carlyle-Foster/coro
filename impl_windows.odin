package coroutines

import "base:runtime"

import "core:slice"
import old_os "core:os"

import win "core:sys/windows"

_allocate_stack :: proc(min_size: int) -> (Stack, runtime.Allocator_Error) {
    page_size := old_os.get_page_size()
    size      := runtime.align_forward(min_size, page_size) + page_size

    reserved := win.VirtualAlloc(nil, uint(size), win.MEM_RESERVE|win.MEM_COMMIT, win.PAGE_READWRITE)
    if reserved == nil {
        return nil, .Out_Of_Memory
    }

    // setup the guard page
    _old_protection: u32
    ok := win.VirtualProtect(reserved, uint(page_size), win.PAGE_NOACCESS, &_old_protection)
    assert(ok == win.TRUE)

    stack := Stack(slice.bytes_from_ptr(reserved, size))
    // skip the guard page
    stack = stack[page_size:]

    return stack, .None
}

_free_stack :: proc(stack: Stack) {
    if stack == nil {
        return
    }

    page_size := old_os.get_page_size()
    base := rawptr(uintptr(raw_data(stack)) - uintptr(page_size))
    ok := win.VirtualFree(base, 0, win.MEM_RELEASE)
    
    assert(ok == win.TRUE)
}