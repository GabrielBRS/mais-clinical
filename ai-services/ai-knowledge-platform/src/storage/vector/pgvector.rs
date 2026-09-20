use crate::core::{Chunk, Embedding, Error, Result};

use super::super::VectorStore;

#[derive(Debug, Default)]
pub struct PgvectorStore;

impl VectorStore for PgvectorStore {
    fn upsert(&self, _: Chunk) -> Result<()> {
        Err(Error::unimplemented("pgvector"))
    }
    fn search(&self, _: &Embedding, _: usize) -> Result<Vec<Chunk>> {
        Err(Error::unimplemented("pgvector"))
    }
    fn scan(&self) -> Result<Vec<Chunk>> {
        Err(Error::unimplemented("pgvector"))
    }
    fn delete(&self, _: &str) -> Result<()> {
        Err(Error::unimplemented("pgvector"))
    }
}
