use crate::core::Result;

pub trait Stage: Send + Sync {
    fn name(&self) -> &str;
    fn run(&self, input: String) -> Result<String>;
}
