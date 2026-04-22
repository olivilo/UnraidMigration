# UnraidMigration Roadmap

## Vision

UnraidMigration will evolve from script toolkit into a full Unraid App Hub (Community Applications) app:

- beautiful live transfer dashboard
- workflow buttons for common migration pipelines
- job templates for one-to-one and many-to-one migrations
- full SSH and port settings in-app
- safe cutover assistant with rollback guidance

Target outcome: best-in-class migration tool for Unraid servers.

## Planned product stages

## Stage 1 (current)
- CLI scripts + resumable transfer
- multi-job support
- DE/EN/SR documentation

## Stage 2 (next)
- Unraid plugin UI page
- in-app job editor (source host, target path, SSH port/key path)
- workflow actions: start, stop, resume, status, logs
- live progress panel (throughput, transferred bytes, ETA)

## Stage 3 (App Hub-ready)
- packaging as installable Unraid plugin
- release artifacts and update channel
- support thread + CA policy compliance
- onboarding wizard for SSH keys and connectivity tests

## Stage 4 (advanced)
- visual workflow builder
- staged cutover checklist with confirmations
- optional Cloudflare/Tailscale post-check hooks
- profile export/import for teams

## Functional requirements for app version

- Configure per job:
  - source host/IP
  - SSH user/key/port
  - destination base path
  - bandwidth and CPU/IO limits
  - stage toggles (`inventory`, `appdata`, `domains`, `boot_config`)
- Live monitoring:
  - transfer speed
  - cumulative transferred size
  - progress trend and ETA
  - heartbeat indicators for active rsync jobs
- Safety:
  - no source deletion
  - conflict warnings for existing target workloads
  - explicit final cutover flow and rollback hints

## Non-goals (for now)

- automatic destructive cleanup on source
- mandatory external service integration during data phase

## Community and contribution

Contributions are welcome for:
- plugin UI
- telemetry-free progress widgets
- translation improvements
- CA packaging and release engineering
