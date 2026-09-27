import hashlib
import platform
import subprocess
import uuid
from datetime import UTC, datetime
from pathlib import Path
from typing import Any


def metadata(dataset: Path | None = None) -> dict[str, Any]:
    try:
        commit = subprocess.check_output(
            ["git", "rev-parse", "HEAD"], text=True, stderr=subprocess.DEVNULL, timeout=5
        ).strip()
        dirty = bool(
            subprocess.check_output(
                ["git", "status", "--porcelain", "--", "."], text=True, timeout=5
            ).strip()
        )
    except (OSError, subprocess.SubprocessError):
        commit, dirty = None, None
    return {
        "experiment_id": str(uuid.uuid4()),
        "timestamp": datetime.now(UTC).isoformat(),
        "commit_sha": commit,
        "working_tree_dirty": dirty,
        "python": platform.python_version(),
        "os": platform.system(),
        "architecture": platform.machine(),
        "gpu": None,
        "model": None,
        "dataset_sha256": hashlib.sha256(dataset.read_bytes()).hexdigest() if dataset else None,
    }
