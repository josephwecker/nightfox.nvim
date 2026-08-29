#!/bin/sh
# snapshot.sh FILE [SCHEME] [OUT.png] [light|dark] [HEIGHT]
# Full-color render of FILE under SCHEME (default nightfox) -> PNG.
# Pipeline: nvim --headless + builtin tohtml (byte-exact applied highlights,
# treesitter + injections included) -> headless Chrome screenshot.
# Window height auto-sizes to the document (headless Chrome is happy to be
# very, very tall; capped at 16000px for GPU texture safety). HTML kept
# beside the PNG for inspection/diffing.
set -e
FILE=$1; SCHEME=${2:-nightfox}; OUT=${3:-/tmp/snapshot-$SCHEME.png}; BG=${4:-dark}
HTML=${OUT%.png}.html
DIR=$(cd "$(dirname "$0")/.." && pwd)
SNAP_FILE=$(cd "$(dirname "$FILE")" && pwd)/$(basename "$FILE") \
SNAP_OUT=$HTML SNAP_SCHEME=$SCHEME SNAP_BG=$BG SNAP_RTP=$DIR \
  nvim --headless --clean -l "$DIR/tools/snapshot.lua"
LINES=$(wc -l < "$FILE")
H=${5:-$(( (LINES + 8) * 19 ))}
[ "$H" -lt 400 ] && H=400
[ "$H" -gt 16000 ] && H=16000
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --screenshot="$OUT" --window-size=1100,$H \
  --hide-scrollbars "file://$(cd "$(dirname "$HTML")" && pwd)/$(basename "$HTML")" 2>/dev/null
echo "$OUT"
