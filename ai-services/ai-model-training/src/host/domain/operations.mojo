"""Allowlisted operation catalog."""


def normalize_operation(operation: String) -> String:
    if operation == "prepare-data":
        return "prepare_data"
    return operation


def is_allowed_operation(operation: String) -> Bool:
    var normalized = normalize_operation(operation)
    return (
        normalized == "train"
        or normalized == "evaluate"
        or normalized == "export"
        or normalized == "prepare_data"
        or normalized == "publish"
        or normalized == "health"
    )


def operation_requires_recipe(operation: String) -> Bool:
    return normalize_operation(operation) != "health"
