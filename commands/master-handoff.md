---
description: Generate a comprehensive seed prompt for a successor master session to take over this campaign
---

You are the incumbent MASTER SESSION and the owner has asked for a handoff seed — a successor
master will take over (model switch, context ceiling, or session hygiene; nothing is wrong).
Produce a seed prompt the successor can be started with, cold, and lose nothing. Follow these
steps in order; do not skip the refresh.

## 1. Refresh before writing — the seed describes LIVE state, never your cache

- Census every session (list sessions; transcript-tail anything surprising or quiet-too-long).
- Refetch open PRs with SHA-pinned check states, merge-queue entries, and any in-flight
  deploy/CI runs.
- Read the live production/readiness surface if the campaign has one.
- Enumerate YOUR monitors and background watchers — these DIE with you and are the successor's
  first rebuild.

## 2. Settle the record

The seed points at the handoff doc; it does not replace it. If the campaign's consolidation
doc exists, update its perishable sections (children, PRs, monitors, open decisions,
environment facts) to match step 1; if the delta is large or none exists, invoke the
`consolidate` skill and write it properly. Every claim in the doc the successor must be able
to re-verify — include the verification recipe.

## 3. Emit the seed — ONE fenced block, paste-ready, self-contained

All warnings and stop-lines go INSIDE the fence (a banner above a fence does not travel with
a paste). Required sections, in this order:

1. **Identity + charter** — "You are the MASTER SESSION for <campaign>, taking over from a
   predecessor (reason — nothing is wrong). Invoke the master-session skill and hold its
   doctrine for the whole session."
2. **FIRST** — read <handoff doc path> IN FULL, then run its verification list before acting
   on any claim. "Your view is a cache; children and git are ground truth."
3. **MISSION** — verbatim, unchanged from the owner's charter.
4. **IMMEDIATE STATE** — active children (session ids, one-line state, what each is waiting
   on and whether that wait is an instruction of record); open PRs + queue positions;
   in-flight deploys; the monitors that died with the predecessor, listed as REBUILD FIRST.
5. **INTRODUCE YOURSELF** — message every active child by name/worktree so routing moves to
   the successor; until then children route to a dead session.
6. **STANDING AUTHORIZATIONS** — exactly which owner words CARRY (first-hand conditional
   class), quoted verbatim with timestamps; which are CONSUMED; and the classes that never
   bank (migrations, destructive ops, live external calls, flag changes, write-surface
   widenings, mode-key/deploy-window changes, anything security-relevant — always the owner's
   fresh word, in the executing session).
7. **HARD RULES** — the campaign's protocol lines, verbatim (govern-never-implement; children
   never AskUserQuestion; tests+CI never sufficient; SHA-pinned merge gates; one branch one
   writer; relay ≠ authorization).
8. **OPEN OWNER DECISIONS** — the batch, each with the master's recommendation and the exact
   line the owner can speak.
9. **CADENCE + CARRIED TRAPS** — notification thresholds, and the specific traps most likely
   to bite in the successor's first hour (name them concretely; a trap list that names
   nothing prevents nothing).

## 4. State the interregnum terms

After the fence: what YOU still own until the successor confirms takeover (your monitors keep
running; you press no further merges; you relay nothing new), and that the successor's
introduction message to each child supersedes your routing. Do NOT archive yourself — the
owner decides when the incumbent stops.
