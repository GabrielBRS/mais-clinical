use std::sync::Arc;

use crate::core::{Embedding, Query, Result, Score, ScoreSource, ScoredChunk};
use crate::storage::VectorStore;

use super::Retriever;

pub struct DenseRetriever {
    store: Arc<dyn VectorStore>,
    dim: usize,
}

impl DenseRetriever {
    pub fn new(store: Arc<dyn VectorStore>, dim: usize) -> Self {
        Self { store, dim }
    }
}

impl Retriever for DenseRetriever {
    fn retrieve(&self, query: &Query) -> Result<Vec<ScoredChunk>> {
        let embedding = Embedding::hashed(&query.text, self.dim);
        let chunks = self.store.search(&embedding, query.top_k)?;
        let hits = chunks
            .into_iter()
            .filter(|c| c.metadata.matches(&query.filter))
            .map(|chunk| {
                let value = chunk
                    .embedding
                    .as_ref()
                    .map(|e| e.cosine(&embedding))
                    .unwrap_or(0.0);
                ScoredChunk {
                    chunk,
                    score: Score::new(value, ScoreSource::Dense),
                }
            })
            .collect();
        Ok(hits)
    }
}
