# Claude Code config

Personal Claude Code setup: global instructions, review skills and the agents
they use. The layout mirrors `~/.claude/`, so every file here has one home there.

```
claude/
├── install.sh                    repo → ~/.claude (set up a machine)
├── collect.sh                    ~/.claude → repo (bring your edits back)
├── uninstall.sh                  undo install.sh (restore ~/.claude)
├── CLAUDE.md                     → ~/.claude/CLAUDE.md      global working principles + coding checklist
├── RTK.md                        → ~/.claude/RTK.md         rtk token-proxy notes (included by CLAUDE.md)
├── settings.json                 → ~/.claude/settings.json  rtk hook, effort level, theme, plugins
├── skills/
│   ├── myreview/SKILL.md         → ~/.claude/skills/myreview/
│   └── dualreview/SKILL.md       → ~/.claude/skills/dualreview/
└── agents/
    ├── plain-reviewer.md         → ~/.claude/agents/
    ├── review-challenger.md      → ~/.claude/agents/
    └── review-merger.md          → ~/.claude/agents/
```

## Install

```sh
~/configs/claude/install.sh
```

It copies `CLAUDE.md`, `RTK.md`, `settings.json`, `skills/` and `agents/` into
`~/.claude/`, and is safe to re-run:

- files already identical are skipped;
- it records in `~/.claude/config-install/` every file it adds, every file it
  replaces (keeping the original), and every directory it creates — on the
  first install, so re-running it never loses the true originals;
- nothing else in `~/.claude` (credentials, history, projects, plugins,
  review archive) is touched.

## Uninstall

```sh
~/configs/claude/uninstall.sh
```

Puts `~/.claude` back to how it was before the first install: deletes the files
install added, restores the ones it replaced, and removes the directories it
created (a directory that has since gained other files, such as Claude Code's
own state on a fresh machine, is kept). Start a new session afterwards.

If you edited an installed file since, it refuses and lists the files: run
`collect.sh` first to keep the edits, or `uninstall.sh --force` to discard them.

New or changed agents load only in a new Claude Code session; skills reload
immediately.

Requires `rtk` on `PATH`: `settings.json` installs its hook (`rtk hook claude`)
and the review skills run `rtk proxy git diff`. The script warns if it is
missing.

## Saving changes

Edit skills, agents or `CLAUDE.md` where Claude Code uses them, in
`~/.claude`. Then bring them back here and commit:

```sh
~/configs/claude/collect.sh     # copies changed files into this directory, shows git status
cd ~/configs && git add claude && git commit -m "..."
```

`collect.sh` picks up `CLAUDE.md`, `RTK.md`, `settings.json`, every agent and
every skill, including new ones, except `graphify` (installed by its own tool)
and `synced` (managed by claude.ai). It never deletes: if you remove a skill
from `~/.claude`, delete it here yourself. Review `git status` before committing.

## New machine

1. Install Claude Code and `rtk`.
2. Clone this repo and run `claude/install.sh`.

## Usage

### `/myreview` — one checklist-driven review

Reviews the current branch against its merge target, or the working tree for
uncommitted edits. It first sketches the minimal change that would meet the
goal and classifies the diff against it, then walks a 10-point checklist and
has a fresh agent challenge the draft.

It runs in the main session plus one challenger agent.

### `/dualreview` — two independent reviews, challenged and merged

Runs four agents:

1. `plain-reviewer` reviews the change as a model normally would. It has only
   Bash, Read and Write, so it cannot load a review skill or spawn agents.
2. A general-purpose agent runs `/myreview`, minus its own challenge step.
   Both reviewers run in parallel and end with a "Clean list" of what they
   found correct (names only).
3. `review-challenger` gets only those names, forms its own verdict on each
   before reading either report, and reports what the reviewers missed.
4. `review-merger` verifies every finding only one source raised, settles
   disagreements by evidence, and writes one report in `/myreview`'s format.

The challenger looks for missed bugs; the merger weeds out false alarms.
Arguments are passed through to `/myreview`. Expect roughly 40–60 minutes.
The skill runs `caffeinate` so idle sleep can't pause the agents, but closing
the lid on battery still does.

Each completed run is archived to
`~/.claude/reviews/<repo>/<branch>/<date>-<sha>/` (`meta.md`, both reports,
the merged report, the probes). That archive is not part of this repo.

**Follow-ups:** after the PR is updated, pull it and run `/dualreview` again.
It finds the last archived run for the branch and reviews the update: the plain
reviewer stays blind to old findings, the `/myreview` reviewer re-checks them,
and the merged report opens with a "Prior findings" table (landed / not landed /
addressed differently / no longer applies, each with evidence). If the old head
was force-pushed away, every prior finding is re-checked against the full diff.
