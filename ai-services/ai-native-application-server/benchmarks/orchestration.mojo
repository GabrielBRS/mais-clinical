from application.application import make_application
from application.config import Settings


def main() raises:
    var app = make_application(Settings.default())
    var last = String()
    for i in range(1000):
        _ = i
        last = app.execute_agent("default", "benchmark").text
    print("1000 agent executions", last)
