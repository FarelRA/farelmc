#!/usr/bin/env bash
# Re-download all pinned mods from mods/manifest.json (no jars in git).
set -euo pipefail
cd "$(dirname "$0")/../mods"
python3 - <<'PY'
import json, urllib.request, os
man = json.load(open('manifest.json'))
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
