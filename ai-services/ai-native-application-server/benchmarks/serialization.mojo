from infrastructure.ipc.protocol import (
    Frame,
    MessageType,
    decode_frame,
    encode_frame,
    payload_from_string,
)


def main() raises:
    var frame = Frame.new(
        MessageType.agent_execute_request, 1, payload_from_string("benchmark")
    )
    var size = 0
    for i in range(100000):
        _ = i
        size = len(decode_frame(encode_frame(frame)).payload)
    print("100000 ACE1 roundtrips", size)
