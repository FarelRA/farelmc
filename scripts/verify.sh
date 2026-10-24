#!/usr/bin/env bash
# Boot-smoke test: start server, wait for "Done", stop cleanly.
set -uo pipefail
cd "$(dirname "$0")/.."
LOG="$(mktemp)"
java -jar fabric-server-launch.jar nogui >"$LOG" 2>&1 &
PID=$!
READY=0
for i in $(seq 1 100); do
  sleep 3
  grep -q 'Done (' "$LOG" && { READY=1; break; }
  kill -0 $PID 2>/dev/null || break
done
if [[ $READY -eq 1 ]]; then
  echo "READY: $(grep 'Done (' "$LOG" | tail -1)"
  kill $PID  # SIGTERM triggers Fabric graceful shutdown
else
  echo "FAILED — tail:"; tail -30 "$LOG"
  kill $PID 2>/dev/null
  exit 1
fi
for i in $(seq 1 40); do kill -0 $PID 2>/dev/null || break; sleep 3; done
kill -0 $PID 2>/dev/null && { echo "did not stop, killing"; kill -9 $PID; exit 1; }
echo "STOPPED cleanly"
grep -cE 'ERROR|Mixin.*conflict|Incompatible mods' "$LOG" || true
