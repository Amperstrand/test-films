#!/usr/bin/env bash
# record-film — run a browser-recording test lane on a beefier remote
# box and pull the artifacts back. Generic movie-record runner:
# rsync the source tree, prepare deps once, run the given test
# command headless, pull whatever the run produced (video dirs,
# stills, timeline JSON).
#
# Usage:
#   record-film.sh <host> <remote-dir> <artifacts-glob> [-- <command>]
#   <command> runs from <remote-dir> (default: the project's default
#   film lane — pass yours explicitly the first time).
#
# Environment (all required unless noted):
#   RECORD_PREP    dependency-prep shell snippet run once on the host
#                  (default: none)
#   RECORD_ENV     extra env vars for the command (default: none)
#   OUT_DIR        local artifacts destination (default: ./film-out)
#
# Example:
#   RECORD_PREP='cd app && npm ci && npx playwright install chromium' \
#   RECORD_ENV='FILM_MODE=1' \
#   record-film.sh builder-box /tmp/film 'app/e2e/.results-video/*' \
#     -- 'cd app && npx playwright test film --config video'
set -eu
HOST=${1:?host required}
RDIR=${2:?remote-dir required}
GLOB=${3:?artifacts-glob required}
shift 3
[ "${1:-}" = "--" ] && shift
CMD=${*:?-- '<command>' required}

echo "==> rsync source to ${HOST}:${RDIR}"
ssh "$HOST" "rm -rf $RDIR && mkdir -p $RDIR"
rsync -az --exclude node_modules --exclude target --exclude .git --exclude dist \
  ./ "$HOST:$RDIR/"

if [ -n "${RECORD_PREP:-}" ]; then
  echo "==> prep on ${HOST} (first run takes a while)"
  ssh "$HOST" "cd $RDIR && (${RECORD_PREP}) >/dev/null 2>&1; echo ready"
fi

echo "==> roll camera on ${HOST} (headless)"
status=0
ssh "$HOST" "cd $RDIR && env ${RECORD_ENV:-} $CMD" || status=$?

echo "==> pull artifacts"
mkdir -p "${OUT_DIR:-./film-out}"
rsync -az ${GLOB} "${OUT_DIR:-./film-out}/" || true
echo "==> verdict: $status (gate on THIS line, not the artifact list)"
exit "$status"
