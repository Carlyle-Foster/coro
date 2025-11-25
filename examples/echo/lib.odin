package echo

import "core:fmt"
import "core:net"
import "core:strings"

// import "core:sys/linux"

import coroutine "../../../coroutines"

Socket :: net.Socket
TCP_Socket :: net.TCP_Socket
TCP_Recv_Error :: net.TCP_Recv_Error
TCP_Send_Error :: net.TCP_Send_Error

HOST :: "localhost"
PORT :: "8783"

quit := false
server_id := 0

main :: proc() {
    server_id = coroutine.id()

    endpoint, _, resolve_err := net.resolve(HOST + ":" + PORT)
    assert(resolve_err == nil)

    server, network_err := net.listen_tcp(endpoint)
    assert(network_err == nil)
    
    server_set_blocking_error := net.set_blocking(server, should_block=false)
    assert(server_set_blocking_error == nil)

    fmt.printfln("[%v] Server listening to %v:%v", coroutine.id(), HOST, PORT)
    
    for {
        coroutine.wait_until(Socket(server), .Readable)
        if quit {
            break
        }
        client, _, accept_err := net.accept_tcp(server)
        assert(accept_err == nil)

        client_set_blocking_error := net.set_blocking(client, should_block=false)
        assert(client_set_blocking_error == nil)

        coroutine.go(serve_client_coroutine, rawptr(uintptr(client)))
    }

    fmt.printfln("[%v] Server has been shutdown", coroutine.id())
}

serve_client_coroutine :: proc(args: rawptr) {
    serve_client(net.TCP_Socket(uintptr(args)))
}
serve_client :: proc(client: TCP_Socket) {
    fmt.printfln("[%v] Client connected!", coroutine.id())

    buf: [4096]byte
    defer {
        net.shutdown(client, .Both)
        net.close(client)
    }

    for {
        message := recieve_message(client, buf[:]) or_break

        switch strings.trim(message, " \t\r\n") {
        case "quit":
            fmt.printfln("[%v] Client requested to quit", coroutine.id())
            return
        case "shutdown":
            fmt.printfln("[%v] Client requested to shutdown the server", coroutine.id())
            quit = true
            coroutine.signal_other(server_id)
            return
        case:
            fmt.printfln("[%v] Client said %s", coroutine.id(), strings.trim_right_space(message))
        }

        bytes_echoed := echo_message(client, transmute([]byte)message) or_break
        fmt.printfln("[%v] echoed %d bytes to client", coroutine.id(), bytes_echoed)
    }

    fmt.printfln("[%v] Client disconnected", coroutine.id())
}

recieve_message :: proc(client: TCP_Socket, buf: []byte) -> (string, TCP_Recv_Error) {
    for {
        n, err := net.recv_tcp(client, buf)

        #partial switch err {
        case nil:
            if n == 0 && len(buf) != 0 {
                return "", .Connection_Closed
            }
            return string(buf[:n]), nil
        case .Interrupted:
            continue
        case .Would_Block:
            coroutine.wait_until(Socket(client), .Readable)
        case:
            fmt.printfln("[%v] Error when receiving from client: %v", coroutine.id(), err)
            return "", err
        }
    }
}

echo_message :: proc(client: TCP_Socket, message: []byte) -> (bytes_sent: int, err: TCP_Send_Error) {
    for bytes_sent < len(message) {
        n: int
        n, err = net.send_tcp(client, message)
        bytes_sent += n

        #partial switch err {
        case .None, .Interrupted:
            continue
        case .Would_Block:
            coroutine.wait_until(Socket(client), .Writeable)
        case:
            fmt.printfln("[%v] Error when sending to client: %v", coroutine.id(), err)
            return
        }
    }
    return
}