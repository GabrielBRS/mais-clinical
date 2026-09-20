mod fjall;
mod redb;
mod redis;

pub use fjall::FjallKv;
pub use redb::RedbKv;
pub use redis::RedisKv;

use std::collections::HashMap;
use std::sync::Mutex;

use crate::core::{Error, Result};

use super::KvStore;

#[derive(Default)]
pub struct MemoryKv {
    inner: Mutex<HashMap<String, Vec<u8>>>,
}

impl MemoryKv {
    pub fn new() -> Self {
        Self::default()
    }
}

impl KvStore for MemoryKv {
    fn get(&self, key: &str) -> Result<Option<Vec<u8>>> {
        let map = self.inner.lock().map_err(|e| Error::internal(e.to_string()))?;
        Ok(map.get(key).cloned())
    }

    fn put(&self, key: &str, value: &[u8]) -> Result<()> {
        let mut map = self.inner.lock().map_err(|e| Error::internal(e.to_string()))?;
        map.insert(key.to_owned(), value.to_vec());
        Ok(())
    }

    fn delete(&self, key: &str) -> Result<()> {
        let mut map = self.inner.lock().map_err(|e| Error::internal(e.to_string()))?;
        map.remove(key);
        Ok(())
    }
}
