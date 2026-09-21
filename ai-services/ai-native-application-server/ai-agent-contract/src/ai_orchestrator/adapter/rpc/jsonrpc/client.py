class JsonRpcClient:
    def call(self, method: str, params: dict) -> dict:
        del method, params
        raise RuntimeError("jsonrpc nao ligado")
