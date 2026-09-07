#!/usr/bin/env bash
# Record whatever is playing out the onboard (Starship/Matisse) jack into a bank.
# Captures the PipeWire monitor of the output — a digital tap, no analog loop.
#
# Usage: ./record.sh <bank> <name> [seconds]   (default 8s)
# Leading/trailing silence below -45dB is trimmed; manifest is regenerated.
set -euo pipefail

BANK=${1:?usage: ./record.sh <bank> <name> [seconds]}
NAME=${2:?usage: ./record.sh <bank> <name> [seconds]}
SECS=${3:-8}
TARGET=alsa_output.pci-0000_2d_00.4.analog-stereo.monitor
DIR="$(cd "$(dirname "$0")" && pwd)"

RAW=$(mktemp --suffix=.wav)
trap 'rm -f "$RAW"' EXIT

echo "Recording ${SECS}s from output monitor — play now..."
timeout "$SECS" pw-record --target "$TARGET" --rate 48000 --channels 2 "$RAW" || true

mkdir -p "$DIR/$BANK"
OUT="$DIR/$BANK/$NAME.wav"
ffmpeg -hide_banner -loglevel error -y -i "$RAW" -af \
  "silenceremove=start_periods=1:start_threshold=-45dB,areverse,silenceremove=start_periods=1:start_threshold=-45dB,areverse" \
  "$OUT"

DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT" 2>/dev/null || echo 0)
[[ -z "$DUR" || "$DUR" == "N/A" ]] && DUR=0
if awk -v d="$DUR" 'BEGIN{exit !(d < 0.05)}'; then
  rm -f "$OUT"
  echo "Nothing captured above -45dB — was audio playing? (no file written)"
  exit 1
fi

echo "Saved $OUT (${DUR}s after trim)"
python3 "$DIR/update-manifest.py"
