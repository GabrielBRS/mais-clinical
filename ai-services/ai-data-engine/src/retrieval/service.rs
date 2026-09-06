use crate::core::{Query, Result, ScoredChunk};

use super::{HybridMode, HybridRetriever};

pub struct RetrievalService {
    retriever: HybridRetriever,
}

impl RetrievalService {
    pub fn new(retriever: HybridRetriever) -> Self {
        Self { retriever }
    }

    pub fn retrieve(&self, query: Query, mode: HybridMode) -> Result<Vec<ScoredChunk>> {
        self.retriever.retrieve_mode(&query, mode)
    }
}
