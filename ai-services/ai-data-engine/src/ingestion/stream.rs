use crate::core::{Document, Result};

use super::batch::ingest_batch;
use super::chunk_writer::ChunkWriter;

pub fn ingest_stream<'a>(
    writer: &ChunkWriter,
    documents: impl IntoIterator<Item = &'a Document>,
    chunk_chars: usize,
) -> Result<(usize, usize)> {
    let docs: Vec<_> = documents.into_iter().cloned().collect();
    ingest_batch(writer, &docs, chunk_chars)
}
