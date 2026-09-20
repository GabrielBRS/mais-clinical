use super::Stage;

pub struct PipelineGraph {
    pub stages: Vec<Box<dyn Stage>>,
}

impl PipelineGraph {
    pub fn linear(stages: Vec<Box<dyn Stage>>) -> Self {
        Self { stages }
    }
}
