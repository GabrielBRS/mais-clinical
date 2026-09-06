from __future__ import annotations

from dataclasses import dataclass


@dataclass(slots=True)
class ClusterSpec:
    nodes: int = 1
    gpus_per_node: int = 1
    strategy: str = "single_gpu"

    @property
    def world_size(self) -> int:
        return self.nodes * self.gpus_per_node
