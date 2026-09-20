from domain.errors import OrchestratorError
from domain.status import StatusCode

comptime MAGIC_0: UInt8 = 65  # 'A'
comptime MAGIC_1: UInt8 = 67  # 'C'
comptime MAGIC_2: UInt8 = 69  # 'E'
comptime MAGIC_3: UInt8 = 49  # '1'
comptime PROTOCOL_VERSION: UInt16 = 1
comptime HEADER_SIZE: Int = 20


@fieldwise_init
struct MessageType(Equatable, ImplicitlyCopyable, Writable):
    var _value: UInt16

    comptime health_request = Self(1)
    comptime health_response = Self(2)
    comptime infer_request = Self(10)
    comptime infer_response = Self(11)
    comptime generate_request = Self(12)
    comptime generate_response = Self(13)
    comptime embed_request = Self(20)
    comptime embed_response = Self(21)
    comptime rerank_request = Self(30)
    comptime rerank_response = Self(31)
    comptime retrieve_request = Self(110)
    comptime retrieve_response = Self(111)
    comptime ingest_request = Self(120)
    comptime ingest_response = Self(121)
    comptime rag_request = Self(130)
    comptime rag_response = Self(131)
    comptime agent_execute_request = Self(210)
    comptime agent_execute_response = Self(211)
    comptime workflow_execute_request = Self(220)
    comptime workflow_execute_response = Self(221)
    comptime error = Self(99)

    def write_to(self, mut writer: Some[Writer]):
        writer.write(Int(self._value))


@fieldwise_init
struct Header(Copyable, ImplicitlyCopyable):
    var version: UInt16
    var type: MessageType
    var request_id: UInt64
    var payload_size: UInt32


struct Frame(Copyable):
    var header: Header
    var payload: List[UInt8]

    def __init__(
        out self, header: Header, var payload: List[UInt8] = List[UInt8]()
    ):
        self.header = header
        self.payload = payload^

    @staticmethod
    def new(
        ty: MessageType,
        request_id: UInt64,
        var payload: List[UInt8] = List[UInt8](),
    ) -> Frame:
        return Frame(
            Header(PROTOCOL_VERSION, ty, request_id, UInt32(len(payload))),
            payload^,
        )


def write_le16(mut out: List[UInt8], offset: Int, value: UInt16):
    out[offset] = UInt8(value & 0xFF)
    out[offset + 1] = UInt8((value >> 8) & 0xFF)


def write_le32(mut out: List[UInt8], offset: Int, value: UInt32):
    out[offset] = UInt8(value & 0xFF)
    out[offset + 1] = UInt8((value >> 8) & 0xFF)
    out[offset + 2] = UInt8((value >> 16) & 0xFF)
    out[offset + 3] = UInt8((value >> 24) & 0xFF)


def write_le64(mut out: List[UInt8], offset: Int, value: UInt64):
    write_le32(out, offset, UInt32(value & 0xFFFFFFFF))
    write_le32(out, offset + 4, UInt32((value >> 32) & 0xFFFFFFFF))


def read_le16(bytes: List[UInt8], offset: Int) -> UInt16:
    return UInt16(bytes[offset]) | (UInt16(bytes[offset + 1]) << 8)


def read_le32(bytes: List[UInt8], offset: Int) -> UInt32:
    return (
        UInt32(bytes[offset])
        | (UInt32(bytes[offset + 1]) << 8)
        | (UInt32(bytes[offset + 2]) << 16)
        | (UInt32(bytes[offset + 3]) << 24)
    )


def read_le64(bytes: List[UInt8], offset: Int) -> UInt64:
    return UInt64(read_le32(bytes, offset)) | (
        UInt64(read_le32(bytes, offset + 4)) << 32
    )


def encode_header(header: Header) -> List[UInt8]:
    var out = List[UInt8](length=HEADER_SIZE, fill=0)
    out[0] = MAGIC_0
    out[1] = MAGIC_1
    out[2] = MAGIC_2
    out[3] = MAGIC_3
    write_le16(out, 4, header.version)
    write_le16(out, 6, header.type._value)
    write_le64(out, 8, header.request_id)
    write_le32(out, 16, header.payload_size)
    return out^


def decode_header(bytes: List[UInt8]) raises OrchestratorError -> Header:
    if len(bytes) < HEADER_SIZE:
        raise OrchestratorError(
            StatusCode.invalid_argument, "frame menor que o header"
        )
    if (
        bytes[0] != MAGIC_0
        or bytes[1] != MAGIC_1
        or bytes[2] != MAGIC_2
        or bytes[3] != MAGIC_3
    ):
        raise OrchestratorError(
            StatusCode.invalid_argument, "magic ACE1 invalido"
        )
    var version = read_le16(bytes, 4)
    if version != PROTOCOL_VERSION:
        raise OrchestratorError(
            StatusCode.invalid_argument, "versao de protocolo nao suportada"
        )
    return Header(
        version,
        MessageType(read_le16(bytes, 6)),
        read_le64(bytes, 8),
        read_le32(bytes, 16),
    )


def encode_frame(frame: Frame) -> List[UInt8]:
    var header = frame.header
    header.version = PROTOCOL_VERSION
    header.payload_size = UInt32(len(frame.payload))
    var head = encode_header(header)
    var out = List[UInt8](capacity=HEADER_SIZE + len(frame.payload))
    var i = 0
    while i < len(head):
        out.append(head[i])
        i += 1
    i = 0
    while i < len(frame.payload):
        out.append(frame.payload[i])
        i += 1
    return out^


def decode_frame(bytes: List[UInt8]) raises OrchestratorError -> Frame:
    if len(bytes) < HEADER_SIZE:
        raise OrchestratorError(
            StatusCode.invalid_argument, "frame menor que o header"
        )
    var header = decode_header(bytes)
    if len(bytes) != HEADER_SIZE + Int(header.payload_size):
        raise OrchestratorError(
            StatusCode.invalid_argument, "payload_size nao bate"
        )
    var payload = List[UInt8](capacity=Int(header.payload_size))
    var i = HEADER_SIZE
    while i < len(bytes):
        payload.append(bytes[i])
        i += 1
    return Frame(header, payload^)


def payload_from_string(text: String) -> List[UInt8]:
    var out = List[UInt8]()
    var raw = text.as_bytes()
    var i = 0
    while i < len(raw):
        out.append(UInt8(Int(raw[i])))
        i += 1
    return out^


def payload_to_string(payload: List[UInt8]) -> String:
    var out = String()
    var i = 0
    while i < len(payload):
        out += String(chr(Int(payload[i])))
        i += 1
    return out^
