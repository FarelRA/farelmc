#!/usr/bin/env bash
# Pre-generate chunks via Chunky (run once, server stopped or running idle).
# Usage: ./scripts/pregen.sh [radius-blocks]  (default 2000)
set -euo pipefail
R="${1:-2000}"
echo "Pregenerating radius $R blocks. Run in server console:"
echo "  chunky radius $R"
echo "  chunky center 0 0"
echo "  chunky start"
