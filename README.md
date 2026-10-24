# FarelMC — Fabric 26.3 SMP, universal join

> Ground truth for the FarelMC server. CI builds `ghcr.io/farelra/farelmc`
> (`:latest` + short-sha, arm64+amd64) on every `main` push; prod runs from
> nodus-infra, which pulls the image and fronts it with Traefik.

- **Server:** `MC 26.3 + Fabric Loader 0.20.1 + Java 25`, 61 pinned jars
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
| `mods/manifest.json` | 61 pinned 26.3 jars; `scripts/download-mods.sh` reproduces them |
| `config/` | Tuned per-mod defaults (server may add version stamps — harmless) |
| `server.properties`, `eula.txt` | Committed tuning |
| `scripts/` | `download-mods.sh` `install.sh` `run.sh` `verify.sh` `backup.sh` `pregen.sh` |
| `docker-compose.yml` | Local dev run (prod lives in nodus-infra) |

## Dev

```bash
./scripts/download-mods.sh  # fetch 61 jars (also run by CI)
./scripts/verify.sh         # boot smoke test (bare metal, needs Java 25)
docker compose up --build   # dev server (plain-HTTP signaling; prod Traefik terminates TLS)
```

Prod (nodus-infra): `ghcr.io/farelra/farelmc:latest` + Traefik terminates ALL
TLS (BlueMap `map.mc.farel.is-a.dev`, NetherNet signaling `mc.farel.is-a.dev:19132`
→ plain HTTP to Geyser, trusted `10.89.0.0/24`), raw publishes for game UDP/TCP.
