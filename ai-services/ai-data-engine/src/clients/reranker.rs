use crate::core::{Query, ScoredChunk};
use crate::ranking::LocalReranker;

use super::ComputeEngineClient;

pub struct RerankerClient {
    pub compute: ComputeEngineClient,
    local: LocalReranker,
}

impl RerankerClient {
    pub fn new(compute: ComputeEngineClient) -> Self {
        Self {
            compute,
            local: LocalReranker::default(),
        }
    }

    pub fn rerank_local(&self, query: &Query, hits: Vec<ScoredChunk>) -> Vec<ScoredChunk> {
        self.local.rerank(query, hits)
    }
}
