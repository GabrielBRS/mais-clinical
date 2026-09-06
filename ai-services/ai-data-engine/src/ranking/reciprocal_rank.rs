use std::collections::HashMap;

use crate::core::{Score, ScoreSource, ScoredChunk};

/// Reciprocal Rank Fusion. k=60 é o default clássico.
pub fn fuse(lists: &[Vec<ScoredChunk>], top_k: usize) -> Vec<ScoredChunk> {
    const K: f32 = 60.0;
    let mut acc: HashMap<String, (f32, ScoredChunk)> = HashMap::new();

    for list in lists {
        for (rank, hit) in list.iter().enumerate() {
            let add = 1.0 / (K + (rank as f32) + 1.0);
            acc.entry(hit.chunk.id.as_str().to_owned())
                .and_modify(|(score, _)| *score += add)
                .or_insert_with(|| (add, hit.clone()));
        }
    }

    let mut fused: Vec<ScoredChunk> = acc
        .into_values()
        .map(|(value, mut hit)| {
            hit.score = Score::new(value, ScoreSource::Fusion);
            hit
        })
        .collect();
    fused.sort_by(|a, b| b.score.value.total_cmp(&a.score.value));
    fused.truncate(top_k.max(1));
    fused
}
