use crate::core::{Chunk, Embedding, Error, Result};

use super::super::VectorStore;

#[derive(Debug, Default)]
pub struct MilvusStore;

impl VectorStore for MilvusStore {
    fn upsert(&self, _: Chunk) -> Result<()> {
        Err(Error::unimplemented("milvus"))
    }
    fn search(&self, _: &Embedding, _: usize) -> Result<Vec<Chunk>> {
        Err(Error::unimplemented("milvus"))
    }
    fn scan(&self) -> Result<Vec<Chunk>> {
        Err(Error::unimplemented("milvus"))
    }
    fn delete(&self, _: &str) -> Result<()> {
        Err(Error::unimplemented("milvus"))
    }
}
