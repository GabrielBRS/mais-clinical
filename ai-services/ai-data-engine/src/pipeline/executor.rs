use crate::core::Result;

use super::graph::PipelineGraph;

pub struct PipelineExecutor {
    graph: PipelineGraph,
}

impl PipelineExecutor {
    pub fn new(graph: PipelineGraph) -> Self {
        Self { graph }
    }

    pub fn run(&self, mut input: String) -> Result<String> {
        for stage in &self.graph.stages {
            input = stage.run(input)?;
        }
        Ok(input)
    }
}
