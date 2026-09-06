use crate::core::{Chunk, Embedding, Metadata, Result};

pub trait VectorStore: Send + Sync {
    fn upsert(&self, chunk: Chunk) -> Result<()>;
    fn search(&self, embedding: &Embedding, top_k: usize) -> Result<Vec<Chunk>>;
    fn scan(&self) -> Result<Vec<Chunk>>;
    fn delete(&self, chunk_id: &str) -> Result<()>;
}

pub trait KvStore: Send + Sync {
    fn get(&self, key: &str) -> Result<Option<Vec<u8>>>;
    fn put(&self, key: &str, value: &[u8]) -> Result<()>;
    fn delete(&self, key: &str) -> Result<()>;
}

pub trait ObjectStore: Send + Sync {
    fn put(&self, key: &str, bytes: &[u8]) -> Result<()>;
    fn get(&self, key: &str) -> Result<Vec<u8>>;
}

pub fn filter_metadata(chunks: Vec<Chunk>, filter: &std::collections::BTreeMap<String, String>) -> Vec<Chunk> {
    if filter.is_empty() {
        return chunks;
    }
    chunks
        .into_iter()
        .filter(|c| c.metadata.matches(filter))
        .collect()
}

#[allow(dead_code)]
pub fn empty_metadata() -> Metadata {
    Metadata::new()
}
