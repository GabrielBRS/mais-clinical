use ai_data_engine::core::Document;
use ai_data_engine::transform::to_json;
use criterion::{Criterion, criterion_group, criterion_main};

fn bench_json(c: &mut Criterion) {
    let docs: Vec<_> = (0..32)
        .map(|i| Document::with_id(format!("d{i}"), format!("text {i}")))
        .collect();
    c.bench_function("serialize_docs", |b| {
        b.iter(|| to_json(&docs).unwrap());
    });
}

criterion_group!(benches, bench_json);
criterion_main!(benches);
