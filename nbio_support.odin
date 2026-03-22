#+feature using-stmt
package co_def

import "core:nbio"

accept :: proc(socket: nbio.TCP_Socket, $cb: proc(Caller, nbio.TCP_Socket, nbio.Endpoint), $on_err: proc(Caller, nbio.Error)) {
    nbio.accept(socket, on_accept)

    on_accept :: proc(op: ^nbio.Operation) {
        using op.accept
        
        if err == .None {
            c := create(cb, client, client_endpoint)
            unsafe_resume(c)
        } else {
            c := create(on_err, err)
            unsafe_resume(c)
        }
        nbio.accept(socket, on_accept)
    }
}

write :: proc(c: Caller, handle: nbio.Handle, offset: int, buf: []byte) -> (writ: int, err: nbio.FS_Error) {
    op := nbio.write_poly(handle, offset, buf, c, resumer)
    pass(c)
    return op.write.written, op.write.err
}

read :: proc(c: Caller, handle: nbio.Handle, offset: int, buf: []byte) -> (read: int, err: nbio.FS_Error) {
    op := nbio.read_poly(handle, offset, buf, c, resumer)
    pass(c)
    return op.read.read, op.read.err
}

send :: proc(c: Caller, socket: nbio.Any_Socket, bufs: [][]byte) -> (sent: int, err: nbio.Send_Error) {
    op := nbio.send_poly(socket, bufs, c, resumer)
    pass(c)
    return op.send.sent, op.send.err
}

recv :: proc(c: Caller, socket: nbio.Any_Socket, bufs: [][]byte) -> (received: int, err: nbio.Recv_Error) {
    op := nbio.recv_poly(socket, bufs, c, resumer)
    pass(c)
    return op.recv.received, op.recv.err
}

@(private="file")
resumer :: proc(op: ^nbio.Operation, c: Caller) {
    unsafe_resume(cast(^Coroutine)c)
}
