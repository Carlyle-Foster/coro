package counter

import "core:fmt"

import co "../../../coroutines/basic"

counter :: proc(cc: co.Caller, n: int) {
    for i in 1..=n {
        fmt.printfln("%d / %d", i, n)
        co.yield(cc)
    }
}

main :: proc() {
    co.start(
        proc(cc: co.Caller) {fmt.printfln("Hello from an odin Lambda (a non-capturing lambda, mind you)")},
    )

    co.alternate(co.start(counter, 5), co.start(counter, 10), co.start(counter, 1))
    
    fmt.printfln("(back in the main routine..) all done!")
}
