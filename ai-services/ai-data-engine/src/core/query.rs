use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

use super::QueryId;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Query {
    pub id: QueryId,
    pub text: String,
    pub top_k: usize,
    pub filter: BTreeMap<String, String>,
}

impl Query {
    pub fn new(text: impl Into<String>) -> Self {
        Self {
            id: QueryId::new(),
            text: text.into(),
            top_k: 8,
            filter: BTreeMap::new(),
        }
    }

    pub fn with_top_k(mut self, top_k: usize) -> Self {
        self.top_k = top_k.max(1);
        self
    }
}
