# Landing strategy — integration branches, batched presses, the local gate

The doctrine here was earned on 2026-09-01 (SAIL score-push campaign, account 3), measured from
GitHub rather than remembered. Read the numbers before the rules; the rules are the numbers'
consequences.

## The measurement that motivates it

One ten-hour window, fifteen PRs opened, eleven merged, every PR small (median ~150 lines):

| quantity | value |
|---|---|
| CI workflow runs | 57 — **2,029 runner-minutes** |
| runs cancelled because a second push landed mid-run | 14 (**18%** of minutes) |
| full-suite runs per merged PR | **3** (PR check → merge-group speculative run → post-merge push run) plus a deploy |
| PR open → merge, mean | **116 min** (73–186) |
| deploys | 12 (one per merge) |
| semantic conflicts between individually-green PRs, found only in the queue | 3 |
| children measured idle waiting on a sibling's MERGE for a symbol already on the sibling's branch | four children, 1.5–3 h each |
| gauntlet reviewer queue depth at peak | 4 |

Two conclusions the table forces:

1. **Pipeline cost is per-PR, not per-line.** A 60-line rename paid the same three runs and
   deploy as a 2,500-line seam integration. Fewer landings is the only lever on that cost that
   does not touch infrastructure.
2. **The fleet serialized what the queue can parallelize.** The merge queue in play allowed five
   speculative groups to build at once and five PRs to merge in one push (one deploy). Arming one
   PR at a time — each gated on a review verdict and a per-PR owner word — kept the queue at one
   or two entries and produced twelve deploys for eleven PRs.

And the fact that makes the remedy free: in the repository in question, CI triggered only on
pull requests **into `main`** and pushes **to `main`**; the deploy only on `main`; the only
protected branch was `main`. A non-`main` integration branch cost nothing — no CI, no deploy, no
protection — so all verification of it was local by construction. **Check the equivalent facts
for your repository before adopting this** (`on:` blocks of the workflows; ruleset targets).

## The rules

### R1 — Land per wave, not per PR: the campaign integration branch

`campaign/<wave>` cut from `main`. Children push their commits to it (or open PRs into it — a
review surface, not a gate; both are free of CI). One PR from the branch to `main` per wave, or
per coherent feature set when a wave is large.

Six sub-rules, each tied to a defect already paid for:

| rule | the defect it prevents |
|---|---|
| **No migrations on the branch, ever.** A migration lands via its own tiny PR straight to `main`, first; the branch rebases onto it. | The only change that can hurt production from a branch is a migration (the repo's own retired feature-branch precedent said exactly this); migration guards assume `main`-only. |
| **Rebase onto `main` at every `main` movement, and always before the landing PR.** One named owner of the rebase; the local gate (R3) runs after each. | Stale-base conflicts — a PR rebased one merge too early conflicted with the PR that merged an hour later, in the queue, after review. On a branch that follows `main` continuously the conflict surfaces once, locally, at rebase time. |
| **Every push to the branch is preceded by the local gate (R3) on `branch + your commits`.** | Cancelled runs (14 of 57) and reds from repo-root guards outside the child's scoped run. |
| **Review per commit as it lands on the branch**, not per PR at the end; the landing PR gets a delta re-read against pre-committed criteria. | The four-deep reviewer queue — review spreads across the wave instead of bunching. |
| **Branch lifetime ≤ one wave. Land, delete, cut the next.** | Truth living on a branch the owner cannot see; a landing PR nobody can read. |
| **The landing PR body is assembled from the per-commit review records as commits land.** | A PR body two hours behind its own branch at sitting time. |

Cost model: the measured day's eleven merges become roughly three landings — ≈4.5 h of
pipeline in the background instead of ≈22 h — and children never wait on it.

### R2 — Batch the presses; collect class-level words at kickoff

Arm cleared PRs **in groups**, never singly. With `max_entries_to_build ≥ 5` the queue builds
the groups in parallel; with `max_entries_to_merge ≥ 5` they land in ONE push → one deploy.
Wall-clock for five PRs ≈ one group run + one deploy instead of five cycles.

This needs the owner's words granted **by class, at kickoff** (see the authorization doctrine):
e.g. "hygiene PRs — sweeps, renames, comment-truth — cleared by a gauntlet: master presses without
asking; anything touching prompts, migrations, or authorization: per-PR word." Per-PR words on
hygiene PRs were the single largest source of cleared-but-unarmed time when the owner was in a
meeting.

`grouping_strategy: HEADGREEN` (only the head group's checks gate the batch) removes the
eject-and-rebuild cost of one slow or flaky group. It is a repository *setting*, not
infrastructure; adopt only alongside batching, with the owner's eyes on the trade-off that
per-PR attribution of a red weakens (your gauntlet is what compensates).

### R3 — The local CI-parity gate, before every push

One command that runs exactly CI's steps in CI's order on a **scratch worktree at `main` merged
with the change** (the merge-ref simulation), prints one verdict line carrying the tree it graded,
and refuses on the "gates unavailable" banner. In SAIL it is `./dev ci` (`--fast` for the
sub-suite). Requirements for any implementation:

- **Repo-wide**, never scoped by directory — "scope by directory, miss by repo" is how a green
  scoped run and a red CI coexisted twice in one day.
- Keyless by construction (a scratch worktree has no `.env`; strip `*_API_KEY` from the env).
- A verdict is an **exit status**, not prose; the line carries mode, tree, main, head.
- It is not "more waiting": it runs on the child's clock before the push and turns a
  red-in-queue (~80 min plus a rebase and a re-review) into a red-on-desk (0 pipeline minutes).

### R4 — Dependencies resolve on the branch, never on `main`

A child needing a sibling's symbol builds against the integration branch (or the sibling's
branch merged locally) and pushes when its own gate is green. It does not wait for the sibling to
MERGE. On the master's board, **"waiting on #NNN's merge" is a defect to clear**, in the same
class as an idle child — `/master-check` should report it as such.

### R5 — Reviewer capacity and shape

Two standing readers (a second reader halved the queue the day it was added). Pre-committed
acceptance criteria for every delta re-read. Runnable mutation harnesses ship with the PR so the
reviewer reruns anchors instead of reconstructing a table from prose.

## What not to trade away

- **The gauntlet's rigour.** On the measured day it caught a silently-misreporting join, a false
  body claim with three writers behind it, an inert mutant credited as a kill, two stale mutation
  counts, and a four-way instruction misalignment. Every one would have shipped. That time is the
  cheapest the fleet spends.
- **Migrations via `main` only.** Non-negotiable under R1.
- **The full local suite because "the change is small."** Both reds on the measured day were
  small changes caught by tests outside the change's directory.

## Adoption sequence (no big-bang)

1. Kickoff: collect class-level press words; batch-arm whatever is already cleared.
2. First wave: build the local gate if the repo lacks one; make it the pre-push rule.
3. Second wave: first `campaign/<wave>` branch under R1's six sub-rules; one landing PR;
   retrospective against the table above.
4. Then decide HEADGREEN with batching data in hand.

## Alternatives considered

- **Stacked PRs to `main`**: keeps one pipeline per PR; the queue does not understand stacks
  (a merged base closes dependents; a force-pushed base rewrites their diffs).
- **Fewer, bigger PRs without a shared branch**: pipeline savings, but children still wait on
  each other.
- **Bypassing the queue for hygiene**: no bypass exists by owner decision, and none is wanted.
- **Faster runners / sharding**: infrastructure — the first thing to consider if that constraint
  ever lifts.
