from application.graph.router import pick_id


def main():
    var available = List[String]()
    available.append("default")
    available.append("research")
    var chosen = String()
    for i in range(100000):
        _ = i
        chosen = pick_id("default", available)
    print("100000 routes", chosen)
