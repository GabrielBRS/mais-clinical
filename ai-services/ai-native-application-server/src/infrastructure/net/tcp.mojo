from std.collections import InlineArray
from std.ffi import c_int, c_size_t, c_ssize_t, external_call
from std.memory import Pointer

from domain.errors import OrchestratorError
from domain.status import StatusCode


comptime AF_INET = 2
comptime SOCK_STREAM = 1
comptime SOL_SOCKET = 1
comptime SO_REUSEADDR = 2
comptime SHUT_RDWR = 2
comptime SOCKADDR_LEN = 16


@fieldwise_init
struct SockAddrIn(Copyable):
    var family: UInt16
    var port: UInt16
    var addr: UInt32
    var pad: UInt64


struct TcpListener:
    """POSIX TCP listen socket via libc, without an auxiliary runtime.

    Layer: infrastructure/net
    Why here: Mojo 1.0 has no std.net; libc sockets stay behind this type.
    """

    var fd: Int

    def __init__(out self, host: String, port: Int) raises:
        var fd = Int(
            external_call["socket", c_int](
                c_int(AF_INET), c_int(SOCK_STREAM), c_int(0)
            )
        )
        if fd < 0:
            raise OrchestratorError(
                StatusCode.unavailable, "falha ao criar socket TCP"
            )
        var reuse = c_int(1)
        _ = external_call["setsockopt", c_int](
            c_int(fd),
            c_int(SOL_SOCKET),
            c_int(SO_REUSEADDR),
            Pointer(to=reuse).unsafe_bitcast[UInt8](),
            c_int(4),
        )
        var addr = _sockaddr(host, port)
        var rc = Int(
            external_call["bind", c_int](
                c_int(fd),
                Pointer(to=addr).unsafe_bitcast[UInt8](),
                c_int(SOCKADDR_LEN),
            )
        )
        if rc < 0:
            _ = external_call["close", c_int](c_int(fd))
            raise OrchestratorError(
                StatusCode.unavailable, "falha ao bind TCP " + host
            )
        rc = Int(external_call["listen", c_int](c_int(fd), c_int(64)))
        if rc < 0:
            _ = external_call["close", c_int](c_int(fd))
            raise OrchestratorError(
                StatusCode.unavailable, "falha ao listen TCP"
            )
        self.fd = fd

    def accept(self) raises -> TcpConnection:
        var peer = SockAddrIn(UInt16(0), UInt16(0), UInt32(0), UInt64(0))
        var peer_len = c_int(SOCKADDR_LEN)
        var cfd = Int(
            external_call["accept", c_int](
                c_int(self.fd),
                Pointer(to=peer).unsafe_bitcast[UInt8](),
                Pointer(to=peer_len),
            )
        )
        if cfd < 0:
            raise OrchestratorError(StatusCode.internal, "accept TCP falhou")
        return TcpConnection(cfd)

    def close(mut self):
        if self.fd >= 0:
            _ = external_call["close", c_int](c_int(self.fd))
            self.fd = -1


struct TcpConnection:
    var fd: Int

    def __init__(out self, fd: Int):
        self.fd = fd

    def recv_http(self) raises -> String:
        var data = String()
        while data.find("\r\n\r\n") < 0:
            var chunk = _recv_chunk(self.fd, 4096)
            if chunk.byte_length() == 0:
                break
            data += chunk
        var header_end = data.find("\r\n\r\n")
        if header_end < 0:
            return data^
        var needed = _content_length(_slice(data, 0, header_end))
        var body_start = header_end + 4
        var have = data.byte_length() - body_start
        while have < needed:
            var chunk = _recv_chunk(self.fd, 4096)
            if chunk.byte_length() == 0:
                break
            data += chunk
            have = data.byte_length() - body_start
        return data^

    def send_all(self, data: String) raises:
        var payload = data.copy()
        var total = payload.byte_length()
        var sent = 0
        while sent < total:
            var rc = Int(
                external_call["send", c_ssize_t](
                    c_int(self.fd),
                    payload.as_c_string_slice().unsafe_ptr().unsafe_offset(sent),
                    c_size_t(total - sent),
                    c_int(0),
                )
            )
            if rc <= 0:
                raise OrchestratorError(StatusCode.internal, "send HTTP falhou")
            sent += rc

    def close(mut self):
        if self.fd < 0:
            return
        _ = external_call["shutdown", c_int](c_int(self.fd), c_int(SHUT_RDWR))
        _ = external_call["close", c_int](c_int(self.fd))
        self.fd = -1


def _sockaddr(host: String, port: Int) raises -> SockAddrIn:
    var name = host.copy()
    var ip = UInt32(0)
    var ok = Int(
        external_call["inet_pton", c_int](
            c_int(AF_INET),
            name.as_c_string_slice(),
            Pointer(to=ip).unsafe_bitcast[UInt8](),
        )
    )
    if ok != 1:
        raise OrchestratorError(
            StatusCode.invalid_argument, "host TCP invalido: " + host
        )
    return SockAddrIn(UInt16(AF_INET), _htons(UInt16(port)), ip, UInt64(0))


def _htons(port: UInt16) -> UInt16:
    var value = Int(port)
    return UInt16(((value & 255) << 8) | ((value >> 8) & 255))


def _recv_chunk(fd: Int, cap: Int) raises -> String:
    _ = cap
    var buf = InlineArray[UInt8, 4096](fill=0)
    var n = Int(
        external_call["recv", c_ssize_t](
            c_int(fd), Pointer(to=buf[0]), c_size_t(4096), c_int(0)
        )
    )
    if n <= 0:
        return ""
    var out = String()
    var i = 0
    while i < n:
        out += String(chr(Int(buf[i])))
        i += 1
    return out^


def _content_length(head: String) -> Int:
    var start = head.find("Content-Length:")
    var label_len = 15
    if start < 0:
        start = head.find("content-length:")
        if start < 0:
            return 0
    var i = _skip_ws(head, start + label_len)
    var raw = head.as_bytes()
    var out = 0
    var seen = False
    while i < len(raw):
        var b = Int(raw[i])
        if b < 48 or b > 57:
            break
        seen = True
        out = out * 10 + (b - 48)
        i += 1
    if not seen:
        return 0
    return out


def _slice(text: String, start: Int, end: Int) -> String:
    var raw = text.as_bytes()
    var i = start
    if i < 0:
        i = 0
    var last = end
    if last > len(raw):
        last = len(raw)
    var out = String()
    while i < last:
        out += String(chr(Int(raw[i])))
        i += 1
    return out^


def _skip_ws(text: String, start: Int) -> Int:
    var raw = text.as_bytes()
    var i = start
    while i < len(raw):
        var b = Int(raw[i])
        if b != 32 and b != 9 and b != 10 and b != 13:
            return i
        i += 1
    return i
