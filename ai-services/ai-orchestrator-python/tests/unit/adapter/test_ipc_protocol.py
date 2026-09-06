from ai_orchestrator.adapter.ipc.unix_socket.protocol import (
    MAGIC,
    MessageType,
    Frame,
    decode_frame,
    encode_frame,
)


def test_header_roundtrip() -> None:
    frame = Frame.new(MessageType.HEALTH_REQUEST, 42, b"")
    wire = encode_frame(frame)
    back = decode_frame(wire)
    assert back.header.magic == MAGIC
    assert back.header.ty == MessageType.HEALTH_REQUEST
    assert back.header.request_id == 42


def test_frame_payload() -> None:
    frame = Frame.new(MessageType.HEALTH_RESPONSE, 7, b"0.1.0")
    back = decode_frame(encode_frame(frame))
    assert back.payload == b"0.1.0"
    assert back.header.ty == MessageType.HEALTH_RESPONSE
