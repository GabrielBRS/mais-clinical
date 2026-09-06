from ipc.protocol import (
    Frame,
    MAGIC_0,
    MessageType,
    decode_frame,
    encode_frame,
    payload_from_string,
    payload_to_string,
)
from std.testing import assert_equal, TestSuite


def test_header_roundtrip() raises:
    var frame = Frame.new(MessageType.health_request, 42)
    var wire = encode_frame(frame)
    var back = decode_frame(wire)
    assert_equal(wire[0], MAGIC_0)
    assert_equal(back.header.type, MessageType.health_request)
    assert_equal(Int(back.header.request_id), 42)


def test_frame_payload() raises:
    var frame = Frame.new(
        MessageType.health_response, 7, payload_from_string("0.1.0")
    )
    var back = decode_frame(encode_frame(frame))
    assert_equal(payload_to_string(back.payload), "0.1.0")
    assert_equal(back.header.type, MessageType.health_response)


def test_agent_message_types() raises:
    assert_equal(Int(MessageType.agent_execute_request._value), 210)
    assert_equal(Int(MessageType.workflow_execute_request._value), 220)
    assert_equal(Int(MessageType.error._value), 99)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
