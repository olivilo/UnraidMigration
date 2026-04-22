# UnraidMigration (Deutsch)

Wiederverwendbares Toolkit fuer sichere Unraid-Migrationen (Docker + VMs) mit Pause/Resume und kontrolliertem Cutover.

Zur englischen Hauptdoku: [../README.md](../README.md)

## Ziele

- Keine Loeschung auf dem Quellserver
- Bereits laufende Docker auf dem Zielserver nicht anfassen
- Unterbrechbar und fortsetzbar bei instabiler Leitung
- Erst Daten kopieren, dann kontrolliert umschalten

## Ablauf in Kurzform

1. Job anlegen:

```bash
./scripts/create_job.sh mein_job 100.100.100.10 2222 /mnt/user/MigrationShare/migration
```

2. SSH-Key auf Ziel erstellen und auf Quelle hinterlegen.
3. Preflight:

```bash
./scripts/preflight_ssh.sh mein_job
```

4. Starten:

```bash
./scripts/start_job.sh mein_job
```

5. Status/Logs:

```bash
./scripts/status_job.sh mein_job
./scripts/tail_job.sh mein_job appdata
```

6. Stop/Resume:

```bash
./scripts/stop_job.sh mein_job
./scripts/resume_job.sh mein_job
```

## Stages

- `inventory`
- `appdata`
- `domains`
- `boot_config`

## Wichtiger Punkt: Zusatz-Shares

Viele Apps nutzen Daten ausserhalb von `/mnt/user/appdata`.

Pruefen:

```bash
docker inspect $(docker ps -aq) --format '{{range .Mounts}}{{.Source}}{{"\n"}}{{end}}' | grep '^/mnt/user/' | sort -u
```

Diese Shares muessen zusaetzlich synchronisiert werden.

## SSH-Fallen

- `Permission denied (publickey)`: Key/Rechte/sshd-Config pruefen
- Docker belegt Port 22: Unraid-SSH auf eigenen Port (z. B. 2223) umstellen

## Post-Install/Cutover

Nach dem Kopieren erscheinen Dienste nicht automatisch.

- Docker-Templates auf Ziel importieren/neuanlegen
- Mounts auf kopierte Daten setzen
- VMs importieren und Disk-Pfade auf kopierte `domains` zeigen lassen
- Intern testen (LAN/Tailscale)
- Erst dann Cloudflare/externes Routing umstellen

## KI-Hilfsmittel

- OpenAI Codex (GPT-5 Familie) fuer Skript- und Prozessentwurf
- KI-gestuetzte Dokumentation in 3 Sprachen
- Menschliche Pruefung und Ausfuehrung aller produktiven Schritte

## Blogartikel

- [https://tronhood.kaosklub.in.rs/ger/unraid-migration](https://tronhood.kaosklub.in.rs/ger/unraid-migration)
