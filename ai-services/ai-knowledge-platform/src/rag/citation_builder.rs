use crate::core::{Citation, ScoredChunk};

pub fn citations(hits: &[ScoredChunk]) -> Vec<Citation> {
    hits.iter()
        .map(|hit| Citation {
            document_id: hit.chunk.document_id.to_string(),
            chunk_id: hit.chunk.id.to_string(),
            quote: hit.chunk.text.chars().take(160).collect(),
        })
        .collect()
}
