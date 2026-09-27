from typing import Any

from mcp.server.fastmcp import FastMCP
from mcp.server.transport_security import TransportSecuritySettings

from orzyon import backends
from orzyon.config import Settings
from orzyon.knowledge import Knowledge
from orzyon.telemetry import Telemetry


def create_servers(
    settings: Settings, knowledge: Knowledge, telemetry: Telemetry
) -> dict[str, FastMCP]:
    from urllib.parse import urlsplit

    hostname = urlsplit(settings.mcp_base_url).hostname
    servers = {
        name: FastMCP(
            f"{name}-mcp",
            stateless_http=True,
            json_response=True,
            streamable_http_path="/",
            transport_security=TransportSecuritySettings(
                enable_dns_rebinding_protection=True,
                allowed_hosts=["127.0.0.1:*", "localhost:*", "testserver", f"{hostname}:*"],
                allowed_origins=["http://127.0.0.1:*", "http://localhost:*"],
            ),
        )
        for name in ("platform", "knowledge", "observability")
    }

    @servers["platform"].tool()
    @telemetry.tool
    async def list_deployments() -> dict[str, Any]:
        """Read deployments only in the namespace authorized by the platform operator."""
        return await backends.deployments(settings)

    @servers["platform"].tool()
    @telemetry.tool
    async def get_cluster_status() -> dict[str, Any]:
        """Namespace-scoped readiness summary; not a claim about cluster-wide health."""
        data = await backends.deployments(settings)
        return {"scope": "namespace", **data}

    @servers["knowledge"].tool()
    @telemetry.tool
    async def search_documents(query: str, limit: int = 5) -> list[dict[str, str | int]]:
        """Lexical search in the curated public laboratory corpus, with source IDs."""
        return knowledge.search(query, limit)

    @servers["knowledge"].tool()
    @telemetry.tool
    async def retrieve_document(document_id: str) -> dict[str, str]:
        """Retrieve an allowlisted document ID. Paths and URLs are never accepted."""
        return knowledge.retrieve(document_id)

    @servers["knowledge"].tool()
    @telemetry.tool
    async def list_collections() -> list[dict[str, str | int]]:
        """List collections available to this single-tenant laboratory."""
        return [{"name": "platform-docs", "documents": len(knowledge.documents)}]

    @servers["observability"].tool()
    @telemetry.tool
    async def query_metrics(query_name: str) -> dict[str, Any]:
        """Run a named bounded query: service_health, request_rate, tool_errors, tool_latency."""
        return await backends.metrics(settings, query_name)

    return servers
