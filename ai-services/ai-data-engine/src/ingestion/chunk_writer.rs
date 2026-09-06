use std::sync::Arc;

use crate::core::{Chunk, Embedding, Result};
use crate::storage::VectorStore;

pub struct ChunkWriter {
    store: Arc<dyn VectorStore>,
    dim: usize,
}

impl ChunkWriter {
    pub fn new(store: Arc<dyn VectorStore>, dim: usize) -> Self {
        Self { store, dim }
    }

    pub fn write(&self, mut chunk: Chunk) -> Result<()> {
        if chunk.embedding.is_none() {
            chunk.embedding = Some(Embedding::hashed(&chunk.text, self.dim));
        }
        self.store.upsert(chunk)
    }
}
