pub fn keep_even(ids: &[i32]) -> Vec<i32> {
    ids.iter().copied().filter(|i| i % 2 == 0).collect()
}
