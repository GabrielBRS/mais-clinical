use std::collections::HashMap;

use crate::port::storage::Storage;

#[derive(Default)]
pub struct MemoryStore(HashMap<String, Vec<u8>>);

impl Storage for MemoryStore {
    fn put(&mut self, key: &str, bytes: &[u8]) {
        self.0.insert(key.to_string(), bytes.to_vec());
    }
}
