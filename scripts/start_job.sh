#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/scripts/lib.sh"

[[ $# -eq 1 ]] || { echo "Usage: $0 <job-id>"; exit 1; }
JOB="$1"
load_job "$JOB"

run_inventory() {
  ssh_src "docker ps -a --format '{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' > /tmp/mig_docker_psa.tsv"
  ssh_src "docker volume ls > /tmp/mig_docker_volumes.txt"
  ssh_src "docker network ls > /tmp/mig_docker_networks.txt"
  ssh_src "virsh list --all > /tmp/mig_vm_list.txt || true"
  rsync -a -e "ssh ${SSH_OPTS[*]}" "${SRC_USER}@${SRC_HOST}:/tmp/mig_"* "$JOB_INV_DIR/" || true
  mark_done "$JOB" "inventory"
}
run_appdata() { rsync_pull "$SRC_PATH_APPDATA" "$JOB_DATA_DIR/appdata/"; mark_done "$JOB" "appdata"; }
run_domains() { rsync_pull "$SRC_PATH_DOMAINS" "$JOB_DATA_DIR/domains/"; mark_done "$JOB" "domains"; }
run_boot_config() { rsync_pull "$SRC_PATH_BOOT_CONFIG" "$JOB_DATA_DIR/boot-config/"; mark_done "$JOB" "boot_config"; }

maybe_start() {
  local stage="$1" fn="$2" enabled="$3"
  [[ "$enabled" == "yes" ]] || return 0
  if [[ "$SKIP_DONE_STAGES" == "yes" ]] && stage_is_done "$JOB" "$stage"; then
    echo "Skipping $stage (already done)"
    return 0
  fi
  start_stage "$JOB" "$stage" "$fn"
}

maybe_start inventory run_inventory "${ENABLE_STAGE_INVENTORY:-yes}"
maybe_start appdata run_appdata "${ENABLE_STAGE_APPDATA:-yes}"
maybe_start domains run_domains "${ENABLE_STAGE_DOMAINS:-yes}"
maybe_start boot_config run_boot_config "${ENABLE_STAGE_BOOT_CONFIG:-yes}"

echo "Started job: $JOB"
