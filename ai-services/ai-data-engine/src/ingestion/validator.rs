use crate::core::{Document, Error, Result};

pub fn validate(document: &Document) -> Result<()> {
    if document.text.trim().is_empty() {
        return Err(Error::invalid("documento vazio"));
    }
    if document.id.as_str().is_empty() {
        return Err(Error::invalid("document.id vazio"));
    }
    Ok(())
}
