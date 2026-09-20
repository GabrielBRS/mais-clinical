"""Stable, versioned boundary used by the Mojo application host.

This module deliberately exposes operations, not arbitrary modules or callables.  The
Mojo process hosts CPython and imports this facade by its known package name.
"""

from __future__ import annotations

import importlib
import json
from datetime import UTC, datetime
from pathlib import Path
from typing import Any, Callable, Literal
from uuid import UUID, uuid4

from pydantic import BaseModel, ConfigDict, Field, ValidationError, field_validator, model_validator

from llm_adaptation.pipeline import (
    evaluate_recipe,
    export_recipe,
    prepare_recipe,
    publish_recipe,
    train_recipe,
)
from llm_adaptation.recipe import Recipe, load_yaml, project_root

SCHEMA_VERSION = "1.0"
Operation = Literal["train", "evaluate", "export", "prepare_data", "publish", "health"]


class HostRequest(BaseModel):
    """Validated request accepted at the Mojo/Python boundary."""

    model_config = ConfigDict(extra="forbid")

    schema_version: Literal["1.0"] = SCHEMA_VERSION
    operation: Operation
    run_id: str = Field(default_factory=lambda: str(uuid4()))
    recipe_path: str | None = None
    root: str | None = None
    overrides: dict[str, Any] = Field(default_factory=dict)
    input_dir: str | None = None
    output_dir: str | None = None
    device: str = "cpu"
    distributed: dict[str, Any] = Field(default_factory=dict)
    resume: bool = False
    dry_run: bool = False

    @field_validator("run_id")
    @classmethod
    def valid_run_id(cls, value: str) -> str:
        UUID(value)
        return value

    @field_validator("device")
    @classmethod
    def valid_device(cls, value: str) -> str:
        allowed = {"cpu", "cuda", "mps", "auto"}
        if value not in allowed:
            raise ValueError(f"device must be one of {sorted(allowed)}")
        return value

    @model_validator(mode="after")
    def operation_requirements(self) -> HostRequest:
        if self.operation != "health" and not self.recipe_path:
            raise ValueError(f"recipe_path is required for {self.operation}")
        if self.overrides:
            raise ValueError("overrides are not enabled until an explicit allowlist is defined")
        return self


class HostError(BaseModel):
    model_config = ConfigDict(extra="forbid")

    code: str
    message: str
    kind: str
    retryable: bool = False


class HostResult(BaseModel):
    """Normalized result returned to the Mojo host."""

    model_config = ConfigDict(extra="forbid")

    schema_version: Literal["1.0"] = SCHEMA_VERSION
    run_id: str
    operation: Operation
    status: Literal["succeeded", "failed"]
    started_at: str
    finished_at: str
    metrics: dict[str, float] = Field(default_factory=dict)
    artifacts: dict[str, str] = Field(default_factory=dict)
    checkpoint: str | None = None
    warnings: list[str] = Field(default_factory=list)
    data: dict[str, Any] = Field(default_factory=dict)
    error: HostError | None = None


OperationHandler = Callable[[Recipe], dict[str, Any]]
_OPERATIONS: dict[str, OperationHandler] = {
    "train": train_recipe,
    "evaluate": evaluate_recipe,
    "export": export_recipe,
    "prepare_data": prepare_recipe,
    "publish": publish_recipe,
}

_REQUIRED_MODULES = (
    "llm_adaptation.pipeline",
    "llm_adaptation.recipe",
    "llm_adaptation.training",
)


def allowed_operations() -> tuple[str, ...]:
    """Return the immutable public operation catalog."""

    return (*_OPERATIONS, "health")


def _utc_now() -> str:
    return datetime.now(UTC).isoformat()


def _failure(
    *,
    request: HostRequest,
    started_at: str,
    code: str,
    kind: str,
    message: str,
    retryable: bool = False,
) -> HostResult:
    return HostResult(
        run_id=request.run_id,
        operation=request.operation,
        status="failed",
        started_at=started_at,
        finished_at=_utc_now(),
        error=HostError(code=code, kind=kind, message=message, retryable=retryable),
    )


def _safe_recipe(request: HostRequest) -> Recipe:
    root = Path(request.root).resolve() if request.root else project_root()
    if not root.is_dir():
        raise FileNotFoundError(f"project root not found: {root}")
    recipes_root = (root / "recipes").resolve()
    configs_root = (root / "configs").resolve()
    candidate = Path(request.recipe_path or "")
    recipe_path = candidate.resolve() if candidate.is_absolute() else (root / candidate).resolve()
    if not recipe_path.is_relative_to(recipes_root):
        raise ValueError("recipe_path must resolve inside the project's recipes directory")
    if recipe_path.suffix not in {".yaml", ".yml"}:
        raise ValueError("recipe_path must be a YAML file")
    if not recipe_path.is_file():
        raise FileNotFoundError(f"recipe not found: {recipe_path}")
    raw = load_yaml(recipe_path)
    extends = raw.get("extends") or {}
    if not isinstance(extends, dict):
        raise ValueError("recipe extends must be a mapping")
    for relative in extends.values():
        if not isinstance(relative, str):
            raise ValueError("recipe fragment paths must be strings")
        fragment = (root / relative).resolve()
        if not fragment.is_relative_to(configs_root) or not fragment.is_file():
            raise ValueError(f"recipe fragment is outside the config allowlist: {relative}")
    recipe = Recipe.load(recipe_path, root=root)
    data_path = (root / str(recipe.data.get("path", "data/sft"))).resolve()
    if not data_path.is_relative_to((root / "data").resolve()):
        raise ValueError("recipe data path must resolve inside the project's data directory")
    return recipe


def _health(request: HostRequest, started_at: str) -> HostResult:
    loaded: list[str] = []
    for module_name in _REQUIRED_MODULES:
        importlib.import_module(module_name)
        loaded.append(module_name)
    return HostResult(
        run_id=request.run_id,
        operation="health",
        status="succeeded",
        started_at=started_at,
        finished_at=_utc_now(),
        data={"ready": True, "modules": loaded, "operations": list(allowed_operations())},
    )


def _normalize_success(request: HostRequest, started_at: str, raw: dict[str, Any]) -> HostResult:
    metrics = {
        key: float(value)
        for key, value in raw.items()
        if isinstance(value, (int, float)) and not isinstance(value, bool)
    }
    artifacts = {
        key: value
        for key, value in raw.items()
        if isinstance(value, str) and (key in {"checkpoint", "merged", "quantized", "processed"})
    }
    checkpoint = raw.get("checkpoint") if isinstance(raw.get("checkpoint"), str) else None
    warnings: list[str] = []
    if request.device != "cpu":
        warnings.append(
            f"device={request.device} was requested, but the current dummy engine executes on CPU"
        )
    if request.operation == "train":
        warnings.append("the current training engine is a CPU dummy scaffold, not PyTorch training")
    return HostResult(
        run_id=request.run_id,
        operation=request.operation,
        status="succeeded",
        started_at=started_at,
        finished_at=_utc_now(),
        metrics=metrics,
        artifacts=artifacts,
        checkpoint=checkpoint,
        warnings=warnings,
        data=raw,
    )


def execute(request: dict[str, Any]) -> dict[str, Any]:
    """Validate and execute one allowlisted operation, returning a normalized result."""

    started_at = _utc_now()
    try:
        parsed = HostRequest.model_validate(request)
    except (ValidationError, ValueError) as exc:
        fallback_run_id = request.get("run_id") if isinstance(request.get("run_id"), str) else str(uuid4())
        fallback_operation = request.get("operation")
        if fallback_operation not in allowed_operations():
            fallback_operation = "health"
        result = HostResult(
            run_id=fallback_run_id,
            operation=fallback_operation,
            status="failed",
            started_at=started_at,
            finished_at=_utc_now(),
            error=HostError(
                code="invalid_request",
                kind="validation",
                message=str(exc),
            ),
        )
        return result.model_dump(mode="json")

    try:
        if parsed.operation == "health":
            result = _health(parsed, started_at)
        else:
            recipe = _safe_recipe(parsed)
            if parsed.dry_run:
                result = HostResult(
                    run_id=parsed.run_id,
                    operation=parsed.operation,
                    status="succeeded",
                    started_at=started_at,
                    finished_at=_utc_now(),
                    data={"validated": True, "recipe": str(recipe.path)},
                )
            else:
                raw = (
                    train_recipe(recipe, resume=parsed.resume)
                    if parsed.operation == "train"
                    else _OPERATIONS[parsed.operation](recipe)
                )
                result = _normalize_success(parsed, started_at, raw)
    except ModuleNotFoundError as exc:
        result = _failure(
            request=parsed,
            started_at=started_at,
            code="missing_dependency",
            kind="dependency",
            message=str(exc),
        )
    except (FileNotFoundError, ValueError) as exc:
        result = _failure(
            request=parsed,
            started_at=started_at,
            code="invalid_recipe",
            kind="validation",
            message=str(exc),
        )
    except Exception as exc:  # The boundary must not leak Python tracebacks to the host.
        result = _failure(
            request=parsed,
            started_at=started_at,
            code="operation_failed",
            kind=type(exc).__name__,
            message=str(exc),
        )
    return result.model_dump(mode="json")


def execute_cli(
    operation: str,
    recipe_path: str,
    root: str,
    run_id: str,
    dry_run: bool = False,
    device: str = "cpu",
    resume: bool = False,
) -> dict[str, Any]:
    """Narrow adapter used by Mojo after Mojo validates its CLI arguments."""

    normalized_operation = operation.replace("-", "_")
    request: dict[str, Any] = {
        "schema_version": SCHEMA_VERSION,
        "operation": normalized_operation,
        "run_id": run_id,
        "root": root,
        "dry_run": dry_run,
        "device": device,
        "resume": resume,
    }
    if normalized_operation != "health":
        request["recipe_path"] = recipe_path
    return execute(request)


def execute_json(payload: str) -> str:
    """JSON convenience API for contract probes and non-Mojo consumers."""

    try:
        request = json.loads(payload)
    except json.JSONDecodeError as exc:
        now = _utc_now()
        result = HostResult(
            run_id=str(uuid4()),
            operation="health",
            status="failed",
            started_at=now,
            finished_at=now,
            error=HostError(code="invalid_json", kind="validation", message=str(exc)),
        )
        return result.model_dump_json()
    return json.dumps(execute(request), sort_keys=True)


__all__ = [
    "HostError",
    "HostRequest",
    "HostResult",
    "SCHEMA_VERSION",
    "allowed_operations",
    "execute",
    "execute_cli",
    "execute_json",
]
