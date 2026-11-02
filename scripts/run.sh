#!/usr/bin/env bash
# TEAM-OWNED: how your team launches Doom. Change it however you like.
#
# scripts/score.sh starts this, waits for the time limit, then kills every
# process it started. Demos still running at that moment don't count.
#
# score.sh provides: DOOM_BIN DOOM_IWAD DOOM_DEMO DG_REFERENCE RESULTS_DIR
#
# Must-follow rules (see RULES.md):
#   - run everything on this node: no srun, sbatch or ssh
#   - keep every process in this process group: no setsid, nohup or disown
#   - send each copy's output to a *.log file in $RESULTS_DIR
#
# Baseline strategy: one copy per CPU, each restarting Doom for every demo.

COPIES=${COPIES:-$(nproc)}

for i in $(seq 0 $((COPIES - 1))); do
    workdir="$RESULTS_DIR/w$i"   # each copy needs its own folder for its config file
    mkdir -p "$workdir"
    (
        cd "$workdir"
        while true; do
            "$DOOM_BIN" -iwad "$DOOM_IWAD" -timedemo "$DOOM_DEMO" || true
        done
    ) > "$RESULTS_DIR/w$i.log" 2>&1 &
done
wait
