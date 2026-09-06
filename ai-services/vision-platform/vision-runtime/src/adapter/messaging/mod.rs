use crate::port::messaging::Messaging;

pub struct NoopBus;

impl Messaging for NoopBus {
    fn publish(&self, _topic: &str, _payload: &[u8]) {}
}
