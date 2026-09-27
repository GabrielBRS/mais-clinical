import json
import logging
import time
from collections.abc import Awaitable, Callable
from functools import wraps
from typing import Any

from opentelemetry import trace
from prometheus_client import CollectorRegistry, Counter, Histogram

logger = logging.getLogger("orzyon.audit")
logger.setLevel(logging.INFO)
if not logger.handlers:
    logger.addHandler(logging.StreamHandler())
logger.propagate = False


class Telemetry:
    def __init__(self) -> None:
        self.registry = CollectorRegistry()
        self.requests = Counter(
            "orzyon_http_requests_total", "HTTP responses", ["status"], registry=self.registry
        )
        self.calls = Counter(
            "orzyon_tool_calls_total", "Tool calls", ["tool", "outcome"], registry=self.registry
        )
        self.latency = Histogram(
            "orzyon_tool_seconds", "Tool duration", ["tool"], registry=self.registry
        )
        self.tracer = trace.get_tracer("orzyon")

    def tool(self, function: Callable[..., Awaitable[Any]]) -> Callable[..., Awaitable[Any]]:
        @wraps(function)
        async def wrapped(*args: Any, **kwargs: Any) -> Any:
            started, outcome = time.perf_counter(), "ok"
            with self.tracer.start_as_current_span(function.__name__):
                try:
                    return await function(*args, **kwargs)
                except Exception:
                    outcome = "error"
                    raise
                finally:
                    elapsed = time.perf_counter() - started
                    self.calls.labels(function.__name__, outcome).inc()
                    self.latency.labels(function.__name__).observe(elapsed)
                    logger.info(
                        json.dumps(
                            {
                                "event": "tool",
                                "tool": function.__name__,
                                "outcome": outcome,
                                "duration_s": elapsed,
                            }
                        )
                    )

        return wrapped
