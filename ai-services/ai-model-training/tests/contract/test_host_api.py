from __future__ import annotations

import json
from pathlib import Path
from uuid import uuid4

import llm_adaptation.host_api as host_api


def request(operation: str, root: Path, recipe: str | None = None, **extra: object) -> dict[str, object]:
    value: dict[str, object] = {
        "schema_version": "1.0",
        "operation": operation,
        "run_id": str(uuid4()),
        "root": str(root),
    }
    if recipe is not None:
        value["recipe_path"] = recipe
    value.update(extra)
    return value


def test_health_contract(root: Path) -> None:
    result = host_api.execute(request("health", root))
    assert result["status"] == "succeeded"
    assert result["schema_version"] == "1.0"
    assert result["data"]["ready"] is True
    assert set(result["data"]["operations"]) == set(host_api.allowed_operations())


def test_train_vertical_flow(root: Path) -> None:
    result = host_api.execute(request("train", root, "recipes/qwen/sft_lora.yaml"))
    assert result["status"] == "succeeded"
    assert result["checkpoint"]
    assert Path(result["checkpoint"]).is_relative_to(root)
    assert result["data"]["adapter"] == "lora"


def test_checkpoint_resume(root: Path) -> None:
    first = host_api.execute(request("train", root, "recipes/qwen/sft_lora.yaml"))
    resumed = host_api.execute(
        request("train", root, "recipes/qwen/sft_lora.yaml", resume=True)
    )
    assert first["status"] == "succeeded"
    assert resumed["status"] == "succeeded"
    assert resumed["data"]["resumed"] is True


def test_dry_run_validates_without_creating_artifacts(root: Path) -> None:
    result = host_api.execute(
        request("prepare_data", root, "recipes/qwen/sft_lora.yaml", dry_run=True)
    )
    assert result["status"] == "succeeded"
    assert result["data"]["validated"] is True
    assert not (root / "data/processed/qwen-sft-lora").exists()


def test_path_escape_is_rejected(root: Path) -> None:
    outside = root / "outside.yaml"
    outside.write_text("name: outside")
    result = host_api.execute(request("train", root, str(outside)))
    assert result["status"] == "failed"
    assert result["error"]["code"] == "invalid_recipe"


def test_recipe_fragment_escape_is_rejected(root: Path) -> None:
    recipe = root / "recipes/escape.yaml"
    recipe.write_text("name: escape\nextends:\n  model: outside.yaml\n")
    (root / "outside.yaml").write_text("name: outside")
    result = host_api.execute(request("train", root, "recipes/escape.yaml"))
    assert result["status"] == "failed"
    assert result["error"]["code"] == "invalid_recipe"


def test_unknown_operation_and_extra_fields_are_rejected(root: Path) -> None:
    result = host_api.execute(request("arbitrary.module", root, unexpected=True))
    assert result["status"] == "failed"
    assert result["error"]["code"] == "invalid_request"


def test_python_exception_is_normalized(root: Path, monkeypatch) -> None:
    def fail(_recipe, *, resume=False):
        raise RuntimeError("controlled failure")

    monkeypatch.setattr(host_api, "train_recipe", fail)
    result = host_api.execute(request("train", root, "recipes/qwen/sft_lora.yaml"))
    assert result["status"] == "failed"
    assert result["error"] == {
        "code": "operation_failed",
        "message": "controlled failure",
        "kind": "RuntimeError",
        "retryable": False,
    }


def test_missing_dependency_is_normalized(root: Path, monkeypatch) -> None:
    def missing(_name):
        raise ModuleNotFoundError("missing runtime dependency")

    monkeypatch.setattr(host_api.importlib, "import_module", missing)
    result = host_api.execute(request("health", root))
    assert result["status"] == "failed"
    assert result["error"]["code"] == "missing_dependency"


def test_json_boundary(root: Path) -> None:
    payload = json.dumps(request("health", root))
    result = json.loads(host_api.execute_json(payload))
    assert result["status"] == "succeeded"


def test_invalid_json_is_normalized() -> None:
    result = json.loads(host_api.execute_json("{"))
    assert result["status"] == "failed"
    assert result["error"]["code"] == "invalid_json"
