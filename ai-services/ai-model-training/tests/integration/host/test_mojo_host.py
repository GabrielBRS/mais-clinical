from __future__ import annotations

import json
import os
from pathlib import Path
import shutil
import subprocess

import pytest


PROJECT = Path(__file__).resolve().parents[3]
BINARY = PROJECT / "build/ai-model-training"


def host_env() -> dict[str, str]:
    env = os.environ.copy()
    prefix = Path(env.get("CONDA_PREFIX", PROJECT / ".pixi/envs/default"))
    env["MOJO_PYTHON"] = str(prefix / "bin/python")
    env["MOJO_PYTHON_LIBRARY"] = str(prefix / "lib/libpython3.13.so")
    return env


def run_host(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [str(BINARY), *args],
        cwd=PROJECT,
        env=host_env(),
        text=True,
        capture_output=True,
        check=False,
    )


@pytest.mark.skipif(not BINARY.exists(), reason="build the Mojo host first")
def test_health_through_mojo_binary() -> None:
    completed = run_host("health")
    assert completed.returncode == 0, completed.stderr
    result = json.loads(completed.stdout)
    assert result["status"] == "succeeded"
    assert result["data"]["ready"] is True


@pytest.mark.skipif(not BINARY.exists(), reason="build the Mojo host first")
def test_mojo_python_training_flow(root: Path) -> None:
    completed = run_host(
        "train",
        "--recipe",
        "recipes/qwen/sft_lora.yaml",
        "--root",
        str(root),
    )
    assert completed.returncode == 0, completed.stderr
    result = json.loads(completed.stdout)
    assert result["status"] == "succeeded"
    assert result["data"]["adapter"] == "lora"
    assert Path(result["checkpoint"]).is_file() is False
    assert (Path(result["checkpoint"]) / "checkpoint.json").is_file()


@pytest.mark.skipif(not BINARY.exists(), reason="build the Mojo host first")
def test_full_lifecycle_through_mojo_binary(root: Path) -> None:
    recipe = "recipes/qwen/sft_lora.yaml"
    results = []
    for operation in ("prepare-data", "train", "evaluate", "export", "publish"):
        completed = run_host(operation, "--recipe", recipe, "--root", str(root))
        assert completed.returncode == 0, completed.stderr
        results.append(json.loads(completed.stdout))
    assert all(result["status"] == "succeeded" for result in results)
    assert (root / "artifacts/evaluations/qwen-sft-lora/metrics.json").is_file()
    assert (root / "artifacts/merged/qwen-sft-lora/config.json").is_file()


@pytest.mark.skipif(not BINARY.exists(), reason="build the Mojo host first")
def test_qlora_smoke_through_mojo_binary(root: Path) -> None:
    completed = run_host(
        "train",
        "--recipe",
        "recipes/qwen/sft_qlora.yaml",
        "--root",
        str(root),
    )
    assert completed.returncode == 0, completed.stderr
    result = json.loads(completed.stdout)
    assert result["data"]["adapter"] == "qlora"


@pytest.mark.skipif(not BINARY.exists(), reason="build the Mojo host first")
def test_failure_has_nonzero_exit_and_normalized_error(root: Path) -> None:
    completed = run_host(
        "train",
        "--recipe",
        "../outside.yaml",
        "--root",
        str(root),
    )
    assert completed.returncode != 0
    result = json.loads(completed.stdout)
    assert result["status"] == "failed"
    assert result["error"]["code"] == "invalid_recipe"


@pytest.mark.skipif(
    not BINARY.exists() or shutil.which("strace") is None,
    reason="requires the Mojo binary and strace",
)
def test_normal_flow_does_not_start_python_subprocess(tmp_path: Path) -> None:
    trace = tmp_path / "process.trace"
    completed = subprocess.run(
        ["strace", "-f", "-e", "trace=process", "-o", str(trace), str(BINARY), "health"],
        cwd=PROJECT,
        env=host_env(),
        text=True,
        capture_output=True,
        check=False,
    )
    if completed.returncode != 0 and "Operation not permitted" in completed.stderr:
        pytest.skip("the sandbox does not permit ptrace/strace")
    assert completed.returncode == 0, completed.stderr
    child_python_execs = [
        line
        for line in trace.read_text().splitlines()
        if "execve(" in line and "python" in line.lower()
    ]
    assert child_python_execs == []
