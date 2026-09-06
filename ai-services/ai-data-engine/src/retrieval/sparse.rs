use std::collections::HashSet;
use std::sync::Arc;

use crate::core::embedding::tokenize;
use crate::core::{Query, Result, Score, ScoreSource, ScoredChunk};
use crate::storage::VectorStore;

use super::Retriever;

pub struct SparseRetriever {
    store: Arc<dyn VectorStore>,
}

impl SparseRetriever {
    pub fn new(store: Arc<dyn VectorStore>) -> Self {
        Self { store }
    }
}

impl Retriever for SparseRetriever {
    fn retrieve(&self, query: &Query) -> Result<Vec<ScoredChunk>> {
        let q: HashSet<String> = tokenize(&query.text).into_iter().collect();
        if q.is_empty() {
            return Ok(Vec::new());
        }
        let mut hits: Vec<ScoredChunk> = self
            .store
            .scan()?
            .into_iter()
            .filter(|c| c.metadata.matches(&query.filter))
            .filter_map(|chunk| {
                let tokens: HashSet<String> = tokenize(&chunk.text).into_iter().collect();
                let overlap = q.intersection(&tokens).count();
                if overlap == 0 {
                    return None;
                }
                let value = overlap as f32 / q.len() as f32;
                Some(ScoredChunk {
                    chunk,
                    score: Score::new(value, ScoreSource::Sparse),
                })
            })
            .collect();
        hits.sort_by(|a, b| b.score.value.total_cmp(&a.score.value));
        hits.truncate(query.top_k);
        Ok(hits)
    }
}
