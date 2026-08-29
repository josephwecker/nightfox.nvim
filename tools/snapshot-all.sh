#!/bin/sh
# snapshot-all.sh SCHEME [light|dark] [OUTDIR-NAME]
# Renders every exemplar under SCHEME into exemplars/shots/<OUTDIR-NAME>/
set -e
SCHEME=${1:-nightfox}; BG=${2:-dark}; NAME=${3:-$SCHEME}
DIR=$(cd "$(dirname "$0")/.." && pwd)
OUT="$DIR/exemplars/shots/$NAME"
mkdir -p "$OUT"
for f in "$DIR"/exemplars/[0-9]*; do
  base=$(basename "$f"); base=${base%.*}
  "$DIR/tools/snapshot.sh" "$f" "$SCHEME" "$OUT/$base.png" "$BG" >/dev/null
  echo "$base"
done
echo "-> $OUT"
