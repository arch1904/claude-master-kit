# Master Session — monitoring rig

Set this up in the first minutes of the session. The master's authority rests
on knowing state before anyone asks; a master that polls on request is a
secretary.

## Principles

- **Event-driven first, heartbeat as fallback.** Monitors wake you on
  conclusions; a periodic sweep (10–30 min) catches what no event covers
  (session states, stalls). Never poll in a foreground loop.
- **Silence is not success.** Every watcher's filter must match failure
  signatures, not just the happy path. A monitor that only greps for
  "success" reports a crashloop as "still running".
- **Watch every deploy to its verify step.** A merge is not a deploy and a
  deploy is not a verify. One background watcher per production run.
- **Your view is a cache.** Before acting on any PR/branch state, refetch.
  Check ancestry (`git merge-base --is-ancestor SHA HEAD`), never trust
  "updated" labels or your memory of the board.
- **Read terminal states from the authoritative object; summary fields lie
  in both directions.** `autoMergeRequest` reads null for a PR sitting in
  the merge queue (four sessions independently mis-read it in one night);
  `gh pr checks` can report pending minutes after the run's jobs completed;
  near a queue landing, every snapshot is stale by the time it's read. Queue
  truth is GraphQL `mergeQueue.entries` + paired timeline events; check truth
  is the run's jobs. Verify a PR "left the open set" is a merge and not an
  eviction before reporting it as one.
- **A deploy-verify failure is triaged by its poll outcomes, not its verdict.**
  All-`unreachable` polls with every prior job green is the benign
  dark-window-outran-the-budget signature — read the live endpoint and the
  container/App state before treating it as an unshipped release; the release
  may already be serving. `mismatch` and `not_ready` point at different
  processes and are real. (One red verify landed on a healthy, fully-live
  release — a cold reader reaches for a rollback there, and rollback is the
  wrong move twice over.) Two refinements from a night of them: **a
  merge-queue BATCH lands as back-to-back pushes = back-to-back deploys**,
  so one verify budget can straddle two restart windows — expect the first
  run of a pair to red; and when the dark window itself needs explaining,
  **the platform boot log answers in one line what the poll budget cannot**
  (`az webapp log tail | grep -i failure` surfaced a `VNETFailure`
  container-start fault that 46 polls could only report as darkness).
- **Watchers are mortal and their logs must be self-dating.** After any
  master interruption or machine sleep, assume every watcher is dead —
  verify and rebuild before trusting quiet, because dead monitors read
  exactly like a calm fleet. Prepend `$(date -u)` to every emitted line: an
  untimestamped transition log once held the answer to an incident's
  timeline question and couldn't give it. A pending ScheduleWakeup that
  fires after a sleep gap is STALE — re-verify the world before executing
  any instruction it carries.
- **Platform weather beats PR forensics — check it first.** Before
  re-pressing after an unexplained queue ejection: (1) is the queue
  ejecting OTHER authors' PRs too? (2) `curl -s
  https://www.githubstatus.com/api/v2/summary.json` — components +
  incidents in one read. All jobs cancelled simultaneously with impossible
  durations (a 15-second job "running" 15 minutes) is the platform holding
  places, not tests failing. During a declared outage: stop pressing (the
  queue eats entries), park with owner words standing, watch for the
  recovery transition, and let the queue prove itself on someone else's PR
  first.

## CI monitor (all open PRs, event on every check conclusion + merge/close)

Persistent Monitor; emits one line per concluded check and per PR leaving the
open set. Initializes silently to avoid a first-poll flood; skips update on
API failure so an outage doesn't read as "everything merged":

```bash
first=1; prev=""; prevopen=""
while true; do
  json=$(gh pr list --state open --json number,statusCheckRollup 2>/dev/null) || { sleep 60; continue; }
  cur=$(echo "$json" | jq -r '.[] | .number as $n | .statusCheckRollup[]? \
    | select(.status=="COMPLETED") | "PR #\($n) \(.name): \(.conclusion)"' | sort)
  curopen=$(echo "$json" | jq -r '.[].number' | sort)
  if [ "$first" = 1 ]; then first=0; else
    comm -13 <(printf '%s\n' "$prev") <(printf '%s\n' "$cur")
    comm -23 <(printf '%s\n' "$prevopen") <(printf '%s\n' "$curopen") \
      | sed 's/^/merged-or-closed: PR #/'
  fi
  prev="$cur"; prevopen="$curopen"
  sleep 60
done
```

## Deploy watcher (one per production run, background Bash)

```bash
gh run watch RUN_ID --exit-status >/dev/null 2>&1; rc=$?
echo "DEPLOY-RESULT rc=$rc $(gh run view RUN_ID --json conclusion,jobs \
  --jq '{c:.conclusion, jobs:[.jobs[] | "\(.name):\(.conclusion // .status)"]}')"
```

Report per-job conclusions, not just the run verdict — "which job failed" is
the actionable fact.

## Sweep tick (heartbeat)

A persistent Monitor emitting a line every 10–30 min (`while true; do sleep
900; echo SWEEP-TICK; done`), or the scheduler if available. On each tick:
list sessions, compare against your board, read the transcript tail of
anything surprising. Respond to quiet ticks with one line, not a report.

## Escalation rules

- Check FAILURE on any PR → pull the failed job's log signature *before*
  anyone reruns; two identical failures on unrelated code = systemic, stop
  the queue.
- A session idle at a decision point ≠ stalled; a session mid-tool for a
  long time ≠ stalled. Transcript growth is the tell. Nudge with a
  checkpoint request, don't interrupt.
- Notify the owner (push notification) only for events that change what they
  would do next: a red required check, a session blocked on their word, a
  production verify failure. Landings and green checks are board material,
  not pings.
