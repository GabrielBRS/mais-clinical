use crate::core::{Chunk, Document};

pub fn chunk_document(document: &Document, max_chars: usize) -> Vec<Chunk> {
    let max_chars = max_chars.max(32);
    let text = document.text.trim();
    if text.is_empty() {
        return Vec::new();
    }

    let mut chunks = Vec::new();
    let mut start = 0;
    let mut index = 0;
    let chars: Vec<char> = text.chars().collect();

    while start < chars.len() {
        let mut end = (start + max_chars).min(chars.len());
        if end < chars.len() {
            if let Some(rel) = chars[start..end].iter().rposition(|c| c.is_whitespace()) {
                if rel > max_chars / 4 {
                    end = start + rel;
                }
            }
        }
        let piece: String = chars[start..end].iter().collect();
        let piece = piece.trim();
        if !piece.is_empty() {
            let mut chunk = Chunk::new(document.id.clone(), piece, index);
            chunk.metadata = document.metadata.clone();
            chunks.push(chunk);
            index += 1;
        }
        start = end.max(start + 1);
        while start < chars.len() && chars[start].is_whitespace() {
            start += 1;
        }
    }
    chunks
}
