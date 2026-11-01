# DOOMATHON ISC track: rules

## Score

Your score is the number of **valid demos your code completes in 120 seconds** on one whole Frontenac CPU node, using `scripts/score.sh`. Organizers run it 3 times and take the **median**.

- **Hardware:** one exclusive node of type **[NODE TYPE]** with **[N] cores**. CPU only; no GPUs.
- **Demo:** announced at scoring time, one of `demo1`, `demo2` or `demo3`. Make sure your code is fast on all three.
- **Ties:** broken by the best of the three runs.

## Valid demos

`doom/platform.c` fingerprints the frame drawn at every game tic and compares it with `reference/`. When a demo finishes it prints:
```
DGVALID tics=7116 matched=7115
```
A demo counts only if **every tic was drawn** (`tics` equals the reference length) and **almost every frame matches** (at most 5 may differ). The small allowance exists because one frame in demo1 changes slightly from run to run in the original engine itself.

Demos still running when time is up don't count.

## What you may change

- Anything in `doom/` **except `platform.c`**: engine code, `launcher.c`, the `Makefile` and compiler flags
- `scripts/run.sh`: how many copies run, how they're started, pinned and arranged
- Anything new you add, such as helper scripts or notes

## What you may not do

1. **Edit `platform.c` or `reference/`.** Organizers replace both with the official copies.
2. **Change what's drawn.** Every frame must be the full 640×400 image the original draws. No lower resolution, no skipped frames.
3. **Cache or precompute.** No storing frames, game state or results from earlier runs, or from files, to reuse later. Each demo must be computed in full.
4. **Leave the node.** `run.sh` runs everything on the scoring node itself: no `srun`, `sbatch` or `ssh`.
5. **Hide processes from the scorer.** No `setsid`, `nohup`, `disown` or daemons; the scorer must be able to stop everything you start.
6. **Share accounts.** Never log in as someone else.

Organizers review the final code. Anything that breaks these rules scores zero.

## Submitting

1. By **November 16, [TIME]**, tag the commit you want scored and push the tag:
   ```
   git tag final
   git push origin final
   ```
2. Your `README.md` must say:
   - your best score, and which demo it was measured on
   - what you changed and why it helped
   - what limits you now (CPU, memory, cache, I/O, start-up)
   - which AI tools you used, if any, and how

## How organizers score

1. Clone your repo at the `final` tag.
2. Replace `doom/platform.c` and `reference/` with the official copies.
3. On an exclusive **[NODE TYPE]** node, build with your Makefile: `make -C doom`.
4. Run `scripts/score.sh <demo> 120 3`.

## Also

- AI tools are allowed; disclose them in your README.
- One track per person. Club execs may take part, but not in a track they organize or judge.
- Individuals from this track will be considered for the club's ISC team, with an optional interview after the showcase.
