use std::sync::{
    Arc,
    atomic::{AtomicBool, Ordering},
};

use crate::{application::records::RecordStore, infrastructure::agent::MojoPythonRuntimeClient};

#[derive(Clone, Debug)]
pub struct RuntimeState {
    inner: Arc<RuntimeStateInner>,
}

#[derive(Debug)]
struct RuntimeStateInner {
    ready: AtomicBool,
    version: &'static str,
}

impl RuntimeState {
    pub fn new(version: &'static str) -> Self {
        Self {
            inner: Arc::new(RuntimeStateInner {
                ready: AtomicBool::new(false),
                version,
            }),
        }
    }

    pub fn is_ready(&self) -> bool {
        self.inner.ready.load(Ordering::Acquire)
    }

    pub fn mark_ready(&self) {
        self.inner.ready.store(true, Ordering::Release);
    }

    pub fn mark_not_ready(&self) {
        self.inner.ready.store(false, Ordering::Release);
    }

    pub fn version(&self) -> &'static str {
        self.inner.version
    }
}

/// Public composition root. Traditional stores stay here; the agent runtime is optional.
#[derive(Clone, Debug)]
pub struct AppState {
    pub runtime: RuntimeState,
    pub records: RecordStore,
    pub agents: MojoPythonRuntimeClient,
}

impl AppState {
    pub fn new(runtime: RuntimeState, agents: MojoPythonRuntimeClient) -> Self {
        Self {
            runtime,
            records: RecordStore::new(),
            agents,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn readiness_transitions_are_explicit() {
        let state = RuntimeState::new("test");
        assert!(!state.is_ready());

        state.mark_ready();
        assert!(state.is_ready());

        state.mark_not_ready();
        assert!(!state.is_ready());
    }
}
