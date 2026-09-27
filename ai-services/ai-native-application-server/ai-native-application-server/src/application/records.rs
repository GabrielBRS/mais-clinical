use std::{
    collections::HashMap,
    sync::{
        Arc, Mutex,
        atomic::{AtomicU64, Ordering},
    },
};

use serde::{Deserialize, Serialize};

use crate::error::RuntimeError;

/// Traditional backend store. Never calls the agent runtime.
///
/// Layer: application
/// Why here: CRUD use cases belong to the Rust runtime, not the agent process.
#[derive(Clone, Debug)]
pub struct RecordStore {
    inner: Arc<Mutex<HashMap<String, Record>>>,
    seq: Arc<AtomicU64>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Record {
    pub id: String,
    pub title: String,
}

#[derive(Debug, Deserialize)]
pub struct CreateRecord {
    pub title: String,
}

impl RecordStore {
    pub fn new() -> Self {
        Self {
            inner: Arc::new(Mutex::new(HashMap::new())),
            seq: Arc::new(AtomicU64::new(1)),
        }
    }

    pub fn list(&self) -> Result<Vec<Record>, RuntimeError> {
        let guard = self
            .inner
            .lock()
            .map_err(|_| RuntimeError::Internal("record store poisoned".to_owned()))?;
        let mut records: Vec<Record> = guard.values().cloned().collect();
        records.sort_by(|left, right| left.id.cmp(&right.id));
        Ok(records)
    }

    pub fn get(&self, id: &str) -> Result<Option<Record>, RuntimeError> {
        let guard = self
            .inner
            .lock()
            .map_err(|_| RuntimeError::Internal("record store poisoned".to_owned()))?;
        Ok(guard.get(id).cloned())
    }

    pub fn create(&self, command: CreateRecord) -> Result<Record, RuntimeError> {
        let title = command.title.trim().to_owned();
        if title.is_empty() {
            return Err(RuntimeError::InvalidArgument(
                "title obrigatorio".to_owned(),
            ));
        }

        let id = format!("rec-{}", self.seq.fetch_add(1, Ordering::Relaxed));
        let record = Record {
            id: id.clone(),
            title,
        };
        let mut guard = self
            .inner
            .lock()
            .map_err(|_| RuntimeError::Internal("record store poisoned".to_owned()))?;
        guard.insert(id, record.clone());
        Ok(record)
    }
}

impl Default for RecordStore {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn create_list_and_get_do_not_need_mojo() {
        let store = RecordStore::new();
        let created = store
            .create(CreateRecord {
                title: "paciente".to_owned(),
            })
            .expect("create");

        assert_eq!(created.id, "rec-1");
        assert_eq!(store.list().expect("list"), vec![created.clone()]);
        assert_eq!(store.get("rec-1").expect("get"), Some(created));
        assert_eq!(store.get("missing").expect("missing"), None);
    }

    #[test]
    fn empty_title_is_rejected() {
        let store = RecordStore::new();
        let error = store
            .create(CreateRecord {
                title: "   ".to_owned(),
            })
            .expect_err("blank title");
        assert!(matches!(error, RuntimeError::InvalidArgument(_)));
    }
}
