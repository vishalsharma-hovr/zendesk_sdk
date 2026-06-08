#!/bin/sh
set -e

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
ENV_FILE="${REPO_ROOT}/.secrets/zendesk.env"
OUT_FILE="$(cd "$(dirname "$0")/.." && pwd)/Flutter/Secrets.generated.xcconfig"

if [ ! -f "$ENV_FILE" ]; then
  echo "error: Missing ${ENV_FILE}"
  echo "Run: cp .secrets/zendesk.env.example .secrets/zendesk.env"
  exit 1
fi

{
  echo "// Generated from .secrets/zendesk.env - do not edit"
  grep -E '^[A-Z0-9_]+=' "$ENV_FILE" | while IFS= read -r line; do
    key="${line%%=*}"
    value="${line#*=}"
    value="$(echo "$value" | sed -e 's/^["'\'']//' -e 's/["'\'']$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    # xcconfig treats // as a comment — use $(/) to emit a slash (https:/$()/host).
    value="$(echo "$value" | sed 's|://|:/$()/|g')"
    echo "${key} = ${value}"
  done
} > "$OUT_FILE"

echo "Generated ${OUT_FILE}"
