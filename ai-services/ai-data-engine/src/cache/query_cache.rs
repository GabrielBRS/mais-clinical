use std::collections::HashMap;
use std::sync::Mutex;

use crate::core::{Error, Result};

#[derive(Default)]
pub struct QueryCache {
    inner: Mutex<HashMap<String, String>>,
}

impl QueryCache {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn get(&self, key: &str) -> Result<Option<String>> {
        let map = self.inner.lock().map_err(|e| Error::internal(e.to_string()))?;
        Ok(map.get(key).cloned())
    }

    pub fn put(&self, key: String, value: String) -> Result<()> {
        let mut map = self.inner.lock().map_err(|e| Error::internal(e.to_string()))?;
        map.insert(key, value);
        Ok(())
    }
}
