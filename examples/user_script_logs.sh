#!/usr/bin/env bash
set -euo pipefail
BASE="/mnt/user/MigrationShare/migration/UnraidMigration"
ls -1 "$BASE/logs"/*.log 2>/dev/null | while read -r f; do
  echo "===== $f ====="
  tail -n 40 "$f"
done
