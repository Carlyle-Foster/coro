package selector

import "core:net"

Selector :: _Selector

Error :: enum {
    None,
    Invalid_Argument,
    Too_many_File_Descriptors_In_Process,
    Too_many_File_Descriptors_In_System,
    Out_Of_Memory,
    Miscellaneous,
}

Interest :: enum {
    Readable,
    Writeable,
    One_Shot,
}

Event :: struct {
    interests: bit_set[Interest],
    id: int,
}

init :: proc(s: ^Selector) -> Error {
    return _init(s)
}

register_socket :: proc(s: ^Selector, socket: net.Socket, interests: bit_set[Interest], id: int) -> Error {
    return _register_socket(s, socket, interests, id)
}

deregister_socket :: proc(s: ^Selector, socket: net.Socket) -> Error {
    return _deregister_socket(s, socket)
}

select :: proc(s: ^Selector, event_storage: []Event, timeout_nanosecs: Maybe(uint)) -> (event_count: int, err: Error) {
    return _select(s, event_storage, timeout_nanosecs)
}

destroy :: proc(s: ^Selector) -> Error {
    return _destroy(s)
}