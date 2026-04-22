#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/scripts/lib.sh"

[[ $# -eq 1 ]] || { echo "Usage: $0 <job-id>"; exit 1; }
JOB="$1"

echo "Job: $JOB"
for stage in inventory appdata domains boot_config; do
  done_file="$(job_done_file "$JOB" "$stage")"
  done_at="-"
  [[ -f "$done_file" ]] && done_at="$(cat "$done_file")"
  echo "  - $stage: $(stage_status "$JOB" "$stage") (done_at: $done_at)"
done
