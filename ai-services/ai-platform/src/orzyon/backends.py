import ssl
from pathlib import Path
from typing import Any

import httpx

from orzyon.config import Settings

SA_ROOT = Path("/var/run/secrets/kubernetes.io/serviceaccount")


class BackendUnavailable(Exception):
    """Dependency unavailable; never fabricate a successful response."""


async def get_json(url: str, *, params: dict[str, str] | None = None) -> dict[str, Any]:
    try:
        async with httpx.AsyncClient(timeout=5, follow_redirects=False, trust_env=False) as client:
            async with client.stream("GET", url, params=params) as response:
                response.raise_for_status()
                body = bytearray()
                async for chunk in response.aiter_bytes():
                    body.extend(chunk)
                    if len(body) > 1_000_000:
                        raise BackendUnavailable("Dependency response exceeded size limit")
                import json

                result = json.loads(body)
                if not isinstance(result, dict):
                    raise BackendUnavailable("Invalid dependency response")
                return result
    except (httpx.HTTPError, ValueError) as error:
        raise BackendUnavailable("Dependency request failed") from error


async def deployments(settings: Settings) -> dict[str, Any]:
    if not (SA_ROOT / "token").exists():
        raise BackendUnavailable("Kubernetes service account unavailable; run inside the cluster")
    try:
        context = ssl.create_default_context(cafile=str(SA_ROOT / "ca.crt"))
        # Read on every call so projected-token rotation is respected.
        token = (SA_ROOT / "token").read_text().strip()
        async with httpx.AsyncClient(verify=context, timeout=5, trust_env=False) as client:
            response = await client.get(
                f"https://kubernetes.default.svc/apis/apps/v1/namespaces/{settings.namespace}"
                "/deployments",
                params={"limit": "100"},
                headers={"Authorization": f"Bearer {token}"},
            )
            response.raise_for_status()
            payload = response.json()
        return {
            "namespace": settings.namespace,
            "truncated": bool(payload.get("metadata", {}).get("continue")),
            "deployments": [
                {
                    "name": item["metadata"]["name"],
                    "desired": item["spec"].get("replicas", 1),
                    "ready": item.get("status", {}).get("readyReplicas", 0),
                }
                for item in payload["items"]
            ],
        }
    except (httpx.HTTPError, OSError, ValueError, KeyError) as error:
        raise BackendUnavailable("Kubernetes read failed; inspect RBAC and connectivity") from error


METRIC_QUERIES = {
    "service_health": "up",
    "request_rate": "sum(rate(orzyon_http_requests_total[5m])) by (status)",
    "tool_errors": 'sum(rate(orzyon_tool_calls_total{outcome="error"}[5m])) by (tool)',
    "tool_latency": "histogram_quantile(0.95, sum(rate(orzyon_tool_seconds_bucket[5m])) "
    "by (le, tool))",
}


async def metrics(settings: Settings, query_name: str) -> dict[str, Any]:
    if query_name not in METRIC_QUERIES:
        raise ValueError(f"Allowed queries: {', '.join(METRIC_QUERIES)}")
    result = await get_json(
        f"{settings.prometheus_url}/api/v1/query",
        params={"query": METRIC_QUERIES[query_name], "timeout": "3s"},
    )
    if result.get("status") != "success":
        raise BackendUnavailable("Prometheus query failed")
    return result
