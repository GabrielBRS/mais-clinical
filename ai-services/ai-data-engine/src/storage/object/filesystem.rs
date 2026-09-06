use std::fs;
use std::path::{Path, PathBuf};

use crate::core::{Error, Result};

use super::super::ObjectStore;

pub struct FilesystemStore {
    root: PathBuf,
}

impl FilesystemStore {
    pub fn new(root: impl AsRef<Path>) -> Result<Self> {
        let root = root.as_ref().to_path_buf();
        fs::create_dir_all(&root).map_err(|e| Error::internal(e.to_string()))?;
        Ok(Self { root })
    }
}

impl ObjectStore for FilesystemStore {
    fn put(&self, key: &str, bytes: &[u8]) -> Result<()> {
        let path = self.root.join(key);
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).map_err(|e| Error::internal(e.to_string()))?;
        }
        fs::write(path, bytes).map_err(|e| Error::internal(e.to_string()))
    }

    fn get(&self, key: &str) -> Result<Vec<u8>> {
        fs::read(self.root.join(key)).map_err(|e| Error::not_found(e.to_string()))
    }
}
