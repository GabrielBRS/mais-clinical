class KafkaProducer:
    def publish(self, topic: str, payload: bytes) -> None:
        del topic, payload
