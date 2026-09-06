use crate::core::{Error, Result};

use super::super::KvStore;

#[derive(Debug, Default)]
pub struct RedbKv;

impl KvStore for RedbKv {
    fn get(&self, _: &str) -> Result<Option<Vec<u8>>> {
        Err(Error::unimplemented("redb"))
    }
    fn put(&self, _: &str, _: &[u8]) -> Result<()> {
        Err(Error::unimplemented("redb"))
    }
    fn delete(&self, _: &str) -> Result<()> {
        Err(Error::unimplemented("redb"))
    }
}
