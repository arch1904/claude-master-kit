# Master Session — Codex execution track (optional, owner-toggled)

An optional capability: **Codex-run children** — executors and reviewers — governed by a
Claude master, alongside or instead of Claude (CCD) children. It exists for owners who want
Codex capacity or cross-model diversity on implementation work, not only on verification.

**This mode is OFF by default and is enabled only by the owner via `/master-codex`.** While
off, the base doctrine stands unchanged, including
[codex-adversarial-verification.md](codex-adversarial-verification.md)'s rule that Codex
never implements. When the owner sets mode `codex` or `hybrid`, that single restriction is
lifted **by owner configuration**; every other rule below still binds. The mode is read from
`~/.claude/master-session-codex.mode`; absent file = `off`. The master reads it at session
start and whenever `/master-codex` fires; it never edits the file except through that
command. File format — line 1 is the mode word (`off` | `codex` | `hybrid`); optional
following lines are owner-set dispatch defaults, `model=<name>` and `effort=<level>`
(readers that take only the first word stay correct):

```
hybrid
model=gpt-5.2-codex
effort=high
```

## What stays true in every mode — no exceptions

- **The master still governs and never implements.** A Codex child implementing is not the
  master implementing; the master launching Codex with a brief is dispatch, not typing.
- **One branch, one writer.** Each Codex child gets its own fresh worktree and branch; the
  master and other children never touch it.
- **Words never bank.** Merges, deploys, flags, migrations, destructive ops — owner's fresh
  word, same as for Claude children. Codex output is never authorization.
- **PRs open unpressed.** The brief says so, exactly as for Claude children.
- **Briefs are hypotheses; evidence precedes records; harvest before archive** (for Codex:
  read the job's `result` before cancelling or cleaning its worktree).

## Mechanics (verified against the companion runtime, 2026-08-02/03)

The plugin's `codex-companion.mjs` is the whole interface. Render its `--help` before first
use each session — flags are evidence, not memory:

| Need | Command shape |
| --- | --- |
| Launch an executor chip | `task --background --write [--model M] [--effort E] "<brief>"` run FROM the child's fresh worktree (cwd = the workspace) |
| Check on it | `status [job-id]` (poll via a Monitor; also `status --all`) |
| Read its report | `result [job-id]` |
| Communicate / steer mid-task | `task --resume-last "<message>"` from the same worktree (continues the thread) |
| Reviewer chair | `adversarial-review --base <ref> --scope branch "<skeptic protocol>"` |
| Hand over context | `transfer --source <claude-jsonl>` |
| Stop | `cancel [job-id]` |

**Traps (all measured, not hypothetical):**
- **Worktree paths are single-use.** A removed-and-recreated path fails with
  `failed to load configuration`. Mint a fresh path per child and per review.
- **Codex children are invisible to the CCD fabric.** No session id, no `list_sessions`
  census, no transcript tail, no chips UI. The master MUST keep a ledger line per Codex
  child (job-id, worktree, branch, brief summary, last-checked) and poll `status` on the
  sweep tick — the idle-children rule applies with `status`/`result` standing in for
  tail-reads. An unledgered Codex job is a lost child.
- **No AskUserQuestion equivalent.** The brief must carry the same escalation rule as a
  chip prompt: never guess on an owner decision; write the question into the final result
  and stop.
- **Same secrets rule.** Code, diffs, logs only — never credentials, tokens, or DSNs in a
  Codex prompt.

## Launch recipe (executor chip)

1. Fresh worktree: `git worktree add --detach <new-unique-path> origin/main` then create the
   child's branch there.
2. Adapt the standard chip brief (self-contained; verify-the-brief; gates; unpressed PR;
   escalation-into-result; no migrations unless chartered; commit rules). Add Codex-specific
   lines: which absolute venv to use, that it must push its branch and open the PR itself
   with `gh` (unpressed), and that follow-up instructions arrive via resumed turns.
3. `task --background --write "<brief>"` from that worktree; ledger the job-id.
4. Arm a Monitor polling `status <job-id>` (60–120s; alert on state change and on completion
   — silence is not success; a monitor that only reports "done" misses a wedged job).
5. On completion: read `result` IN FULL, verify claims against git/CI exactly as for a
   Claude child, then route to review.

## Model & effort selection (per dispatch, owner-overridable)

Resolution order for every Codex dispatch, most specific wins:
1. **Per-dispatch choice** by the master, from the table below — recorded in the ledger
   line with the reason.
2. **Owner defaults** from the mode file (`model=` / `effort=` lines, set via
   `/master-codex model <name>` / `/master-codex effort <level>`).
3. **CLI defaults** — omit the flags; Codex uses `~/.codex/config.toml`'s configured model.

**Never hardcode model names in briefs or docs** — model ids churn. The owner names models;
the master verifies a name is accepted by rendering `task --help` / a dry probe before a
big fan-out, and reports rejection back instead of guessing a substitute.

**Owner-ratified routing (Archit, 2026-08-03; researched against community/vendor guidance
for the GPT-5.6 tier — sol=biggest, terra=middle, luna=fastest).** The model NAMES below are
owner-configured data current as of that date, not doctrine — the owner re-speaks them when
the lineup churns, and every name is verified against the companion's live help / a dry
probe at dispatch time before a fan-out. The routing LOGIC is the doctrine:

| Task class | Model | Effort |
| --- | --- | --- |
| PURE planning / design / scoping (blueprints, specs, decompositions) | `gpt-5.6-sol` | `medium`, escalate to `high` for architecture-grade or high-blast-radius plans |
| PURE execution (implement from a finished blueprint, crisp-DONE diffs, test gen, migrations-with-strong-checks) | `gpt-5.6-luna` | top available level (owner's word: "max" — resolve to the highest the live help offers); master MAY drop trivial mechanical diffs to `medium`, ledgered |
| Adversarial reviews, refutation, stuck-state second diagnosis | `gpt-5.6-sol` | `high`+ |
| MIXED plan+execute work | **split the chip**: plan on sol-medium, then execute the blueprint on luna-max (the fleet's existing blueprint→executor pattern). `gpt-5.6-terra` only if a blind eval shows it beating the split — community consensus calls the middle tier dominated, not a default |
| Second-implementation comparisons (diversity is the point) | deliberately a DIFFERENT model than any prior attempt | match the sibling's tier |

**Escalation diagnostic (community rule, adopted):** if the model understood the task but
stopped short on planning/checking/follow-through → raise EFFORT one step; if it
misunderstood the tradeoff or applied wrong judgment → raise the MODEL tier. Raise effort
before tier while still on the price/intelligence frontier.

Effort level NAMES churn across the tier ("light/medium/high/extra-high/ultra" vs
`none|minimal|low|medium|high|xhigh` on older surfaces) — record the owner's word verbatim,
resolve against the live `--help` at dispatch. Bias effort UP on verification and DOWN on
mechanical execution: a cheap executor with an expensive refuter catches more per token
than the reverse. The ledger doubles as the 20-50-task blind-eval data the guides recommend
before locking any routing permanently — revisit at consolidation.

## Review pairing — protect the decorrelation

The two-model skepticism is the most valuable property this fleet has. Pair by this rule:

| Executor | Required reviewer(s) |
| --- | --- |
| Codex child | **Claude refuter child** (mutation mandate) — Codex reviewing Codex shares priors; the Claude master's own tree-verification is the floor, a Claude refuter is the standard |
| Claude child | Codex `adversarial-review` (the base doctrine's trigger 1) + Claude refuter as today |

In `codex` mode (all executors on Codex), a standing Claude refuter child is therefore not
optional overhead — it is the second model. Do not let "all Codex" quietly become
"no cross-model review".

## Hybrid mode — delegation heuristic

In `hybrid`, route per task at dispatch time; record the routing choice and reason in the
chip ledger (one line — it is the data that tunes this table):

| Route to Codex | Route to Claude (CCD chip) |
| --- | --- |
| Well-specified mechanical execution from a finished blueprint or fixed diff plan | Open-ended scoping, census, or design work where the brief will be corrected |
| Single-file or narrow-scope changes with a crisp DONE | Multi-file arcs needing mid-flight master rulings |
| Second-implementation comparisons (build the same thing twice, diff the approaches) | Anything needing CCD features: owner-clickable chips, session messaging, transcript tails |
| Token/capacity relief when Claude children are saturated | Safety-adjacent judgment calls, doctrine-heavy work, anything touching owner-word workflows |
| — | Owner-attended sittings and their prep (always) |

When unsure, Claude — the CCD fabric's observability is worth more than the capacity until
the ledger shows otherwise.

## Anti-ceremony — same as the verification track

Every Codex child gets a ledger line (dispatched, findings/deliverable, verification
outcome, wall-clock). At consolidation the ledger answers whether the execution track earned
its place; the mode defaults back to `off` in the next campaign unless it did.
