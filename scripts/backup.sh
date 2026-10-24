#!/usr/bin/env bash
# Snapshot world data. Usage: ./scripts/backup.sh [dest-dir]
set -euo pipefail
cd "$(dirname "$0")/.."
DEST="${1:-$HOME/backups/minecraft-server}"
TS="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DEST"
tar -czf "$DEST/world-$TS.tar.gz" data/world server.properties config whitelist.json ops.json 2>/dev/null || \
tar -czf "$DEST/world-$TS.tar.gz" data/world server.properties config
echo "backup: $DEST/world-$TS.tar.gz"
