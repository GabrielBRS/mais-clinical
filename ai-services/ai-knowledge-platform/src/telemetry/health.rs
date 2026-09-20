#[derive(Debug, Clone)]
pub struct Health {
    pub ready: bool,
    pub version: &'static str,
}

impl Health {
    pub fn ok() -> Self {
        Self {
            ready: true,
            version: env!("CARGO_PKG_VERSION"),
        }
    }
}
