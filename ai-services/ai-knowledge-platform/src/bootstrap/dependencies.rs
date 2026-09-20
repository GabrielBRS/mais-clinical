use std::sync::Arc;

use crate::config::{AppConfig, VectorBackend};
use crate::storage::vector::{MilvusStore, PgvectorStore, QdrantStore};
use crate::storage::{MemoryVectorStore, VectorStore};

pub fn vector_store(config: &AppConfig) -> Arc<dyn VectorStore> {
    match config.database.vector {
        VectorBackend::Memory => Arc::new(MemoryVectorStore::new()),
        VectorBackend::Milvus => Arc::new(MilvusStore),
        VectorBackend::Qdrant => Arc::new(QdrantStore),
        VectorBackend::Pgvector => Arc::new(PgvectorStore),
    }
}
