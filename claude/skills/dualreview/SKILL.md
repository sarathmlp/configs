---
name: dualreview
description: Review a branch/PR with two independent reviewers — a plain one and one running /myreview — then a challenger blind-checks what both called correct and a merger verifies and merges all three. Re-running it after the PR is updated does a follow-up review against the previous run. Arguments are passed through to /myreview.
---

# Dual review

You only dispatch and relay. Do not read the diff or form any opinion of the
change yourself: the agents do the reviewing, challenging and merging.

## 1. Set up the run

1. Detect the merge target and fix one exact diff command.
   - `gh pr view` / `gh pr diff <n>` when `gh` is available.
   - Otherwise the branch the parent PR was merged into
     (`git branch -r --contains <merge commit>`) or the remote branch with the
     nearest `git merge-base`; `origin/main` can be the wrong base.
   - Use `rtk proxy git diff <base>...HEAD` so the diff is not summarised.
2. `git fetch`. If `origin/<branch>` exists and differs from local `HEAD`,
   tell the user (the checkout is not the PR's latest commit) and ask whether
   to continue before reviewing it.
3. Find the previous run: the newest directory under
   `~/.claude/reviews/<repo dir name>/<branch, with / replaced by _>/`.
   - None: this is a first review.
   - Its `meta.md` head equals the current `HEAD`: nothing new to review. Tell
     the user and stop.
   - Otherwise: this is a follow-up. If its head commit is an ancestor of
     `HEAD` (`git merge-base --is-ancestor <old> HEAD`), the update diff is
     `rtk proxy git diff <old>..HEAD`. If not (force-push or rebase), there is
     no update diff: every prior finding is re-checked against the full diff,
     and the report must say so.
4. Create the run directory in your scratchpad, `dualreview-<short HEAD>/`,
   with empty `plain/`, `skill/`, `challenge/`, `merge/`, and a `meta.md` recording: repo
   path, branch, merge target, base commit (`git merge-base`), HEAD commit,
   the full diff command, the update diff command (or why there is none), the
   previous run's path (or "none"), and the date.
5. Keep the Mac awake for the run: start `caffeinate -i -t 10800` with
   `run_in_background` (skip if `caffeinate` is missing). Idle sleep pauses
   every agent; this does not stop sleep when the lid is closed on battery.

## 2. Reviewers

Spawn both in one message, in parallel, in the background. Give each the same
facts — repo path, the full diff command, the commit/PR title, how to run the
tests — plus its own subdirectory, and tell each to run probes against the
repo checkout (or a fresh export of HEAD, kept under an `export/`
subdirectory so the archive leaves it out), not to modify the repo, and not
to read any directory it was not given.

- `plain-reviewer` agent: add nothing else on a first review. On a follow-up,
  add only which commits are new since the last review. Never give it the
  previous run's path or findings, and do not mention /myreview, the other
  reviewer, or anything you suspect.
- `general-purpose` agent: "Invoke the myreview skill with the Skill tool
  (arguments: <this skill's arguments, or none>) and follow it end to end on
  this diff. Skip the skill's challenge step: this review runs a separate
  challenger after both reviewers. End the report with a section headed
  `## Clean list`: the units you scored KEEP and the checklist items you
  marked clean, one per line, names only, no reasons. Return its full final
  report. Do not run mutation testing unless
  the change adds or alters a safety check (authorization, a size limit, path
  validation) that no existing test exercises; then mutate only that check."
  On a follow-up, add: the previous run's `merge/merged.md` path, its
  `plain/`, `skill/`, `challenge/` and `merge/` directories (for the probes to rerun), the
  update diff command, and "This is a follow-up: apply the skill's 'Follow-up
  passes' section to every finding in the previous merged report, with one
  exception: for a finding that report marks landed, rerun its probe only if
  the update diff touches a file the probe exercises; otherwise confirm it by
  citing the unchanged code."

When both return, write each returned report verbatim to `plain/report.md`
and `skill/report.md`. (Claude Code refuses report-file writes from these
subagents, so the reports arrive only as their returned text.)

## 3. Challenge

Collect the lines under `## Clean list` from both reports, drop duplicates,
and keep the names only. Spawn a `review-challenger` agent with the repo path,
the full diff command (and the update diff command on a follow-up), that list
of names, the two report paths and the run's `challenge/` directory. Do not
add anything from the reports beyond the names. Write its returned text
verbatim to `challenge/report.md`.

## 4. Merge

Spawn a `review-merger` agent with the repo path, the full diff command, the
three report paths (`plain/`, `skill/` and `challenge/report.md`) and the
run's `merge/` directory. On a follow-up, also give
it the previous run's `merge/merged.md` and the update diff command. It
writes `merge/merged.md` and returns only a short summary; if it returns the
full text instead (its write was refused), save that as `merge/merged.md`.

## 5. Archive and report

1. Copy the run directory to
   `~/.claude/reviews/<repo dir name>/<branch, / replaced by _>/<YYYYMMDD-HHMM>-<short HEAD>/`,
   leaving out code exports and virtualenvs (`export/`, `base/`, `head/`,
   `venv/`, `__pycache__/`): probes are always rerun against the current
   checkout, never an old export.
2. Stop the `caffeinate` started in step 1.5 (`pkill -f "caffeinate -i -t 10800"`).
3. Read `merge/merged.md` and show it to the user verbatim, then one line with
   the archive path.

If any agent stops on an error (an API or usage limit, a crash) before
returning its report, resume it once with SendMessage, telling it to continue
from where it stopped. If it fails again, or returns no report, tell the user
which agent and stop (and stop `caffeinate`): do not merge a single review,
and do not archive the run, since an incomplete run would become the next
follow-up's baseline.
