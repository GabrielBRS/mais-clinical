use crate::core::Query;

/// Expansão trivial: repete tokens únicos. Synonyms entram depois.
pub fn expand(query: &Query) -> Query {
    query.clone()
}
