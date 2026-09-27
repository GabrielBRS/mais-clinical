"""Check external documentation URLs without downloading media or copying content."""

import argparse
import concurrent.futures
import json
import re
from datetime import UTC, datetime
from pathlib import Path

import httpx


def check(url: str) -> dict:
    try:
        with httpx.Client(
            timeout=20,
            follow_redirects=True,
            headers={"User-Agent": "OrzyonDocumentationCheck/0.1"},
        ) as client:
            with client.stream("GET", url) as response:
                return {"url": url, "final_url": str(response.url), "status": response.status_code}
    except httpx.HTTPError as error:
        return {"url": url, "status": "unverified", "reason": type(error).__name__}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path("docs/learning/resources"))
    args = parser.parse_args()
    urls = sorted(
        {
            url
            for path in args.root.glob("*.md")
            for url in re.findall(r"\]\((https?://[^)]+)\)", path.read_text(encoding="utf-8"))
        }
    )
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        results = list(pool.map(check, urls))
    report = {"checked_at": datetime.now(UTC).isoformat(), "results": results}
    (args.root / "link-check.json").write_text(
        json.dumps(report, indent=2) + "\n", encoding="utf-8"
    )
    failures = [item for item in results if item["status"] != 200]
    print(json.dumps({"checked": len(results), "non_200": failures}, indent=2))
