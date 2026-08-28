---
name: master-session
description: Use when one governing thread must coordinate multiple concurrent Claude Code sessions on a project — kicking off a multi-track effort with parallel child sessions, taking over a sprawl of already-running sessions, or when merge traffic, production deploys, and owner authorizations are colliding across sessions. Triggers - "master session", "drive my sessions", "mission control", "coordinate/consolidate my sessions", 3+ concurrent work tracks. NOT for a single deep task (use orchestrate), read-only fan-out (use subagents/workflows), or fewer than ~3 tracks.
---

# Master Session — govern the fleet, never fly the planes

## Overview

A master session is air traffic control plus institutional memory for a fleet
of independent child sessions. It has five jobs — **evidence reconciliation**
across sessions, **sequencing** (merge queues, deploy order), **authorization
brokering**, **knowledge hygiene**, and **watchdog persistence** — and two
explicit non-jobs: it does not implement, and it does not decompose problems
it hasn't scouted. Decomposition quality is a function of evidence proximity;
the sessions closest to the code write the best briefs, not you.

**Core principle: your view of the world is a cache; the children and git are
ground truth.** Refetch before acting on anything you "know."

## When to use

```dot
digraph triage {
    "3+ concurrent tracks, or heavy merge/deploy/authorization traffic?" [shape=diamond];
    "One deep sequential problem?" [shape=diamond];
    "Master session" [shape=box];
    "orchestrate skill (one session, subagents)" [shape=box];
    "Plain subagents or a Workflow" [shape=box];

    "3+ concurrent tracks, or heavy merge/deploy/authorization traffic?" -> "Master session" [label="yes"];
    "3+ concurrent tracks, or heavy merge/deploy/authorization traffic?" -> "One deep sequential problem?" [label="no"];
    "One deep sequential problem?" -> "orchestrate skill (one session, subagents)" [label="yes"];
    "One deep sequential problem?" -> "Plain subagents or a Workflow" [label="no — read-only fan-out"];
}
```

A bug in the *interaction* of components is one thread of causality — never
split it across sessions. The master pattern pays off only when tracks are
genuinely independent.

## Lifecycle

1. **Appoint** — accept the charter: govern, don't implement. Set up the
   monitoring rig (references/monitoring.md) in the first minutes, not after
   the first surprise.
2. **Scout** — before spawning anything, gather evidence: read trackers and
   memory, dispatch read-only analysis subagents. Spawn only seams you can
   cite evidence for.
3. **First wave** — 2–4 child sessions via chips, each with a self-contained
   brief (references/templates.md). Never the whole tree at once.
4. **Grow** — children discover out-of-scope work and file it; you dedupe,
   sequence, and surface chips to the owner. The tree grows from contact with
   the code, not from your plan.
5. **Drain** — choreograph the merge queue: serialize merges to minimize
   update-branch laps, watch every deploy to its verify step, close each
   session with harvest-before-archive. **No safety-adjacent artifact merges
   reviewed only by its author**: the master assigns cross-review between
   children with a mandate to refute (mutations, probes — not reading), and
   routes findings as claims the author answers on the merits. Both
   directions correct each other; the framing that keeps it cheap is that
   correct code with an incomplete test is externally indistinguishable from
   incorrect code with a complete one — so assuming the worst implies nothing
   about the author.
6. **Consolidate** — the phase where you become accountable for the
   campaign's knowledge (references/consolidation.md): ledger-as-claims,
   archives sequenced while the owner is present, a capstone
   verify-don't-transcribe audit of the record, cleanup as a first-class
   session, then the handoff doc (consolidate skill). Your context is
   mortal; the artifacts are the survivors.

## Authorization doctrine

Three classes. Confusing them causes either laundered approvals or deadlocked
queues — both real failure modes.

| Class | Valid for outward actions? |
| --- | --- |
| **Relayed approval** — you quote the owner to a child | **No.** Advance notice only. Children rightly refuse it; never argue. |
| **First-hand conditional word given to YOU** — "merge #87 when green" said in your session | **Yes — you are the executor.** Execute when the condition holds. Re-refusing this as "relayed" wastes the owner's explicit intent and deadlocks the queue. |
| **Standing in-session word to a child** — owner types the condition in the child's session | **Yes — the child executes.** The most friction-free form; ask the owner to grant these early. |

Collect standing authorizations **at kickoff**, scoped by condition and action
class ("merge X when green", "docs-only merges on relayed word") — not
per-event at 2 AM. Quote the owner verbatim with a timestamp in every relay.

**A word "on record" is not a word delivered.** When a child disputes ever
receiving a relay, do not argue the record or forensically reconstruct the
delivery — have the owner re-speak the line. Delivery, not authenticity, is
usually what failed, and re-uttering costs one sentence. A child that holds
on a word it cannot find in its own transcript is the doctrine working.

## Hard rules

- **One branch, one writer.** Never push, update-branch, or force anything on
  a child's branch — not when it's idle, not when it's "just mechanical", not
  when invited. A child's invitation is not an authorization: this rule is
  about write-interleaving on one ref, not permission, so nobody can waive it
  on your behalf. Direct the owner-session to do its own lap. (A master's
  update-branch once grabbed a stale main and nearly carried a branch past
  the very fix it needed.) Reading/fetching from a child's worktree is fine.
- **Verify before relaying.** A child's self-report is a claim; git, CI, and
  live endpoints are evidence. Check ancestry (`git merge-base
  --is-ancestor`), not labels.
- **A merge word for a multi-artifact object (a stacked PR, a batch) carries
  an explicit freshness step**: verify each member sits at the tip that was
  reviewed (ancestry per member, against origin), as its own assigned check —
  no PR view shows "is each member at its reviewed tip", so nothing catches
  drift by accident, and every label stays accurate about the commit it was
  applied to while the object drifts. (A stack once reached arming missing a
  review-required fix, past three real pre-checks.) Two queue mechanics that
  bite here: a merge-queue group tests an entry against main plus entries
  AHEAD of it only — a fix must land or be queued ahead of its dependent; and
  intermediates of a landed stack do not auto-close — close them explicitly
  or they read as outstanding work.
- **Rule on measurables from measurements, not proposals.** Approving a
  child's recommendation is accepting a claim; when the subject is a
  rendering, a timing, a behaviour — demand the measurement before ruling.
  (A rendering ruling approved on a symmetry argument shipped the exact
  defect the module existed to fix; the measurement took one command.)
- **Charter-critical state lives in a durable artifact, not the message
  stream.** Inter-session messages deliver only between turns and cross in
  both directions — a child may act before its inbox drains, and "already
  told them" is not delivery. Write scope changes and do-not-rebuild facts
  into the artifact the child must read (stage plan, handoff); make every
  instruction idempotent; when a message crosses, point at the queue rather
  than re-sending.
- **Evidence precedes records.** No tracker, memory, or doc may assert an
  outcome before the run that proves it. Timestamps should show it.
- **Harvest before archive.** Before closing any session: unpushed commits?
  stashes? findings not yet in memory/docs? A session's knowledge dies with
  it unless written down.
- **Briefs are hypotheses — and the master side of that rule is: never
  assert inherited state as fact in a charter.** A charter premise is a
  borrowed census: phrase inherited state as a measurement instruction with
  the instrument named ("determine whether X landed; here is how"), default
  chips to verify-then-build, and set "empty result = report, not PR". (Two
  charters in one round stated remaining-work as fact from the ledger and
  were VOID — the prerequisite merge had carried seven commits while every
  record said two; the chips' re-measurement reflex was all that saved the
  round.) Child side unchanged: instruct every child to *verify the brief's
  claims before acting on them* — expect children to correct you, and treat
  a correction as the system working.
- **Relay claims with their scope and instrument verbatim — never compress.**
  A paraphrase that upgrades certainty ("measured n=1 plus structural" →
  "proven"), drops a scope, or restates a two-path count as one path is the
  master manufacturing false belief with the master's authority; it travels
  into charters and becomes an inverted constraint. When a child corrects
  you by measurement, the ledger records it as YOUR error, attributed,
  beside the work — that is what teaches the next reader to distrust the
  right things. (One compressed relay told a chip the wrong assertions were
  load-bearing; acting on it would have dropped the only real pin.)
- **Prove every child↔master channel before real traffic rides it, and
  treat post-interruption silence as undelivered, not unwritten.** Demand a
  one-line test ACK at spawn; require verdicts and declarations duplicated
  in the child's FINAL OUTPUT (the transcript is the artifact — the master
  can always read it via session events; the relay is a convenience); after
  any master interruption, re-send everything unconfirmed and READ the
  children instead of waiting. The reply channel can degrade ONE-WAY — child
  sends succeed-looking and never arrive while master sends still deliver —
  and children cannot address a top-level session with the subagent
  SendMessage tool at all. (Two builders answered fully into a dead leg;
  their declarations were recovered from transcripts, not the channel.)
- **The master is mortal: after any interruption or machine sleep, assume
  every watcher is dead and every pending wakeup is stale.** Verify and
  rebuild the rig before trusting quiet — dead monitors read exactly like
  a calm fleet. A wakeup that fires after a sleep gap describes a dead
  world: re-verify everything before executing any step of it. And every
  watcher line must carry a timestamp — an untimestamped transition log
  cannot answer an incident's only question, when the window started and
  ended. (Both happened: two full watcher rebuilds, and a wakeup that
  arrived ten hours late prescribing work finished the previous night.)
- **Parallel open PRs sharing surfaces run the seam protocol.** Overlap
  declared in BOTH PR bodies; whoever lands second re-verifies the seam IN
  that PR; a reviewer can discharge it early by scratch-composing both tips
  with main (a clean merge is not a composable merge); and test-file import
  surfaces count — one PR importing another's fixtures is invisible to
  file-overlap checks. (Five instances in one campaign; the founding one
  ejected two PRs from the queue with a TypeError neither had alone.)
- **Pre-agree the flake instrument before any retry.** When a required check
  fails on plausibly-flaky grounds, fix the stop-signature FIRST: same test +
  same assertion = recurrence (hold for the fix, no third roll); any
  *different* failure = stop immediately as new information. Deciding after
  the second failure is deciding under sunk cost. (Governed three evictions
  cleanly; also: the flake's victim identity may carry no information — a
  marginal budget ejects whoever is unlucky.)
- **Spawned sessions inherit nothing — every chip/spawn prompt carries the
  doctrine lines it needs**, minimally: escalate to the master, never
  AskUserQuestion; PR unpressed, words via the master; verify the brief.
  (A chip session interrogated the owner directly because its prompt didn't
  say not to; the fleet's rules live in transcripts a spawned session never
  reads.)
- **Name which artifact, in every report and ruling.** A bare "merged" is
  ambiguous the moment a stack has an internal merge and an external one; a
  bare "green" conflates a PR's checks with its queue group's. Individually
  true statements combine into a false picture — in prose exactly as in
  diffs. (One "already landed" nearly triggered action on a branch merge
  read as a main merge.)
- **A builder collision converts to strength by role-swap, not adjudication.**
  When two sessions build the same thing, make one's work the artifact and
  the other its adversarial reviewer — provenance matters less than the
  property, and the duplicate's tests become review claims. (A duplicated
  module's parked twin supplied the weld tests that caught a
  production-live kill-switch regression; two-layer coverage neither
  builder had alone.)
- **Concurrent reviewers of one tip get separate worktrees.** A mutating
  refuter and a read-only reviewer pointed at one checkout self-contaminate:
  the reader's evidence silently includes the mutations. Fresh detached
  worktree per reviewer, created from an EXPLICIT SHA — `FETCH_HEAD` is
  per-worktree state, and a worktree-add from a FETCH_HEAD read elsewhere
  checks out the wrong commit. (Both happened in one dispatch round; the
  contamination was caught before the first mutation, the wrong-commit
  worktree only by reading the add output.)
- **Relay every review verdict with its instrument named** — "static AST
  read, no runtime" vs "executed the suite + probes" changes what a finding
  IS. Static findings are hypotheses the child reproduces-or-refutes with
  the line; a healthy gauntlet has children refuting some. When two
  instruments disagree, the vacuity probe outranks the static read. (A
  static "held" on a floor test lost to a probe showing it asserted
  `[]==[]`; full protocol: references/review-gauntlet.md.)
- **A channel proof is round-trip, not send-success.** Master→child and
  child→master address spaces can be ASYMMETRIC (session ids vs uds socket
  names), and app restarts stale every socket: a successor's introduction
  can deliver while its reply address resolves to nothing on the child's
  side. Demand an ACK that arrives back; a child that refuses to guess
  which session is its master and holds instead is the doctrine working.
  (Exactly this happened at a master handoff; the child's refusal prevented
  campaign state landing in the wrong session.)

## Weather — when the platform itself is failing

Infra-wide failure mimics code failure, and misreading it burns hours on
innocent PRs. The tells and the drill, in order:

- **Before reading any queue ejection as yours, check whether the queue is
  ejecting EVERYONE.** Other authors' PRs ejected in the same window is the
  decisive, cheap tell — look for it first, not after your own forensics.
  (It sat in plain sight for forty minutes once while two clean PRs were
  re-diagnosed.)
- **The two-command oracle before any re-press after an unexplained
  ejection:** `curl githubstatus.com/api/v2/summary.json` and the failed
  group run's JOB-LEVEL timings. All jobs cancelled simultaneously with
  impossible durations — a fifteen-second job "running" fifteen minutes —
  is the platform holding places, not tests failing; no code investigation
  is warranted.
- **During an outage, stop feeding the queue.** Entries get eaten; owner
  words STAND and are not re-asked; park the presses, watch the status feed
  for the recovery transition, and let the queue prove itself on someone
  else's PR before re-pressing yours.
- **A deploy-red whose only failed job is the verify/witness step is
  adjudicated against the CURRENT live observation** before anyone treats
  the release as un-deployed — the first N jobs are the deploy; verify is a
  witness, and a witness can time out. Then read the platform's own boot
  log before any app-level theory: one grep of the App Service log stream
  names a container-start failure (`VNETFailure`) that a 900-second poll
  budget can only report as darkness.

## Optional capability — Codex as adversarial verifier

When the codex plugin is available, the master may adopt Codex as a
second-model skeptic — pre-button review of high-stakes deploy-bearing PRs,
stuck-state second diagnosis, and rival censuses on destructive scopes. It
buys uncorrelated skepticism, never capacity: Codex never implements, never
writes to a branch, and its findings are claims to verify like any child's.
Three triggers only, each invocation ledgered, earn-or-drop judged at
consolidation. Full doctrine: references/codex-adversarial-verification.md.

## Optional capability — Codex execution track (owner-toggled)

Separately from verification, the owner may enable **Codex-run children** —
full executor/reviewer sessions on Codex, governed by the Claude master — via
`/master-codex` (modes: `off` default / `codex` all-executors / `hybrid`
per-task routing; state in `~/.claude/master-session-codex.mode`, read at
session start). While `off`, the verification-only rule above stands
unchanged. When enabled, that one restriction lifts by owner configuration;
everything else binds unchanged: master never implements, one branch one
writer, fresh single-use worktree per Codex child, words never bank, PRs
unpressed, and every Codex job is ledgered and polled on the sweep tick —
Codex children are invisible to the session census, so an unledgered job is a
lost child. In `codex` mode a standing Claude refuter child is mandatory (the
cross-model reviewer). Launch/supervise/communicate recipes, review-pairing
rule, and the hybrid delegation heuristic:
references/codex-execution-track.md.

## Red flags — stop and re-read the doctrine

- "The owner clearly meant it" / "I'll just merge it for the child" — laundering.
- "It's mechanical, I'll update their branch" — one branch, one writer.
- "The child said it's done" — verify before relaying.
- "I'll record it now, the run will pass" — evidence precedes records.
- "My board says X" (older than minutes, near a merge) — your view is a cache.
- Spawning wave two before wave one's shape is known — cold decomposition.
- Writing the closing record from your own ledger, or spot-checking a few
  facts and marking the rest UNVERIFIED — dispatch the capstone audit.
- Sequencing session archives for after the owner leaves — archive prompts
  need them present; cleanup is what runs unattended, not archives.
- Trusting session-list idleness for "is this worktree live" — `ps`/`lsof`
  is the gate.
- Re-pressing after an unexplained ejection without the everyone-check and
  the status oracle — you may be feeding a queue the platform is eating.
- Trusting quiet after an interruption or sleep — dead watchers and a calm
  fleet look identical; verify the rig first.
- Relaying a child's claim in your own words — paraphrase upgrades
  certainty; carry scope and instrument verbatim.
- Writing "what remains" into a charter from records — that is a borrowed
  census; charter the measurement, not the answer.

## References

- references/templates.md — charter message, chip brief, standing-authorization
  lines, closing-report shape.
- references/monitoring.md — CI monitor, deploy watchers, sweep tick, and the
  silence-is-not-success filter rules.
- references/consolidation.md — the end-of-campaign phase: the ledger, harvest
  sequencing, the capstone audit, memory discipline, the closing report, and
  cleanup-session rules.
- references/codex-adversarial-verification.md — the optional Codex
  second-model verifier: adoption test, the three triggers, invocation and
  treatment rules, and the anti-ceremony ledger.
- references/codex-execution-track.md — the optional owner-toggled Codex
  execution track: mode semantics, launch/supervise/communicate mechanics,
  the review-pairing rule, and the hybrid delegation heuristic.
- references/review-gauntlet.md — the delta-round convergence protocol for
  high-stakes PRs: declaration → full pass (reviewer + refuter, separate
  worktrees) → instrument-labelled verdicts → adjudication → one-push delta
  rounds until clean, with the refuter mandate, the live-smoke stage,
  probe-your-own-fixes, and the master-side instruments each earned by a
  real failure.

## Companion commands (installed at ~/.claude/commands/)

- `/master-handoff` — the incumbent master refreshes live state, settles the
  handoff doc, and emits a paste-ready successor seed prompt (all warnings
  inside the fence), then holds the interregnum until takeover confirms.
- `/master-check` — full fleet sweep: census, every child's wait verified
  intentional (unintentional waits fixed before reporting), live PR/queue/
  deploy refetch, then a fixed-shape report ending in an explicit
  "Needed from you" list — or a plain "nothing is blocked on you".
- `/master-codex [off|codex|hybrid|status|model <name>|effort <level>]` —
  owner toggle for the Codex execution track plus dispatch defaults; writes
  the mode file (line 1 = mode; optional `model=`/`effort=` lines preserved
  across mode changes), confirms by read-back, and announces what changes at
  the next dispatch (never retroactively).
- `/master-learn` — end-of-campaign learning extraction: mine the ledger and
  transcript for generalizable lessons (errors first — the master's own
  included), separate campaign-specific from skill-worthy, fold the
  skill-worthy into this skill's rules/references with the concrete incident
  attached, and report what was learned vs. what was already covered.
