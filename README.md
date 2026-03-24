# coro: coroutines for odin

## Create! your coroutine
```odin
package my_coroutine

import co "path/to/coro"

import "core:fmt"

message := "this is.."

main :: proc() {
    c := co.create(proc(cc: co.Caller) {
        for _ in 0..<2 {
            fmt.println(message)
            co.pass(cc)
        }
    })
```
## Resume it
```odin
co.resume(&c)
```
```shell
This is..
```
## Resume it again!
```odin
message = "..a test"
co.resume(&c)
```
```shell
..a test
```
## A resounding success
```odin
// resume returns false when the coroutines done
assert(co.resume(&c) == false)

fmt.println("A resounding success")
```
```shell
A resounding success
```

## Now put it all together
```odin
package my_coroutine

import co "path/to/coro"

import "core:fmt"

message := "this is.."

main :: proc() {
    c := co.create(proc(cc: co.Caller) {
        for _ in 0..<2 {
            fmt.println(message)
            co.pass(cc)
        }
    })
    co.resume(&c)
    message = "..a test"
    co.resume(&c)

    // resume returns false when the coroutines done
    assert(co.resume(&c) == false)

    fmt.println("A resounding success")
}
```
```shell
This is..
..a test
A resounding success
```

### Installation
```shell
cd your-project
git clone https://github.com/Carlyle-Foster/coro.git
```
```odin
import co "coro"
```
