package coroutines

// import "core:fmt"

import "core:net"

import sl "selector"

foreign import assembly "coroutine.asm"
@(link_prefix="coroutine_", default_calling_convention="odin")
foreign assembly {
    start           :: proc(f: proc"odin"(arg: rawptr), arg: rawptr, rsp: rawptr) ---
    restore_context :: proc(rsp: rawptr) ---
}

@(private)
ensure_init :: #force_inline proc() {
    if len(contexts) == 0 {
        append(&contexts, Context{ active_id = 0 })
        append(&active, 0)

        selector_init_err := sl.init(&selector)
        assert(selector_init_err == nil)
    }
}

@(private, export)
__go :: proc(f: proc(rawptr), arg: rawptr, rsp: rawptr) {
    ensure_init()

    contexts[active[current]].rsp = rsp

    id := 0
    if len(dead) > 0 {
        id = pop(&dead)
    } else {
        append(&contexts, Context{})
        id = len(contexts)-1

        contexts[id].stack_base = allocate_stack(STACK_CAPACITY)
    }
    append(&active, id)
    current = len(active)-1

    rsp := ([^]rawptr)(contexts[id].stack_base)[STACK_CAPACITY/size_of(rawptr): ]

    start(f, arg, rsp)
}

@(private, export)
__yield :: proc(rsp: rawptr) {
    ensure_init()

    contexts[active[current]].rsp = rsp

    current += 1

    switch_context()
}

@(private, export)
__wait_until :: proc(socket: net.Socket, event: Event_Kind, rsp: rawptr) {
    // fd := fd
    
    ensure_init()

    self := active[current]
    contexts[self].rsp = rsp

    unordered_remove(&active, current)

    // errno: linux.Errno
    // fd, errno = linux.dup(fd)
    // assert(errno == nil)
    // errno = linux.epoll_ctl(
    //     epoll,
    //     .ADD,
    //     fd,
    //     &{ events={ .RDNORM if event == .Readable else .WRNORM, .ONESHOT },
    //     data={ u64=u64(self) } },
    // )
    // assert(errno == nil)

    interest: sl.Interest = .Readable if event == .Readable else .Writeable

    sl.register_socket(&selector, socket, { interest, .One_Shot }, self)

    switch_context()
}

@(private, export)
__finish_current :: proc() {
    assert(id() != 0)

    append(&dead, active[current])
    unordered_remove(&active, current)

    switch_context()
}

@(private)
switch_context :: proc() {
    timeout: Maybe(uint) =  nil if (len(active) == 0) else 0

    events: [128]sl.Event

    event_count, select_err := sl.select(&selector, events[:], timeout)
    assert(select_err == nil)

    for event in events[:event_count] {
        ctx_id := event.id
        append(&active, ctx_id)
        contexts[ctx_id].active_id = Active_Index(len(active)-1)
    }
    assert(len(active) > 0, "deadlock")

    current %= len(active) // in case we came here from __yield()

    restore_context(contexts[active[current]].rsp)
}
