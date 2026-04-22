#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/scripts/lib.sh"

[[ $# -ge 1 ]] || { echo "Usage: $0 <job-id> [stage]"; exit 1; }
JOB="$1"
STAGE="${2:-appdata}"
LOGF="$(job_log_file "$JOB" "$STAGE")"
[[ -f "$LOGF" ]] || { echo "No log yet: $LOGF"; exit 0; }
tail -f "$LOGF"
