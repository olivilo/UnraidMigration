#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
JOBS_DIR="$BASE_DIR/jobs"
mkdir -p "$JOBS_DIR"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <job-id> [src_host] [src_ssh_port] [dest_base]"
  exit 1
fi

JOB_ID="$1"
SRC_HOST="${2:-100.100.100.10}"
SRC_PORT="${3:-22}"
DEST_BASE="${4:-/mnt/user/MigrationShare/migration}"

cat >"$JOBS_DIR/${JOB_ID}.env" <<EOC
JOB_NAME="$JOB_ID"
SRC_HOST="$SRC_HOST"
SRC_USER="root"
SRC_SSH_PORT="$SRC_PORT"
SRC_SSH_KEY="/root/.ssh/migrate_${JOB_ID}"
DEST_BASE="$DEST_BASE"

SRC_PATH_APPDATA="/mnt/user/appdata/"
SRC_PATH_DOMAINS="/mnt/user/domains/"
SRC_PATH_BOOT_CONFIG="/boot/config/"

RSYNC_BWLIMIT="20m"
NICE_LEVEL="15"
IONICE_CLASS="2"
IONICE_LEVEL="7"
SKIP_DONE_STAGES="yes"

ENABLE_STAGE_INVENTORY="yes"
ENABLE_STAGE_APPDATA="yes"
ENABLE_STAGE_DOMAINS="yes"
ENABLE_STAGE_BOOT_CONFIG="yes"
EOC

echo "Created: $JOBS_DIR/${JOB_ID}.env"
