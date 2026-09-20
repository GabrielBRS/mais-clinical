use std::time::Duration;

use reqwest::Client;
use serde::Deserialize;
use serde_json::json;

use crate::ports::agent_runtime::{
    AgentRuntime, AgentRuntimeError, AgentRuntimeFuture, AgentRuntimeRequest, AgentRuntimeResponse,
};

/// HTTP adapter for the internal Mojo agent runtime.
///
/// Layer: infrastructure
/// Why here: the public runtime talks to Mojo over a private HTTP API. Clients
/// never receive this URL.
#[derive(Clone, Debug)]
pub struct MojoAgentClient {
    base_url: String,
    http: Client,
}

#[derive(Debug, Deserialize)]
struct MojoExecutionBody {
    #[serde(default)]
    execution_id: String,
    #[serde(default)]
    text: String,
    #[serde(default)]
    context: Vec<String>,
    #[serde(default)]
    steps: Vec<String>,
    #[serde(default)]
    message: Option<String>,
    #[serde(default)]
    error: Option<String>,
}

impl MojoAgentClient {
    pub fn new(base_url: impl Into<String>) -> Result<Self, reqwest::Error> {
        let http = Client::builder().timeout(Duration::from_secs(30)).build()?;
        Ok(Self {
            base_url: base_url.into().trim_end_matches('/').to_owned(),
            http,
        })
    }
}

impl AgentRuntime for MojoAgentClient {
    fn invoke(&self, request: AgentRuntimeRequest) -> AgentRuntimeFuture<'_> {
        Box::pin(async move {
            let path = if request.workflow {
                "/workflows/execute"
            } else {
                "/agents/execute"
            };
            let url = format!("{}{path}", self.base_url);
            let payload = if request.workflow {
                json!({ "prompt": request.prompt })
            } else {
                json!({
                    "prompt": request.prompt,
                    "agent_id": request.agent_id,
                    "retrieve": request.retrieve,
                    "backend": request.backend,
                })
            };

            let response = self
                .http
                .post(url)
                .json(&payload)
                .send()
                .await
                .map_err(|error| {
                    if error.is_timeout() {
                        AgentRuntimeError::Timeout
                    } else {
                        AgentRuntimeError::Unavailable
                    }
                })?;

            let status = response.status();
            let body = response
                .json::<MojoExecutionBody>()
                .await
                .map_err(|error| AgentRuntimeError::InvalidResponse(error.to_string()))?;

            if !status.is_success() {
                return Err(AgentRuntimeError::Rejected(
                    body.message
                        .or(body.error)
                        .unwrap_or_else(|| status.to_string()),
                ));
            }

            Ok(AgentRuntimeResponse {
                execution_id: body.execution_id,
                text: body.text,
                context: body.context,
                steps: body.steps,
            })
        })
    }
}
