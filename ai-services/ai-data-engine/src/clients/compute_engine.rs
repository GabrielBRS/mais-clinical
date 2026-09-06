use std::path::{Path, PathBuf};

use crate::core::{Error, Result};
use crate::transport::ipc::{Frame, MessageType, UnixSocket};

/// Cliente ACE1 do compute-engine (embed / rerank / health).
pub struct ComputeEngineClient {
    path: PathBuf,
}

impl ComputeEngineClient {
    pub fn new(path: impl AsRef<Path>) -> Self {
        Self {
            path: path.as_ref().to_path_buf(),
        }
    }

    pub async fn health(&self) -> Result<String> {
        let mut sock = UnixSocket::connect(&self.path).await?;
        sock.send(&Frame::new(MessageType::HealthRequest, 1, Vec::new()))
            .await?;
        let reply = sock.recv().await?;
        if reply.header.ty != MessageType::HealthResponse {
            return Err(Error::unavailable("resposta health inesperada"));
        }
        String::from_utf8(reply.payload).map_err(|e| Error::internal(e.to_string()))
    }
}
