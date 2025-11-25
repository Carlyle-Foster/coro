package selector

import "core:net"
import "core:log"

import "core:sys/linux"

@(private)
_Selector :: struct {
    epoll: linux.Fd,
}

@(private)
_init :: proc(s: ^Selector) -> Error {
    errno: linux.Errno
    s.epoll, errno = linux.epoll_create1({})
    return errno_2_error(errno)
}

@(private)
_register_socket :: proc(s: ^Selector, socket: net.Socket, interests: bit_set[Interest], id: int) -> Error {
    fd, errno := linux.dup(linux.Fd(socket))
    if errno != .NONE {
        return errno_2_error(errno)
    }

    event := linux.EPoll_Event {
        events = { .ET },
        data = { u64=u64(id) },
    }
    for i in interests {
        switch i {
            case .Readable: event.events += { .IN }
            case .Writeable: event.events  += { .OUT }
            case .One_Shot: event.events += { .ONESHOT }
        }
    }
    errno = linux.epoll_ctl(s.epoll, .ADD, fd, &event)
    
    return errno_2_error(errno)
}

@(private)
_deregister_socket :: proc(s: ^Selector, socket: net.Socket) -> Error {
    errno := linux.epoll_ctl(s.epoll, .DEL, linux.Fd(socket), nil)
    
    return errno_2_error(errno)
}

@(private)
_select :: proc(s: ^Selector, event_storage: []Event, timeout_nanosecs: Maybe(uint)) -> (event_count: int, err: Error) {
    _events: [128]linux.EPoll_Event
    time_spec: linux.Time_Spec
    timeout_arg: ^linux.Time_Spec
    
    if timeout_nanosecs != nil {
        time_spec.time_nsec = timeout_nanosecs.?
        timeout_arg = &time_spec
    }
    
    fd_count, errno := linux.epoll_pwait2(s.epoll, raw_data(_events[:]), len(_events), timeout_arg, nil)

    events_caught := clamp(int(fd_count), 0, len(event_storage))
    for i in 0..<events_caught {
        event_storage[i] = epoll_event_2_event(_events[i])
    }
    
    event_count = int(events_caught)
    err = errno_2_error(errno)
    return
}

@(private)
_destroy :: proc(s: ^Selector) -> Error {
    errno := linux.close(s.epoll)
    return errno_2_error(errno)
}

@(private)
epoll_event_2_event :: proc(epoll_event: linux.EPoll_Event) -> Event {
    event: Event
    if .IN in epoll_event.events {
        event.interests += { .Readable }
    }
    if .OUT in epoll_event.events {
        event.interests += { .Writeable }
    }
    event.id = int(epoll_event.data.u64)

    return event
}

@(private)
errno_2_error :: proc(errno: linux.Errno, loc := #caller_location) -> Error {
    #partial switch errno {
    case .NONE: return .None

    case .EINVAL: return .Invalid_Argument
    case .ENOMEM: return .Out_Of_Memory

    case .EMFILE: return .Too_many_File_Descriptors_In_Process
    case .ENFILE: return .Too_many_File_Descriptors_In_System
    case:
        log.warn("unimplemented Error: ", errno)
        return .Miscellaneous
    }
}