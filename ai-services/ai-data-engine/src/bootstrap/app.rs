use std::sync::Arc;

use anyhow::Context;
use tokio::net::TcpListener;
use tokio::signal;
use tonic::transport::Server;

use crate::cache::{EmbeddingCache, QueryCache};
use crate::clients::ComputeEngineClient;
use crate::config::AppConfig;
use crate::core::{Document, Query};
use crate::ingestion::{ChunkWriter, IngestionService};
use crate::rag::RagPipeline;
use crate::retrieval::{DenseRetriever, HybridMode, HybridRetriever, RetrievalService, SparseRetriever};
use crate::telemetry;
use crate::transport;
use crate::transport::ipc::{Frame, MessageType, UnixSocket};

use super::dependencies;

const EMBED_DIM: usize = 64;

/// Grafo de dependências. Clone barato: tudo atrás de `Arc`.
#[derive(Clone)]
pub struct App {
    pub config: Arc<AppConfig>,
    pub retrieval: Arc<RetrievalService>,
    pub rag: Arc<RagPipeline>,
    pub ingestion: Arc<IngestionService>,
    pub compute: Arc<ComputeEngineClient>,
    pub query_cache: Arc<QueryCache>,
    pub embedding_cache: Arc<EmbeddingCache>,
}

impl App {
    pub fn compose(config: AppConfig) -> Self {
        let store = dependencies::vector_store(&config);
        let dense = DenseRetriever::new(store.clone(), EMBED_DIM);
        let sparse = SparseRetriever::new(store.clone());
        let retrieval = Arc::new(RetrievalService::new(HybridRetriever::new(dense, sparse)));
        let rag = Arc::new(RagPipeline::new(RetrievalService::new(HybridRetriever::new(
            DenseRetriever::new(store.clone(), EMBED_DIM),
            SparseRetriever::new(store.clone()),
        ))));
        let ingestion = Arc::new(IngestionService::new(
            ChunkWriter::new(store, EMBED_DIM),
            512,
        ));
        let compute = Arc::new(ComputeEngineClient::new(&config.compute_ipc_path));

        Self {
            config: Arc::new(config),
            retrieval,
            rag,
            ingestion,
            compute,
            query_cache: Arc::new(QueryCache::new()),
            embedding_cache: Arc::new(EmbeddingCache::new()),
        }
    }

    pub async fn serve(self) -> anyhow::Result<()> {
        let http_addr = self.config.http_bind;
        let grpc_addr = self.config.grpc_bind;
        let ipc_path = self.config.ipc_path.clone();

        let http_router = transport::http::router::router(self.clone());
        let http_listener = TcpListener::bind(http_addr)
            .await
            .with_context(|| format!("falha ao bindar HTTP em {http_addr}"))?;

        let (_health_reporter, grpc_routes) = transport::grpc::router(self.clone());

        tracing::info!(%http_addr, "HTTP (Axum) ouvindo");
        tracing::info!(%grpc_addr, "gRPC (Tonic) ouvindo");
        tracing::info!(path = %ipc_path.display(), "IPC ACE1 ouvindo");

        let http = axum::serve(http_listener, http_router).with_graceful_shutdown(shutdown_signal());
        let grpc = Server::builder()
            .add_routes(grpc_routes)
            .serve_with_shutdown(grpc_addr, shutdown_signal());
        let ipc = serve_ipc(self.clone(), ipc_path);

        tokio::try_join!(
            async { http.await.context("servidor HTTP") },
            async { grpc.await.context("servidor gRPC") },
            ipc,
        )?;
        Ok(())
    }

    fn handle_frame(&self, incoming: &Frame) -> Frame {
        match incoming.header.ty {
            MessageType::HealthRequest => Frame::new(
                MessageType::HealthResponse,
                incoming.header.request_id,
                env!("CARGO_PKG_VERSION").as_bytes().to_vec(),
            ),
            MessageType::RetrieveRequest => self.handle_retrieve(incoming),
            MessageType::IngestRequest => self.handle_ingest(incoming),
            MessageType::RagRequest => self.handle_rag(incoming),
            MessageType::RankRequest => self.handle_rank(incoming),
            MessageType::TransformRequest => self.handle_transform(incoming),
            _ => Frame::new(
                MessageType::Error,
                incoming.header.request_id,
                b"unimplemented".to_vec(),
            ),
        }
    }

    fn handle_retrieve(&self, incoming: &Frame) -> Frame {
        let body: RetrieveWire = match serde_json::from_slice(&incoming.payload) {
            Ok(v) => v,
            Err(e) => {
                return Frame::new(MessageType::Error, incoming.header.request_id, e.to_string());
            }
        };
        let query = Query::new(body.query).with_top_k(body.top_k.unwrap_or(8));
        match self
            .retrieval
            .retrieve(query, HybridMode::parse(&body.mode.unwrap_or_default()))
        {
            Ok(hits) => Frame::new(
                MessageType::RetrieveResponse,
                incoming.header.request_id,
                serde_json::to_vec(&hits).unwrap_or_default(),
            ),
            Err(e) => Frame::new(MessageType::Error, incoming.header.request_id, e.to_string()),
        }
    }

    fn handle_ingest(&self, incoming: &Frame) -> Frame {
        let body: IngestWire = match serde_json::from_slice(&incoming.payload) {
            Ok(v) => v,
            Err(e) => {
                return Frame::new(MessageType::Error, incoming.header.request_id, e.to_string());
            }
        };
        let docs: Vec<Document> = body
            .documents
            .into_iter()
            .map(|d| match d.id {
                Some(id) => Document::with_id(id, d.text),
                None => Document::new(d.text),
            })
            .collect();
        match self.ingestion.ingest(&docs) {
            Ok((documents, chunks)) => Frame::new(
                MessageType::IngestResponse,
                incoming.header.request_id,
                serde_json::to_vec(&serde_json::json!({ "documents": documents, "chunks": chunks }))
                    .unwrap_or_default(),
            ),
            Err(e) => Frame::new(MessageType::Error, incoming.header.request_id, e.to_string()),
        }
    }

    fn handle_rag(&self, incoming: &Frame) -> Frame {
        let body: RagWire = match serde_json::from_slice(&incoming.payload) {
            Ok(v) => v,
            Err(e) => {
                return Frame::new(MessageType::Error, incoming.header.request_id, e.to_string());
            }
        };
        let query = Query::new(body.query).with_top_k(body.top_k.unwrap_or(8));
        match self.rag.run(query, body.max_context_chars.unwrap_or(2048)) {
            Ok(ctx) => Frame::new(
                MessageType::RagResponse,
                incoming.header.request_id,
                serde_json::to_vec(&ctx).unwrap_or_default(),
            ),
            Err(e) => Frame::new(MessageType::Error, incoming.header.request_id, e.to_string()),
        }
    }

    fn handle_rank(&self, incoming: &Frame) -> Frame {
        Frame::new(
            MessageType::RankResponse,
            incoming.header.request_id,
            incoming.payload.clone(),
        )
    }

    fn handle_transform(&self, incoming: &Frame) -> Frame {
        let body: TransformWire = match serde_json::from_slice(&incoming.payload) {
            Ok(v) => v,
            Err(e) => {
                return Frame::new(MessageType::Error, incoming.header.request_id, e.to_string());
            }
        };
        let text = crate::transform::apply(&body.text, &body.ops);
        Frame::new(
            MessageType::TransformResponse,
            incoming.header.request_id,
            serde_json::to_vec(&serde_json::json!({ "text": text })).unwrap_or_default(),
        )
    }
}

#[derive(serde::Deserialize)]
struct RetrieveWire {
    query: String,
    top_k: Option<usize>,
    mode: Option<String>,
}

#[derive(serde::Deserialize)]
struct IngestWire {
    documents: Vec<IngestDoc>,
}

#[derive(serde::Deserialize)]
struct IngestDoc {
    id: Option<String>,
    text: String,
}

#[derive(serde::Deserialize)]
struct RagWire {
    query: String,
    top_k: Option<usize>,
    max_context_chars: Option<usize>,
}

#[derive(serde::Deserialize)]
struct TransformWire {
    text: String,
    #[serde(default)]
    ops: Vec<String>,
}

async fn serve_ipc(app: App, path: std::path::PathBuf) -> anyhow::Result<()> {
    let listener = UnixSocket::listen(&path)
        .await
        .map_err(|e| anyhow::anyhow!(e))?;
    loop {
        tokio::select! {
            _ = shutdown_signal() => break,
            accepted = listener.accept() => {
                let (stream, _) = accepted.context("ipc accept")?;
                let app = app.clone();
                tokio::spawn(async move {
                    let mut sock = UnixSocket::from_stream(stream);
                    if let Ok(incoming) = sock.recv().await {
                        let outgoing = app.handle_frame(&incoming);
                        let _ = sock.send(&outgoing).await;
                    }
                });
            }
        }
    }
    Ok(())
}

pub async fn run() -> anyhow::Result<()> {
    dotenvy::dotenv().ok();
    let config = AppConfig::from_env().context("falha ao carregar configuracao")?;
    telemetry::init_tracing(&config.telemetry.log_level);
    tracing::info!(app_name = %config.app_name, "composition root montado");
    App::compose(config).serve().await
}

async fn shutdown_signal() {
    let ctrl_c = async {
        signal::ctrl_c()
            .await
            .expect("falha ao instalar handler de Ctrl+C");
    };

    #[cfg(unix)]
    let terminate = async {
        signal::unix::signal(signal::unix::SignalKind::terminate())
            .expect("falha ao instalar handler de SIGTERM")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {},
        _ = terminate => {},
    }
    tracing::info!("sinal de shutdown recebido, encerrando...");
}
