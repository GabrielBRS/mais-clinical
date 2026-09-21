from host.config import HostSettings
from host.runtime import AgentRuntimeHost


def main() raises:
    var runtime = AgentRuntimeHost(HostSettings.load())
    runtime.serve()
