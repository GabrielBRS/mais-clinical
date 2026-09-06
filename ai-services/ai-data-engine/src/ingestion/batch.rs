use crate::core::{Document, Result};
use crate::rag::{chunk_document, dedup::dedup_chunks};

use super::chunk_writer::ChunkWriter;
use super::validator::validate;

pub fn ingest_batch(writer: &ChunkWriter, documents: &[Document], chunk_chars: usize) -> Result<(usize, usize)> {
    let mut chunks_written = 0;
    for document in documents {
        validate(document)?;
        let chunks = dedup_chunks(chunk_document(document, chunk_chars));
        for chunk in chunks {
            writer.write(chunk)?;
            chunks_written += 1;
        }
    }
    Ok((documents.len(), chunks_written))
}
