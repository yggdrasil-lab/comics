# Comics Stack

Self-hosted manga & comics stack on the Muspelheim worker node. Split out of Apollo Core to keep the media stack focused.

| Service   | Purpose                     | Image                                    | Auth                     |
|-----------|-----------------------------|------------------------------------------|--------------------------|
| Komga     | Comics/manga reader + OPDS  | `gotson/komga`                           | Authentik OIDC (native)  |
| Suwayomi  | Manga downloader (Mihon)    | `ghcr.io/suwayomi/suwayomi-server`       | HTTP Basic (admin-only)  |

## How the pieces fit

Suwayomi downloads manga chapters as CBZ files directly into the shared
`/mnt/storage/comics/library` directory. Komga reads that same directory as a
library, so downloaded chapters appear automatically after a scan.

```
Suwayomi --downloads (CBZ)--> /mnt/storage/comics/library <--library-- Komga
```

The `DOWNLOAD_AS_CBZ=true` env is mandatory — Suwayomi defaults to loose image
folders, which Komga cannot index.

## Deploy

Pushes to `main` deploy automatically via GitHub Actions on the Gaia runner
(`.github/workflows/deploy.yml`). Manual:

```bash
./setup_host_muspelheim.sh          # once, on the Muspelheim host
./scripts/deploy.sh "comics" docker-compose.yml
```

## Secrets / Variables (GitHub Actions)

| Name                    | Type     | Purpose                        |
|-------------------------|----------|--------------------------------|
| `DOMAIN_NAME`           | var      | Fleet domain (shared)          |
| `SUWAYOMI_AUTH_USERNAME`| var      | Suwayomi basic-auth username   |
| `SUWAYOMI_AUTH_PASSWORD`| secret   | Suwayomi basic-auth password   |

Komga needs no auth secrets here — it uses native OIDC via Authentik.

## Auth

- **Komga** — native OIDC against Authentik (`id.${DOMAIN_NAME}`). Configure the
  Authentik Application + OAuth2/OpenID Connect provider, then set Komga's
  `komga.oauth2-account-creation=true` (and the provider issuer/client details)
  in `/opt/comics/komga/application.yml`. Browser login is SSO; OPDS/Mihon still
  uses per-user Komga credentials (Basic Auth).
- **Suwayomi** — no OIDC support yet (upstream request #926). Runs admin-only
  behind HTTP Basic Auth (`AUTH_MODE=basic_auth`). Treat as an internal
  downloader, not a public reader.

## Migration from Apollo Core

Komga's existing data lives at `/opt/apollo-core/komga`. Before first deploy,
move it to the comics stack's config path and fix ownership:

```bash
sudo rsync -a /opt/apollo-core/komga/ /opt/comics/komga/
sudo chown -R 1000:1000 /opt/comics/komga
```

Komga's previous library mount pointed at `/mnt/storage/media`; the comics
stack keeps that mount (`/data`) so existing libraries resolve unchanged, and
adds `/mnt/storage/comics/library` as `/downloads` for the Suwayomi pipeline.

## Hostnames

| Service   | URL                          |
|-----------|------------------------------|
| Komga     | `https://komga.${DOMAIN_NAME}` |
| Suwayomi  | `https://manga.${DOMAIN_NAME}` |

## Notes

- Vault doc: `Areas/90-Infrastructure/Apollo/Apollo Stack.md`
- Effort: `Efforts/Manga Acquisition Pipeline/_Manga Acquisition Pipeline.md`
