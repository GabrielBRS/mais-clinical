from __future__ import annotations

import socket

from ai_orchestrator.adapter.ipc.unix_socket.protocol import (
    HEADER_SIZE,
    Frame,
    decode_header,
    encode_frame,
)


class AceConnection:
    def __init__(self, sock: socket.socket) -> None:
        self._sock = sock

    def send(self, frame: Frame) -> None:
        self._sock.sendall(encode_frame(frame))

    def recv(self) -> Frame:
        header_raw = _read_exact(self._sock, HEADER_SIZE)
        header = decode_header(header_raw)
        payload = _read_exact(self._sock, header.payload_size) if header.payload_size else b""
        return Frame(header, payload)

    def close(self) -> None:
        self._sock.close()


def _read_exact(sock: socket.socket, n: int) -> bytes:
    buf = bytearray()
    while len(buf) < n:
        chunk = sock.recv(n - len(buf))
        if not chunk:
            raise ConnectionError("peer fechou o socket")
        buf.extend(chunk)
    return bytes(buf)
