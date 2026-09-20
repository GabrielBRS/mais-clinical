from __future__ import annotations

from ai_orchestrator.adapter.ipc.unix_socket.client import AceClient
from ai_orchestrator.adapter.ipc.unix_socket.protocol import MessageType


class InferenceClient:
    """Prefere IPC ACE1 do compute-engine; gRPC entra quando o stub for gerado."""

    def __init__(self, ipc_path: str) -> None:
        self._ipc = AceClient(ipc_path)

    def health(self) -> str:
        try:
            return self._ipc.health()
        except OSError:
            return "unavailable"

    def generate(self, prompt: str) -> str:
        try:
            reply = self._ipc.call(MessageType.GENERATE_REQUEST, prompt.encode())
            if reply.header.ty == MessageType.ERROR:
                raise RuntimeError(reply.payload.decode())
            return reply.payload.decode()
        except OSError:
            return f"[local-fallback] {prompt}"
