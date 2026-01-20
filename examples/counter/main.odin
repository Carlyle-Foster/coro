package counter

import "core:fmt"

import co "../../examples/runtime"

counter :: proc(cc: co.Caller, n: int) {
    for i in 1..=n {
        // #force_no_inline is just for ease of debugging, it's not needed to repro 
        #force_no_inline fmt.printfln("%d / %d", i, n)
        co.yield(cc) // this segfaults with `-o:speed`
    }
}

main :: proc() {
    c := co.start(counter, 1)

    co.resume(&c)

    assert(c == nil)
}
