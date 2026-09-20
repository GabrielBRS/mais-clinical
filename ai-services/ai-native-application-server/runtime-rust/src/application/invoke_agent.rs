use crate::{
    error::RuntimeError,
    ports::agent_runtime::{
        AgentRuntime, AgentRuntimeError, AgentRuntimeRequest, AgentRuntimeResponse,
    },
};

/// Explicit agentic use case boundary.
///
/// Traditional use cases do not depend on `AgentRuntime`; only use cases that
/// intentionally opt into agentic execution receive this dependency.
pub struct InvokeAgentUseCase<R> {
    runtime: R,
}

impl<R> InvokeAgentUseCase<R>
where
    R: AgentRuntime,
{
    pub fn new(runtime: R) -> Self {
        Self { runtime }
    }

    pub async fn execute(
        &self,
        request: AgentRuntimeRequest,
    ) -> Result<AgentRuntimeResponse, RuntimeError> {
        if request.prompt.trim().is_empty() {
            return Err(RuntimeError::InvalidArgument(
                "prompt obrigatorio".to_owned(),
            ));
        }

        self.runtime
            .invoke(request)
            .await
            .map_err(RuntimeError::from)
    }
}

impl From<AgentRuntimeError> for RuntimeError {
    fn from(error: AgentRuntimeError) -> Self {
        match error {
            AgentRuntimeError::Unavailable | AgentRuntimeError::Timeout => {
                RuntimeError::AgentUnavailable(error.to_string())
            }
            AgentRuntimeError::Rejected(message) => RuntimeError::InvalidArgument(message),
            AgentRuntimeError::InvalidResponse(message) => RuntimeError::Internal(message),
        }
    }
}

#[cfg(test)]
mod tests {
    use std::sync::{
        Arc,
        atomic::{AtomicUsize, Ordering},
    };

    use crate::ports::agent_runtime::AgentRuntimeFuture;

    use super::*;

    struct RecordingRuntime {
        calls: Arc<AtomicUsize>,
    }

    impl AgentRuntime for RecordingRuntime {
        fn invoke(&self, request: AgentRuntimeRequest) -> AgentRuntimeFuture<'_> {
            self.calls.fetch_add(1, Ordering::Relaxed);
            Box::pin(async move {
                Ok(AgentRuntimeResponse {
                    execution_id: "agent-1".to_owned(),
                    text: format!("[mojo] {}", request.prompt),
                    context: request.context,
                    steps: vec!["route".to_owned(), "generate".to_owned()],
                })
            })
        }
    }

    struct RejectingRuntime;

    impl AgentRuntime for RejectingRuntime {
        fn invoke(&self, _request: AgentRuntimeRequest) -> AgentRuntimeFuture<'_> {
            panic!("Mojo must not be called when the prompt is empty");
        }
    }

    #[tokio::test]
    async fn agentic_use_case_invokes_mojo_port_once() {
        let calls = Arc::new(AtomicUsize::new(0));
        let use_case = InvokeAgentUseCase::new(RecordingRuntime {
            calls: calls.clone(),
        });

        let response = use_case
            .execute(AgentRuntimeRequest {
                request_id: "request-1".to_owned(),
                ..AgentRuntimeRequest::agent("hello")
            })
            .await
            .expect("agent invocation must succeed");

        assert_eq!(calls.load(Ordering::Relaxed), 1);
        assert_eq!(response.text, "[mojo] hello");
    }

    #[tokio::test]
    async fn empty_prompt_stays_in_rust() {
        let use_case = InvokeAgentUseCase::new(RejectingRuntime);
        let error = use_case
            .execute(AgentRuntimeRequest::agent(""))
            .await
            .expect_err("empty prompt");
        assert!(matches!(error, RuntimeError::InvalidArgument(_)));
    }
}
