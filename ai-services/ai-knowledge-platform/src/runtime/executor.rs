/// Tokio é o runtime. Este tipo só documenta o dono do loop.
pub struct RuntimeExecutor;

impl RuntimeExecutor {
    pub fn name() -> &'static str {
        "tokio"
    }
}
