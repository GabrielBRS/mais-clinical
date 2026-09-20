from bootstrap.application import Application
from infrastructure.ipc.protocol import Frame, MessageType, payload_from_string
from std.testing import assert_equal, assert_true


def main() raises:
    var process = Application.build()
    process.orchestrator.lifecycle.start()
    var health = process.service.http.handle(
        process.orchestrator, "GET /health/ready HTTP/1.1\r\n\r\n"
    )
    assert_equal(health.status, 200)
    var agent = process.orchestrator.handle(
        Frame.new(
            MessageType.agent_execute_request,
            1,
            payload_from_string("ping"),
        )
    )
    assert_equal(agent.header.type, MessageType.agent_execute_response)
    assert_true(len(agent.payload) > 0)
    print("smoke ok")
