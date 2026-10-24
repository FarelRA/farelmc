#!/usr/bin/env bash
# Install/patch Fabric server launcher for MC 26.3 (downloads Mojang server jar + Fabric loader).
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source scripts/fabric.env; set +a
LAUNCH_JAR="fabric-server-launch.jar"
if [[ -f "$LAUNCH_JAR" ]]; then
  echo "exists: $LAUNCH_JAR"
  exit 0
fi
URL="https://meta.fabricmc.net/v2/versions/loader/${MC_VERSION}/${LOADER_VERSION}/${INSTALLER_VERSION}/server/jar"
echo "downloading: $URL"
curl -fL --retry 3 -o "$LAUNCH_JAR" "$URL"
echo "installed: $LAUNCH_JAR"
