#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/scripts/lib.sh"

[[ $# -eq 1 ]] || { echo "Usage: $0 <job-id>"; exit 1; }
JOB="$1"
stop_stage "$JOB" inventory
stop_stage "$JOB" appdata
stop_stage "$JOB" domains
stop_stage "$JOB" boot_config
echo "Stopped job: $JOB"
