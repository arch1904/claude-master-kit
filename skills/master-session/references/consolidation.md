# Master Session — the consolidation phase

Consolidation is where the master stops being a router and becomes
**accountable for the campaign's knowledge**. Every mechanic below exists
because a summary somewhere was wrong and only a primary source caught it.
Begin when the last worker PR is in sight, not after everything is quiet —
several steps need the owner present.

## 1. The ledger — claims, not truth

Throughout the campaign, keep a cross-session fact ledger: learnings,
corrections, salvage items, open questions. Every entry carries an evidence
pointer (PR body, commit SHA, run id, doc path) — the pointer is the point:
relays compress, and your ledger is downstream of children's self-reports.
Treat it as a map of where to look, never as what is true. (A capstone audit
once falsified six of a master's ledger facts against primary sources.)

## 2. Harvest before archive — sequenced while the owner is present

No session archives until its closing report has landed or its transcript has
been read for unharvested knowledge. Ask idle sessions to send remaining
findings; triage each item into repo docs vs memory vs chips. **Archive
prompts require the owner to confirm — sequence archives while they are
available, or the pipeline stalls.** If the owner is leaving, archives come
first, cleanup can run unattended after.

## 3. The capstone audit — verify, don't transcribe

Do not write the campaign's record from your own ledger. Dispatch a dedicated
documentation-audit agent (high-capability model, isolated worktree) with:

- the **ledger as WHERE TO LOOK**, the **repo as WHAT IS TRUE**;
- a mandate to fix only *measured* staleness — every doc edit backed by a
  check it ran, not a claim it read;
- the empirical checks the campaign left open (e.g. timestamps proving a
  mechanism was actually exercised, deploy-run tallies);
- salvage adjudication: read each candidate artifact **fully** before
  deciding — commit what survives scrutiny, reject what regresses against a
  better copy already landed, and say which;
- found-not-fixed items reported for chips, never silently repaired beyond
  mandate;
- merge under a pre-given owner word (get it before dispatch).

Spot-checking a few "load-bearing" facts yourself and labelling the rest
UNVERIFIED is not a substitute — it ships the exact staleness the audit
exists to catch.

## 4. Memory discipline

Lessons are banked the moment they're learned, as one-fact memory files with
cross-links, **by whichever session learned them** — not batch-written by the
master at the end. The master's closing duties are narrower: catch stale
frontmatter *descriptions* (what recall actually reads — a correct body under
a stale description recalls a false state) and index rot, and verify each
completed arc's entries say shipped when shipped.

## 5. The closing report

A repo document, not a constellation of PR bodies. Sequence it deliberately
**after the last worker PR merges**, so it describes the true end state and
its checks run once. It indexes the memory slugs rather than duplicating
their content, links per-PR detail to the PR bodies, and states plainly that
where it and the repo disagree, the repo wins.

## 6. Cleanup is a first-class session, not a chore

Deleting branches/worktrees/databases gets its own child session with its own
discipline:

- **Verify-then-delete with per-item accounting** — one line of evidence per
  deleted item (ancestry check, patch-equivalence result), never a bulk rm.
- **Hard do-not-touch lists, and the guard must be self-testing**: before any
  destructive pass, assert the guard actually excludes the expected count of
  protected items. (A shell guard once silently no-op'd and deleted a
  protected branch.)
- **Squash-merged branches need patch-equivalence**, not ancestry — ancestry
  says unmerged for content that fully landed. Branches that fail
  equivalence are kept and escalated, not deleted.
- **Uncommitted work found in a worktree escalates to the owner** — never
  bulldozed, never auto-committed.
- **`ps`/`lsof` is the hard gate for "is this worktree live"** — session-list
  idleness lies; a process writing in a worktree can outlive its session's
  apparent state.

## 7. End-state handoff

Every open item is named with an owner and an evidence pointer. Future work
is filed as self-contained chips that survive the master's death. Finish with
the consolidate skill's handoff doc so a successor master rehydrates from
artifacts, not from anyone's memory of the campaign.
