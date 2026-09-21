use std::io;

use thiserror::Error;

use crate::config::ConfigError;

#[derive(Debug, Error)]
pub enum RuntimeError {
    #[error(transparent)]
    Config(#[from] ConfigError),
    #[error("runtime I/O failed: {0}")]
    Io(#[from] io::Error),
    #[error("health check failed: {0}")]
    HealthCheck(String),
    #[error("invalid argument: {0}")]
    InvalidArgument(String),
    #[error("agent engine unavailable: {0}")]
    AgentUnavailable(String),
    #[error("{0}")]
    Internal(String),
}
