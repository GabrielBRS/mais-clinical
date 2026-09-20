from bootstrap.application import Application


def main() raises:
    var process = Application.build()
    process.orchestrator.lifecycle.start()
    var raw = "POST /agents/execute HTTP/1.1\r\nContent-Type: application/json\r\nContent-Length: 23\r\n\r\n{\"prompt\":\"hello mojo\"}"
    var response = process.service.http.handle(process.orchestrator, raw)
    print(response.encode())
