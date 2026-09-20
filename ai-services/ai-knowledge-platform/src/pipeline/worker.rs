use crate::core::Result;

use super::PipelineExecutor;

pub fn run_job(executor: &PipelineExecutor, input: String) -> Result<String> {
    executor.run(input)
}
