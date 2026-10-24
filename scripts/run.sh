#!/usr/bin/env bash
# Start the Fabric server (Aikar G1GC flags, spark-ready). Single locked stack: mods/ is the modpack.
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source scripts/fabric.env; set +a
if [[ ! -f fabric-server-launch.jar ]]; then
  echo "fabric-server-launch.jar is missing. Run scripts/install.sh first" >&2
  exit 1
fi
HEAP="${HEAP_GB:-4}G"
exec "$JAVA_BIN" \
  -Xms"$HEAP" -Xmx"$HEAP" \
  -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
  -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
  -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M \
  -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 \
  -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 \
  -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem \
  -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true \
  -jar fabric-server-launch.jar nogui
