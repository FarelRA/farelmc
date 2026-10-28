#!/usr/bin/env sh
# FarelMC entrypoint seeds pinned jars, links persistent data, then runs the server.
# Runs as container root (unprivileged host user under rootless podman).
set -eu

mkdir -p /server/mods /data

# Seed the 70 pinned jars (first boot copies; later boots: -n keeps existing).
# Fresh mod versions land via a rebuilt image (CI) + recreated container.
if [ -d /pinned-mods ]; then
  cp -n /pinned-mods/*.jar /server/mods/ 2>/dev/null || true
fi

# Runtime state shipped alongside the image (nodus data/ layout):
#   /server/nethernet-data -> Geyser NetherNet identity.pem (persistent volume)
#   /server/EasyAuth -> EasyAuth login SQLite database (persistent volume)
# Each jar expects its state under its own config dir, so link it once per boot.
for spec in "nethernet-data:config/Geyser-Fabric/nethernet" "minecraft-easyauth:EasyAuth"; do
  sdir="/server/${spec%%:*}"; dlink="/server/${spec##*:}"
  if [ -e "$sdir" ]; then
    if [ ! -L "$dlink" ] || [ "$(readlink "$dlink")" != "$sdir" ]; then rm -rf "$dlink"; ln -sfn "$sdir" "$dlink"; fi
  fi
done

# World + player files live in /data (persistent volume, survives rebuilds).
for d in world world_nether world_the_end; do
  if [ -L "/server/$d" ] && [ ! -e "/server/$d" ]; then rm "/server/$d"; fi
  if [ ! -e "/server/$d" ]; then mkdir -p "/data/$d" && ln -sfn "/data/$d" "/server/$d"; fi
done
for f in whitelist.json ops.json banned-ips.json banned-players.json usercache.json; do
  if [ -L "/server/$f" ] && [ ! -e "/server/$f" ]; then rm "/server/$f"; fi
  [ -e "/server/$f" ] || ln -sfn "/data/$f" "/server/$f"
done

# Secrets NEVER live in the repo. RCON password (and the management secret,
# kept disabled upstream) come from the container env and land in the LIVE
# server.properties at boot. Both live only in nodus-infra
# data/minecraft/.env (mode 600). Uses tmp swap because server.properties is
# a bind-mounted file and sed in place cannot rename across that mount.
if [ -n "${RCON_PASSWORD:-}" ]; then
  sed "s/^rcon\.password=.*/rcon.password=${RCON_PASSWORD}/" /server/server.properties > /tmp/server.properties \
    && cat /tmp/server.properties > /server/server.properties \
    && rm -f /tmp/server.properties
else
  echo "WARN: RCON_PASSWORD is unset so RCON stays disabled in server.properties" >&2
  sed "s/^enable-rcon=true.*/enable-rcon=false/" /server/server.properties > /tmp/server.properties \
    && cat /tmp/server.properties > /server/server.properties \
    && rm -f /tmp/server.properties
fi
if [ -n "${MGMT_SECRET:-}" ]; then
  sed "s/^management-server-secret=.*/management-server-secret=${MGMT_SECRET}/" /server/server.properties > /tmp/server.properties \
    && cat /tmp/server.properties > /server/server.properties \
    && rm -f /tmp/server.properties
fi

HEAP="${HEAP_GB:-4}G"
exec java -Xms"$HEAP" -Xmx"$HEAP" \
  -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
  -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
  -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M \
  -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 \
  -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 \
  -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem \
  -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true \
  -jar /server/fabric-server-launch.jar nogui
