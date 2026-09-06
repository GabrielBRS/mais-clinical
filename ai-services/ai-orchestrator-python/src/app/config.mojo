from adapters.python.bridge import PythonBridge
from domain.model import Provider


@fieldwise_init
struct Settings(Copyable):
    var app_name: String
    var app_env: String
    var log_level: String
    var http_host: String
    var http_port: UInt16
    var grpc_host: String
    var grpc_port: UInt16
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
            "0.0.0.0",
            8080,
            "0.0.0.0",
            50051,
            "/tmp/ai-orchestrator-python.sock",
            "/tmp/ai-compute-engine.sock",
            "/tmp/ai-data-engine.sock",
            Provider.local,
            "fjall",
        )

    @staticmethod
    def from_env() raises -> Self:
        var settings = Self.default()
        settings.app_name = PythonBridge.env("AOR_APP_NAME", settings.app_name)
        settings.app_env = PythonBridge.env("AOR_APP_ENV", settings.app_env)
        settings.log_level = PythonBridge.env(
            "AOR_LOG_LEVEL", settings.log_level
        )
        settings.http_host = PythonBridge.env(
            "AOR_HTTP_HOST", settings.http_host
        )
        settings.grpc_host = PythonBridge.env(
            "AOR_GRPC_HOST", settings.grpc_host
        )
        settings.ipc_path = PythonBridge.env("AOR_IPC_PATH", settings.ipc_path)
        settings.compute_ipc_path = PythonBridge.env(
            "AOR_COMPUTE_IPC_PATH", settings.compute_ipc_path
        )
        settings.data_ipc_path = PythonBridge.env(
            "AOR_DATA_IPC_PATH", settings.data_ipc_path
        )
        settings.llm_provider = Provider.parse(
            PythonBridge.env("AOR_LLM_PROVIDER", settings.llm_provider.name())
        )
        settings.storage_engine = PythonBridge.env(
            "AOR_STORAGE_ENGINE", settings.storage_engine
        )
        return settings^
