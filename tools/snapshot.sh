#!/bin/sh
# snapshot.sh FILE [SCHEME] [OUT.png] [light|dark]
# Full-color render of FILE under SCHEME (default nightfox) -> PNG.
# Pipeline: nvim --headless + builtin tohtml (byte-exact applied highlights,
# treesitter + injections included) -> headless Chrome screenshot.
# HTML is kept beside the PNG (same name, .html) for inspection/diffing.
set -e
FILE=$1; SCHEME=${2:-nightfox}; OUT=${3:-/tmp/snapshot-$SCHEME.png}; BG=${4:-dark}
HTML=${OUT%.png}.html
DIR=$(cd "$(dirname "$0")/.." && pwd)
SNAP_FILE=$(cd "$(dirname "$FILE")" && pwd)/$(basename "$FILE") \
SNAP_OUT=$HTML SNAP_SCHEME=$SCHEME SNAP_BG=$BG SNAP_RTP=$DIR \
  nvim --headless --clean -l "$DIR/tools/snapshot.lua"
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --screenshot="$OUT" --window-size=1100,1400 \
  --hide-scrollbars "file://$HTML" 2>/dev/null
echo "$OUT"
