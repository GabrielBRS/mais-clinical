from __future__ import annotations

import socket

from ai_orchestrator.adapter.ipc.unix_socket.connection import AceConnection
from ai_orchestrator.adapter.ipc.unix_socket.protocol import Frame, MessageType


class AceClient:
    def __init__(self, path: str) -> None:
        self._path = path

    def call(self, ty: MessageType, payload: bytes = b"", request_id: int = 1) -> Frame:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.settimeout(2.0)
        sock.connect(self._path)
        conn = AceConnection(sock)
        try:
            conn.send(Frame.new(ty, request_id, payload))
            return conn.recv()
        finally:
            conn.close()

    def health(self) -> str:
        reply = self.call(MessageType.HEALTH_REQUEST)
        if reply.header.ty != MessageType.HEALTH_RESPONSE:
            raise RuntimeError("resposta health inesperada")
        return reply.payload.decode()
