pub mod application;
pub mod bootstrap;
pub mod config;
pub mod error;
pub mod infrastructure;
pub mod observability;
pub mod ports;
pub mod proto;
pub mod transport;

pub const VERSION: &str = env!("CARGO_PKG_VERSION");
