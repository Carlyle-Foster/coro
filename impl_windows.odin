package coroutines

import "base:runtime"

import "core:slice"
import old_os "core:os"

import "core:sys/windows"

_allocate_stack :: proc(min_size: int) -> (Stack, runtime.Allocator_Error) {
    page_size := old_os.get_page_size()
    size := runtime.align_forward(min_size, page_size)

    stack := windows.VirtualAlloc(nil, uint(size), windows.MEM_COMMIT|windows.MEM_RESERVE, windows.PAGE_READWRITE)
    if stack == nil && windows.GetLastError() == windows.ERROR_OUTOFMEMORY {
        return nil, .Out_Of_Memory
    }
    assert(stack != nil)

    return Stack(slice.bytes_from_ptr(stack, size)), .None
}

_free_stack :: proc(stack: Stack) {
    if stack == nil {
        return
    }

    ok := windows.VirtualFree(raw_data(stack), 0, windows.MEM_RELEASE)
    
    assert(ok == windows.TRUE)
}