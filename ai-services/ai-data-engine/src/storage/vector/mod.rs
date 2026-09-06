mod milvus;
mod pgvector;
mod qdrant;

pub use milvus::MilvusStore;
pub use pgvector::PgvectorStore;
pub use qdrant::QdrantStore;

use std::sync::Mutex;

use crate::core::{Chunk, Embedding, Error, Result};

use super::VectorStore;

#[derive(Default)]
pub struct MemoryVectorStore {
    chunks: Mutex<Vec<Chunk>>,
}

impl MemoryVectorStore {
    pub fn new() -> Self {
        Self::default()
    }
}

impl VectorStore for MemoryVectorStore {
    fn upsert(&self, chunk: Chunk) -> Result<()> {
        let mut chunks = self
            .chunks
            .lock()
            .map_err(|e| Error::internal(e.to_string()))?;
        if let Some(existing) = chunks.iter_mut().find(|c| c.id == chunk.id) {
            *existing = chunk;
        } else {
            chunks.push(chunk);
        }
        Ok(())
    }

    fn search(&self, embedding: &Embedding, top_k: usize) -> Result<Vec<Chunk>> {
        let chunks = self
            .chunks
            .lock()
            .map_err(|e| Error::internal(e.to_string()))?;
        let mut scored: Vec<(f32, Chunk)> = chunks
            .iter()
            .filter_map(|chunk| {
                let score = chunk.embedding.as_ref()?.cosine(embedding);
                Some((score, chunk.clone()))
            })
            .collect();
        scored.sort_by(|a, b| b.0.total_cmp(&a.0));
        scored.truncate(top_k.max(1));
        Ok(scored.into_iter().map(|(_, c)| c).collect())
    }

    fn scan(&self) -> Result<Vec<Chunk>> {
        let chunks = self
            .chunks
            .lock()
            .map_err(|e| Error::internal(e.to_string()))?;
        Ok(chunks.clone())
    }

    fn delete(&self, chunk_id: &str) -> Result<()> {
        let mut chunks = self
            .chunks
            .lock()
            .map_err(|e| Error::internal(e.to_string()))?;
        chunks.retain(|c| c.id.as_str() != chunk_id);
        Ok(())
    }
}
