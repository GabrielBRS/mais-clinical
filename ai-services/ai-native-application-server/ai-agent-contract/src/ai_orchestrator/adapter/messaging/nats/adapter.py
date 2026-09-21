class NatsMessaging:
    def publish(self, topic: str, payload: bytes) -> None:
        del topic, payload

    def consume(self, topic: str) -> bytes | None:
        del topic
        return None
