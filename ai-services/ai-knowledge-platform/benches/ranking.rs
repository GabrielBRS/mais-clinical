use ai_data_engine::core::{Chunk, DocumentId, Score, ScoreSource, ScoredChunk};
use ai_data_engine::ranking::fuse;
use criterion::{Criterion, criterion_group, criterion_main};

fn hit(i: usize) -> ScoredChunk {
    let mut chunk = Chunk::new(DocumentId::from_raw("d"), format!("t{i}"), i);
    chunk.id = ai_data_engine::core::ChunkId::from_raw(format!("c{i}"));
    ScoredChunk {
        chunk,
        score: Score::new(1.0 / (i as f32 + 1.0), ScoreSource::Dense),
    }
}

fn bench_rrf(c: &mut Criterion) {
    let a: Vec<_> = (0..32).map(hit).collect();
    let b: Vec<_> = (16..48).map(hit).collect();
    c.bench_function("rrf_fuse", |bch| {
        bch.iter(|| fuse(&[a.clone(), b.clone()], 8));
    });
}

criterion_group!(benches, bench_rrf);
criterion_main!(benches);
