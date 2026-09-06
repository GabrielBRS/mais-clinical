use crate::core::Document;

pub fn parse_plain(id: &str, text: &str) -> Document {
    Document::with_id(id, text)
}
