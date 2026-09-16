#!/usr/bin/env bash
# frames — extract stills from a recording at given timestamps, for
# frame-by-frame review (the mechanical half of the frame-review
# loop; the judging half is prompts/frame-review.md).
#
# Usage: frames.sh <video> <outdir> <t1> <t2> [...]
#   timestamps in seconds; also accepts 'N@t' labels (shot1@41).
set -eu
VID=${1:?video required}
OUT=${2:?outdir required}
shift 2
mkdir -p "$OUT"
for spec in "$@"; do
  t=${spec#*@}; label=${spec%@*}
  [ "$label" = "$t" ] && label="f${t}"
  ffmpeg -y -v error -ss "$t" -i "$VID" -frames:v 1 "$OUT/${label}.png"
  echo "$OUT/${label}.png"
done
