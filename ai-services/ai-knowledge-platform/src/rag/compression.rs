use crate::core::ScoredChunk;

/// Compressão extractive: corta o texto do chunk no limite.
pub fn compress(hits: Vec<ScoredChunk>, max_chars: usize) -> Vec<ScoredChunk> {
    hits.into_iter()
        .map(|mut hit| {
            if hit.chunk.text.chars().count() > max_chars {
                hit.chunk.text = hit.chunk.text.chars().take(max_chars).collect();
            }
            hit
        })
        .collect()
}
