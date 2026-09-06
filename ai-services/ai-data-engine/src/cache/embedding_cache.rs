use std::collections::HashMap;
use std::sync::Mutex;

use crate::core::{Embedding, Error, Result};

#[derive(Default)]
pub struct EmbeddingCache {
    inner: Mutex<HashMap<String, Embedding>>,
}

impl EmbeddingCache {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn get(&self, text: &str) -> Result<Option<Embedding>> {
        let map = self.inner.lock().map_err(|e| Error::internal(e.to_string()))?;
        Ok(map.get(text).cloned())
    }

    pub fn put(&self, text: String, embedding: Embedding) -> Result<()> {
        let mut map = self.inner.lock().map_err(|e| Error::internal(e.to_string()))?;
        map.insert(text, embedding);
        Ok(())
    }
}
