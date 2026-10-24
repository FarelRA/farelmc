# FarelMC — Fabric 26.3 SMP, universal join (Java + Bedrock).
# Image bakes the 61 pinned mod jars; per-mod configs mount at runtime
# (nodus-infra) or live in ./config (bare-metal dev).
# Runs as container root — under rootless podman this maps to the unprivileged
# host user, so bind-mounted config/data stay writable (VMP/FerriteCore/
# Geyser all write on first boot).
FROM eclipse-temurin:25-jre
RUN mkdir -p /server /data /pinned-mods
WORKDIR /server
COPY fabric-server-launch.jar /server/
# Pinned mod jars baked in (reproducible via mods/manifest.json).
COPY mods/*.jar /pinned-mods/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 25565/tcp 24454/udp 8100/tcp 19132/tcp 19132/udp 19133/udp
ENV HEAP_GB=4
ENTRYPOINT ["/entrypoint.sh"]
