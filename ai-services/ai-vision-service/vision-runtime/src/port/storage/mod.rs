pub trait Storage {
    fn put(&mut self, key: &str, bytes: &[u8]);
}
