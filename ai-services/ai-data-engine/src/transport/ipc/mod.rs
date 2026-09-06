//! Framing ACE1 compartilhado com o compute-engine.
//!
//! [ magic 4 ][ version u16 ][ type u16 ][ request_id u64 ][ payload_size u32 ][ payload ]

mod unix_socket;

pub use unix_socket::UnixSocket;

use crate::core::{Error, Result};

pub const MAGIC: &[u8; 4] = b"ACE1";
pub const PROTOCOL_VERSION: u16 = 1;
pub const HEADER_SIZE: usize = 20;

#[repr(u16)]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MessageType {
    HealthRequest = 1,
    HealthResponse = 2,
    InferRequest = 10,
    InferResponse = 11,
    GenerateRequest = 12,
    GenerateResponse = 13,
    EmbedRequest = 20,
    EmbedResponse = 21,
    RerankRequest = 30,
    RerankResponse = 31,
    ListModelsRequest = 40,
    ListModelsResponse = 41,
    LoadModelRequest = 50,
    LoadModelResponse = 51,
    UnloadModelRequest = 52,
    UnloadModelResponse = 53,
    RetrieveRequest = 110,
    RetrieveResponse = 111,
    IngestRequest = 120,
    IngestResponse = 121,
    RagRequest = 130,
    RagResponse = 131,
    RankRequest = 140,
    RankResponse = 141,
    TransformRequest = 150,
    TransformResponse = 151,
    Error = 99,
}

impl MessageType {
    pub fn from_u16(value: u16) -> Self {
        match value {
            1 => Self::HealthRequest,
            2 => Self::HealthResponse,
            10 => Self::InferRequest,
            11 => Self::InferResponse,
            12 => Self::GenerateRequest,
            13 => Self::GenerateResponse,
            20 => Self::EmbedRequest,
            21 => Self::EmbedResponse,
            30 => Self::RerankRequest,
            31 => Self::RerankResponse,
            40 => Self::ListModelsRequest,
            41 => Self::ListModelsResponse,
            50 => Self::LoadModelRequest,
            51 => Self::LoadModelResponse,
            52 => Self::UnloadModelRequest,
            53 => Self::UnloadModelResponse,
            110 => Self::RetrieveRequest,
            111 => Self::RetrieveResponse,
            120 => Self::IngestRequest,
            121 => Self::IngestResponse,
            130 => Self::RagRequest,
            131 => Self::RagResponse,
            140 => Self::RankRequest,
            141 => Self::RankResponse,
            150 => Self::TransformRequest,
            151 => Self::TransformResponse,
            _ => Self::Error,
        }
    }
}

#[derive(Debug, Clone)]
pub struct Header {
    pub magic: [u8; 4],
    pub version: u16,
    pub ty: MessageType,
    pub request_id: u64,
    pub payload_size: u32,
}

impl Header {
    pub fn new(ty: MessageType, request_id: u64, payload_size: u32) -> Self {
        Self {
            magic: *MAGIC,
            version: PROTOCOL_VERSION,
            ty,
            request_id,
            payload_size,
        }
    }
}

#[derive(Debug, Clone)]
pub struct Frame {
    pub header: Header,
    pub payload: Vec<u8>,
}

impl Frame {
    pub fn new(ty: MessageType, request_id: u64, payload: impl Into<Vec<u8>>) -> Self {
        let payload = payload.into();
        Self {
            header: Header::new(ty, request_id, payload.len() as u32),
            payload,
        }
    }
}

pub fn encode_header(header: &Header) -> [u8; HEADER_SIZE] {
    let mut out = [0u8; HEADER_SIZE];
    out[..4].copy_from_slice(&header.magic);
    out[4..6].copy_from_slice(&header.version.to_le_bytes());
    out[6..8].copy_from_slice(&(header.ty as u16).to_le_bytes());
    out[8..16].copy_from_slice(&header.request_id.to_le_bytes());
    out[16..20].copy_from_slice(&header.payload_size.to_le_bytes());
    out
}

pub fn decode_header(bytes: &[u8]) -> Result<Header> {
    if bytes.len() < HEADER_SIZE {
        return Err(Error::invalid("frame menor que o header"));
    }
    let magic: [u8; 4] = bytes[..4].try_into().unwrap();
    if &magic != MAGIC {
        return Err(Error::invalid("magic ACE1 invalido"));
    }
    let version = u16::from_le_bytes([bytes[4], bytes[5]]);
    if version != PROTOCOL_VERSION {
        return Err(Error::invalid("versao de protocolo nao suportada"));
    }
    Ok(Header {
        magic,
        version,
        ty: MessageType::from_u16(u16::from_le_bytes([bytes[6], bytes[7]])),
        request_id: u64::from_le_bytes(bytes[8..16].try_into().unwrap()),
        payload_size: u32::from_le_bytes(bytes[16..20].try_into().unwrap()),
    })
}

pub fn encode_frame(frame: &Frame) -> Vec<u8> {
    let mut header = frame.header.clone();
    header.magic = *MAGIC;
    header.version = PROTOCOL_VERSION;
    header.payload_size = frame.payload.len() as u32;
    let mut out = Vec::with_capacity(HEADER_SIZE + frame.payload.len());
    out.extend_from_slice(&encode_header(&header));
    out.extend_from_slice(&frame.payload);
    out
}

pub fn decode_frame(bytes: &[u8]) -> Result<Frame> {
    let header = decode_header(bytes)?;
    if bytes.len() != HEADER_SIZE + header.payload_size as usize {
        return Err(Error::invalid("payload_size nao bate"));
    }
    Ok(Frame {
        header,
        payload: bytes[HEADER_SIZE..].to_vec(),
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn header_roundtrip() {
        let header = Header::new(MessageType::HealthRequest, 42, 0);
        let encoded = encode_header(&header);
        let decoded = decode_header(&encoded).unwrap();
        assert_eq!(decoded.request_id, 42);
        assert_eq!(decoded.ty, MessageType::HealthRequest);
        assert_eq!(&decoded.magic, MAGIC);
    }

    #[test]
    fn frame_roundtrip() {
        let frame = Frame::new(MessageType::HealthResponse, 7, b"0.1.0".to_vec());
        let wire = encode_frame(&frame);
        let back = decode_frame(&wire).unwrap();
        assert_eq!(back.payload, b"0.1.0");
        assert_eq!(back.header.request_id, 7);
    }
}
