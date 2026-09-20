use crate::core::Result;

pub fn with_retry<T>(mut op: impl FnMut() -> Result<T>, attempts: usize) -> Result<T> {
    let attempts = attempts.max(1);
    let mut last = None;
    for _ in 0..attempts {
        match op() {
            Ok(value) => return Ok(value),
            Err(err) => last = Some(err),
        }
    }
    Err(last.expect("attempts >= 1"))
}
