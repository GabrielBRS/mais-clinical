use crate::core::ScoredChunk;

pub fn pack(hits: &[ScoredChunk], max_chars: usize) -> String {
    let mut out = String::new();
    for (i, hit) in hits.iter().enumerate() {
        let piece = format!("[{}] {}\n", i + 1, hit.chunk.text.trim());
        if out.chars().count() + piece.chars().count() > max_chars {
            break;
        }
        out.push_str(&piece);
    }
    out
}
