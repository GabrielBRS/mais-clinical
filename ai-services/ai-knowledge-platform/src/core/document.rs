use serde::{Deserialize, Serialize};

use super::{DocumentId, Metadata};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Document {
    pub id: DocumentId,
    pub text: String,
    pub metadata: Metadata,
}

impl Document {
    pub fn new(text: impl Into<String>) -> Self {
        Self {
            id: DocumentId::new(),
            text: text.into(),
            metadata: Metadata::new(),
        }
    }

    pub fn with_id(id: impl Into<String>, text: impl Into<String>) -> Self {
        Self {
            id: DocumentId::from_raw(id.into()),
            text: text.into(),
            metadata: Metadata::new(),
        }
    }
}
