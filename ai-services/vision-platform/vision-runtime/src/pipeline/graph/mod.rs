use crate::pipeline::stage::Stage;

#[derive(Clone, Debug, Default)]
pub struct Graph {
    pub stages: Vec<Stage>,
}
