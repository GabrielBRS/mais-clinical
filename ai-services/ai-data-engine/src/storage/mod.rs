//! Ports de persistência. Adapters concretos só entram no composition root.

pub mod kv;
pub mod object;
pub mod traits;
pub mod vector;

pub use traits::{KvStore, ObjectStore, VectorStore};
pub use vector::MemoryVectorStore;
