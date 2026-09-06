pub trait Messaging {
    fn publish(&self, topic: &str, payload: &[u8]);
}
