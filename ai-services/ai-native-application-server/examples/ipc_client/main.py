"""Client ACE1 do orchestrator (tipos 210/220)."""

from ai_orchestrator.adapter.ipc.unix_socket.client import AceClient
from ai_orchestrator.adapter.ipc.unix_socket.protocol import MessageType


def main() -> None:
    client = AceClient("/tmp/ai-orchestrator-python.sock")
    try:
        print("health", client.health())
    except OSError as exc:
        print("orchestrator nao esta ouvindo:", exc)
        return
    reply = client.call(MessageType.AGENT_EXECUTE_REQUEST, b'{"prompt":"ping"}')
    print(reply.payload.decode())


if __name__ == "__main__":
    main()
