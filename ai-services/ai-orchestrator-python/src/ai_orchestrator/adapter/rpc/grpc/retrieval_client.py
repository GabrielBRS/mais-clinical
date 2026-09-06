from __future__ import annotations

import json

from ai_orchestrator.adapter.ipc.unix_socket.client import AceClient
from ai_orchestrator.adapter.ipc.unix_socket.protocol import MessageType


class RetrievalClient:
    def __init__(self, ipc_path: str) -> None:
        self._ipc = AceClient(ipc_path)

    def health(self) -> str:
        try:
            return self._ipc.health()
        except OSError:
            return "unavailable"

    def retrieve(self, query: str, top_k: int = 8) -> list[str]:
        payload = json.dumps({"query": query, "top_k": top_k, "mode": "hybrid"}).encode()
        try:
            reply = self._ipc.call(MessageType.RETRIEVE_REQUEST, payload)
        except OSError:
            return []
        if reply.header.ty == MessageType.ERROR:
            return []
        try:
            body = json.loads(reply.payload.decode())
        except json.JSONDecodeError:
            return []
        if isinstance(body, list):
            return [item.get("chunk", {}).get("text", "") for item in body if isinstance(item, dict)]
        return []
