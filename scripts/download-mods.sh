#!/usr/bin/env bash
# Re-download all pinned mods from mods/manifest.json (no jars in git).
# Usage: bash scripts/download-mods.sh [out-dir]
#   OUT env or $1 wins (install.sh points it at the installed tree);
#   default is the repo-adjacent mods/ dir (dev/verify/CI flow).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-${OUT:-$ROOT/mods}}"
MAN="$ROOT/mods/manifest.json"
mkdir -p "$OUT"
cd "$OUT"
python3 - "$MAN" <<'PY'
import json, urllib.request, os, sys
man = json.load(open(sys.argv[1]))
for m in man:
    fn = m['file']
    if os.path.exists(fn) and os.path.getsize(fn) == m['size']:
        print('have', fn); continue
    print('get ', fn)
    req = urllib.request.Request(m['url'], headers={'User-Agent': 'minecraft-server setup'})
    with urllib.request.urlopen(req, timeout=120) as r, open(fn, 'wb') as o:
        o.write(r.read())
    assert os.path.getsize(fn) == m['size'], f"size mismatch {fn}"
print('done:', len(man), 'mods')
PY
