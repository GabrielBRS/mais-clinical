from ai_orchestrator.domain.workflow import Edge, Graph, Node


def test_graph_start_and_successors() -> None:
    graph = Graph(
        nodes=[Node("r", "retrieve"), Node("g", "generate")],
        edges=[Edge("r", "g")],
    )
    assert graph.start().id == "r"
    assert [n.id for n in graph.successors("r")] == ["g"]
    assert graph.successors("g") == []
