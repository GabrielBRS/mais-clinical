use crate::core::{Query, ScoredChunk};

use super::{score_overlap, take_top_k};

pub struct Ranker;

impl Ranker {
    pub fn rerank(&self, query: &Query, hits: Vec<ScoredChunk>) -> Vec<ScoredChunk> {
        let rescored = hits
            .into_iter()
            .map(|mut hit| {
                hit.score.value = score_overlap(&query.text, &hit.chunk.text);
                hit.score.source = crate::core::ScoreSource::Rerank;
                hit
            })
            .collect();
        take_top_k(rescored, query.top_k)
    }
}
