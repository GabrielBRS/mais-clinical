from std.os import getenv


@fieldwise_init
struct HostSettings(Copyable):
    var host: String
    var port: UInt16
    var contract_root: String

    @staticmethod
    def load() -> HostSettings:
        return HostSettings(
            _env("AOR_AGENT_HTTP_HOST", "127.0.0.1"),
            _env_port("AOR_AGENT_HTTP_PORT", UInt16(8090)),
            _env("AOR_CONTRACT_ROOT", "ai-agent-contract"),
        )


def _env(name: String, default: String) -> String:
    var value = getenv(name, default)
    if value.byte_length() == 0:
        return default
    return value^


def _env_port(name: String, default: UInt16) -> UInt16:
    var raw = getenv(name, "")
    if raw.byte_length() == 0:
        return default
    var value = 0
    for byte in raw.as_bytes():
        var digit = Int(byte) - 48
        if digit < 0 or digit > 9:
            return default
        value = value * 10 + digit
    if value <= 0 or value > 65535:
        return default
    return UInt16(value)
