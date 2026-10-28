#!/usr/bin/env bash
# Start the Fabric server (ZGC flags). Single locked stack: mods/ is the modpack.
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
  -XX:+UnlockExperimentalVMOptions -XX:+UseZGC -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+PerfDisableSharedMem -XX:+UseDynamicNumberOfGCThreads \
  -jar fabric-server-launch.jar nogui
