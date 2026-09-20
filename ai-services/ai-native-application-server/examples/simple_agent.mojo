from application.application import make_application
from application.config import Settings


def main() raises:
    var app = make_application(Settings.default())
    var result = app.execute_agent("default", "hello agent")
    print(result.execution_id, result.text)
