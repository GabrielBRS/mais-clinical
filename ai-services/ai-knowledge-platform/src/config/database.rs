use super::app::env_or;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum VectorBackend {
    Memory,
    Milvus,
    Qdrant,
    Pgvector,
}

#[derive(Debug, Clone)]
pub struct DatabaseConfig {
    pub vector: VectorBackend,
    pub redis_url: String,
    pub object_root: String,
}

impl DatabaseConfig {
    pub fn from_env() -> Self {
        Self {
            vector: parse_vector(),
            redis_url: env_or("ADE_REDIS_URL", "redis://127.0.0.1:6379"),
            object_root: env_or("ADE_OBJECT_ROOT", "/tmp/ai-data-engine-objects"),
        }
    }
}

fn parse_vector() -> VectorBackend {
    match env_or("ADE_VECTOR_BACKEND", "memory")
        .to_ascii_lowercase()
        .as_str()
    {
        "milvus" => VectorBackend::Milvus,
        "qdrant" => VectorBackend::Qdrant,
        "pgvector" => VectorBackend::Pgvector,
        _ => VectorBackend::Memory,
    }
}
