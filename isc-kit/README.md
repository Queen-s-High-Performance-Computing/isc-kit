# DOOMATHON: ISC track starter kit

**Goal:** finish as many valid Doom demos as possible in **2 minutes** on one Frontenac CPU node.

A *demo* is a recorded game that Doom plays back by itself. Your team decides how to run it: how many copies, how they're compiled, how they share the CPUs. Read [RULES.md](RULES.md) before you start, and [OPTIMIZATION.md](OPTIMIZATION.md) for ideas.

## What's in here

| Path | What it is | Can you change it? |
|---|---|---|
| `doom/` | The Doom engine ([doomgeneric](https://github.com/ozkl/doomgeneric)), its `Makefile` and `launcher.c` | Yes |
| `doom/platform.c` | Runs Doom headless and checks every demo | **No** (replaced at scoring) |
| `scripts/run.sh` | How your team launches Doom | Yes |
| `scripts/score.sh` | The official scorer | No |
| `reference/` | Correct frame fingerprints for demo1–demo3 | No |
| `get_freedoom.sh` | Downloads the game data | No |

## Quickstart

You need a Frontenac account with MFA, and you need to have accepted the GitHub org invite.

**1. Log in**
```
ssh <username>@login.cac.queensu.ca
```

**2. Get your team's code** (git only works on the login node; compute nodes have no internet)
```
git clone https://github.com/Queen-s-High-Performance-Computing/<your-team-repo>.git
cd <your-team-repo>
```
Your repo is private. When git asks for a password, paste a GitHub **personal access token** (GitHub → Settings → Developer settings → Personal access tokens), not your GitHub password.

**3. Get the game data and build**
```
./get_freedoom.sh
module load gcc
make -C doom -j8
```
You'll see compiler warnings. That's normal for 1990s code. The build worked if `doom/doomgeneric` exists.

**4. Start a job.** Never run Doom on the login node.
```
salloc --time=00:30:00 --cpus-per-task=8 --mem-per-cpu=1G
cd ~/<your-team-repo>
```

**5. Score yourself** (a quick 30-second, 1-run version)
```
scripts/score.sh demo1 30 1
```
You should see something like:
```
Scoring demo1: 1 run(s) of 30s on frnt201, 8 CPUs
  run 1: 48 valid demos, 0 invalid
SCORE: 48 valid demo1 demos in 30s (median of 1)
```
Each copy's output is in `results/run1/`. The official score is `scripts/score.sh demo1 120 3` on a whole node.

**6. Save your work.** Type `exit` to leave the job, then:
```
git add -A
git commit -m "describe what you changed"
git push
```

**Week-1 checkpoint (November 9):** post a screenshot of your first `SCORE:` line in the club channel.

## Common problems

| Problem | Fix |
|---|---|
| `Not inside a Slurm job` | Start a job with `salloc` first (step 4) |
| `Please specify memory per cpu using --mem-per-cpu` | Use `--mem-per-cpu`, not `--mem` |
| `Build first` or `Get the game data first` | Run step 3 again |
| `has exceeded its time limit` | Your files are safe. Start a new `salloc` with a longer `--time` |
| Every demo is `invalid` | Your change altered what's drawn. See *Valid demos* in RULES.md |
| `git push` asks for a password and fails | Use a personal access token, and run git on the login node |
| `Illegal instruction` | You built with `-march=native` on the login node. Build inside a job instead |

## Licence

`doom/` is doomgeneric, licensed under the GNU GPL v2 (see `LICENSE`). Keep the licence file in your repo.
