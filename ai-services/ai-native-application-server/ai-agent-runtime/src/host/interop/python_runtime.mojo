"""Load and invoke ai_orchestrator in the embedded CPython runtime."""

from std.python import Python, PythonObject
from contracts.registry import PythonContractRegistry, load_all_contract_modules


@fieldwise_init
struct PythonResponse(Copyable):
    var status: Int
    var body: String


def initialize_python(contract_root: String) raises -> PythonContractRegistry:
    Python.add_to_path(contract_root + "/src")
    var contracts = load_all_contract_modules()
    var composition_root = Python.import_module(
        "ai_orchestrator.bootstrap.composition_root"
    )
    var api = Python.import_module("ai_orchestrator.host_api")
    api.install_container(composition_root.AppContainer.build())
    return contracts^


def health() raises -> PythonResponse:
    var api = Python.import_module("ai_orchestrator.host_api")
    return _response(api.health())


def execute_agent(payload: String) raises -> PythonResponse:
    var api = Python.import_module("ai_orchestrator.host_api")
    return _response(api.execute_agent(payload))


def execute_workflow(payload: String) raises -> PythonResponse:
    var api = Python.import_module("ai_orchestrator.host_api")
    return _response(api.execute_workflow(payload))


def _response(result: PythonObject) raises -> PythonResponse:
    return PythonResponse(
        _status(String(result["status"])), String(result["body"])
    )


def _status(raw: String) -> Int:
    var value = 0
    for byte in raw.as_bytes():
        var digit = Int(byte) - 48
        if digit < 0 or digit > 9:
            return 500
        value = value * 10 + digit
    return value
