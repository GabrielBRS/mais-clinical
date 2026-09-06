use crate::core::{Error, Result};

use super::super::KvStore;

#[derive(Debug, Default)]
pub struct RedisKv;

impl KvStore for RedisKv {
    fn get(&self, _: &str) -> Result<Option<Vec<u8>>> {
        Err(Error::unimplemented("redis"))
    }
    fn put(&self, _: &str, _: &[u8]) -> Result<()> {
        Err(Error::unimplemented("redis"))
    }
    fn delete(&self, _: &str) -> Result<()> {
        Err(Error::unimplemented("redis"))
    }
}
