"""Create local development credentials once; never overwrite or rotate existing secrets."""

import os
import secrets
from pathlib import Path

target = Path(".env")
template = Path(".env.example").read_text(encoding="utf-8")
for variable in (
    "ORZYON_API_TOKEN",
    "ORZYON_GRAFANA_PASSWORD",
    "ORZYON_GATEWAY_TOKEN",
    "VLLM_API_KEY",
):
    template = template.replace(f"{variable}=\n", f"{variable}={secrets.token_urlsafe(32)}\n")
try:
    descriptor = os.open(target, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
except FileExistsError:
    raise SystemExit(".env already exists; no credentials were overwritten") from None
with os.fdopen(descriptor, "w", encoding="utf-8", newline="\n") as stream:
    stream.write(template)
print("Created .env with distinct local credentials. Values were not printed.")
