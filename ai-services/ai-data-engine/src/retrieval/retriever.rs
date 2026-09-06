use crate::core::{Query, Result, ScoredChunk};

pub trait Retriever: Send + Sync {
    fn retrieve(&self, query: &Query) -> Result<Vec<ScoredChunk>>;
}
