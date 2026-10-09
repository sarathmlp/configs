---
name: myreview
description: Review the current code changes (working diff or a PR/branch) — construct the minimal alternative first, then apply a 10-point checklist.
---

# Checklist-driven code review

Review branch/PR changes: `gh pr diff <n>`, or `git diff <base>...HEAD` (`<base>`
= merge target, detect it; not always `main`). Working-tree `git diff` only for
uncommitted edits.

Review the full diff, never a summary of it. `rtk` rewrites `git diff` into a
condensed summary, so run it as `rtk proxy git diff …`, or save the diff to a
file in scratch and read that file.

## Dependency source — install it, do not recall it

- Pin the version the change targets, read from the manifest or lockfile in the
  diff, not from the latest release.
- Install into a throwaway environment (`python -m venv` under the scratch dir,
  `npm install --prefix`, `go mod download`), never the project or system one,
  and delete it when the review ends.
- Only when installation genuinely fails: name which claims went unverified.
  "Not installed" is never the end of the check.

## Step 0 — construct the alternative, before reading the diff

You need to identify the minimal and simple code that does the stated objective
and compare it against the diff and verify if the submitter has done it 
correctly, or overdone or done it wrongly. Most of the time, the submitter use
AI to code and it's your responsibility to figure out and flag the bloats it create.

A review machine (this one) may not have database, queue or upstream services.
So, consider that limitation when you run/test the code.

Answer three baseline questions before sketching. Remember the answers as
Step 0 Q&A which you need to include in the final report.

1. WHAT DOES THE DEPENDENCY DO OUT OF THE BOX? From its installed source AND
   from memory figure out what that package/library do out of the box. And 
   is the submitter trying to re-invent it instead of using it?
   — install it first if absent. This is what shows if the diff is OVERDONE:
   Evidence `file:line`. Mandatory.
   There can be also cases where you are using an SDK for a utility in code,
   if something is manually computed while using SDK, first check if the
   utility deployed already provides that. For eg: lot of observability
   platforms lets you compute lot of metrics from raw data, you don't need to
   compute from application code and then send it.

2. ARE THERE BETTER UTILITIES OR LIBRARIES THAT DOES IT BETTER?
   The submitter or the AI code agent might have used the most popular or pre
   existing utilities or libraries for a particular job. But you can always
   check if there are better ones that are more apt for this job. And only
   suggest those if they outclass the current solution.

3. WHAT DOES THE EXISTING CODE ALREADY DOES?
   Scan the codebase, installed packages for any existing implementations,
   solutions etc that solves the same problem or similar problems and
   ask yourself is the diff reusing those? the existing functions,
   classes, utilities, etc? or it's reinventing the wheel?

Based on what you observed from above steps, sketch the smallest code that
delivers the stated goal.

Then classify how the diff relates to that sketch, citing the sketch's entry
points `file:line` in the installed source against what the diff does instead.
This classification is the TOP finding, not a closing aside.

- SAME PRIMITIVES, SAME SHAPE. The diff calls what the sketch calls. Proceed to
  the checklist.
- SAME PRIMITIVES, EXTRA SCAFFOLDING. The right calls, wrapped in layers. Name
  each layer and what deleting it costs; the findings are trims. Proceed to
  checklist.
- DIFFERENT PRIMITIVES, REASON GIVEN. The submitter needed something the sketched
  path does not provide. The sketch was wrong: say so, revise it, review the
  diff on its own terms. A confidently wrong sketch is worse than no Step 0.
  Proceed to checklist.
- DIFFERENT PRIMITIVES, NO REASON GIVEN. The diff reimplements or bypasses what
  the dependency already provides, and nothing in the change explains why.
  Verdict `rework`. Still run the checklist over the rest of the diff: a PR
  often bundles several changes, and one needing rework does not review the
  others.
- PLATFORM DOES, NOT CODE. The diff automates in code what the installed library
  or utility already does. Or the deployed utility does with simple configuration.
  A QUESTION to the submitter, never an automatic `rework`. Still run the
  checklist over the rest of the diff.

Score every new file, class and exported function against the sketch: KEEP, FOLD
or DELETE, each with a written reason —
what it replaces, or the failure it prevents. No answer = DELETE.

A KEEP must cite evidence that the unit does what it claims: a test that
asserts it, a probe you ran, or the code path you traced. A KEEP resting only
on the diff's own comments or docstrings is unverified: mark it so, and the
challenge step must test it.

A DELETE verdict does not end the review of that unit. The submitter may keep
it, so still check its failure modes and report them.

The scores are working notes, not part of the report. Every verdict that is
not a plain KEEP — FOLD, DELETE, KEEP with a fix, or a question — must appear
in the report as a finding (Blocker, Should-fix, Nit or Open question) with a
concrete fix; a verdict that is not in the findings is lost.

Do all of this before the per-function pass: bloat is invisible locally, and
shows up only against a baseline the diff never contains.

Cannot construct the sketch (no repo access, or a dependency that cannot be
installed)? Say so explicitly rather than skipping silently.

## Follow-up passes

Reviewing a new commit on a PR you already reviewed:

- Re-run every probe from the previous pass against the new code. A fix
  that looks right and has a green test can still not work.
- A fix is new code. Score it and check it like any other.
- For each prior finding say: landed / not landed / addressed
  differently. "Addressed differently" means re-ask the ORIGINAL
  question — the submitter may have satisfied your stated reason while
  leaving the problem.
- Do not carry a prior verdict forward as settled. Re-derive it from the
  code in front of you. "Do not assume previously-reviewed code is fine"
  applies to your own conclusions about it, not just the submitter's.

## Checklist

Apply this in addition to ordinary correctness review. For each finding name the
root cause and category, not just the symptom, and cite `file:line`. Translate
language-specific judgement to the language at hand.

1. SIMPLICITY FIRST: Minimum code that solves the problem. Nothing speculative.
   Combat the tendency toward overengineering:
   - No features beyond what was asked
   - No abstractions for single-use code
   - No "flexibility" or "configurability" that wasn't requested
   - No error handling for impossible scenarios
   - If 200 lines could be 50, flag it

2. SURGICAL CHANGES. Scope creep (unrelated refactors, restyling, "improved"
   adjacent code) is a finding; unrelated dead code is mentioned, not deleted.
   - Flag imports/variables/functions/constants the diff made unused.
   - Flag pre-existing dead code the diff removed.

3. REVIEW THE WHOLE CHANGED UNIT, ITS CALLERS AND ITS CONSUMERS.
   - Re-read every touched function in full, not just the changed lines. Do
     not assume previously-reviewed code is fine.
   - When a signature, return type or semantics changed, check each caller:
     what does it do when this fails, returns empty, or returns partial?
   - For every new value the diff introduces — return value, flag, exception
     type, state field, config key — read every place that consumes it, in any
     file, and check the consumer handles it.
   - Every safety claim the diff makes — in a comment, docstring or test name —
     is a claim to TEST, not evidence. Probe it or read the test that proves it.
   - For every new config flag: what does it do combined with the flags next to
     it, including combinations nobody intended?

4. HARDCODED VALUES & UNUSED CONFIG. Flag any string/number literal that
   identifies an actual variable that can change such as env key, URL,
   threshold, or magic number, magic strings etc.
   Also check the application configuration thoroughly to understand what's
   used, what's useful, what's not used etc.

5. REUSE & MATCH, DON'T REINVENT. Before judging new logic, search the
   codebase for an existing function/module/utility that does the same thing.
   If a prior implementation exists, flag that the change
   reinvents instead of reusing/extending it.
   Match the codebase's idiom, not its volume — where the diff is
   verbose, defensive or heavily commented and its neighbours are not, the
   convention is what carries over, never the quantity.

6. FAIL LOUD. Go through EVERY try/except, catch, fallback and
   default-on-miss accessor the diff adds, not just the obvious ones. Each must
   name the input that triggers it; one that cannot is a finding.

7. EDGE CASES & RESOURCES. Null/empty/zero/negative/oversized inputs and
   resource release on all paths, as usual.
   - Shared mutable state under concurrency protected; no hidden mutation of
     passed-in args.

8. TESTS. New logic is tested, happy path and item 7's edge cases.
   - Integration code: at least one test asserts on the arguments crossing the
     external boundary.
   - Flag tests that restate the implementation or assert on source text.
   - Tests must run when optional deps are absent.

9. PERFORMANCE. For code that runs per request, per turn or per row:
   - Complexity: O(n²)+ on unbounded input, repeated work in loops, N+1 queries.
   - Latency: blocking waits and timeouts on the request path, sequential I/O
     that could run concurrently, and every network/DB/LLM round-trip the diff
     adds per request.
   - Memory and payload: loading everything to use a little; unbounded
     results, buffers, caches or prompt/context growth.
   - When a clearly faster approach is no more complex, name it and estimate
     the gain. Do not ask for optimisation the code does not need; flag
     micro-optimisations with no measurement behind them.

10. TRUST BOUNDARIES. For every input the diff reads, who controls it?
    Anything from the client or request body (ids, flags, lists, maps) must be
    validated or bounded before it drives access, cost or loops.

## Output

Before writing the report:

1. Re-open the Checklist section of this file with the Read tool and walk it
   item by item against the diff. You have run many tool calls since you last
   saw it, and the items you have not thought about recently are precisely the
   ones you skipped.
2. Draft the report, then have it challenged. Spawn one fresh agent and give
   it the diff command, the repo path, and the list of units you marked KEEP
   and checklist items you marked clean — names only, WITHOUT your reasons —
   plus the path to your draft saved in scratch.
   - It first forms its own verdict on each, and tests every safety claim the
     diff makes in comments, docstrings or test names.
   - Only then does it read your draft and report every disagreement.
   - A confirmation needs the same file:line evidence as a break; one without
     evidence counts as not checked.
   Verify each of its claims yourself before adding it to the report; drop
   what does not hold.

The report should be in the below format:

    ## Review notes

    Checklist Coverage — found: 0,1,2,3... | clean: 5 | skipped: 4
    <what'd done right in the PR and what's done wrong?>
    <what you could not verify>

    ---

    <Step 0 Q&A, Step 0 classification>
    <DIFFERENT PRIMITIVES, NO REASON GIVEN. PLATFORM DOES, NOT CODE.?>
    <If above two classification, instruct what change submitter should do>

    **Verdict:** <approve | request-changes | rework>. <one sentence: what must happen before merge.>

    ### Blockers
    <finding, file:line, root cause, fix>

    ### Should-fix
    ### Nits
    ### Open question
    <any PLATFORM DOES, NOT CODE item, with the number that decides it>

Every table must be a plain pipe table indented under a bullet point. No
other table format.
