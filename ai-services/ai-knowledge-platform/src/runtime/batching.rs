pub fn next_batch_size(pending: usize, max_batch: usize) -> usize {
    pending.min(max_batch.max(1))
}
