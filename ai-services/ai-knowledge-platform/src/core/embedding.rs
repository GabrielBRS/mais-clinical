use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Embedding {
    pub values: Vec<f32>,
}

impl Embedding {
    pub fn new(values: Vec<f32>) -> Self {
        Self { values }
    }

    pub fn dim(&self) -> usize {
        self.values.len()
    }

    pub fn cosine(&self, other: &Self) -> f32 {
        if self.values.is_empty() || self.dim() != other.dim() {
            return 0.0;
        }
        let mut dot = 0.0f32;
        let mut na = 0.0f32;
        let mut nb = 0.0f32;
        for (a, b) in self.values.iter().zip(other.values.iter()) {
            dot += a * b;
            na += a * a;
            nb += b * b;
        }
        let denom = na.sqrt() * nb.sqrt();
        if denom == 0.0 { 0.0 } else { dot / denom }
    }

    /// Hashing trick determinístico — fallback local sem o compute-engine.
    pub fn hashed(text: &str, dim: usize) -> Self {
        let dim = dim.max(8);
        let mut values = vec![0.0f32; dim];
        for token in tokenize(text) {
            let idx = hash_token(&token) % dim;
            let sign = if hash_token(&(token.clone() + "#")) % 2 == 0 {
                1.0
            } else {
                -1.0
            };
            values[idx] += sign;
        }
        let norm = values.iter().map(|v| v * v).sum::<f32>().sqrt();
        if norm > 0.0 {
            for v in &mut values {
                *v /= norm;
            }
        }
        Self { values }
    }
}

pub(crate) fn tokenize(text: &str) -> Vec<String> {
    text.to_lowercase()
        .split(|c: char| !c.is_alphanumeric())
        .filter(|t| !t.is_empty())
        .map(str::to_owned)
        .collect()
}

fn hash_token(token: &str) -> usize {
    let mut h: u64 = 1469598103934665603;
    for b in token.as_bytes() {
        h ^= u64::from(*b);
        h = h.wrapping_mul(1099511628211);
    }
    h as usize
}
