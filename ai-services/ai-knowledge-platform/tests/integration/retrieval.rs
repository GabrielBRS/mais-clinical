use std::sync::Arc;

use ai_data_engine::core::{Document, Query};
use ai_data_engine::ingestion::{ChunkWriter, IngestionService};
use ai_data_engine::retrieval::{DenseRetriever, HybridMode, HybridRetriever, RetrievalService, SparseRetriever};
use ai_data_engine::storage::MemoryVectorStore;

fn service() -> RetrievalService {
    let store = Arc::new(MemoryVectorStore::new());
    let ingest = IngestionService::new(ChunkWriter::new(store.clone(), 64), 256);
    ingest
        .ingest(&[
            Document::with_id("a", "rust tokio async runtime for network services"),
            Document::with_id("b", "cuda kernels and tensorrt inference on gpu"),
        ])
        .unwrap();
    RetrievalService::new(HybridRetriever::new(
        DenseRetriever::new(store.clone(), 64),
        SparseRetriever::new(store),
    ))
}

#[test]
fn sparse_finds_rust_document() {
    let hits = service()
        .retrieve(Query::new("tokio rust").with_top_k(2), HybridMode::Sparse)
        .unwrap();
    assert!(!hits.is_empty());
    assert!(hits[0].chunk.text.contains("tokio"));
}

#[test]
fn hybrid_returns_top_k() {
    let hits = service()
        .retrieve(Query::new("gpu inference").with_top_k(1), HybridMode::Hybrid)
        .unwrap();
    assert_eq!(hits.len(), 1);
}
