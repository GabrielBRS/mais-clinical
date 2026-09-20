from application.graph.edge import Edge
from application.graph.graph import Graph
from application.graph.node import Node
from application.graph.router import Router, pick_id
from std.testing import assert_equal, assert_raises, TestSuite


def test_graph_start_and_successors() raises:
    var nodes = List[Node]()
    nodes.append(Node("r", "retrieve"))
    nodes.append(Node("g", "generate"))
    var edges = List[Edge]()
    edges.append(Edge("r", "g"))
    var graph = Graph(nodes^, edges^)
    assert_equal(graph.start().id, "r")
    var next_nodes = graph.successors("r")
    assert_equal(len(next_nodes), 1)
    assert_equal(next_nodes[0].id, "g")
    assert_equal(len(graph.successors("g")), 0)


def test_default_graph() raises:
    var graph = Graph.default_retrieve_generate()
    assert_equal(graph.start().id, "r")
    assert_equal(graph.start().kind, "retrieve")


def test_missing_node() raises:
    var graph = Graph()
    with assert_raises(contains="graph vazio"):
        _ = graph.start()


def test_router_prefers_id() raises:
    var available = List[String]()
    available.append("default")
    available.append("other")
    assert_equal(pick_id("other", available), "other")
    assert_equal(pick_id("missing", available), "default")
    var router = Router()
    assert_equal(router.route("", "prompt", available), "default")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
