from host.domain.operations import (
    is_allowed_operation,
    normalize_operation,
    operation_requires_recipe,
)
from std.testing import assert_equal, assert_false, assert_true


def main() raises:
    assert_equal(normalize_operation("prepare-data"), "prepare_data")
    assert_true(is_allowed_operation("train"))
    assert_true(is_allowed_operation("health"))
    assert_false(is_allowed_operation("python.module"))
    assert_true(operation_requires_recipe("train"))
    assert_false(operation_requires_recipe("health"))
