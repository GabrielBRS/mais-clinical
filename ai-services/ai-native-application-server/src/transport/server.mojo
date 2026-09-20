from std.collections import InlineArray
from std.ffi import c_int, c_short, c_size_t, external_call
from std.memory import Pointer

from application.application import Application
from domain.errors import OrchestratorError
from domain.status import StatusCode
from infrastructure.ipc.unix_socket import UnixListener
from infrastructure.net.tcp import TcpListener
from transport.http.server import HTTPServer
from transport.ipc.server import IPCServer


comptime POLLIN = 1


@fieldwise_init
struct PollFd(Copyable):
    var fd: c_int
    var events: c_short
    var revents: c_short


struct Service:
    """Single-process HTTP + ACE1 event loop."""

    var http: HTTPServer
    var ipc: IPCServer

    def __init__(
        out self, var http: HTTPServer, var ipc: IPCServer
    ):
        self.http = http^
        self.ipc = ipc^

    def serve(mut self, mut app: Application) raises:
        var tcp = TcpListener(self.http.host, Int(self.http.port))
        var unix = UnixListener(self.ipc.path)
        var fds = InlineArray[PollFd, 2](
            fill=PollFd(c_int(-1), c_short(POLLIN), c_short(0))
        )
        fds[0].fd = c_int(tcp.fd)
        fds[1].fd = c_int(unix.fd)
        print("http listening", self.http.host, Int(self.http.port))
        print("ipc listening", self.ipc.path)
        while True:
            fds[0].revents = c_short(0)
            fds[1].revents = c_short(0)
            var ready = Int(
                external_call["poll", c_int](
                    Pointer(to=fds[0]), c_size_t(2), c_int(-1)
                )
            )
            if ready < 0:
                raise OrchestratorError(
                    StatusCode.internal, "poll dos transports falhou"
                )
            if (Int(fds[0].revents) & POLLIN) != 0:
                self.http.accept_once(app, tcp)
            if (Int(fds[1].revents) & POLLIN) != 0:
                self.ipc.accept_once(app, unix)
