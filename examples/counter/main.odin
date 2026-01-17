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
    hello := co.create(
        proc(cc: co.Caller) {fmt.printfln("Hello from an odin Lambda (a non-capturing lambda, mind you)")},
    )
    co.resume(hello)

    assert(hello.finished)

    counters := []^co.Coroutine{
        co.create(counter, 5),
        co.create(counter, 10),
        co.create(counter, 1),
    }

    co.alternate(..counters)
    
    fmt.printfln("(back in the main routine..) all done!")
}
