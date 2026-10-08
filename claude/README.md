# Claude Code config

Personal Claude Code setup: global instructions, review skills and the agents
they use. The layout mirrors `~/.claude/`, so every file here has one home there.

```
claude/
├── CLAUDE.md                     → ~/.claude/CLAUDE.md      global working principles + coding checklist
├── RTK.md                        → ~/.claude/RTK.md         rtk token-proxy notes (included by CLAUDE.md)
├── skills/
│   ├── myreview/SKILL.md         → ~/.claude/skills/myreview/
│   └── dualreview/SKILL.md       → ~/.claude/skills/dualreview/
└── agents/
    ├── plain-reviewer.md         → ~/.claude/agents/
    └── review-merger.md          → ~/.claude/agents/
```

## Install

Symlink each file into `~/.claude/` so edits made there land in this repo:

```sh
REPO=~/configs/claude
mkdir -p ~/.claude/skills ~/.claude/agents
ln -sf $REPO/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf $REPO/RTK.md    ~/.claude/RTK.md
for s in myreview dualreview; do ln -sfn $REPO/skills/$s ~/.claude/skills/$s; done
for a in plain-reviewer review-merger; do ln -sf $REPO/agents/$a.md ~/.claude/agents/$a.md; done
```

`ln -sf` replaces an existing file, so back up anything in `~/.claude` you have
not committed yet. New or changed agents load only in a new Claude Code session;
skills reload immediately.

Requires `rtk` (see `RTK.md`) on `PATH`: the review skills run
`rtk proxy git diff` so the diff is not summarised.

## Usage

### `/myreview` — one checklist-driven review

Reviews the current branch against its merge target, or the working tree for
uncommitted edits. It first sketches the minimal change that would meet the
goal and classifies the diff against it, then walks a 10-point checklist and
has a fresh agent challenge the draft.

- `/myreview` — normal review (main session + one challenger agent).
- `/myreview deep` — two independent reviews merged; about 3× the cost.

### `/dualreview` — two independent reviews, merged

Runs three agents:

1. `plain-reviewer` reviews the change as a model normally would. It has only
   Bash, Read and Write, so it cannot load a review skill or spawn agents.
2. A general-purpose agent runs `/myreview` unchanged.
3. `review-merger` verifies every finding only one review raised, settles
   disagreements by evidence, and writes one report in `/myreview`'s format.

Arguments are passed through to `/myreview`. A run takes roughly 15–20 minutes
and four agents (including `/myreview`'s challenger).

Each completed run is archived to
`~/.claude/reviews/<repo>/<branch>/<date>-<sha>/` (`meta.md`, both reports,
the merged report, the probes). That archive is not part of this repo.

**Follow-ups:** after the PR is updated, pull it and run `/dualreview` again.
It finds the last archived run for the branch and reviews the update: the plain
reviewer stays blind to old findings, the `/myreview` reviewer re-checks them,
and the merged report opens with a "Prior findings" table (landed / not landed /
addressed differently / no longer applies, each with evidence). If the old head
was force-pushed away, every prior finding is re-checked against the full diff.
