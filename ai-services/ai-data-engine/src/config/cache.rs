use super::app::env_or;

#[derive(Debug, Clone)]
pub struct CacheConfig {
    pub enabled: bool,
    pub max_entries: usize,
}

impl CacheConfig {
    pub fn from_env() -> Self {
        Self {
            enabled: env_or("ADE_CACHE_ENABLED", "true") != "false",
            max_entries: env_or("ADE_CACHE_MAX", "4096")
                .parse()
                .unwrap_or(4096),
        }
    }
}
