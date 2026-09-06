from ai_orchestrator.adapter.ipc.unix_socket.protocol import Frame, MessageType, encode_frame


def test_encode_many_frames() -> None:
    for i in range(100):
        encode_frame(Frame.new(MessageType.HEALTH_REQUEST, i))
