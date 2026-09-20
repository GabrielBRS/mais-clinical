"""Import and invoke the known Python facade in the hosted CPython runtime."""

from std.python import Python
from host.application.request import HostRequest


struct HostResponse:
    var status: String
    var payload: String

    def __init__(out self, status: String, payload: String):
        self.status = status
        self.payload = payload


def execute_python(request: HostRequest) raises -> HostResponse:
    Python.add_to_path(request.root + "/src")
    var api = Python.import_module("llm_adaptation.host_api")
    var uuid = Python.import_module("uuid")
    var json = Python.import_module("json")
    var run_id = String(uuid.uuid4())
    var result = api.execute_cli(
        request.operation,
        request.recipe_path,
        request.root,
        run_id,
        request.dry_run,
        request.device,
        request.resume,
    )
    return HostResponse(
        String(result["status"]), String(json.dumps(result, sort_keys=True))
    )
