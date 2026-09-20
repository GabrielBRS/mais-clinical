use std::{future::Future, pin::Pin};

use thiserror::Error;

pub type AgentRuntimeFuture<'a> =
    Pin<Box<dyn Future<Output = Result<AgentRuntimeResponse, AgentRuntimeError>> + Send + 'a>>;

/// Internal-only port from a Rust use case to the Mojo agent runtime.
///
/// Public transports must never expose this port directly. Authorization,
/// validation and business decisions happen in Rust before an invocation is
/// constructed.
pub trait AgentRuntime: Send + Sync {
    fn invoke(&self, request: AgentRuntimeRequest) -> AgentRuntimeFuture<'_>;
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct AgentRuntimeRequest {
    pub request_id: String,
    pub agent_id: String,
    pub prompt: String,
    pub context: Vec<String>,
    pub retrieve: bool,
    pub backend: String,
    pub workflow: bool,
}

impl AgentRuntimeRequest {
    pub fn agent(prompt: impl Into<String>) -> Self {
        Self {
            request_id: String::new(),
            agent_id: "default".to_owned(),
            prompt: prompt.into(),
            context: Vec::new(),
            retrieve: false,
            backend: "local".to_owned(),
            workflow: false,
        }
    }

    pub fn workflow(prompt: impl Into<String>) -> Self {
        let mut request = Self::agent(prompt);
        request.workflow = true;
        request
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct AgentRuntimeResponse {
    pub execution_id: String,
    pub text: String,
    pub context: Vec<String>,
    pub steps: Vec<String>,
}

#[derive(Clone, Debug, Error, Eq, PartialEq)]
pub enum AgentRuntimeError {
    #[error("Mojo agent runtime is unavailable")]
    Unavailable,
    #[error("Mojo agent runtime timed out")]
    Timeout,
    #[error("Mojo agent runtime rejected the invocation: {0}")]
    Rejected(String),
    #[error("Mojo agent runtime returned an invalid response: {0}")]
    InvalidResponse(String),
}
