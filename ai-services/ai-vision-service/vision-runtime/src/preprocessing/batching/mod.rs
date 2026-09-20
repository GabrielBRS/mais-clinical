pub fn batch_size(n: usize, max: usize) -> usize {
    n.min(max)
}
