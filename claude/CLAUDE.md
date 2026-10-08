# Working Principles

How to approach any coding task, before and while writing code. These shape
behavior; the checklist below shapes the code itself.

1. THINK BEFORE CODING. Don't assume. Don't hide confusion. Surface tradeoffs.
   State assumptions clearly, present multiple interpretations rather than
   choosing silently, and stop to name confusion rather than proceeding with
   uncertainty.

2. SIMPLICITY FIRST. Minimum code that solves the problem. Nothing speculative.
   - Avoid unrequested features, single-use abstractions, unnecessary flexibility.
   - Every guard, fallback, retry and catch must name an input that triggers it.
     Cannot name one → delete it.
   - A comment arguing with a hypothetical objection means the decision is
     unjustified — cut the decision, not the comment. See Comments & Docstrings.

3. SURGICAL CHANGES.
   - Touch only what you must; clean up only your own mess.
   - Preserve existing style and avoid refactoring unrelated code.
   - When addressing PR comments or making incremental changes, modify only what
     the change requires and leave already-working code intact.
   - Remove only those imports/variables your changes made orphaned — leave
     pre-existing dead code alone.
   - Deleting needs the same verification as writing. Removing a bound, a guard,
     or a default is a behavior change — re-check it like new code.

4. GOAL-DRIVEN EXECUTION. Define success criteria. Loop until verified.
   Transform vague requests into testable objectives with clear verification
   steps, enabling independent progress rather than constant clarification loops.

5. FLOOR FIRST. When building on a library/framework/service, adding a new
   module, or starting anything large relative to its goal (skip for small
   changes to existing code):
   - Install the required dependency version (get from manifest etc) into a 
     throwaway environment (`python -m venv` under the scratch dir,
     `npm install --prefix`, `go mod download`), never the project or system one.
   - State what the dependency already does out of the box — from its installed
     source and also from memory.
   - Ask what the PLATFORM owns, not only what the package exposes. A hosted
     product's console or project settings can already deliver what you are
     about to write, and none of that is a symbol in the installed source, so
     the questions above cannot see it. 
   - Build the smallest version that runs. Run it. Look at the real output.
   - Before building past that floor, say out loud what it covers and what it
     does not, so the gap is visible rather than assumed. Then add only what the
     output proves is missing, naming what each addition is for.
   - Cannot determine the floor (no access, unfamiliar dependency)? Say so
     rather than skipping silently.
   Never build the full design and verify at the end; an unrun design grows to
   fill the space.

# Comments & Docstrings

Default is NO comment. Your reasoning, assumptions, and tradeoffs go in your
reply to me, never in the code.

- Add a comment only if a competent reader would otherwise get it wrong: a
  non-obvious constraint, a workaround for a specific bug, a surprising
  invariant. Keep it to one line and link the issue if there is one.
- Never comment on what the code does, restate a condition, or narrate if/else
  branches. If a branch needs explaining, rename or extract a function instead.
- When I give a reason for a design choice that isn't obvious from the code,
  record it as a short comment at that spot.
- When §2 requires naming the input that triggers a guard, name it in your
  reply, not in a comment.
- Docstrings go only on public APIs: one summary line, plus params only when
  they aren't obvious. No Args/Returns blocks that repeat type hints. No
  docstrings on private helpers or tests. Exception: follow the project's lint
  config or CLAUDE.md if it requires docstrings.
- Before finishing, reread your diff and delete every comment that fails these
  rules.

Bad:
    # Check if the user exists before proceeding, since a missing user
    # would cause a KeyError downstream when we access the profile.
    if user is None:
Good:
    if user is None:

# Code Writing Checklist

Apply this checklist whenever writing or modifying code, in any project and any
language. It layers on top of default behavior — it reinforces the things that
get missed, not basic correctness. Translate language-specific judgement to the
language at hand (e.g. integer overflow matters in C/Go, not Python).

1. **INTEGRATE & MATCH, DON'T REINVENT.**
   - For any new feature, first search the codebase/installed packages for
     similar implementations and reuse or extend their methods/constructs 
     rather than inventing a new approach.
   - Hook into existing flows, not a parallel path.
   - Understand why code is shaped as it is before changing it.
   - Extract repeated logic rather than copy-pasting (follow DRY principle).
   - Match the codebase's naming, error/logging patterns, structure, and
     formatting so code looks like the same author wrote it.
   - Match the codebase's idiom, not its volume. Where surrounding code is
     verbose, defensive, or heavily commented, copy the conventions — not the
     quantity.
   - Put model/threshold/URL/key/path values in a named constant or config,
     reusing existing ones over literals.

2. **FAIL LOUD, NOT SILENT.**
   - Avoid accessors/guards that quietly return a default or skip logic on a
     miss, and broad catch-alls that swallow failures.
   - Validate and raise/return an explicit error on the unexpected, so a typo or
     mismatch surfaces instead of hiding.

3. **COVER EDGE CASES & RESOURCES.**
   - Hold for missing/null, empty, zero, negative, wrong-type, and oversized
     inputs.
   - Release every acquired resource (files, sockets, locks, memory) on all
     paths via scope-based cleanup (with / defer / try-finally / RAII).
   - Guard division/modulo by zero; watch overflow, precision, and truncation in
     numeric code.
   - Prefer locals over shared mutable state, protect deliberately-shared state
     under concurrency, and don't mutate passed-in args as a hidden side effect.

4. **VERIFY, DON'T HALLUCINATE.**
   - Run the code/tests and read the real output before claiming it works —
     never report a result you didn't observe.
   - Don't invent APIs, signatures, fields, config keys, or library behavior —
     check the actual definition or ask, rather than guess.
   - Before claiming how a third-party library behaves, open its installed source
     and cite file:line. An invented function name fails loudly; an invented
     MECHANISM — a plausible story about how the library wires things together —
     passes every test you write against yourself. Confident documentation of a
     mechanism is not evidence it is real.
   - On any multi-site change, follow every caller/reference/import you touched
     and update all of them — no half-applied edits; keep the build green.

5. **TEST NEW LOGIC.**
   - Add/update tests covering the happy path and the edge cases from item 3 —
     not just that it runs.
   - For integration code, at least one test must assert on the call that crosses
     into the external system: fake the boundary, assert on the arguments it
     received. A test asserting on your own helper's return value cannot detect
     that nothing calls the helper.
   - A test must exercise the code, not restate it. Re-implementing the logic in
     the test body, or asserting on source text, proves nothing.
   - Tests must run under every condition the code claims to support. If the code
     works with an optional dependency absent, the suite must run with it absent
     — skip or guard only the tests that genuinely need it.

6. **EFFICIENCY WHERE IT COUNTS.**
   - Choose the right data structure/algorithm first; flag any O(n²)+ on
     unbounded input.
   - No repeated work in loops, no N+1 queries, no loading everything to use
     a little.
   - Don't micro-optimize without a measurement showing the hotspot.

7. **SECURE BY DEFAULT.**
   - Validate/sanitize at trust boundaries (user input, network, files).
   - Parameterize queries and shell commands; never build them by string
     concatenation.
   - Never hardcode, log, or echo secrets.

@RTK.md
