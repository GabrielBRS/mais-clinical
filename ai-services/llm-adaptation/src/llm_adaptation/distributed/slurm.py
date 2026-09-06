from __future__ import annotations


def slurm_script(*, job: str, nodes: int, gpus: int, command: str) -> str:
    return "\n".join(
        [
            "#!/bin/bash",
            f"#SBATCH --job-name={job}",
            f"#SBATCH --nodes={nodes}",
            f"#SBATCH --gres=gpu:{gpus}",
            "set -euo pipefail",
            command,
            "",
        ]
    )
