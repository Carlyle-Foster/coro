package counter

import "core:fmt"

import co "../../../coroutines"

counter :: proc(cc: co.Caller, arg: rawptr) {
    n := int(uintptr(arg))
    for i in 1..=n {
        fmt.printfln("%d / %d", i, n)
        co.yield(cc)
    }
}

main :: proc() {
    hello := co.create(
        proc(cc: co.Caller, arg: rawptr) {
            fmt.printfln("Hello from an odin Lambda (a non-capturing lambda, mind you)")
        },
        nil,
    )
    co.resume(hello)

    // assert(hello.finished)

    counters := []^co.Coroutine{
        co.create(counter, rawptr(uintptr(5))),
        co.create(counter, rawptr(uintptr(10))),
        co.create(counter, rawptr(uintptr(1))),
    }

    co.alternate(..counters)
    
    fmt.printfln("(back in the main routine..) all done!")
}
