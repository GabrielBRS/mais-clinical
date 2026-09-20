use crate::core::{Query, ScoredChunk};

use super::Ranker;

/// Rerank local. O client do compute-engine entra quando o socket existir.
pub struct LocalReranker {
    inner: Ranker,
}

impl Default for LocalReranker {
    fn default() -> Self {
        Self { inner: Ranker }
    }
}

impl LocalReranker {
    pub fn rerank(&self, query: &Query, hits: Vec<ScoredChunk>) -> Vec<ScoredChunk> {
        self.inner.rerank(query, hits)
    }
}
