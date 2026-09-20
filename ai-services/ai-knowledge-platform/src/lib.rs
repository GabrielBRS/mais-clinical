//! Data / RAG engine: ingestão, retrieval, ranking e packing de contexto.
//!
//! Os três processos da plataforma falam ACE1 no unix socket. HTTP (Axum) e
//! gRPC (Tonic) expõem o mesmo contrato de `proto/`.

pub mod bootstrap;
pub mod cache;
pub mod clients;
pub mod config;
pub mod core;
pub mod ingestion;
pub mod pipeline;
pub mod rag;
pub mod ranking;
pub mod retrieval;
pub mod runtime;
pub mod storage;
pub mod telemetry;
pub mod transform;
pub mod transport;
