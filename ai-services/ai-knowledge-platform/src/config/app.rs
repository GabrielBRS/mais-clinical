use std::net::SocketAddr;
use std::path::PathBuf;

use anyhow::{Context, bail};

use super::{CacheConfig, DatabaseConfig, TelemetryConfig};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AppEnv {
    Development,
    Staging,
    Production,
}

#[derive(Debug, Clone)]
pub struct AppConfig {
    pub app_name: String,
    pub app_env: AppEnv,
    pub http_bind: SocketAddr,
    pub grpc_bind: SocketAddr,
    pub ipc_path: PathBuf,
    pub compute_ipc_path: PathBuf,
    pub database: DatabaseConfig,
    pub cache: CacheConfig,
    pub telemetry: TelemetryConfig,
}

impl AppConfig {
    pub fn from_env() -> anyhow::Result<Self> {
        Ok(Self {
            app_name: env_or("ADE_APP_NAME", "ai-data-engine"),
            app_env: parse_app_env()?,
            http_bind: parse_addr("ADE_HTTP_BIND", "0.0.0.0:8082")?,
            grpc_bind: parse_addr("ADE_GRPC_BIND", "0.0.0.0:50053")?,
            ipc_path: PathBuf::from(env_or(
                "ADE_IPC_PATH",
                "/tmp/ai-data-engine.sock",
            )),
            compute_ipc_path: PathBuf::from(env_or(
                "ADE_COMPUTE_IPC_PATH",
                "/tmp/ai-compute-engine.sock",
            )),
            database: DatabaseConfig::from_env(),
            cache: CacheConfig::from_env(),
            telemetry: TelemetryConfig::from_env(),
        })
    }
}

pub(crate) fn env_or(key: &str, default: &str) -> String {
    std::env::var(key).ok().filter(|v| !v.is_empty()).unwrap_or_else(|| default.to_owned())
}

fn parse_addr(key: &str, default: &str) -> anyhow::Result<SocketAddr> {
    let raw = env_or(key, default);
    raw.parse()
        .with_context(|| format!("{key} invalido: {raw}"))
}

fn parse_app_env() -> anyhow::Result<AppEnv> {
    match env_or("ADE_APP_ENV", "development").to_ascii_lowercase().as_str() {
        "development" | "dev" => Ok(AppEnv::Development),
        "staging" => Ok(AppEnv::Staging),
        "production" | "prod" => Ok(AppEnv::Production),
        other => bail!("ADE_APP_ENV invalido: {other}"),
    }
}
