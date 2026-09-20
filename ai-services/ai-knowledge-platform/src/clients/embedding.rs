use crate::core::{Embedding, Result};

use super::ComputeEngineClient;

pub struct EmbeddingClient {
    pub compute: ComputeEngineClient,
    pub dim: usize,
}

impl EmbeddingClient {
    pub fn local(dim: usize, compute: ComputeEngineClient) -> Self {
        Self { compute, dim }
    }

    pub fn embed_local(&self, text: &str) -> Embedding {
        Embedding::hashed(text, self.dim)
    }

    pub async fn health(&self) -> Result<String> {
        self.compute.health().await
    }
}
