//! Configuração carregada no composition root (env / `.env`).

mod app;
mod cache;
mod database;
mod telemetry;

pub use app::{AppConfig, AppEnv};
pub use cache::CacheConfig;
pub use database::{DatabaseConfig, VectorBackend};
pub use telemetry::TelemetryConfig;
