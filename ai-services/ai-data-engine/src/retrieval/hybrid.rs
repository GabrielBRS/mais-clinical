use crate::core::{Query, Result, ScoredChunk};
use crate::ranking::reciprocal_rank::fuse;

use super::{DenseRetriever, Retriever, SparseRetriever};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum HybridMode {
    Dense,
    Sparse,
    Hybrid,
}

impl HybridMode {
    pub fn parse(raw: &str) -> Self {
        match raw.to_ascii_lowercase().as_str() {
            "dense" => Self::Dense,
            "sparse" => Self::Sparse,
            _ => Self::Hybrid,
        }
    }
}

pub struct HybridRetriever {
    dense: DenseRetriever,
    sparse: SparseRetriever,
}

impl HybridRetriever {
    pub fn new(dense: DenseRetriever, sparse: SparseRetriever) -> Self {
        Self { dense, sparse }
    }

    pub fn retrieve_mode(&self, query: &Query, mode: HybridMode) -> Result<Vec<ScoredChunk>> {
        match mode {
            HybridMode::Dense => self.dense.retrieve(query),
            HybridMode::Sparse => self.sparse.retrieve(query),
            HybridMode::Hybrid => {
                let dense = self.dense.retrieve(query)?;
                let sparse = self.sparse.retrieve(query)?;
                Ok(fuse(&[dense, sparse], query.top_k))
            }
        }
    }
}

impl Retriever for HybridRetriever {
    fn retrieve(&self, query: &Query) -> Result<Vec<ScoredChunk>> {
        self.retrieve_mode(query, HybridMode::Hybrid)
    }
}
