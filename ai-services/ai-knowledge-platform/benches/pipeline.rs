use ai_data_engine::pipeline::{PipelineExecutor, PipelineGraph, Stage};
use ai_data_engine::transform::normalize;
use criterion::{Criterion, criterion_group, criterion_main};

struct N;
impl Stage for N {
    fn name(&self) -> &str {
        "n"
    }
    fn run(&self, input: String) -> ai_data_engine::core::Result<String> {
        Ok(normalize(&input))
    }
}

fn bench_pipeline(c: &mut Criterion) {
    let exec = PipelineExecutor::new(PipelineGraph::linear(vec![Box::new(N)]));
    c.bench_function("pipeline_normalize", |b| {
        b.iter(|| exec.run("  a   b  c  ".into()).unwrap());
    });
}

criterion_group!(benches, bench_pipeline);
criterion_main!(benches);
