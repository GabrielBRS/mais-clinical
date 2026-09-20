use serde::{Deserialize, Serialize};

use super::{ChunkId, DocumentId, Embedding, Metadata};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Chunk {
    pub id: ChunkId,
    pub document_id: DocumentId,
    pub text: String,
    pub index: usize,
    pub embedding: Option<Embedding>,
    pub metadata: Metadata,
}

impl Chunk {
    pub fn new(document_id: DocumentId, text: impl Into<String>, index: usize) -> Self {
        Self {
            id: ChunkId::new(),
            document_id,
            text: text.into(),
            index,
            embedding: None,
            metadata: Metadata::new(),
        }
    }
}
