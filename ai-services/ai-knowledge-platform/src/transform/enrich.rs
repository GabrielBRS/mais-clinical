use crate::core::Metadata;

pub fn tag(metadata: &mut Metadata, key: &str, value: &str) {
    metadata.insert(key, value);
}
