use std::time::Duration;

use axum::Router;
use axum::http::StatusCode;
use axum::routing::{get, post};
use tower_http::cors::CorsLayer;
use tower_http::timeout::TimeoutLayer;
use tower_http::trace::TraceLayer;

use crate::bootstrap::App;
use crate::transport::http::handlers;

pub fn router(app: App) -> Router {
    Router::new()
        .route("/health", get(handlers::health))
        .route("/retrieve", post(handlers::retrieve))
        .route("/rag", post(handlers::rag))
        .route("/ingest", post(handlers::ingest))
        .layer(TraceLayer::new_for_http())
        .layer(TimeoutLayer::with_status_code(
            StatusCode::REQUEST_TIMEOUT,
            Duration::from_secs(30),
        ))
        .layer(CorsLayer::permissive())
        .with_state(app)
}
