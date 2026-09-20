import socket
import threading
from pathlib import Path

from ai_orchestrator.adapter.ipc.unix_socket.client import AceClient
from ai_orchestrator.adapter.ipc.unix_socket.connection import AceConnection
from ai_orchestrator.adapter.ipc.unix_socket.protocol import Frame, MessageType


def test_unix_socket_health(tmp_path: Path) -> None:
    path = str(tmp_path / "ace.sock")
    ready = threading.Event()
    done = threading.Event()

    def server() -> None:
        srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        srv.bind(path)
        srv.listen(1)
        ready.set()
        client, _ = srv.accept()
        conn = AceConnection(client)
        incoming = conn.recv()
        conn.send(
            Frame.new(MessageType.HEALTH_RESPONSE, incoming.header.request_id, b"0.1.0")
        )
        conn.close()
        srv.close()
        done.set()

    thread = threading.Thread(target=server)
    thread.start()
    assert ready.wait(timeout=2)
    assert AceClient(path).health() == "0.1.0"
    assert done.wait(timeout=2)
    thread.join(timeout=2)
