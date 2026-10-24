# FarelMC — Fabric 26.3 SMP, universal join

> Ground truth for the FarelMC server. CI builds `ghcr.io/farelra/farelmc`
> (`:latest` + short-sha, arm64+amd64) on every `main` push; prod runs from
> nodus-infra, which pulls the image and fronts it with Traefik.

- **Server:** `MC 26.3 + Fabric Loader 0.20.1 + Java 25`, 62 pinned jars
  (`mods/manifest.json` — Via stack = any Java joins; Geyser + Floodgate =
  current Bedrock joins, no Java account).
- **Ports:** Java `:25565/tcp`, Bedrock `:19132/udp+tcp` + `:19133/udp`,
  voice `:24454/udp`, map `:8100`.
- **Image bakes the jars** (`COPY mods/*.jar /pinned-mods/`); entrypoint seeds
  `/server/mods` with `cp -n` so rebuilds land fresh jars.

## Layout

| Path | Purpose |
|---|---|
| `Dockerfile`, `entrypoint.sh` | Temurin 25 image; seeds jars, links persistent data |
| `mods/manifest.json` | 62 pinned 26.3 jars; `scripts/download-mods.sh` reproduces them |
| `config/` | Tuned per-mod defaults (server may add version stamps — harmless) |
| `server.properties`, `eula.txt` | Committed tuning |
| `scripts/` | `download-mods.sh` `install.sh` `run.sh` `verify.sh` `backup.sh` `pregen.sh` |
| `docker-compose.yml` | Local dev run (prod lives in nodus-infra) |

## Dev

```bash
./scripts/download-mods.sh  # fetch 62 jars (also run by CI)
./scripts/verify.sh         # boot smoke test (bare metal, needs Java 25)
docker compose up --build   # dev server (HTTPS signaling = trust prompt; prod gets real ACME cert)
```

Prod (nodus-infra): `ghcr.io/farelra/farelmc:latest` + Traefik routes
(`map.mc.farel.is-a.dev` → BlueMap, `mc.farel.is-a.dev` ACME via
`minecraft-cert-exporter` → Geyser `certs/`), raw publishes for game UDP/TCP.
