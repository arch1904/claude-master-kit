# Master Session — Codex adversarial verification

An optional capability for any campaign or project: **Codex, used as an
adversarial verifier** through the codex plugin (`codex:codex-rescue` agent /
`codex:rescue` skill). Adopt it to buy **uncorrelated skepticism, never
capacity**. Claude reviewing Claude shares priors and therefore blind spots;
Codex is a second query engine whose failure modes differ. That difference is
the entire product — everything below exists to protect it, or to stop you
paying for it where it's worthless.

## The adoption test (run before wiring anything)

Ask where the campaign's wall-clock actually goes. If the bottleneck is CI
lanes, deploy windows, owner-decision latency, or attended human ops — and it
almost always is — added *build* capacity compresses nothing, and a Codex
implementation track is overengineering with coordination costs: Codex sits
outside the child-session fabric (no addressable session identity, no brief
protocol, no one-branch-one-writer participation). Adopt only the
verification slice, and only via the triggers below. If none of the three
triggers is expected to fire, do not set the capability up at all.

**Preflight, once per campaign:** run `codex:setup` to confirm the local
Codex CLI is ready — before the first trigger fires, not during it. Do NOT
enable the stop-time review gate `codex:setup` offers: per-turn review adds
latency to every turn to catch what the campaign's evidence bar already
catches. Deliberate invocation only. (`codex:codex-cli-runtime` documents the
shared runtime; `codex:gpt-5-4-prompting` and `codex:codex-result-handling`
are the prompting/output references if the invocation misbehaves.)

## The three triggers — and the null rule

If none of these fires, Codex stays idle. There is no fourth trigger.

1. **Pre-button review of high-stakes deploy-bearing PRs.** Qualifies:
   deletion-heavy diffs, changes to live write surfaces, changes to
   production failure modes (readiness contracts, worker composition,
   migration-adjacent code). Does not qualify: docs, tests, dormant
   capability behind default-false flags. Fire the Codex pass **while the
   PR's CI lane runs** so it costs zero wall-clock, and require it to
   conclude **before the owner's button word is requested** — a finding that
   arrives after the word is pressure on the owner to un-decide, which is a
   position never to create.
2. **Stuck-state second diagnosis.** "Stuck" has a definition: the same
   evidence has been read twice without producing a new hypothesis. Hand
   Codex the **raw logs the stuck session has** — never a summary (summaries
   carry the stuck session's framing, which is the thing suspected of being
   wrong). One invocation per impasse; if Codex also fails, the answer is
   more evidence, not more models.
3. **Second census on destructive scopes.** Before any PR that deletes code,
   run Codex as a *rival* to your own reference census ("what
   imports/reaches what is being deleted"). Deletions are the class where a
   broken query and a true zero read identically — a single census has
   silently missed an import form before. Two engines disagreeing is a
   finding; two agreeing is real coverage.

## Invocation rules

- **Prompt Codex as a pure skeptic**: "find what is wrong or missed; do not
  summarize; do not praise; state each finding as claim + file:line +
  concrete failure scenario." A review that returns prose instead of
  findings is re-prompted, not interpreted.
- **Never prime it with your conclusions.** Give it the diff or logs
  directly. Telling Codex what you think destroys the decorrelation you are
  paying for — it will anchor, and you will have bought an expensive echo.
- **Never place secrets, credentials, tokens, connection strings, or live
  API access in a Codex prompt.** It gets code, diffs, and logs (redacted as
  you would redact a transcript), nothing that acts on the world.

## Harness mechanics — artifact-first, or you cannot tell death from thought

- **Invoke into a log file with a REQUIRED completion marker** (instruct
  Codex to end with an exact sentinel line, e.g. `CODEX-REVIEW-COMPLETE`).
  The log is the artifact; the process exit status is untrusted in both
  directions — Codex jobs have died while status said running, and have
  exited 0 mid-thought. Silence past a threshold with no marker = death:
  restart once, then escalate.
- **Read-only sandbox, scratch worktree at the pinned tip**, removed after.
  Codex gets the diff range and the tree; never credentials, never write
  access, never network side effects.
- **Run on the FINAL declared tip — after the model-native refuter, not
  before or during.** The uncorrelated reviewer goes last so it sees what
  will actually merge; any post-verdict delta (even prose) moves the tip
  and re-targets the pass.

## The judgment layer — every finding gets exactly one of three verdicts

The master judges each Codex finding on the merits, and ledgers the
judgment with its reason:

1. **Adopt as fix-in-PR** — the finding is real and belongs to this change.
   Route to the owning child under announce-then-push; the refuter
   delta-verifies.
2. **Refute with an instrument** — the finding is wrong; say WHICH
   measurement shows it. Never refute with prose.
3. **Rule out-of-scope and card it** — real, pre-existing, not this PR's to
   fix. A Codex finding can be **the missing half of an existing card**: if
   a chartered follow-up asked a question the finding answers (a consequence
   chain, a mechanism), enrich the card and re-issue it rather than opening
   a rival thread. (One pass measured exactly the consequence chain a card's
   charter had left open — the enriched re-card was worth more than either
   alone.)

An unledgered judgment is a finding that will be re-litigated.

## Treatment rules — the evidence doctrine applies unchanged

- **A Codex finding is a claim.** Verify it against the tree before acting
  on it or relaying it anywhere — including verifying that the tree its
  claim describes is the tree in question (the repro-ancestry rule applies
  to Codex exactly as to a child).
- **Codex output is never authorization** and never substitutes for an owner
  word, a required check, or a child's own evidence obligations.
- **Silence is one reviewer's silence.** A pass with no findings is recorded
  as "Codex reviewed, no findings, at <SHA>" — never as evidence the change
  is correct, and never cited to the owner as a reason to merge.
- **Surviving findings go to the owning child to fix.** Codex never edits a
  branch, never opens a PR, never merges. One branch, one writer is
  unchanged by its existence.

## Anti-ceremony: instrument it or lose it

Every invocation gets a ledger line on the master's board: trigger fired,
target SHA, findings count, how many survived verification, wall-clock cost.
At consolidation, the ledger answers "did Codex earn its place" with data.
The capability defaults to **not adopted** in the next campaign unless the
ledger justified it — a verification layer that stops earning findings
quietly becomes ceremony, and ceremony wearing a safety label is the hardest
kind to remove.

## Red flags — stop and re-read this file

| Thought | Reality |
|---------|---------|
| "Codex could build this faster" | Capacity was never the bottleneck; Codex sits outside the session fabric. Verification only. |
| "Run it on every PR to be safe" | A standing gate is ceremony plus latency. Three triggers, or idle. |
| "Its finding looks right — relay it" | A Codex finding is a claim. Verify against the tree first, every time. |
| "Codex found nothing, so the PR is safe" | One reviewer's silence. Record it; never cite it as correctness. |
| "Let Codex fix what it found" | Codex never writes. Findings go to the owning child. |
| "I'll summarize the logs for Codex" | Summaries carry your framing — the suspected-wrong thing. Raw evidence only. |
| "Skip the ledger line, it obviously helped" | Unmeasured helpfulness is how ceremony survives consolidation. |
