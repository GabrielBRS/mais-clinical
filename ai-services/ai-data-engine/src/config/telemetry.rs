use super::app::env_or;

#[derive(Debug, Clone)]
pub struct TelemetryConfig {
    pub log_level: String,
}

impl TelemetryConfig {
    pub fn from_env() -> Self {
        Self {
            log_level: env_or("ADE_LOG_LEVEL", "info"),
        }
    }
}
