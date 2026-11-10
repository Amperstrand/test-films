#!/usr/bin/env bash
# narrate-film — add a synthesized voice-over to a recorded film.
#
# Takes a silent video and a narration timeline (JSON: entries with
# start/end milliseconds and a "say" line each — emitted by the film
# runner's chrome, see templates/film-chrome.ts), synthesizes each
# line with the local OS voice, rate-fits it into its window, and
# mixes everything over a silent bed.
#
# Usage:
#   narrate-film.sh <video-in> <timeline.json> <mp4-out> [voice]
# Environment:
#   T0_OFFSET_MS  recording-start anchor correction (default 1500)
#   RATE_CLAMP    max time-stretch factor (default 1.45)
set -eu
VID=${1:?video-in required}
TL=${2:?timeline.json required}
OUT=${3:?mp4-out required}
VOICE=${4:-Samantha}
T0_OFFSET_MS=${T0_OFFSET_MS:-1500}
RATE_CLAMP=${RATE_CLAMP:-1.45}
WORK=$(mktemp -d /tmp/narrate-film.XXXXXX)
trap 'rm -rf "$WORK"' EXIT

[ -f "$VID" ] || { echo "no video at $VID" >&2; exit 1; }
[ -f "$TL" ] || { echo "no timeline at $TL" >&2; exit 1; }
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VID")
echo "==> film: ${DUR}s · voice: $VOICE"

python3 - "$TL" "$T0_OFFSET_MS" > "$WORK/plan.txt" <<'PY'
import json, sys
tl = json.load(open(sys.argv[1]))
t0 = float(sys.argv[2])
for e in tl["entries"]:
    if not e.get("say"):
        continue
    start = max(0, e["start"] - t0) / 1000.0
    end = min(e.get("end", e["start"] + 4000), 10**9) / 1000.0
    window = max(1.0, end - start - 0.3)
    print(f"{start:.3f}\t{window:.3f}\t{e['say']}")
PY

n=0
while IFS=$'\t' read -r start window text; do
  n=$((n+1))
  say -o "$WORK/line$n.aiff" -v "$VOICE" "$text" 2>/dev/null \
    || { echo "OS speech synth unavailable (macOS say?)" >&2; exit 1; }
  rawdur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$WORK/line$n.aiff")
  tempo=$(python3 -c "print(1.0 if $rawdur <= $window else round(min($RATE_CLAMP, $rawdur / $window), 3))")
  ffmpeg -y -v error -i "$WORK/line$n.aiff" \
    -filter:a "atempo=$tempo,apad" -t "$window" -ar 44100 -ac 2 "$WORK/line$n.wav"
  echo "$start" >> "$WORK/delays.txt"
done < "$WORK/plan.txt"
[ "$n" -gt 0 ] || { echo "no narrated entries in timeline" >&2; exit 1; }
echo "==> $n narrated lines"

python3 - "$VID" "$OUT" "$DUR" "$WORK" <<'PY'
import subprocess, sys
vid, out, dur, work = sys.argv[1], sys.argv[2], float(sys.argv[3]), sys.argv[4]
delays = [float(l) for l in open(f"{work}/delays.txt")]
n = len(delays)
cmd = ["ffmpeg", "-y", "-v", "error"]
for i in range(n):
    cmd += ["-i", f"{work}/line{i+1}.wav"]
cmd += ["-f", "lavfi", "-t", str(dur), "-i", "anullsrc=r=44100:cl=stereo", "-i", vid]
bed, video = n, n + 1
parts = [f"[{bed}:a]atrim=0:{dur}[bed]"]
for i, d in enumerate(delays):
    parts.append(f"[{i}:a]adelay={int(d*1000)}:all=1[d{i}]")
mix_in = "".join(f"[d{i}]" for i in range(n))
# duration=longest is load-bearing: duration=first ends the track at
# the first short segment (a film that goes silent after line one).
parts.append(f"{mix_in}[bed]amix=inputs={n+1}:duration=longest:normalize=0,volume=1.6[aout]")
cmd += ["-filter_complex", ";".join(parts),
        "-map", f"{video}:v", "-map", "[aout]",
        # Browser-recorded VP8/VP9 cannot stream-copy into MP4.
        "-c:v", "libx264", "-preset", "medium", "-crf", "19",
        "-pix_fmt", "yuv420p", "-movflags", "+faststart",
        "-c:a", "aac", "-b:a", "160k", out]
subprocess.run(cmd, check=True)
PY
echo "==> narrated film: $OUT ($(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT")s)"
