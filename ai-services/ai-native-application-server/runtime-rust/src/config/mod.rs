use std::{
    env,
    net::{IpAddr, SocketAddr},
};

use thiserror::Error;

const DEFAULT_APP_NAME: &str = "ai-native-runtime";
const DEFAULT_APP_ENV: &str = "development";
const DEFAULT_HTTP_HOST: &str = "0.0.0.0";
const DEFAULT_HTTP_PORT: &str = "8080";
const DEFAULT_LOG_LEVEL: &str = "info";
const DEFAULT_MOJO_RUNTIME_URL: &str = "http://127.0.0.1:8090";

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Settings {
    pub app_name: String,
    pub app_env: String,
    pub http_addr: SocketAddr,
    pub log_level: String,
    pub mojo_runtime_url: String,
}

impl Settings {
    pub fn load() -> Result<Self, ConfigError> {
        Self::from_reader(|key| env::var(key).ok())
    }

    pub fn from_reader(mut read: impl FnMut(&str) -> Option<String>) -> Result<Self, ConfigError> {
        let host = read("AOR_HTTP_HOST").unwrap_or_else(|| DEFAULT_HTTP_HOST.to_owned());
        let port = read("AOR_HTTP_PORT").unwrap_or_else(|| DEFAULT_HTTP_PORT.to_owned());
        let ip: IpAddr = host.parse().map_err(|_| ConfigError::InvalidHttpAddress {
            host: host.clone(),
            port: port.clone(),
        })?;
        let port_number: u16 = port
            .parse()
            .map_err(|_| ConfigError::InvalidHttpAddress { host, port })?;
        let http_addr = SocketAddr::new(ip, port_number);

        let mojo_runtime_url =
            read("AOR_MOJO_RUNTIME_URL").unwrap_or_else(|| DEFAULT_MOJO_RUNTIME_URL.to_owned());
        if !(mojo_runtime_url.starts_with("http://") || mojo_runtime_url.starts_with("https://")) {
            return Err(ConfigError::InvalidMojoRuntimeUrl(mojo_runtime_url));
        }

        Ok(Self {
            app_name: read("AOR_APP_NAME").unwrap_or_else(|| DEFAULT_APP_NAME.to_owned()),
            app_env: read("AOR_APP_ENV").unwrap_or_else(|| DEFAULT_APP_ENV.to_owned()),
            http_addr,
            log_level: read("AOR_LOG_LEVEL").unwrap_or_else(|| DEFAULT_LOG_LEVEL.to_owned()),
            mojo_runtime_url,
        })
    }
}

#[derive(Debug, Error, Eq, PartialEq)]
pub enum ConfigError {
    #[error("invalid HTTP listen address: {host}:{port}")]
    InvalidHttpAddress { host: String, port: String },
    #[error("Mojo agent runtime URL must use http or https: {0}")]
    InvalidMojoRuntimeUrl(String),
}

#[cfg(test)]
mod tests {
    use std::collections::HashMap;

    use super::*;

    #[test]
    fn defaults_are_stable() {
        let settings = Settings::from_reader(|_| None).expect("default settings must be valid");

        assert_eq!(settings.app_name, "ai-native-runtime");
        assert_eq!(settings.http_addr, "0.0.0.0:8080".parse().unwrap());
        assert_eq!(settings.mojo_runtime_url, "http://127.0.0.1:8090");
    }

    #[test]
    fn environment_values_are_validated() {
        let values = HashMap::from([
            ("AOR_HTTP_HOST", "127.0.0.1"),
            ("AOR_HTTP_PORT", "18080"),
            ("AOR_MOJO_RUNTIME_URL", "http://127.0.0.1:8090"),
        ]);
        let settings = Settings::from_reader(|key| values.get(key).map(ToString::to_string))
            .expect("settings must be valid");

        assert_eq!(settings.http_addr, "127.0.0.1:18080".parse().unwrap());
        assert_eq!(settings.mojo_runtime_url, "http://127.0.0.1:8090");
    }

    #[test]
    fn invalid_mojo_runtime_scheme_is_rejected() {
        let error = Settings::from_reader(|key| {
            (key == "AOR_MOJO_RUNTIME_URL").then(|| "file:///tmp/agent.sock".to_owned())
        })
        .expect_err("invalid scheme must fail");

        assert!(matches!(error, ConfigError::InvalidMojoRuntimeUrl(_)));
    }
}
