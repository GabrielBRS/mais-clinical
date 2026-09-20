from infrastructure.ipc.protocol import (
    Frame,
    MessageType,
    payload_from_string,
    payload_to_string,
)
from infrastructure.ipc.unix_socket import UnixClient


def main() raises:
    var client = UnixClient("/tmp/ai-orchestrator.sock")
    var health = client.call(Frame.new(MessageType.health_request, 1))
    print("health", payload_to_string(health.payload))
    var reply = client.call(
        Frame.new(
            MessageType.agent_execute_request,
            2,
            payload_from_string("ping"),
        )
    )
    print(payload_to_string(reply.payload))
