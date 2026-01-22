package simple

import "core:fmt"

import co "../../../coroutines/default"

main :: proc() {
    co.start(proc(cc: co.Caller) {fmt.printfln("i hope this coroutine finds you well..")})
    
    fmt.println("(back in the main routine) ..best regards")
}

