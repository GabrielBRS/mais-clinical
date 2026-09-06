use std::sync::Arc;

use ai_data_engine::core::Document;
use ai_data_engine::ingestion::{ChunkWriter, IngestionService};
use ai_data_engine::storage::{MemoryVectorStore, VectorStore};

fn main() {
    let store = Arc::new(MemoryVectorStore::new());
    let ingest = IngestionService::new(ChunkWriter::new(store.clone(), 64), 80);
    let docs: Vec<Document> = (0..5)
        .map(|i| Document::with_id(format!("d{i}"), format!("document number {i} about retrieval")))
        .collect();
    let (n, chunks) = ingest.ingest(&docs).unwrap();
    println!("ingested documents={n} chunks={chunks} stored={}", store.scan().unwrap().len());
}
