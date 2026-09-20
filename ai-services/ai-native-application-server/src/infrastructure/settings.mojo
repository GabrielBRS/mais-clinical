from application.config import Settings
from domain.model import Provider
from std.os import getenv


def load_settings() raises -> Settings:
    """Fill Settings from the process environment via libc getenv.

    Layer: infrastructure
    Why here: application owns the Settings shape; I/O stays out of it.
    """
    var settings = Settings.default()
    settings.app_name = _env("AOR_APP_NAME", settings.app_name)
    settings.app_env = _env("AOR_APP_ENV", settings.app_env)
    settings.log_level = _env("AOR_LOG_LEVEL", settings.log_level)
    settings.http_host = _env("AOR_HTTP_HOST", settings.http_host)
    settings.ipc_path = _env("AOR_IPC_PATH", settings.ipc_path)
    settings.compute_ipc_path = _env(
        "AOR_COMPUTE_IPC_PATH", settings.compute_ipc_path
    )
    settings.data_ipc_path = _env("AOR_DATA_IPC_PATH", settings.data_ipc_path)
    settings.llm_provider = Provider.parse(
        _env("AOR_LLM_PROVIDER", settings.llm_provider.name())
    )
    settings.storage_engine = _env("AOR_STORAGE_ENGINE", settings.storage_engine)
    settings.http_port = _env_port("AOR_HTTP_PORT", settings.http_port)
    return settings^


def _env(name: String, default: String) -> String:
    var value = getenv(name, default)
    if value.byte_length() == 0:
        return default
    return value^


def _env_port(name: String, default: UInt16) -> UInt16:
    var raw = getenv(name, "")
    if raw.byte_length() == 0:
        return default
    var parsed = _parse_uint(raw)
    if parsed <= 0 or parsed > 65535:
        return default
    return UInt16(parsed)


def _parse_uint(text: String) -> Int:
    var raw = text.as_bytes()
    var out = 0
    var i = 0
    var seen = False
    while i < len(raw):
        var b = Int(raw[i])
        if b < 48 or b > 57:
            if seen:
                break
            i += 1
            continue
        seen = True
        out = out * 10 + (b - 48)
        i += 1
    if not seen:
        return 0
    return out
