from domain.errors import OrchestratorError, graph_empty, node_not_found

from .edge import Edge
from .node import Node


struct Graph(Copyable):
    var nodes: List[Node]
    var edges: List[Edge]

    def __init__(
        out self,
        var nodes: List[Node] = List[Node](),
        var edges: List[Edge] = List[Edge](),
    ):
        self.nodes = nodes^
        self.edges = edges^

    def node(self, node_id: String) raises OrchestratorError -> Node:
        for item in self.nodes:
            if item.id == node_id:
                return item.copy()
        raise node_not_found(node_id)

    def start(self) raises OrchestratorError -> Node:
        var targets = List[String]()
        for edge in self.edges:
            targets.append(edge.target.copy())
        for node in self.nodes:
            var is_target = False
            for target in targets:
                if node.id == target:
                    is_target = True
                    break
            if not is_target:
                return node.copy()
        if len(self.nodes) == 0:
            raise graph_empty()
        return self.nodes[0].copy()

    def successors(
        self, node_id: String
    ) raises OrchestratorError -> List[Node]:
        var out = List[Node]()
        for edge in self.edges:
            if edge.source == node_id:
                out.append(self.node(edge.target))
        return out^

    @staticmethod
    def default_retrieve_generate() -> Graph:
        var nodes = List[Node]()
        nodes.append(Node("r", "retrieve", "retrieve"))
        nodes.append(Node("g", "generate", "generate"))
        var edges = List[Edge]()
        edges.append(Edge("r", "g"))
        return Graph(nodes^, edges^)
