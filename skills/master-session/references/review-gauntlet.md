# The review gauntlet — delta-round convergence for high-stakes PRs

Distilled from the account-context campaign (2026-08-17/18): three units, ~70 findings
adjudicated across 4–5 rounds each, zero post-merge defects. The pattern is a loop that
CONVERGES — each round reviews only the new delta, so finding classes narrow monotonically
(16→7→6→1→0 on one unit) and the loop provably terminates.

## The loop

1. **Declaration** (child): tip SHA · literal invocations WITH their measured results (not
   just the commands — a reviewer must see what they returned) · probes with named red sets ·
   seams. Anything containing code spans goes to GitHub via `--body-file`, then is READ BACK
   (see instruments below).
2. **Full pass** (round 1 only): second-model reviewer (codex sol-high) + an Opus refuter
   with a mutation mandate, in PARALLEL — but in **separate worktrees**: the refuter mutates
   files while the reviewer reads them; one shared worktree self-contaminates the read.
   (Caught live: both were pointed at one worktree; corrected before the first mutation.)
3. **Route the verdict with its instrument named.** "Static AST read, no runtime" vs
   "executed 66 tests + ASGI probes" changes what a finding IS: static findings are
   hypotheses the child must reproduce-or-refute WITH THE LINE; runtime findings arrive
   pre-reproduced. Never relay a verdict without this label — a static "held" lost to a
   refuter's vacuity probe in the same round (the probe outranks the read).
4. **Adjudication** (child): accept+fix each finding with the mutation that reddens it, or
   refute with the specific line and test. Children refute as often as they confirm
   (a creation-race claim died against a measured FOR KEY SHARE block; a cross-tenant claim
   died against a 404 guard with its test named) — a gauntlet where nothing is ever refuted
   is a child rubber-stamping, not adjudicating.
5. **ONE push, re-declaration, delta round**: next review covers only `prev-tip..new-tip`.
   Repeat until clean.
6. **Proportionality at the tail**: when the last round's survivors are a one-test fix, the
   master verifies the closing diff DIRECTLY (read it) instead of spending another review
   round. State this in the close-out instruction so the child knows the bar.

## Refuter mandate (the parts that found real defects)

- Each mutation applied ALONE; exact red set recorded; tree restored and verified clean
  between mutations. **Commit first, then probe** — `git checkout -- <file>` restores from
  the INDEX and destroys uncommitted fixes; this bit three children in one campaign, once
  AFTER the child had written the rule itself. It is structural (probe+cleanup share a
  batched command), so the countermeasure must be mechanical:
  `git diff --quiet -- <file> || exit 1` before any probe batch.
- **Independently re-run the author's claimed probes.** Verifying a declared red set is
  cheap and either vindicates the declaration or catches an honest error; both outcomes are
  worth having on record.
- **Verify the mutation applied before trusting a green.** A heredoc-applied mutation
  silently no-ops; require an explicit "mutation applies: True" preflight. A probe harness
  once reported a fix held when nothing had changed.
- **Hunt vacuity**: a floor test comparing `[]==[]` because the fixture seeds no floor; a
  census asserting "no offenders" over a tree containing none (a broken detector passes
  identically — exercise the detector against sources that DO contain each form); an
  "assembled once" test whose second assembly is byte-identical by construction. The
  house question for every pin: name the mutation IT ALONE catches.

## The live-smoke stage (when the unit has an external surface)

A cheap live run catches classes no suite reaches: one $0.31 smoke found a floor rendered
TWICE (every presence assertion satisfied — a COUNT was needed) and a validator refusing
the system's own honesty line. Rules: acceptance evidence is MEASURED ON THE STORED
ARTIFACT, not asserted from code; cache-replay makes re-verification after render-only
fixes $0 (but a rebuilt database carries the TEMPLATE's cache, not the run's — preserve
the cache table across schema rebuilds); decline a re-smoke when the changed paths are
unreachable by the fixture (an identical artifact adds no evidence).

## Probe-your-own-fixes (the recurring defect of review rounds themselves)

Fixes minted DURING a review round are the likeliest code in the PR to be correct-and-
unpinned — four instances in one campaign where a freshly written fix, probed, reddened
nothing. Make "probe the fix before declaring it" part of the adjudication step, not a
courtesy. Corollary: a plan the master ratified is still a hypothesis — one child found the
ratified fix needed NO production change by reading the function first (it already returned
the value); read-before-write outranks the ruling.

## Master-side instruments (each earned by a failure)

- **Fresh worktree per review round, created from an EXPLICIT SHA** — `FETCH_HEAD` is
  per-worktree state; a worktree-add from a FETCH_HEAD read in another worktree checked out
  the wrong commit and was caught only by reading the add output.
- **Read the posted artifact back.** `gh pr comment/edit --body` lets the shell expand
  backticks (a re-declaration silently lost every code span); a failed `cd` in a compound
  command made `gh pr edit` a silent no-op (caught because the new suite figure was absent
  from the stored body). Cheap instrument: backtick COUNT, local vs posted, plus a
  byte-level diff. Anything with code spans goes through `--body-file`.
- **Evidence freshness**: a suite run is evidence only for the tip it ran on — a child that
  discards its own green run because two commits landed after it is the discipline working;
  CI's full lane at the tip is the pre-merge gate for test-only close-outs.
- **The declaration gate catches false claims mechanically**: "regenerated and committed"
  was a false claim caught by CI's two-file drift check, not by trust — and only the
  two-file check could see it (the TypeScript generator omits `minLength`, so the artifact
  humans read looked clean while the schema was stale).
