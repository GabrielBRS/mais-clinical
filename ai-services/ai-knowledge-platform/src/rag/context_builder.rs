use crate::core::{Context, ScoredChunk};

use super::citation_builder::citations;
use super::context_packer::pack;

pub fn build(hits: Vec<ScoredChunk>, max_chars: usize) -> Context {
    let packed_text = pack(&hits, max_chars);
    let citations = citations(&hits);
    Context {
        chunks: hits,
        packed_text,
        citations,
    }
}
