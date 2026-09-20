use axum::{
    Json, Router,
    extract::{Path, State},
    http::StatusCode,
    response::{IntoResponse, Response},
    routing::{get, post},
};
use serde::Deserialize;
use serde_json::json;
use tower_http::trace::TraceLayer;

use crate::{
    application::{invoke_agent::InvokeAgentUseCase, records::CreateRecord},
    bootstrap::AppState,
    error::RuntimeError,
    ports::agent_runtime::{AgentRuntimeRequest, AgentRuntimeResponse},
};

#[derive(Debug, serde::Serialize)]
struct HealthResponse {
    status: &'static str,
    version: &'static str,
    ready: bool,
}

#[derive(Debug, Deserialize)]
struct ExecuteAgentBody {
    #[serde(default)]
    prompt: String,
    #[serde(default = "default_agent_id")]
    agent_id: String,
    #[serde(default)]
    retrieve: bool,
    #[serde(default = "default_backend")]
    backend: String,
}

#[derive(Debug, Deserialize)]
struct ExecuteWorkflowBody {
    #[serde(default)]
    prompt: String,
}

fn default_agent_id() -> String {
    "default".to_owned()
}

fn default_backend() -> String {
    "local".to_owned()
}

pub fn router(state: AppState) -> Router {
    Router::new()
        .route("/health", get(live))
        .route("/health/live", get(live))
        .route("/health/ready", get(ready))
        .route("/records", get(list_records).post(create_record))
        .route("/records/{id}", get(get_record))
        .route("/agents/execute", post(execute_agent))
        .route("/workflows/execute", post(execute_workflow))
        .layer(TraceLayer::new_for_http())
        .with_state(state)
}

async fn live(State(state): State<AppState>) -> Json<HealthResponse> {
    Json(health_response(&state))
}

async fn ready(State(state): State<AppState>) -> Response {
    let status = if state.runtime.is_ready() {
        StatusCode::OK
    } else {
        StatusCode::SERVICE_UNAVAILABLE
    };

    (status, Json(health_response(&state))).into_response()
}

fn health_response(state: &AppState) -> HealthResponse {
    HealthResponse {
        status: "ok",
        version: state.runtime.version(),
        ready: state.runtime.is_ready(),
    }
}

async fn list_records(State(state): State<AppState>) -> Response {
    match state.records.list() {
        Ok(records) => (StatusCode::OK, Json(records)).into_response(),
        Err(error) => runtime_error(error),
    }
}

async fn create_record(
    State(state): State<AppState>,
    Json(command): Json<CreateRecord>,
) -> Response {
    match state.records.create(command) {
        Ok(record) => (StatusCode::CREATED, Json(record)).into_response(),
        Err(error) => runtime_error(error),
    }
}

async fn get_record(State(state): State<AppState>, Path(id): Path<String>) -> Response {
    match state.records.get(&id) {
        Ok(Some(record)) => (StatusCode::OK, Json(record)).into_response(),
        Ok(None) => (
            StatusCode::NOT_FOUND,
            Json(json!({"error":"not_found","message":"record not found"})),
        )
            .into_response(),
        Err(error) => runtime_error(error),
    }
}

async fn execute_agent(
    State(state): State<AppState>,
    Json(body): Json<ExecuteAgentBody>,
) -> Response {
    let mut request = AgentRuntimeRequest::agent(body.prompt);
    request.agent_id = body.agent_id;
    request.retrieve = body.retrieve;
    request.backend = body.backend;
    invoke_agent(state, request).await
}

async fn execute_workflow(
    State(state): State<AppState>,
    Json(body): Json<ExecuteWorkflowBody>,
) -> Response {
    invoke_agent(state, AgentRuntimeRequest::workflow(body.prompt)).await
}

async fn invoke_agent(state: AppState, request: AgentRuntimeRequest) -> Response {
    match InvokeAgentUseCase::new(state.agents).execute(request).await {
        Ok(result) => (StatusCode::OK, Json(execution_json(result))).into_response(),
        Err(error) => runtime_error(error),
    }
}

fn execution_json(result: AgentRuntimeResponse) -> serde_json::Value {
    json!({
        "execution_id": result.execution_id,
        "text": result.text,
        "context": result.context,
        "steps": result.steps,
    })
}

fn runtime_error(error: RuntimeError) -> Response {
    let (status, code) = match error {
        RuntimeError::InvalidArgument(_) => (StatusCode::BAD_REQUEST, "invalid_argument"),
        RuntimeError::AgentUnavailable(_) => (StatusCode::SERVICE_UNAVAILABLE, "agent_unavailable"),
        _ => (StatusCode::INTERNAL_SERVER_ERROR, "internal"),
    };
    (
        status,
        Json(json!({"error": code, "message": error.to_string()})),
    )
        .into_response()
}
