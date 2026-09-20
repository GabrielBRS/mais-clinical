"""Single operational entrypoint for AI Model Training."""

from host.interop.python_runtime import execute_python
from host.transport.cli.parser import parse_cli, print_usage, wants_help


def main() raises:
    if wants_help():
        print_usage()
        return

    var request = parse_cli()
    var response = execute_python(request)
    print(response.payload)
    if response.status != "succeeded":
        raise Error("job failed; see normalized JSON result above")
