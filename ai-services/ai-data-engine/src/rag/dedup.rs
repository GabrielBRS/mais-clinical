use std::collections::HashSet;

use crate::core::Chunk;

pub fn dedup_chunks(chunks: Vec<Chunk>) -> Vec<Chunk> {
    let mut seen = HashSet::new();
    chunks
        .into_iter()
        .filter(|c| seen.insert(normalize(&c.text)))
        .collect()
}

fn normalize(text: &str) -> String {
    text.split_whitespace().collect::<Vec<_>>().join(" ").to_lowercase()
}
