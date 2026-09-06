class FjallStorage:
    def __init__(self) -> None:
        self._data: dict[str, bytes] = {}

    def load(self, key: str) -> bytes | None:
        return self._data.get(key)

    def save(self, key: str, value: bytes) -> None:
        self._data[key] = value

    def delete(self, key: str) -> None:
        self._data.pop(key, None)
