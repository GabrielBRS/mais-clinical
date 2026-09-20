use crate::core::{Document, Result};

use super::batch::ingest_batch;
use super::chunk_writer::ChunkWriter;

pub struct IngestionService {
    writer: ChunkWriter,
    chunk_chars: usize,
}

impl IngestionService {
    pub fn new(writer: ChunkWriter, chunk_chars: usize) -> Self {
        Self {
            writer,
            chunk_chars,
        }
    }

    pub fn ingest(&self, documents: &[Document]) -> Result<(usize, usize)> {
        ingest_batch(&self.writer, documents, self.chunk_chars)
    }
}
