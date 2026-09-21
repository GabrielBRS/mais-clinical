use ai_native_runtime::{
    VERSION,
    bootstrap::{AppState, RuntimeState},
    infrastructure::agent::MojoPythonRuntimeClient,
    transport::http,
};
use axum::{
    body::{Body, to_bytes},
    http::{Request, StatusCode},
};
use tower::ServiceExt;

fn test_state() -> AppState {
    AppState::new(
        RuntimeState::new(VERSION),
        MojoPythonRuntimeClient::new("http://127.0.0.1:1").expect("client"),
    )
}

#[tokio::test]
async fn liveness_does_not_depend_on_readiness() {
    let app = http::router(test_state());
    let response = app
        .oneshot(Request::get("/health/live").body(Body::empty()).unwrap())
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
}

#[tokio::test]
async fn readiness_tracks_runtime_state() {
    let state = test_state();
    let unavailable = http::router(state.clone())
        .oneshot(Request::get("/health/ready").body(Body::empty()).unwrap())
        .await
        .unwrap();
    assert_eq!(unavailable.status(), StatusCode::SERVICE_UNAVAILABLE);

    state.runtime.mark_ready();
    let ready = http::router(state)
        .oneshot(Request::get("/health/ready").body(Body::empty()).unwrap())
        .await
        .unwrap();
    assert_eq!(ready.status(), StatusCode::OK);
    let body = to_bytes(ready.into_body(), 1024).await.unwrap();
    assert!(String::from_utf8_lossy(&body).contains("\"ready\":true"));
}

#[tokio::test]
async fn records_are_traditional_and_never_call_mojo() {
    let state = test_state();
    let created = http::router(state.clone())
        .oneshot(
            Request::post("/records")
                .header("content-type", "application/json")
                .body(Body::from(r#"{"title":"paciente"}"#))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(created.status(), StatusCode::CREATED);

    let listed = http::router(state)
        .oneshot(Request::get("/records").body(Body::empty()).unwrap())
        .await
        .unwrap();
    assert_eq!(listed.status(), StatusCode::OK);
    let body = to_bytes(listed.into_body(), 1024).await.unwrap();
    assert!(String::from_utf8_lossy(&body).contains("paciente"));
}

#[tokio::test]
async fn empty_agent_prompt_is_rejected_without_mojo() {
    let response = http::router(test_state())
        .oneshot(
            Request::post("/agents/execute")
                .header("content-type", "application/json")
                .body(Body::from(r#"{"prompt":""}"#))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);
}

#[tokio::test]
async fn agent_execute_is_unavailable_when_mojo_is_down() {
    let response = http::router(test_state())
        .oneshot(
            Request::post("/agents/execute")
                .header("content-type", "application/json")
                .body(Body::from(r#"{"prompt":"hello"}"#))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(response.status(), StatusCode::SERVICE_UNAVAILABLE);
}
