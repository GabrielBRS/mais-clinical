use std::sync::Arc;

use ai_data_engine::core::{Document, Query};
use ai_data_engine::ingestion::{ChunkWriter, IngestionService};
use ai_data_engine::rag::RagPipeline;
use ai_data_engine::retrieval::{DenseRetriever, HybridRetriever, RetrievalService, SparseRetriever};
use ai_data_engine::storage::MemoryVectorStore;

fn main() {
    let store = Arc::new(MemoryVectorStore::new());
    let ingest = IngestionService::new(ChunkWriter::new(store.clone(), 64), 256);
    ingest
        .ingest(&[
            Document::with_id("1", "ACE1 is the IPC framing used by the three engines."),
            Document::with_id("2", "The data engine does retrieval, ranking and RAG packing."),
        ])
        .unwrap();

    let rag = RagPipeline::new(RetrievalService::new(HybridRetriever::new(
        DenseRetriever::new(store.clone(), 64),
        SparseRetriever::new(store),
    )));
    let ctx = rag
        .run(Query::new("ipc framing ACE1").with_top_k(2), 1024)
        .unwrap();
    println!("{}", ctx.packed_text);
}
