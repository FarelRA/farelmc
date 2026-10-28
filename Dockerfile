# FarelMC runs Fabric 26.3 SMP with universal join for Java and Bedrock.
# Image bakes the 70 pinned mod jars; per-mod configs mount at runtime
# (nodus-infra) or live in ./config (bare-metal dev).
# The container runs as root. Under rootless podman that maps to the unprivileged
# host user, so bind-mounted config/data stay writable (VMP/FerriteCore/
# Geyser all write on first boot).
FROM eclipse-temurin:25-jre
RUN mkdir -p /server /data /pinned-mods
WORKDIR /server
COPY fabric-server-launch.jar /server/
COPY server-icon.png /server/
# Pinned mod jars baked in (reproducible via mods/manifest.json).
COPY mods/*.jar /pinned-mods/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 25565/tcp 24454/udp 8100/tcp 19132/tcp 19132/udp 19133/udp
ENV HEAP_GB=4
ENTRYPOINT ["/entrypoint.sh"]
