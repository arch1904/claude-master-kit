---
description: Full fleet census — every session's state, every wait verified intentional, and an explicit "needed from you" list
---

You are the MASTER SESSION. Run the full sweep NOW — refetch everything, trust nothing from
your board older than minutes — and report in the fixed shape below.

## Sweep

1. **Census**: list all sessions; identify the campaign's children. For any session that is
   surprising, quiet-too-long, or inconsistent with your board, read its transcript tail —
   transcript growth is the tell for stalled-vs-working; do not interrupt a session mid-tool.
2. **Verify every wait is intentional**: for EACH child, state what it is waiting on and
   check that the wait is an instruction of record that STILL applies. A wait based on a
   superseded procedure, a missed signal, or a hold you forgot to lift is a defect — FIX IT
   NOW (send the unblocking message) and report it as "found and cleared", not as status.
   **A child waiting on a sibling's MERGE for a symbol that exists on the sibling's branch is
   a defect too** (landing strategy R4): re-charter it to build against the integration branch
   or the sibling's branch merged locally, and report it as cleared.
3. **Refetch live state**: open PRs with check states at their SHA-pinned heads, merge-queue
   entries, in-flight deploys followed to their verify step, and the production/readiness
   surface if the campaign has one. **Count cleared-but-unarmed PRs**: if more than one PR has a
   review clear and no queue entry, that is presses being serialized — arm them as a batch
   under the class-level words, or say which word is missing (landing strategy R2).
4. **Sweep your own monitors**: confirm each watcher is still running and still pointed at
   something that exists; a monitor watching a finished thing is noise, a dead monitor is a
   blind spot.

## Report shape

- A table: **session | state | waiting on | verdict** (✅ intentional / ⚠️ cleared just now /
  🔴 needs attention).
- Then **"Needed from you"** as an explicit list — each item names the exact word, line, or
  action and where it goes (which session, which button, which console). If the list is
  empty, say plainly: *"Nothing is blocked on you"* — and name the next scheduled ping so
  the owner knows when they'll next be needed.
- Escalations last, only if real: red required checks, a genuinely stalled child, production
  sideways. No ceremony when there is nothing to escalate.
