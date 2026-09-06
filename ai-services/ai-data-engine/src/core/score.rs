use serde::{Deserialize, Serialize};

use super::Chunk;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ScoreSource {
    Dense,
    Sparse,
    Hybrid,
    Rerank,
    Fusion,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Score {
    pub value: f32,
    pub source: ScoreSource,
}

impl Score {
    pub fn new(value: f32, source: ScoreSource) -> Self {
        Self { value, source }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScoredChunk {
    pub chunk: Chunk,
    pub score: Score,
}
