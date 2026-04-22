#!/usr/bin/env bash
set -euo pipefail

# Run from your local machine.
# Usage: ./deploy/install_on_target.sh <target-host> [target-dir]

TARGET_HOST="${1:-}"
TARGET_DIR="${2:-/mnt/user/MigrationShare/migration/UnraidMigration}"
[[ -n "$TARGET_HOST" ]] || { echo "Missing target host"; exit 1; }

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

rsync -av --delete \
  --exclude '.git/' \
  --exclude 'logs/' \
  --exclude 'state/' \
  "$ROOT_DIR/" "root@${TARGET_HOST}:${TARGET_DIR}/"

echo "Installed to ${TARGET_HOST}:${TARGET_DIR}"
