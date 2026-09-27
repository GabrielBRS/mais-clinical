"""Real SDK client against a running server. No fake backend or protocol implementation."""

import argparse
import asyncio
import os

from mcp import ClientSession

from orzyon.mcp_client import connect


async def main(url: str) -> None:
    token = os.environ["ORZYON_API_TOKEN"]
    for service in ("platform", "knowledge", "observability"):
        async with connect(
            f"{url}/mcp/{service}/", headers={"Authorization": f"Bearer {token}"}
        ) as streams:
            async with ClientSession(streams[0], streams[1]) as session:
                await session.initialize()
                tools = await session.list_tools()
                print(service, [tool.name for tool in tools.tools])
                if service == "knowledge":
                    result = await session.call_tool("search_documents", {"query": "Kubernetes"})
                    if result.isError:
                        raise RuntimeError("Knowledge MCP failed")
                    print(result.model_dump_json())


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", default="http://127.0.0.1:8000")
    asyncio.run(main(parser.parse_args().url))
