use std::path::Path;

use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::{UnixListener, UnixStream};

use super::{decode_header, encode_frame, Frame, HEADER_SIZE};
use crate::core::{Error, Result};

pub struct UnixSocket {
    stream: UnixStream,
}

impl UnixSocket {
    pub async fn connect(path: impl AsRef<Path>) -> Result<Self> {
        let stream = UnixStream::connect(path)
            .await
            .map_err(|e| Error::unavailable(e.to_string()))?;
        Ok(Self { stream })
    }

    pub async fn listen(path: impl AsRef<Path>) -> Result<UnixListener> {
        let path = path.as_ref();
        if path.exists() {
            let _ = std::fs::remove_file(path);
        }
        UnixListener::bind(path).map_err(|e| Error::unavailable(e.to_string()))
    }

    pub fn from_stream(stream: UnixStream) -> Self {
        Self { stream }
    }

    pub async fn send(&mut self, frame: &Frame) -> Result<()> {
        let bytes = encode_frame(frame);
        self.stream
            .write_all(&bytes)
            .await
            .map_err(|e| Error::internal(e.to_string()))
    }

    pub async fn recv(&mut self) -> Result<Frame> {
        let mut header_buf = [0u8; HEADER_SIZE];
        self.stream
            .read_exact(&mut header_buf)
            .await
            .map_err(|e| Error::unavailable(e.to_string()))?;
        let header = decode_header(&header_buf)?;
        let mut payload = vec![0u8; header.payload_size as usize];
        if !payload.is_empty() {
            self.stream
                .read_exact(&mut payload)
                .await
                .map_err(|e| Error::unavailable(e.to_string()))?;
        }
        Ok(Frame { header, payload })
    }
}
