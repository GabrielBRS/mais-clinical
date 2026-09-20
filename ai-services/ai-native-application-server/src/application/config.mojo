from domain.model import Provider


@fieldwise_init
struct Settings(Copyable):
    var app_name: String
    var app_env: String
    var log_level: String
    var http_host: String
    var http_port: UInt16
    var ipc_path: String
    var compute_ipc_path: String
    var data_ipc_path: String
    var llm_provider: Provider
    var storage_engine: String

    @staticmethod
    def default() -> Self:
        return Self(
            "ai-orchestrator",
            "development",
            "info",
            "127.0.0.1",
            8090,
            "/tmp/ai-orchestrator.sock",
            "/tmp/ai-compute-engine.sock",
            "/tmp/ai-data-engine.sock",
            Provider.local,
            "fjall",
        )
