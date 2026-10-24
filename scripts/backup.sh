#!/usr/bin/env bash
# Snapshot live state (world + configs). Usage: ./scripts/backup.sh [dest-dir]
# For prod (nodus-infra), run on the box against /home/podman/services/data/minecraft.
set -euo pipefail
cd "$(dirname "$0")/.."
SRC="${1:-data}"
DEST="${2:-$HOME/backups/farelmc}"
TS="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DEST"
tar -czf "$DEST/farelmc-$TS.tar.gz" -C "$(dirname "$SRC")" "$(basename "$SRC")"
echo "backup: $DEST/farelmc-$TS.tar.gz"
