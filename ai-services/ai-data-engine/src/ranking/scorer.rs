use crate::core::embedding::tokenize;

pub fn score_overlap(query: &str, document: &str) -> f32 {
    let q = tokenize(query);
    if q.is_empty() {
        return 0.0;
    }
    let doc = tokenize(document);
    let hits = q.iter().filter(|t| doc.contains(t)).count();
    hits as f32 / q.len() as f32
}
