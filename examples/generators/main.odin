package gens

import "core:fmt"

import co "../../../coroutines/default"

enerates :: co.Gen1

repeater :: proc(g:enerates(int), n, times: int) {
    for _ in 1..=times {
        co.yield(g, n)
    }
    return
}

main :: proc() {
    gen := co.gen(repeater, 1, 2)

    for n in co.resume(&gen) {
        fmt.println("got", n)
    }
}