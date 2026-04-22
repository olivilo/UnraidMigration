# UnraidMigration

A reusable, privacy-safe migration toolkit for moving Docker + VM workloads from one Unraid server to another with resumable transfer and controlled cutover.

- Language: English (this file)
- Deutsch: [docs/README.de.md](docs/README.de.md)
- Srpski: [docs/README.sr.md](docs/README.sr.md)

## Why this project

Traditional Unraid migrations are often stressful and fragile. This toolkit turns migration into a repeatable workflow with checkpoints.

Core goals:
- No deletion on source server
- Do not touch existing production containers on target server
- Pause/resume anytime (unstable links supported)
- Move data first, cut over later

## Privacy and anonymization

This repository intentionally removes all private names, hostnames, and paths from the real migration.

All examples use generic names like:
- `source-server`
- `target-server`
- `/mnt/user/MigrationShare/migration`

## Architecture

Recommended model: **target pulls from source**.

Benefits:
- Logs and state are centralized on target
- Source remains unchanged
- Rollback remains simple

Stages:
- `inventory` (read-only inventory)
- `appdata` (docker app data)
- `domains` (vm disks)
- `boot_config` (important Unraid config)

## Repository structure

- `scripts/` migration orchestration scripts
- `jobs/` job configuration templates
- `examples/` User Scripts examples for Unraid GUI buttons
- `deploy/` deploy helper for pushing this repo to target server
- `docs/` localized documentation (DE/SR)

## Requirements

On target server:
- `bash`, `ssh`, `rsync`, `ionice`, `nice`
- SSH key access to source server

On source server:
- SSH enabled
- root access for migration reads

## Quick start

## 1) Create a job

```bash
./scripts/create_job.sh my_source_to_target 100.100.100.10 2222 /mnt/user/MigrationShare/migration
```

Edit `jobs/my_source_to_target.env`.

## 2) Create SSH key on target

```bash
ssh-keygen -t ed25519 -N '' -f /root/.ssh/migrate_my_source_to_target -C 'migration my_source_to_target'
cat /root/.ssh/migrate_my_source_to_target.pub
```

Add the generated public key to source server:

```bash
mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo '<PASTE_PUBLIC_KEY_HERE>' >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
```

## 3) Preflight

```bash
./scripts/preflight_ssh.sh my_source_to_target
```

## 4) Start migration

```bash
./scripts/start_job.sh my_source_to_target
```

## 5) Check status

```bash
./scripts/status_job.sh my_source_to_target
./scripts/tail_job.sh my_source_to_target appdata
```

## 6) Pause/resume

```bash
./scripts/stop_job.sh my_source_to_target
./scripts/resume_job.sh my_source_to_target
```

## Multi-job support

Run separate jobs for different source servers or datasets:

```bash
./scripts/start_job.sh sourceA_to_target
./scripts/start_job.sh sourceB_to_target
```

Use separate SSH keys and separate destination folders per job.

## Performance controls

In each job file:
- `RSYNC_BWLIMIT="20m"`
- `NICE_LEVEL="15"`
- `IONICE_CLASS="2"`
- `IONICE_LEVEL="7"`

These settings keep migration as a background workload.

## Critical migration note: extra data shares

Many apps store data outside `appdata`.

Always discover bind mounts on source:

```bash
docker inspect $(docker ps -aq) --format '{{range .Mounts}}{{.Source}}{{"\n"}}{{end}}' | grep '^/mnt/user/' | sort -u
```

Add separate rsync tasks for such shares.

## SSH troubleshooting

## Problem: publickey denied

Check:

```bash
/usr/sbin/sshd -T | egrep 'permitrootlogin|pubkeyauthentication|authorizedkeysfile'
ls -ld /root/.ssh
ls -l /root/.ssh/authorized_keys
```

## Problem: SSH port conflict with Docker

A container may bind host port `22`, so SSH does not reach Unraid sshd.

Detect:

```bash
docker ps --format '{{.Names}}\t{{.Ports}}' | grep -E '0\.0\.0\.0:22->|:::22->'
```

Fix:
- set Unraid SSH to a dedicated port (e.g. `2222` or `2223`)
- update `SRC_SSH_PORT` in your job config

## Post-copy activation (important)

Copied files do not auto-create running services.

After data sync:
1. Recreate/import Docker templates on target
2. Point mounts to copied paths
3. Recreate/import VMs and point disks to copied `domains`
4. Run functional tests internally (LAN/Tailscale)
5. Only then switch Cloudflare / external routing

## Cutover and rollback strategy

- Run final delta sync with source services briefly stopped
- Start services on target
- Validate app logins, DB writes, file uploads
- Switch external routing last
- Keep source untouched until stable

## Deploy helper

From local workstation:

```bash
./deploy/install_on_target.sh 100.100.100.20 /mnt/user/MigrationShare/migration/UnraidMigration
```

## AI tools used to build this project

This repository and documentation were built with AI-assisted engineering workflow:
- OpenAI Codex (GPT-5 family) for script scaffolding, architecture, and troubleshooting flow
- AI-assisted documentation drafting (multilingual DE/EN/SR)
- Human operator validation and command execution on real systems

AI did not replace operator responsibility. It accelerated structure, repeatability, and incident-safe process design.

## Related blog article

Detailed background article:
- [https://tronhood.kaosklub.in.rs/ger/unraid-migration](https://tronhood.kaosklub.in.rs/ger/unraid-migration)

## Disclaimer

Use at your own risk. Always test in non-production first and keep verified backups.
