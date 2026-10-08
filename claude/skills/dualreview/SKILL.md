---
name: dualreview
description: Review a branch/PR with two independent reviewers — a plain one and one running /myreview — then a third agent merges and verifies their reports. Re-running it after the PR is updated does a follow-up review against the previous run. Arguments are passed through to /myreview.
---

# Dual review

You only dispatch and relay. Do not read the diff or form any opinion of the
change yourself: the three agents do the reviewing and merging.

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
   with empty `plain/`, `skill/`, `merge/`, and a `meta.md` recording: repo
   path, branch, merge target, base commit (`git merge-base`), HEAD commit,
   the full diff command, the update diff command (or why there is none), the
   previous run's path (or "none"), and the date.

## 2. Reviewers

Spawn both in one message, in parallel, in the background. Give each the same
facts — repo path, the full diff command, the commit/PR title, how to run the
tests — plus its own subdirectory, and tell each to run probes against the
repo checkout (or a fresh export of HEAD), not to modify the repo, and not to
read any directory it was not given.

- `plain-reviewer` agent: add nothing else on a first review. On a follow-up,
  add only which commits are new since the last review. Never give it the
  previous run's path or findings, and do not mention /myreview, the other
  reviewer, or anything you suspect.
- `general-purpose` agent: "Invoke the myreview skill with the Skill tool
  (arguments: <this skill's arguments, or none>) and follow it end to end on
  this diff. Return its full final report, and also write it to `report.md`
  in your scratch directory." On a follow-up, add: the previous run's
  `merge/merged.md` path, its `plain/`, `skill/` and `merge/` directories (for
  the probes to rerun), the update diff command, and "This is a follow-up:
  apply the skill's 'Follow-up passes' section to every finding in the
  previous merged report."

When both return, check that `plain/report.md` and `skill/report.md` exist.
If one is missing, write that agent's returned report to the path verbatim
yourself.

## 3. Merge

Spawn a `review-merger` agent with the repo path, the full diff command, the
two report paths and the run's `merge/` directory. On a follow-up, also give
it the previous run's `merge/merged.md` and the update diff command. It
writes `merge/merged.md`.

## 4. Archive and report

1. Copy the whole run directory to
   `~/.claude/reviews/<repo dir name>/<branch, / replaced by _>/<YYYYMMDD-HHMM>-<short HEAD>/`.
2. Show the user the merger's report verbatim, then one line with the
   archive path.

If any agent stops on an error (an API or usage limit, a crash) before
returning its report, resume it once with SendMessage, telling it to continue
from where it stopped. If it fails again, or returns no report, tell the user
which agent and stop: do not merge a single review, and do not archive the
run, since an incomplete run would become the next follow-up's baseline.
