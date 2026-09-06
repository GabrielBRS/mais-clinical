from ai_orchestrator.adapter.ipc.unix_socket.protocol import Frame, MessageType, decode_frame, encode_frame


def main() -> None:
    decode_frame(encode_frame(Frame.new(MessageType.AGENT_EXECUTE_REQUEST, 1, b"{}")))


if __name__ == "__main__":
    main()
