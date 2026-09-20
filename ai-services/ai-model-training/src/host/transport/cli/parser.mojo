"""Strict CLI parser for the Mojo host."""

import std.sys
from host.application.request import HostRequest
from host.domain.operations import (
    is_allowed_operation,
    normalize_operation,
    operation_requires_recipe,
)


def print_usage():
    print("Usage:")
    print("  ai-model-training health [--root PATH]")
    print(
        "  ai-model-training train --recipe PATH [--root PATH] [--device"
        " DEVICE] [--resume] [--dry-run]"
    )
    print(
        "  ai-model-training evaluate --recipe PATH [--root PATH] [--dry-run]"
    )
    print("  ai-model-training export --recipe PATH [--root PATH] [--dry-run]")
    print(
        "  ai-model-training prepare-data --recipe PATH [--root PATH]"
        " [--dry-run]"
    )
    print("  ai-model-training publish --recipe PATH [--root PATH] [--dry-run]")


def wants_help() -> Bool:
    var args = std.sys.argv()
    if len(args) < 2:
        return False
    var value = String(args[1])
    return value == "--help" or value == "-h" or value == "help"


def parse_cli() raises -> HostRequest:
    var args = std.sys.argv()
    if len(args) < 2:
        raise Error("missing operation; use --help")

    var request = HostRequest()
    request.operation = normalize_operation(String(args[1]))
    if not is_allowed_operation(request.operation):
        raise Error("operation is not allowlisted: " + request.operation)

    var index = 2
    while index < len(args):
        var argument = String(args[index])
        if argument == "--recipe":
            if index + 1 >= len(args):
                raise Error("--recipe requires a value")
            request.recipe_path = String(args[index + 1])
            index += 2
        elif argument == "--root":
            if index + 1 >= len(args):
                raise Error("--root requires a value")
            request.root = String(args[index + 1])
            index += 2
        elif argument == "--device":
            if index + 1 >= len(args):
                raise Error("--device requires a value")
            request.device = String(args[index + 1])
            index += 2
        elif argument == "--dry-run":
            request.dry_run = True
            index += 1
        elif argument == "--resume":
            request.resume = True
            index += 1
        else:
            raise Error("unknown argument: " + argument)

    if operation_requires_recipe(request.operation) and not request.recipe_path:
        raise Error("--recipe is required for " + request.operation)
    return request^
