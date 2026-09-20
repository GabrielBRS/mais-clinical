use serde::{Deserialize, Serialize};

use super::ScoredChunk;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Citation {
    pub document_id: String,
    pub chunk_id: String,
    pub quote: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct Context {
    pub chunks: Vec<ScoredChunk>,
    pub packed_text: String,
    pub citations: Vec<Citation>,
}
