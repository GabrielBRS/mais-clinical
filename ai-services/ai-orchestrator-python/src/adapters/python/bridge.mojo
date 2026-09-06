from std.python import Python, PythonObject

from domain.errors import OrchestratorError
from domain.status import StatusCode


struct PythonBridge(Copyable):
    """Single place that talks to embedded CPython.

    Domain, graph and agents never import Python. Only adapters do.
    """

    @staticmethod
    def import_module(name: String) raises OrchestratorError -> PythonObject:
        try:
            return Python.import_module(name)
        except e:
            raise OrchestratorError(
                StatusCode.unavailable, "python module indisponivel: " + name
            )

    @staticmethod
    def env(name: String, default: String) raises -> String:
        try:
            var os = Python.import_module("os")
            var value = os.environ.get(name)
            if value:
                return String(value)
        except e:
            pass
        return default
