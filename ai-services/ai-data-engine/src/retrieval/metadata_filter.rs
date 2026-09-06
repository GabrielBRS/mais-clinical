use std::collections::BTreeMap;

use crate::core::ScoredChunk;

pub fn apply(hits: Vec<ScoredChunk>, filter: &BTreeMap<String, String>) -> Vec<ScoredChunk> {
    if filter.is_empty() {
        return hits;
    }
    hits.into_iter()
        .filter(|hit| hit.chunk.metadata.matches(filter))
        .collect()
}
