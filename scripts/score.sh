#!/usr/bin/env bash
# ISC track scorer: the same script organizers use for official scores.
#
# Counts the demos your scripts/run.sh completes, and that pass validation,
# within a time limit. Run it inside a job, never on the login node.
#
# Usage:   scripts/score.sh [demo] [seconds] [runs]
# Default: scripts/score.sh demo1 120 3     (score = median of 3 runs)
# Quick:   scripts/score.sh demo1 30 1

set -euo pipefail

DEMO=${1:-demo1}
LIMIT=${2:-120}
RUNS=${3:-3}
TOLERANCE=5   # frames allowed to differ from the reference (see RULES.md)

ROOT=$(cd "$(dirname "$0")/.." && pwd)
REF="$ROOT/reference/$DEMO.txt"
[ -f "$REF" ] || { echo "No reference for '$DEMO' (try demo1, demo2 or demo3)."; exit 1; }
[ -x "$ROOT/doom/doomgeneric" ] || { echo "Build first: make -C doom"; exit 1; }
[ -f "$ROOT/freedoom1.wad" ] || { echo "Get the game data first: ./get_freedoom.sh"; exit 1; }
if [ -z "${SLURM_JOB_ID:-}" ]; then
    echo "Not inside a Slurm job. Start one with salloc first (see README.md)."
    exit 1
fi

EXPECTED=$(wc -l < "$REF")
export DOOM_BIN="$ROOT/doom/doomgeneric" DOOM_IWAD="$ROOT/freedoom1.wad"
export DOOM_DEMO="$DEMO" DG_REFERENCE="$REF"

echo "Scoring $DEMO: $RUNS run(s) of ${LIMIT}s on $(hostname), $(nproc) CPUs"
scores=()
for r in $(seq 1 "$RUNS"); do
    export RESULTS_DIR="$ROOT/results/run$r"
    rm -rf "$RESULTS_DIR"
    mkdir -p "$RESULTS_DIR"

    setsid "$ROOT/scripts/run.sh" > "$RESULTS_DIR/run.out" 2>&1 &
    pid=$!
    trap 'kill -KILL -- "-$pid" 2>/dev/null || true' EXIT   # never leave copies running
    trap 'exit 130' INT TERM
    sleep "$LIMIT" & wait $!   # wait, not plain sleep, so Ctrl+C works at once
    kill -KILL -- "-$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
    while kill -0 -- "-$pid" 2>/dev/null; do sleep 0.2; done   # let every copy exit

    read -r valid invalid < <(cat "$RESULTS_DIR"/*.log 2>/dev/null | awk \
        -v want="$EXPECTED" -v tol="$TOLERANCE" '
        /^DGVALID/ {
            split($2, t, "="); split($3, m, "=")
            if (t[2] + 0 == want && m[2] ~ /^[0-9]+$/ && m[2] + 0 >= want - tol) v++
            else bad++
        }
        END { print v + 0, bad + 0 }')
    echo "  run $r: $valid valid demos, $invalid invalid"
    scores+=("$valid")
done

median=$(printf '%s\n' "${scores[@]}" | sort -n | awk '{ a[NR] = $1 } END { print a[int((NR + 1) / 2)] }')
echo "SCORE: $median valid $DEMO demos in ${LIMIT}s (median of $RUNS)"
