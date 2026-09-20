use crate::core::{Error, Result};

use super::super::KvStore;

#[derive(Debug, Default)]
pub struct FjallKv;

impl KvStore for FjallKv {
    fn get(&self, _: &str) -> Result<Option<Vec<u8>>> {
        Err(Error::unimplemented("fjall"))
    }
    fn put(&self, _: &str, _: &[u8]) -> Result<()> {
        Err(Error::unimplemented("fjall"))
    }
    fn delete(&self, _: &str) -> Result<()> {
        Err(Error::unimplemented("fjall"))
    }
}
