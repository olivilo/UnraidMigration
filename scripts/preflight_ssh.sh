#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/scripts/lib.sh"

[[ $# -eq 1 ]] || { echo "Usage: $0 <job-id>"; exit 1; }
load_job "$1"

[[ -f "$SRC_SSH_KEY" ]] || { echo "Missing key: $SRC_SSH_KEY"; exit 1; }

echo "Key fingerprint:"
ssh-keygen -lf "$SRC_SSH_KEY.pub" || true

echo "Remote check:"
ssh "${SSH_OPTS[@]}" "${SRC_USER}@${SRC_HOST}" 'hostname; whoami; /usr/sbin/sshd -T | egrep "permitrootlogin|pubkeyauthentication|passwordauthentication"'

echo "Preflight OK"
