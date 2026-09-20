use axum::Json;
use axum::extract::State;
use axum::http::StatusCode;
use serde::{Deserialize, Serialize};

use crate::bootstrap::App;
use crate::core::{Document, Query};
use crate::retrieval::HybridMode;

#[derive(Serialize)]
pub struct HealthBody {
    pub status: &'static str,
    pub version: &'static str,
}

pub async fn health() -> Json<HealthBody> {
    Json(HealthBody {
        status: "ok",
        version: env!("CARGO_PKG_VERSION"),
    })
}

#[derive(Deserialize)]
pub struct RetrieveBody {
    pub query: String,
    #[serde(default = "default_top_k")]
    pub top_k: usize,
    #[serde(default)]
    pub mode: String,
}

fn default_top_k() -> usize {
    8
}

#[derive(Serialize)]
pub struct RetrieveHit {
    pub text: String,
    pub score: f32,
    pub document_id: String,
}

pub async fn retrieve(
    State(app): State<App>,
    Json(body): Json<RetrieveBody>,
) -> Result<Json<Vec<RetrieveHit>>, (StatusCode, String)> {
    let query = Query::new(body.query).with_top_k(body.top_k);
    let hits = app
        .retrieval
        .retrieve(query, HybridMode::parse(&body.mode))
        .map_err(|e| (StatusCode::BAD_REQUEST, e.to_string()))?;
    Ok(Json(
        hits.into_iter()
            .map(|h| RetrieveHit {
                text: h.chunk.text,
                score: h.score.value,
                document_id: h.chunk.document_id.to_string(),
            })
            .collect(),
    ))
}

#[derive(Deserialize)]
pub struct RagBody {
    pub query: String,
    #[serde(default = "default_top_k")]
    pub top_k: usize,
    #[serde(default = "default_ctx")]
    pub max_context_chars: usize,
}

fn default_ctx() -> usize {
    2048
}

#[derive(Serialize)]
pub struct RagBodyOut {
    pub context: String,
    pub citations: Vec<String>,
}

pub async fn rag(
    State(app): State<App>,
    Json(body): Json<RagBody>,
) -> Result<Json<RagBodyOut>, (StatusCode, String)> {
    let query = Query::new(body.query).with_top_k(body.top_k);
    let ctx = app
        .rag
        .run(query, body.max_context_chars)
        .map_err(|e| (StatusCode::BAD_REQUEST, e.to_string()))?;
    Ok(Json(RagBodyOut {
        context: ctx.packed_text,
        citations: ctx.citations.into_iter().map(|c| c.document_id).collect(),
    }))
}

#[derive(Deserialize)]
pub struct IngestBody {
    pub documents: Vec<IngestDoc>,
}

#[derive(Deserialize)]
pub struct IngestDoc {
    pub id: Option<String>,
    pub text: String,
}

#[derive(Serialize)]
pub struct IngestOut {
    pub documents: usize,
    pub chunks: usize,
}

pub async fn ingest(
    State(app): State<App>,
    Json(body): Json<IngestBody>,
) -> Result<Json<IngestOut>, (StatusCode, String)> {
    let docs: Vec<Document> = body
        .documents
        .into_iter()
        .map(|d| match d.id {
            Some(id) => Document::with_id(id, d.text),
            None => Document::new(d.text),
        })
        .collect();
    let (documents, chunks) = app
        .ingestion
        .ingest(&docs)
        .map_err(|e| (StatusCode::BAD_REQUEST, e.to_string()))?;
    Ok(Json(IngestOut { documents, chunks }))
}
