use crate::core::ScoredChunk;

pub fn take_top_k(mut hits: Vec<ScoredChunk>, k: usize) -> Vec<ScoredChunk> {
    hits.sort_by(|a, b| b.score.value.total_cmp(&a.score.value));
    hits.truncate(k.max(1));
    hits
}
