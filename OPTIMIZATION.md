# Where to start optimizing

The method from the lecture: **measure, change one thing, measure again**. Keep a log of every change and its score, because your README needs it.

## 1. Get a baseline

```
scripts/score.sh demo1 30 1
```
Run it two or three times. Shared nodes are noisy, so only trust changes bigger than the spread between runs.

## 2. Compiler flags (the cheapest win)

The `Makefile` starts with `-Os`, which optimizes for **size**, not speed. Try:

- `-O2` and `-O3`: measure both; `-O3` isn't always faster
- `-march=native`: use every instruction the CPU has. **Build inside a job** on the scoring node type; a binary built on the login node can crash with `Illegal instruction` on a different CPU.
- `-flto`: link-time optimization, which optimizes across all source files at once
- PGO (profile-guided optimization): build with `-fprofile-generate`, play a demo, rebuild with `-fprofile-use`

After every change, check that demos are still `valid`.

## 3. Profile: find where the time goes

```
# Rebuild with -pg added to CFLAGS (make -C doom clean first), then in a job:
mkdir -p results/prof && cd results/prof
../../doom/doomgeneric -iwad ../../freedoom1.wad -timedemo demo1
gprof ../../doom/doomgeneric gmon.out | head -30
```
The functions at the top of the list are where speed-ups pay off. Valgrind's `callgrind` tool gives line-by-line detail but runs far slower. Check what's available with `module spider valgrind`.

## 4. Use the whole node well

- **How many copies?** One per CPU is the baseline. Is that best? Try fewer and more.
- **Hyperthreads:** `lscpu` shows "Thread(s) per core". Two copies on one physical core compete for it.
- **Pinning:** `taskset -c <cpu> <command>` keeps a copy on one CPU, so its cache stays warm.
- **Memory and cache:** many copies share memory bandwidth and the last-level cache. Watch how the score scales as you add copies.
- **Output:** every copy writes a log. Writing less, or less often, can matter at scale.

## 5. Start-up cost

Every demo in the baseline starts a fresh Doom process, which loads the game data again each time. With demos lasting a few seconds, that start-up is a real fraction of your 120 seconds. Running several demos inside one process is a big structural change. `launcher.c`, `g_game.c` (`G_CheckDemoStatus`) and `d_main.c` are the places to look. The validator treats the game-tic counter (`gametic`) going backwards as the start of a new demo, and expects each demo's tics to be numbered exactly as in a fresh process (the reference starts at tic 2).

## Reading

- GCC optimize options: https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
- gprof manual: https://sourceware.org/binutils/docs/gprof/
- Valgrind manual: https://valgrind.org/docs/manual/
- Search terms worth your time: *cache locality*, *false sharing*, *SMT/hyperthreading*, *CPU affinity*, *profile-guided optimization*
