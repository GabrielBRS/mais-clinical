use crate::core::{Context, Query, Result};
use crate::ranking::LocalReranker;
use crate::retrieval::{HybridMode, RetrievalService};

use super::compression::compress;
use super::context_builder;

pub struct RagPipeline {
    retrieval: RetrievalService,
    reranker: LocalReranker,
}

impl RagPipeline {
    pub fn new(retrieval: RetrievalService) -> Self {
        Self {
            retrieval,
            reranker: LocalReranker::default(),
        }
    }

    pub fn run(&self, query: Query, max_context_chars: usize) -> Result<Context> {
        let hits = self.retrieval.retrieve(query.clone(), HybridMode::Hybrid)?;
        let ranked = self.reranker.rerank(&query, hits);
        let compressed = compress(ranked, max_context_chars.max(64));
        Ok(context_builder::build(compressed, max_context_chars.max(64)))
    }
}
