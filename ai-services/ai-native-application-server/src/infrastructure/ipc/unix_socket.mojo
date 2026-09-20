from std.collections import InlineArray
from std.ffi import c_int, c_size_t, c_ssize_t, external_call
from std.memory import Pointer

from domain.errors import OrchestratorError
from domain.status import StatusCode
from infrastructure.ipc.protocol import (
    HEADER_SIZE,
    Frame,
    decode_header,
    encode_frame,
)


comptime AF_UNIX = 1
comptime SOCK_STREAM = 1
comptime SHUT_RDWR = 2
comptime SUN_PATH_CAP = 108
comptime SOCKADDR_UN_LEN = 110
comptime MAX_PAYLOAD_SIZE = 16 * 1024 * 1024


struct SockAddrUn(Copyable):
    var family: UInt16
    var path: InlineArray[UInt8, SUN_PATH_CAP]

    def __init__(out self, path: String) raises:
        var raw = path.as_bytes()
        if len(raw) == 0 or len(raw) >= SUN_PATH_CAP:
            raise OrchestratorError(
                StatusCode.invalid_argument, "caminho de socket Unix invalido"
            )
        self.family = UInt16(AF_UNIX)
        self.path = InlineArray[UInt8, SUN_PATH_CAP](fill=0)
        var i = 0
        while i < len(raw):
            self.path[i] = UInt8(Int(raw[i]))
            i += 1


struct UnixListener:
    """Socket Unix POSIX nativo; não carrega outro runtime."""

    var fd: Int
    var path: String

    def __init__(out self, path: String) raises:
        var fd = Int(
            external_call["socket", c_int](
                c_int(AF_UNIX), c_int(SOCK_STREAM), c_int(0)
            )
        )
        if fd < 0:
            raise OrchestratorError(
                StatusCode.unavailable, "falha ao criar socket Unix"
            )
        var name = path.copy()
        _ = external_call["unlink", c_int](name.as_c_string_slice())
        var addr = SockAddrUn(path)
        var rc = Int(
            external_call["bind", c_int](
                c_int(fd),
                Pointer(to=addr).unsafe_bitcast[UInt8](),
                c_int(SOCKADDR_UN_LEN),
            )
        )
        if rc < 0:
            _ = external_call["close", c_int](c_int(fd))
            raise OrchestratorError(
                StatusCode.unavailable, "falha ao bind socket Unix: " + path
            )
        rc = Int(external_call["listen", c_int](c_int(fd), c_int(64)))
        if rc < 0:
            _ = external_call["close", c_int](c_int(fd))
            _ = external_call["unlink", c_int](name.as_c_string_slice())
            raise OrchestratorError(
                StatusCode.unavailable, "falha ao listen socket Unix"
            )
        self.fd = fd
        self.path = path.copy()

    def accept(self) raises -> UnixConnection:
        var peer = SockAddrUn("/tmp/peer.sock")
        var peer_len = c_int(SOCKADDR_UN_LEN)
        var cfd = Int(
            external_call["accept", c_int](
                c_int(self.fd),
                Pointer(to=peer).unsafe_bitcast[UInt8](),
                Pointer(to=peer_len),
            )
        )
        if cfd < 0:
            raise OrchestratorError(
                StatusCode.internal, "accept socket Unix falhou"
            )
        return UnixConnection(cfd)

    def close(mut self):
        if self.fd >= 0:
            _ = external_call["close", c_int](c_int(self.fd))
            self.fd = -1
        if self.path.byte_length() > 0:
            _ = external_call["unlink", c_int](self.path.as_c_string_slice())


struct UnixConnection:
    var fd: Int

    def __init__(out self, fd: Int):
        self.fd = fd

    def recv_frame(self) raises -> Frame:
        var head = _recv_exact(self.fd, HEADER_SIZE)
        var header = decode_header(head)
        var payload_size = Int(header.payload_size)
        if payload_size > MAX_PAYLOAD_SIZE:
            raise OrchestratorError(
                StatusCode.invalid_argument, "payload ACE1 excede o limite"
            )
        var payload = _recv_exact(self.fd, payload_size)
        return Frame(header, payload^)

    def send_frame(self, frame: Frame) raises:
        _send_all(self.fd, encode_frame(frame))

    def close(mut self):
        if self.fd < 0:
            return
        _ = external_call["shutdown", c_int](c_int(self.fd), c_int(SHUT_RDWR))
        _ = external_call["close", c_int](c_int(self.fd))
        self.fd = -1


struct UnixClient(Copyable):
    var path: String

    def __init__(out self, path: String):
        self.path = path

    def call(self, frame: Frame) raises -> Frame:
        var fd = Int(
            external_call["socket", c_int](
                c_int(AF_UNIX), c_int(SOCK_STREAM), c_int(0)
            )
        )
        if fd < 0:
            raise OrchestratorError(
                StatusCode.unavailable, "falha ao criar cliente Unix"
            )
        var addr = SockAddrUn(self.path)
        var rc = Int(
            external_call["connect", c_int](
                c_int(fd),
                Pointer(to=addr).unsafe_bitcast[UInt8](),
                c_int(SOCKADDR_UN_LEN),
            )
        )
        if rc < 0:
            _ = external_call["close", c_int](c_int(fd))
            raise OrchestratorError(
                StatusCode.unavailable,
                "orchestrator nao esta ouvindo em " + self.path,
            )
        var conn = UnixConnection(fd)
        try:
            conn.send_frame(frame)
            var reply = conn.recv_frame()
            conn.close()
            return reply^
        except e:
            conn.close()
            raise e


def _recv_exact(fd: Int, count: Int) raises -> List[UInt8]:
    var out = List[UInt8](capacity=count)
    var remaining = count
    while remaining > 0:
        var buf = InlineArray[UInt8, 4096](fill=0)
        var wanted = remaining
        if wanted > 4096:
            wanted = 4096
        var n = Int(
            external_call["recv", c_ssize_t](
                c_int(fd), Pointer(to=buf[0]), c_size_t(wanted), c_int(0)
            )
        )
        if n <= 0:
            raise OrchestratorError(
                StatusCode.unavailable, "peer fechou o socket Unix"
            )
        var i = 0
        while i < n:
            out.append(buf[i])
            i += 1
        remaining -= n
    return out^


def _send_all(fd: Int, data: List[UInt8]) raises:
    if len(data) == 0:
        return
    var payload = data.copy()
    var sent = 0
    while sent < len(payload):
        var n = Int(
            external_call["send", c_ssize_t](
                c_int(fd),
                Pointer(to=payload[sent]),
                c_size_t(len(payload) - sent),
                c_int(0),
            )
        )
        if n <= 0:
            raise OrchestratorError(
                StatusCode.unavailable, "envio no socket Unix falhou"
            )
        sent += n
