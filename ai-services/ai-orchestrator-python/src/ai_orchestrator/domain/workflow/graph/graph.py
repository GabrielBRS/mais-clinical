from __future__ import annotations

from dataclasses import dataclass, field

from ai_orchestrator.domain.workflow.edge.edge import Edge
from ai_orchestrator.domain.workflow.node.node import Node


@dataclass(slots=True)
class Graph:
    nodes: list[Node] = field(default_factory=list)
    edges: list[Edge] = field(default_factory=list)

    def node(self, node_id: str) -> Node:
        for item in self.nodes:
            if item.id == node_id:
                return item
        raise KeyError(node_id)

    def start(self) -> Node:
        targets = {e.target for e in self.edges}
        for node in self.nodes:
            if node.id not in targets:
                return node
        if not self.nodes:
            raise ValueError("graph vazio")
        return self.nodes[0]

    def successors(self, node_id: str) -> list[Node]:
        ids = [e.target for e in self.edges if e.source == node_id]
        return [self.node(i) for i in ids]
