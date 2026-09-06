"""Framing ACE1 compartilhado com compute-engine e data-engine.

[ magic 4 ][ version u16 ][ type u16 ][ request_id u64 ][ payload_size u32 ][ payload ]
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import IntEnum

MAGIC = b"ACE1"
PROTOCOL_VERSION = 1
HEADER_SIZE = 20


class MessageType(IntEnum):
    HEALTH_REQUEST = 1
    HEALTH_RESPONSE = 2
    INFER_REQUEST = 10
    INFER_RESPONSE = 11
    GENERATE_REQUEST = 12
    GENERATE_RESPONSE = 13
    EMBED_REQUEST = 20
    EMBED_RESPONSE = 21
    RERANK_REQUEST = 30
    RERANK_RESPONSE = 31
    RETRIEVE_REQUEST = 110
    RETRIEVE_RESPONSE = 111
    INGEST_REQUEST = 120
    INGEST_RESPONSE = 121
    RAG_REQUEST = 130
    RAG_RESPONSE = 131
    AGENT_EXECUTE_REQUEST = 210
    AGENT_EXECUTE_RESPONSE = 211
    WORKFLOW_EXECUTE_REQUEST = 220
    WORKFLOW_EXECUTE_RESPONSE = 221
    ERROR = 99


@dataclass(slots=True)
class Header:
    magic: bytes
    version: int
    ty: MessageType
    request_id: int
    payload_size: int


@dataclass(slots=True)
class Frame:
    header: Header
    payload: bytes

    @classmethod
    def new(cls, ty: MessageType, request_id: int, payload: bytes = b"") -> Frame:
        return cls(
            Header(MAGIC, PROTOCOL_VERSION, ty, request_id, len(payload)),
            payload,
        )


def encode_header(header: Header) -> bytes:
    return (
        header.magic[:4].ljust(4, b"\0")
        + int(header.version).to_bytes(2, "little")
        + int(header.ty).to_bytes(2, "little")
        + int(header.request_id).to_bytes(8, "little")
        + int(header.payload_size).to_bytes(4, "little")
    )


def decode_header(raw: bytes) -> Header:
    if len(raw) < HEADER_SIZE:
        raise ValueError("frame menor que o header")
    magic = raw[:4]
    if magic != MAGIC:
        raise ValueError("magic ACE1 invalido")
    version = int.from_bytes(raw[4:6], "little")
    if version != PROTOCOL_VERSION:
        raise ValueError("versao de protocolo nao suportada")
    ty_raw = int.from_bytes(raw[6:8], "little")
    try:
        ty = MessageType(ty_raw)
    except ValueError:
        ty = MessageType.ERROR
    return Header(
        magic=magic,
        version=version,
        ty=ty,
        request_id=int.from_bytes(raw[8:16], "little"),
        payload_size=int.from_bytes(raw[16:20], "little"),
    )


def encode_frame(frame: Frame) -> bytes:
    header = Header(MAGIC, PROTOCOL_VERSION, frame.header.ty, frame.header.request_id, len(frame.payload))
    return encode_header(header) + frame.payload


def decode_frame(raw: bytes) -> Frame:
    header = decode_header(raw)
    if len(raw) != HEADER_SIZE + header.payload_size:
        raise ValueError("payload_size nao bate")
    return Frame(header, raw[HEADER_SIZE:])
