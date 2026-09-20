use ai_data_engine::core::{Chunk, DocumentId, Query, Score, ScoreSource, ScoredChunk};
use ai_data_engine::ranking::{fuse, take_top_k};

fn hit(id: &str, text: &str, value: f32) -> ScoredChunk {
    let mut chunk = Chunk::new(DocumentId::from_raw("d"), text, 0);
    chunk.id = ai_data_engine::core::ChunkId::from_raw(id);
    ScoredChunk {
        chunk,
        score: Score::new(value, ScoreSource::Dense),
    }
}

#[test]
fn rrf_promotes_consensus() {
    let a = vec![hit("1", "alpha", 0.9), hit("2", "beta", 0.8)];
    let b = vec![hit("2", "beta", 0.95), hit("3", "gamma", 0.1)];
    let fused = fuse(&[a, b], 2);
    assert_eq!(fused[0].chunk.id.as_str(), "2");
}

#[test]
fn top_k_truncates() {
    let hits = vec![hit("1", "a", 0.1), hit("2", "b", 0.4), hit("3", "c", 0.2)];
    let top = take_top_k(hits, 1);
    assert_eq!(top.len(), 1);
    assert_eq!(top[0].chunk.id.as_str(), "2");
}

#[test]
fn ranker_uses_query() {
    let query = Query::new("alpha");
    let ranked = ai_data_engine::ranking::Ranker.rerank(
        &query,
        vec![hit("1", "zzz", 1.0), hit("2", "alpha token", 0.1)],
    );
    assert_eq!(ranked[0].chunk.id.as_str(), "2");
}
