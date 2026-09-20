use std::sync::Arc;

use ai_data_engine::core::{Document, Query};
use ai_data_engine::ingestion::{ChunkWriter, IngestionService};
use ai_data_engine::retrieval::{DenseRetriever, HybridMode, HybridRetriever, RetrievalService, SparseRetriever};
use ai_data_engine::storage::MemoryVectorStore;
use criterion::{Criterion, criterion_group, criterion_main};

fn bench_sparse(c: &mut Criterion) {
    let store = Arc::new(MemoryVectorStore::new());
    let ingest = IngestionService::new(ChunkWriter::new(store.clone(), 64), 128);
    let docs: Vec<_> = (0..64)
        .map(|i| Document::with_id(format!("d{i}"), format!("token{i} retrieval ranking rust")))
        .collect();
    ingest.ingest(&docs).unwrap();
    let svc = RetrievalService::new(HybridRetriever::new(
        DenseRetriever::new(store.clone(), 64),
        SparseRetriever::new(store),
    ));
    c.bench_function("sparse_retrieve", |b| {
        b.iter(|| {
            svc.retrieve(Query::new("token12 rust").with_top_k(8), HybridMode::Sparse)
                .unwrap()
        });
    });
}

criterion_group!(benches, bench_sparse);
criterion_main!(benches);
