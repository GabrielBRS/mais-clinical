use crate::core::{Error, Result};

use super::super::ObjectStore;

#[derive(Debug, Default)]
pub struct S3Store;

impl ObjectStore for S3Store {
    fn put(&self, _: &str, _: &[u8]) -> Result<()> {
        Err(Error::unimplemented("s3"))
    }
    fn get(&self, _: &str) -> Result<Vec<u8>> {
        Err(Error::unimplemented("s3"))
    }
}
