from ai_orchestrator.adapter.ipc.unix_socket.protocol import Frame, MessageType, encode_frame


def main() -> None:
    encode_frame(Frame.new(MessageType.HEALTH_REQUEST, 1, b"{}"))


if __name__ == "__main__":
    main()
