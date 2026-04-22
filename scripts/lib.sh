#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JOBS_DIR="$BASE_DIR/jobs"
STATE_DIR="$BASE_DIR/state"
LOG_DIR="$BASE_DIR/logs"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1" >&2; exit 1; }
}

load_job() {
  local job="$1"
  local file="$JOBS_DIR/${job}.env"
  [[ -f "$file" ]] || { echo "Job config not found: $file" >&2; exit 1; }
  # shellcheck disable=SC1090
  source "$file"

  : "${JOB_NAME:?missing JOB_NAME}"
  : "${SRC_HOST:?missing SRC_HOST}"
  : "${SRC_USER:?missing SRC_USER}"
  : "${SRC_SSH_PORT:?missing SRC_SSH_PORT}"
  : "${SRC_SSH_KEY:?missing SRC_SSH_KEY}"
  : "${DEST_BASE:?missing DEST_BASE}"

  JOB_ID="$job"
  JOB_ROOT="$DEST_BASE/$JOB_NAME"
  JOB_DATA_DIR="$JOB_ROOT/data"
  JOB_INV_DIR="$JOB_ROOT/inventory"
  mkdir -p "$JOB_DATA_DIR" "$JOB_INV_DIR" "$STATE_DIR" "$LOG_DIR"

  RSYNC_BWLIMIT="${RSYNC_BWLIMIT:-20m}"
  NICE_LEVEL="${NICE_LEVEL:-15}"
  IONICE_CLASS="${IONICE_CLASS:-2}"
  IONICE_LEVEL="${IONICE_LEVEL:-7}"
  SKIP_DONE_STAGES="${SKIP_DONE_STAGES:-yes}"

  SSH_OPTS=(
    -i "$SRC_SSH_KEY"
    -p "$SRC_SSH_PORT"
    -o IdentitiesOnly=yes
    -o ServerAliveInterval=30
    -o ServerAliveCountMax=6
    -o StrictHostKeyChecking=accept-new
    -o UserKnownHostsFile=/tmp/unraidmigration_known_hosts
  )
}

job_pid_file() { echo "$STATE_DIR/$1.$2.pid"; }
job_done_file() { echo "$STATE_DIR/$1.$2.done"; }
job_log_file() { echo "$LOG_DIR/$1.$2.log"; }

is_pid_running() { kill -0 "$1" >/dev/null 2>&1; }
stage_is_done() { [[ -f "$(job_done_file "$1" "$2")" ]]; }

mark_done() {
  date -Iseconds >"$(job_done_file "$1" "$2")"
  rm -f "$(job_pid_file "$1" "$2")"
}

stage_status() {
  local pidf="$(job_pid_file "$1" "$2")"
  if [[ -f "$pidf" ]]; then
    local pid
    pid="$(cat "$pidf" 2>/dev/null || true)"
    if [[ -n "${pid:-}" ]] && is_pid_running "$pid"; then
      echo "running (pid $pid)"
      return
    fi
  fi
  if stage_is_done "$1" "$2"; then
    echo "done"
  else
    echo "idle"
  fi
}

start_stage() {
  local job="$1" stage="$2"
  shift 2
  local pidf="$(job_pid_file "$job" "$stage")"
  local logf="$(job_log_file "$job" "$stage")"

  if [[ -f "$pidf" ]]; then
    local pid
    pid="$(cat "$pidf" 2>/dev/null || true)"
    if [[ -n "${pid:-}" ]] && is_pid_running "$pid"; then
      echo "Stage $stage already running (pid $pid)"
      return 0
    fi
  fi

  (
    echo "[$(date -Iseconds)] stage=$stage start"
    "$@"
    rc=$?
    echo "[$(date -Iseconds)] stage=$stage exit_code=$rc"
    exit "$rc"
  ) >>"$logf" 2>&1 &

  echo $! >"$pidf"
  echo "Started stage $stage (pid $(cat "$pidf"))"
}

stop_stage() {
  local job="$1" stage="$2"
  local pidf="$(job_pid_file "$job" "$stage")"
  [[ -f "$pidf" ]] || { echo "Stage $stage not running"; return 0; }
  local pid
  pid="$(cat "$pidf" 2>/dev/null || true)"
  if [[ -n "${pid:-}" ]] && is_pid_running "$pid"; then
    kill "$pid" >/dev/null 2>&1 || true
    sleep 1
    is_pid_running "$pid" && kill -9 "$pid" >/dev/null 2>&1 || true
    echo "Stopped stage $stage (pid $pid)"
  fi
  rm -f "$pidf"
}

ssh_src() { ssh "${SSH_OPTS[@]}" "${SRC_USER}@${SRC_HOST}" "$@"; }

rsync_pull() {
  local src="$1" dst="$2"
  mkdir -p "$dst"
  nice -n "$NICE_LEVEL" ionice -c "$IONICE_CLASS" -n "$IONICE_LEVEL" \
    rsync -aHAX --numeric-ids --partial --append-verify --inplace \
      --human-readable --info=progress2,stats2 --timeout=120 --bwlimit="$RSYNC_BWLIMIT" \
      -e "ssh ${SSH_OPTS[*]}" \
      "${SRC_USER}@${SRC_HOST}:${src}" "$dst"
}
