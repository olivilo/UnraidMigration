#!/usr/bin/env bash
set -euo pipefail
BASE="/mnt/user/MigrationShare/migration/UnraidMigration"
JOB_ID="generic_source_to_target"
"$BASE/scripts/start_job.sh" "$JOB_ID"
