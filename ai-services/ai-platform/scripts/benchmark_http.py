"""Bounded local HTTP load probe. This does not measure LLM TTFT or GPU throughput."""

import argparse
import asyncio
import json
import time
from datetime import UTC, datetime
from urllib.parse import urlsplit

import httpx

from orzyon.experiments import metadata


async def benchmark(url: str, count: int, concurrency: int) -> dict:
    if urlsplit(url).hostname not in {"localhost", "127.0.0.1", "::1"}:
        raise ValueError("This lab intentionally accepts only loopback targets")
    if not 1 <= count <= 1000 or not 1 <= concurrency <= 20:
        raise ValueError("Use count <= 1000 and concurrency <= 20")
    semaphore = asyncio.Semaphore(concurrency)
    durations, errors = [], []
    async with httpx.AsyncClient(timeout=5, trust_env=False) as client:

        async def request() -> None:
            async with semaphore:
                start = time.perf_counter()
                try:
                    response = await client.get(url)
                    errors.append(response.status_code >= 400)
                except httpx.HTTPError:
                    errors.append(True)
                durations.append(time.perf_counter() - start)

        start = time.perf_counter()
        await asyncio.gather(*(request() for _ in range(count)))
        elapsed = time.perf_counter() - start
    ordered = sorted(durations)
    return {
        "timestamp": datetime.now(UTC).isoformat(),
        "url": url,
        "requests": count,
        "concurrency": concurrency,
        "rps": count / elapsed,
        "error_rate": sum(errors) / count,
        "latency_seconds": {
            f"p{p}": ordered[max(0, (len(ordered) * p + 99) // 100 - 1)] for p in (50, 95, 99)
        },
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", default="http://127.0.0.1:8000/health/ready")
    parser.add_argument("--count", type=int, default=100)
    parser.add_argument("--concurrency", type=int, default=5)
    args = parser.parse_args()
    result = asyncio.run(benchmark(args.url, args.count, args.concurrency))
    result["experiment"] = metadata()
    print(json.dumps(result, indent=2))
