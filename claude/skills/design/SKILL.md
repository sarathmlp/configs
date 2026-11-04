---
name: design
description: Work out or review a software/system design before code exists — establish what the platform and existing code already do, compare options including the minimal one, check the leading one, and record the decision as a markdown ADR; or review someone's design doc the same way.
---

# Design

Pick the mode from the arguments:
- a problem or feature to design: **Design mode**, the output is an ADR;
- a path to a design doc: **Review mode**, the output is a review.

Designs often go wrong on a constraint nobody wrote down, or on building what
already exists; steps 1 and 3 check both. The steps check your thinking; they
do not replace it.

## 1. Constraints: ask, never assume

Collect these before proposing anything:
- the problem, who or what hits it, and what success looks like, measurably;
- numbers: load, data size, latency, availability, cost ceiling;
- fixed points: existing stack and platform, team, deadline, compliance;
- non-goals.

Ask for anything missing as numbered plain-text questions, and wait for the
answers. Never fill a gap with an assumed number: no later step catches a
design built on a guessed constraint. In Review mode, a constraint the doc
relies on but never states is a finding.

## 2. Free draft

Before the steps below, think it through as you would without this skill and
save a short draft in scratch: how you would solve it (in Review mode, what
you make of the doc), what worries you, whether the problem is framed right.
The remaining steps check this draft. Whatever it found that they do not
cover still goes in the output.

## 3. Floor: what already exists

Answer the three baseline questions of Step 0 in
`~/.claude/skills/myreview/SKILL.md` against the problem instead of a diff,
under that file's "Dependency source" rules: read the installed source and
cite `file:line`, never recall. Also ask what the PLATFORM owns (a hosted
product's console or settings, a managed service's built-ins): no package
source shows that.

If the floor covers the whole problem, the design is "use it" plus its
configuration. If it covers most of it, say so plainly, then design the part
it leaves.

## 4. Options

Lay out two or three real options. One is always the minimal one: what the
floor gives, plus the least added on top. For each:
- what it is, in a few lines;
- what it costs to build and to run;
- what breaks it: the load, failure or change that makes it the wrong choice;
- in a line each: how it fails, where its data lives, how hard it is to undo.

No option exists only to lose. If only one option is real, say why.

## 5. Check the leading option

At least these, plus anything else this design depends on. Each needs an
answer, or "not applicable because …":
1. Failure: each dependency down, slow or returning garbage; timeouts,
   retries, idempotency.
2. Data: the source of truth for each piece, who writes it, the consistency
   needed, what a partial write leaves behind.
3. Interfaces: the contracts between components, how they are versioned, what
   breaks callers.
4. Migration and rollback: how to get from today's system to this one, and
   back if it fails.
5. Trust boundaries: who controls each input; authentication, authorization,
   secrets.
6. Operations: how you will know it is broken, and who finds out.
7. Cost and scale: what grows with load, and where the first bottleneck is.
8. Reversibility: which parts are hard to undo. Put the most scrutiny there and
   the least on parts that are cheap to change later.

## 6. Prove the riskiest assumption

Name the one assumption that sinks the design if it is wrong. Where you can,
test it now with the smallest spike or probe, in scratch and never in the
project, and read its real output. Where you cannot, say what would test it
and mark the decision provisional.

## 7. Challenge

Save the draft in scratch. Spawn one fresh agent with the step 1 constraints
and the draft's path. It first forms its own view of the riskiest assumption
and the failure modes, and only then reads the draft and reports every
disagreement with evidence. Verify each of its claims yourself; drop what
does not hold.

## Output: Design mode

ADRs go in the repo's ADR folder (`docs/adr/` or similar), numbered after the
last one there. If the repo has none, ask where they should go.

    # <NNNN>. <the decision, as a short phrase>

    Status: proposed · Date: <today>

    ## Context
    <the problem, constraints with their numbers, non-goals>

    ## What already exists
    <the floor, with file:line or platform evidence>

    ## Options
    <each option: what it is, its cost, what breaks it>

    ## Decision
    <the chosen option, and the constraint that decides it>

    ## Consequences
    <what gets easier, what gets harder, the risks accepted>

    ## Validation
    <the riskiest assumption, and the spike and its result or what would test it>

    ## Other considerations
    <anything from the free draft or the challenge that fits no heading above; omit if none>

    ## Revisit when
    <the change in load, cost or requirements that should reopen this>

## Output: Review mode

Run steps 1–7 against the doc; each gap is a finding, including anything the
free draft found that the steps did not. Follow the table and standalone-block
rules in the Output section of `~/.claude/skills/myreview/SKILL.md`, and write:

    ## Review notes
    <what the design gets right and wrong; the floor; what you could not verify>

    ---

    ### Blockers
    ### Should-fix
    ### Nits

    ---

    **Verdict:** <approve | revise | rethink>. <one sentence: what must change before building.>

`rethink` means the floor or the minimal option makes the proposed design
unnecessary.
