use serde::Serialize;

use crate::core::{Error, Result};

pub fn to_json<T: Serialize>(value: &T) -> Result<String> {
    serde_json::to_string(value).map_err(|e| Error::internal(e.to_string()))
}
