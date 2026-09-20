//! Tipos de domínio. Nada aqui conhece transport ou storage concreto.

mod chunk;
mod context;
mod document;
pub(crate) mod embedding;
mod error;
mod ids;
mod metadata;
mod query;
mod score;

pub use chunk::Chunk;
pub use context::{Citation, Context};
pub use document::Document;
pub use embedding::Embedding;
pub use error::{Error, Result};
pub use ids::{ChunkId, DocumentId, QueryId};
pub use metadata::Metadata;
pub use query::Query;
pub use score::{Score, ScoreSource, ScoredChunk};
