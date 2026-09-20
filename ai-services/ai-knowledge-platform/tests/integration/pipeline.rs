use std::sync::Arc;

use ai_data_engine::core::{Document, Query};
use ai_data_engine::ingestion::{ChunkWriter, IngestionService};
use ai_data_engine::pipeline::Stage;
use ai_data_engine::pipeline::{PipelineExecutor, graph::PipelineGraph};
use ai_data_engine::rag::RagPipeline;
use ai_data_engine::retrieval::{DenseRetriever, HybridRetriever, RetrievalService, SparseRetriever};
use ai_data_engine::storage::MemoryVectorStore;
use ai_data_engine::transform::{clean, normalize};

struct NormalizeStage;
impl Stage for NormalizeStage {
    fn name(&self) -> &str {
        "normalize"
    }
    fn run(&self, input: String) -> ai_data_engine::core::Result<String> {
        Ok(normalize(&clean(&input)))
    }
}

#[test]
fn transform_pipeline_runs_stages() {
    let exec = PipelineExecutor::new(PipelineGraph::linear(vec![Box::new(NormalizeStage)]));
    let out = exec.run("  hello   world  ".into()).unwrap();
    assert_eq!(out, "hello world");
}

#[test]
fn rag_builds_context() {
    let store = Arc::new(MemoryVectorStore::new());
    let ingest = IngestionService::new(ChunkWriter::new(store.clone(), 64), 128);
    ingest
        .ingest(&[Document::with_id(
            "doc",
            "reciprocal rank fusion combina listas de retrieval",
        )])
        .unwrap();
    let retrieval = RetrievalService::new(HybridRetriever::new(
        DenseRetriever::new(store.clone(), 64),
        SparseRetriever::new(store),
    ));
    let rag = RagPipeline::new(retrieval);
    let ctx = rag.run(Query::new("rank fusion").with_top_k(3), 512).unwrap();
    assert!(!ctx.packed_text.is_empty());
    assert!(!ctx.citations.is_empty());
}
