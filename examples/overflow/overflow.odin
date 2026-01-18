// this program is expected to crash
package overflow

import "core:fmt"

import co "../../../coroutines/basic"

// the guard page allocated by `allocate_stack()` will catch this stack overflow
// the program will then crash, preventing memory corruption
overflow_stack :: proc(cc: co.Caller, i: int) {
    fmt.printfln("%d / INFINITY", i)
    overflow_stack(cc, i+1)
}

main :: proc() {
    co.start(overflow_stack, 0)
    unreachable() // the stack should have overflown by this point
}