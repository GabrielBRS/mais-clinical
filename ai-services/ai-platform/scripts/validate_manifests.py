"""Validate rendered native Kubernetes resources against versioned JSON schemas.

Uses the kubernetes-json-schema project, which generates schemas from Kubernetes.
Does not validate CRDs, admission policies, scheduling or cluster execution.
"""

import argparse
import json
from pathlib import Path

import httpx
import jsonschema
import yaml

VERSION = "v1.35.0"


def validate(path: Path) -> int:
    count = 0
    with httpx.Client(timeout=20, follow_redirects=True) as client:
        for document in yaml.safe_load_all(path.read_text(encoding="utf-8-sig")):
            if document is None:
                continue
            api = document["apiVersion"].split("/")
            suffix = "" if len(api) == 1 else "-" + api[0].split(".")[0] + "-" + api[1]
            name = document["kind"].lower() + suffix + ".json"
            url = (
                "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/"
                f"{VERSION}-standalone-strict/{name}"
            )
            response = client.get(url)
            response.raise_for_status()
            jsonschema.validate(document, json.loads(response.content))
            count += 1
    if not count:
        raise ValueError("No manifests found")
    return count


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    print(f"Validated {validate(parser.parse_args().manifest)} Kubernetes objects")
