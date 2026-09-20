use ai_native_runtime::{
    VERSION,
    bootstrap::{AppState, RuntimeState},
    infrastructure::agent::MojoAgentClient,
    transport::http,
};
use axum::{
    Json, Router,
    body::{Body, to_bytes},
    http::{Request, StatusCode},
    routing::post,
};
use serde_json::{Value, json};
use tokio::net::TcpListener;
use tower::ServiceExt;

async fn mojo_agent_stub(Json(request): Json<Value>) -> Json<Value> {
    Json(json!({
        "execution_id": "mojo-1",
        "text": format!("[mojo] {}", request["prompt"].as_str().unwrap_or_default()),
        "context": ["internal context"],
        "steps": ["route", "generate"]
    }))
}

#[tokio::test]
async fn client_reaches_mojo_only_through_the_rust_use_case() {
    let listener = TcpListener::bind("127.0.0.1:0")
        .await
        .expect("bind internal Mojo stub");
    let address = listener.local_addr().expect("stub address");
    let mojo = tokio::spawn(async move {
        axum::serve(
            listener,
            Router::new().route("/agents/execute", post(mojo_agent_stub)),
        )
        .await
        .expect("serve internal Mojo stub");
    });

    let runtime = RuntimeState::new(VERSION);
    runtime.mark_ready();
    let state = AppState::new(
        runtime,
        MojoAgentClient::new(format!("http://{address}")).expect("Mojo client"),
    );
    let response = http::router(state)
        .oneshot(
            Request::post("/agents/execute")
                .header("content-type", "application/json")
                .body(Body::from(r#"{"prompt":"hello"}"#))
                .unwrap(),
        )
        .await
        .expect("Rust public response");

    assert_eq!(response.status(), StatusCode::OK);
    let body = to_bytes(response.into_body(), 4096).await.unwrap();
    let body = String::from_utf8(body.to_vec()).unwrap();
    assert!(body.contains("[mojo] hello"));
    assert!(body.contains("route"));
    assert!(!body.contains(&address.to_string()));

    mojo.abort();
}
