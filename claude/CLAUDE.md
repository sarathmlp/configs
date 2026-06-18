# Working Principles

How to approach any coding task, before and while writing code. These shape
behavior; the checklist below shapes the code itself. (Adapted from Andrej
Karpathy's notes on LLM coding pitfalls.)

1. THINK BEFORE CODING. Don't assume. Don't hide confusion. Surface tradeoffs.
   State assumptions clearly, present multiple interpretations rather than
   choosing silently, and stop to name confusion rather than proceeding with
   uncertainty.

2. SIMPLICITY FIRST. Minimum code that solves the problem. Nothing speculative.
   Avoid unrequested features, single-use abstractions, unnecessary
   flexibility, and error handling for impossible scenarios.

3. SURGICAL CHANGES.
   - Touch only what you must; clean up only your own mess.
   - Preserve existing style and avoid refactoring unrelated code.
   - When addressing PR comments or making incremental changes, modify only what
     the change requires and leave already-working code intact.
   - Remove only those imports/variables your changes made orphaned — leave
     pre-existing dead code alone.

4. GOAL-DRIVEN EXECUTION. Define success criteria. Loop until verified.
   Transform vague requests into testable objectives with clear verification
   steps, enabling independent progress rather than constant clarification loops.

Note the deliberate tension: SIMPLICITY/SURGICAL (above) counterbalance
INTEGRATE (checklist #1) — reuse and hook into existing flows, but do not let
that become "refactor everything." Stay minimal and scoped.

# Code Writing Checklist

Apply this checklist whenever writing or modifying code, in any project and any
language. It layers on top of default behavior — it reinforces the things that
get missed, not basic correctness. Translate language-specific judgement to the
language at hand (e.g. integer overflow matters in C/Go, not Python).

1. **INTEGRATE & MATCH, DON'T REINVENT.**
   - For any new feature, first search the codebase for similar implementations
     and reuse or extend their methods/constructs rather than inventing a new
     approach.
   - Reuse or extend an existing function/abstraction before adding new logic;
     hook into existing flows, not a parallel path.
   - Understand why code is shaped as it is before changing it.
   - Extract repeated logic rather than copy-pasting.
   - Match the codebase's naming, error/logging patterns, structure, and
     formatting so code looks like the same author wrote it.
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
   - On any multi-site change, follow every caller/reference/import you touched
     and update all of them — no half-applied edits; keep the build green.

5. **TEST NEW LOGIC.**
   - Add/update tests covering the happy path and the edge cases from item 3 —
     not just that it runs.

@RTK.md
# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
