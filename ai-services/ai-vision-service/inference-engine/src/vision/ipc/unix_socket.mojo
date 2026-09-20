from std.python import Python, PythonObject

from vision.core.error import VisionError
from vision.core.status import StatusCode

from .protocol import HEADER_SIZE, Frame, decode_header, encode_frame


def _to_py_bytes(bytes: List[UInt8]) raises -> PythonObject:
    var builtins = Python.import_module("builtins")
    var arr = Python.import_module("array").array("B")
    var i = 0
    while i < len(bytes):
        _ = arr.append(Int(bytes[i]))
        i += 1
    return builtins.bytes(arr)


def _from_py_bytes(raw: PythonObject) raises -> List[UInt8]:
    var n = Int(len(raw))
    var out = List[UInt8](length=n, fill=0)
    var i = 0
    while i < n:
        out[i] = UInt8(Int(String(raw[i])))
        i += 1
    return out^


struct UnixSocket:
    """Unix-domain session. libc structs stay out; this is process I/O only."""

    var _sock: PythonObject
    var path: String
    var owns_bind: Bool

    def __init__(
        out self, var sock: PythonObject, var path: String, owns_bind: Bool
    ):
        self._sock = sock^
        self.path = path^
        self.owns_bind = owns_bind

    def __deinit__(deinit self):
        try:
            self._sock.close()
        except e:
            pass
        if self.owns_bind and self.path.byte_length() > 0:
            try:
                var os = Python.import_module("os")
                os.unlink(self.path)
            except e:
                pass

    @staticmethod
    def listen(path: String) raises -> UnixSocket:
        var os = Python.import_module("os")
        try:
            os.unlink(path)
        except e:
            pass
        var socket = Python.import_module("socket")
        var sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.bind(path)
        sock.listen(16)
        return UnixSocket(sock^, path, True)

    @staticmethod
    def connect(path: String) raises -> UnixSocket:
        var socket = Python.import_module("socket")
        var sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(path)
        return UnixSocket(sock^, path, False)

    def accept(self) raises -> UnixSocket:
        var client = self._sock.accept()[0]
        return UnixSocket(client^, self.path.copy(), False)

    def send(self, frame: Frame) raises:
        var wire = encode_frame(frame)
        self._sock.sendall(_to_py_bytes(wire))

    def recv(self) raises -> Frame:
        var header_raw = _from_py_bytes(self._sock.recv(HEADER_SIZE, 0x100))
        if len(header_raw) != HEADER_SIZE:
            raise VisionError(StatusCode.unavailable, "peer fechou o socket")
        var header = decode_header(header_raw)
        var payload = List[UInt8]()
        if header.payload_size > 0:
            payload = _from_py_bytes(
                self._sock.recv(Int(header.payload_size), 0x100)
            )
            if len(payload) != Int(header.payload_size):
                raise VisionError(
                    StatusCode.unavailable, "peer fechou o socket"
                )
        return Frame(header, payload^)
