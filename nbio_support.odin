package co_def

import "core:nbio"

accept :: proc(socket: nbio.TCP_Socket, $cb: proc(Caller, nbio.TCP_Socket, nbio.Endpoint), $on_err: proc(Caller, nbio.Error)) {
    nbio.accept(socket, on_accept)

    on_accept :: proc(op: ^nbio.Operation) {
        args := &op.accept

        if args.err == .None {
            c := create(cb, args.client, args.client_endpoint)
            unsafe_resume(c)
        } else {
            c := create(on_err, args.err)
            unsafe_resume(c)
        }
        nbio.accept(args.socket, on_accept)
    }
}

write :: proc(c: Caller, handle: nbio.Handle, offset: int, buf: []byte) -> (writ: int, err: nbio.FS_Error) {
    op := nbio.write(handle, offset, buf, resumer)
    op.user_data[0] = c
    pass(c)
    return op.write.written, op.write.err
}

read :: proc(c: Caller, handle: nbio.Handle, offset: int, buf: []byte) -> (read: int, err: nbio.FS_Error) {
    op := nbio.read(handle, offset, buf, resumer)
    op.user_data[0] = c
    pass(c)
    return op.read.read, op.read.err
}

send :: proc(c: Caller, socket: nbio.Any_Socket, bufs: [][]byte) -> (sent: int, err: nbio.Send_Error) {
    op := nbio.send(socket, bufs, resumer)
    op.user_data[0] = c
    pass(c)
    return op.send.sent, op.send.err
}

recv :: proc(c: Caller, socket: nbio.Any_Socket, bufs: [][]byte) -> (received: int, err: nbio.Recv_Error) {
    op := nbio.recv(socket, bufs, resumer)
    op.user_data[0] = c
    pass(c)
    return op.recv.received, op.recv.err
}

@(private="file")
resumer :: proc(op: ^nbio.Operation) {
    unsafe_resume(cast(^Coroutine)op.user_data[0])
}
