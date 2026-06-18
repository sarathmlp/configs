---
name: myreview
description: Review the current code changes (working diff or a PR/branch) against a 9-point checklist covering correctness, silent-failure patterns, resource lifecycle, concurrency, codebase integration, and convention consistency. Use when the user asks for a thorough/checklist-driven code review of a diff, branch, or PR.
---

# Checklist-driven code review

Review branch/PR changes: `gh pr diff <n>`, or `git diff <base>...HEAD` (`<base>`
= merge target, detect it; not always `main`). Working-tree `git diff` only for
uncommitted edits.

Apply the checklist below in addition to ordinary correctness review. It layers
on top of default behavior — it reinforces the things that get missed. For each
finding, name the root cause and category, not just the symptom, and cite
`file:line`. Translate language-specific judgement to the language at hand.

1. REVIEW THE WHOLE CHANGED UNIT + ITS CALLERS. For every function/block
   touched, re-read the entire function against these standards even if the
   current commit only changed part of it. Do not assume previously-reviewed
   code is fine. When a signature, return type, or semantics changed, check the
   callers too (graphify `path`/query, or Grep) — a change can break or
   mislead code outside the diff.

2. HARDCODED VALUES & UNUSED CONFIG. Flag any string/number literal that
   identifies a model, provider, env key, URL, threshold, or magic prefix/
   suffix when (a) it is duplicated, or (b) an equivalent constant/config value
   already exists elsewhere — production logic must not embed identifiers that
   live in config. Also flag config/keys that are defined but never read.

3. FAIL LOUD, NOT SILENT. Flag code that does the wrong thing without erroring:
   - Fallback lookups (get-with-default, optional-unwrap-to-default, null-
     coalescing) or substring/prefix/membership guards where a typo or format
     mismatch silently skips logic or returns a wrong default.
   - Name/prefix matches: does the real upstream value (prefixes like "models/",
     date/version suffixes, casing) still match?
   - No-op guards; over-broad calls (provider-specific function run for every
     provider).
   - Inputs not held for null/empty/zero/negative/wrong-type/oversized.
   - Broad catch-all (bare except, `catch (...)`, swallowed/ignored errors)
     that hides a real failure instead of surfacing it.
   - Numeric (where the language allows it): integer overflow/underflow on
     fixed-width types, float precision/rounding on money or accumulated
     values, division-or-modulo-by-zero, silent coercion/truncation.
   Ask: "what input breaks this, and does it fail loud or silent?"

4. RESOURCE LIFECYCLE. Trace every acquired resource to end-of-scope; verify it
   is released on ALL paths including exceptions/early returns (scope-based
   cleanup — RAII / `using` / `with` / `defer` — or a finally block). An absent
   close/release is a finding even if it's not on a changed line. Check:
   - File handles, sockets, DB connections/cursors, subprocess pipes: closed?
   - Thread/process pools, executors, async tasks, schedulers: shut down/joined?
     background threads daemonized or stopped?
   - Locks/semaphores: released on every path?
   - Generators/streams: consumed or explicitly closed?
   - Unbounded growth: global/static caches with no eviction/size cap,
     accumulation in loops, retained references that prevent reclamation.

5. CONCURRENCY + STATE. Mutable global/shared state touched on per-request
   paths under concurrency (flag race/lifetime issues — prefer locals or
   explicit locking).

6. ARGUMENT MUTATION & IMMUTABILITY. Flag functions that mutate a passed-in
   object as a side effect (decide: intended+documented, or return a value
   instead). Flag shared/static-lifetime mutable defaults reused across calls.
   Where a value is meant to be constant, use the language's immutability
   construct (const/final/readonly/frozen/immutable type) rather than a
   mutable literal.

7. REUSE, DON'T REINVENT. Before judging new logic, search the codebase for an
   existing function/module/pattern that does the same thing: if
   `graphify-out/graph.json` exists, prefer `graphify query "<what the change
   does>"` (semantic — finds similar code even when names differ); otherwise
   fall back to Grep/Glob. Do NOT trigger a fresh graphify build mid-review —
   too heavy; use the graph only if already built. (Needs repo access — when
   only a patch is available, note this check was skipped.) If a prior
   implementation exists, flag that the change reinvents instead of reusing/
   extending it, and should follow that construct's shape and conventions.

8. SIMPLICITY. Flag needless complexity:
   - Duplicated logic that should be extracted into a function (divergence risk:
     a fix to one copy missed in the other).
   - Over-engineering: speculative flexibility, single-use abstractions,
     dynamic/generic machinery where a few explicit constants would do, error
     handling for impossible cases.
   - Manual/verbose code that reimplements a standard idiom (scope-based
     cleanup, iteration/collection idioms over index loops, enums/typed
     structures over magic strings and loose maps, standard path/IO over string
     munging, type checking + static analysis to catch typos mechanically).
   Ask "what is the simplest thing that solves exactly what was asked?"

9. SCOPE CREEP. Flag diff lines that change code unrelated to the stated goal:
   gratuitous refactors of adjacent code, renames not required by the task,
   reformatting untouched lines, dead-code cleanup the change didn't cause.
   The change should touch only what it must.


## Output

Group findings by severity (blocker / should-fix / nit). For each: `file:line`,
the root cause, and a concrete fix. 
End with a verdict (approve / approve-with-nits / request-changes).

For security-sensitive diffs (auth, input handling, secrets, deserialization,
shell/SQL/path construction), note that `/security-review` covers that surface
and is out of scope here.
