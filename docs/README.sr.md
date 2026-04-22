# UnraidMigration (Srpski)

Alat za bezbednu i ponovljivu migraciju Unraid servera (Docker + VM) sa pause/resume pristupom.

Glavna dokumentacija (EN): [../README.md](../README.md)

## Ciljevi

- Bez brisanja na source serveru
- Postojeci Docker kontejneri na target serveru ostaju netaknuti
- Migracija moze da se prekine i nastavi
- Prvo kopiranje podataka, pa tek onda kontrolisan cutover

## Brzi tok

1. Napravi job:

```bash
./scripts/create_job.sh moj_job 100.100.100.10 2222 /mnt/user/MigrationShare/migration
```

2. Generisi SSH kljuc na target-u i dodaj public key na source.
3. Preflight:

```bash
./scripts/preflight_ssh.sh moj_job
```

4. Start:

```bash
./scripts/start_job.sh moj_job
```

5. Status/logovi:

```bash
./scripts/status_job.sh moj_job
./scripts/tail_job.sh moj_job appdata
```

6. Stop/Resume:

```bash
./scripts/stop_job.sh moj_job
./scripts/resume_job.sh moj_job
```

## Stage-ovi

- `inventory`
- `appdata`
- `domains`
- `boot_config`

## Vazno: dodatni share-ovi

Mnoge aplikacije cuvaju podatke van `appdata`.

Provera:

```bash
docker inspect $(docker ps -aq) --format '{{range .Mounts}}{{.Source}}{{"\n"}}{{end}}' | grep '^/mnt/user/' | sort -u
```

Sve relevantne share-ove treba posebno sinhronizovati.

## SSH problemi

- `Permission denied (publickey)` -> proveri key, dozvole, sshd
- Ako Docker zauzme port 22 -> prebaci Unraid SSH na npr. 2223

## Posle kopiranja (post-install)

Servisi se ne pojavljuju automatski samo od kopiranih fajlova.

- Import/recreate Docker template-ova na target-u
- Podesi mount putanje na kopirane podatke
- Import VM-ova i putanja diskova na kopirane `domains`
- Interni test (LAN/Tailscale)
- Cloudflare/routing prebaciti tek na kraju

## AI alati korisceni u izradi

- OpenAI Codex (GPT-5 familija) za skripte i strukturu procesa
- AI pomoc pri pisanju dokumentacije na 3 jezika
- Zavrsnu validaciju i izvrsavanje radi ljudski operator

## Blog clanak

- [https://tronhood.kaosklub.in.rs/ger/unraid-migration](https://tronhood.kaosklub.in.rs/ger/unraid-migration)
