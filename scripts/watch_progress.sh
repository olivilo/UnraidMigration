#!/usr/bin/env bash
set -euo pipefail
JOB="${1:-example_job}"
INTERVAL="${2:-20}"
BASE="/mnt/user/MigrationShare/migration/${JOB}/data"
APP="$BASE/appdata"
DOM="$BASE/domains"
prev=0
prev_t=0

bytes() { du -sb "$1" 2>/dev/null | awk '{print $1+0}'; }

while true; do
  t=$(date +%s)
  a=$(bytes "$APP" || echo 0)
  d=$(bytes "$DOM" || echo 0)
  tot=$((a+d))
  if [[ "$prev_t" -eq 0 ]]; then
    rate="0.00"
  else
    dt=$((t-prev_t)); ((dt<=0)) && dt=1
    delta=$((tot-prev))
    rate=$(awk -v x="$delta" -v dt="$dt" 'BEGIN{printf "%.2f", (x/1024/1024)/dt}')
  fi
  clear
  echo "Job: $JOB"
  date
  echo "appdata bytes: $a"
  echo "domains bytes: $d"
  echo "total bytes: $tot"
  echo "speed: $rate MiB/s"
  prev="$tot"; prev_t="$t"
  sleep "$INTERVAL"
done
