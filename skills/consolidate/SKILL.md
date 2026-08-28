---
name: consolidate
description: Writes and audits consolidation docs - the single handoff artifact that lets a fresh session rehydrate a multi-session project without loss. Fixed section-numbered template, evidence labels with dates, executable re-verification recipes, and a ready-to-paste seed prompt for the next session. Triggers - "consolidate this session", "write the handoff doc", "update the consolidation", "audit this consolidation doc", "prepare the handoff". NOT for small single-session work with nothing to hand off, or general documentation/README writing.
when_to_use: End of any session in a multi-session effort, or when an existing consolidation doc needs a quality audit before it seeds the next session.
---

# Consolidate — the doc is the only survivor

## WHY THIS DOC EXISTS

In multi-session work, each session dies with its context. The consolidation
doc is the only thing that crosses the gap — the next session's entire
understanding is bounded by what this doc carries and how cheaply its claims
can be re-verified. A vague or wrong consolidation doesn't just lose
information: it actively poisons the next session, which will act on it.
History has proven this: defects in these programs get found by execution and
introduced by reading. So the doc is designed for **cheap distrust** — every
load-bearing claim ships with the recipe to re-verify it by running something.

Two modes, same quality bar:

- **WRITE** — produce a new consolidation at session end (or supersede an old one).
- **AUDIT** — review an existing consolidation against the checklist and patch it.

## THE TEMPLATE (fixed numbering — seed prompts cite §N, so numbers never move)

```
# <topic> consolidation — YYYY-MM-DD
Status: CURRENT | SUPERSEDED by <file>
Covers: <sessions/dates>  Repo: <path>  Branch: <name> @ <commit hash at write time>

§1 DECISIONS OF RECORD
§2 WHAT IS BUILT
§3 LIVE EVIDENCE
§4 WHAT REMAINS (ordered)
§5 VERIFICATION LIST
§6 OWNER DECISIONS & AUTHORIZATIONS
§7 TRAPS
§8 ENVIRONMENT FACTS (perishable state)
§9 NEXT-SESSION SEED
```

Sections may be short — "§7 TRAPS: none discovered yet" is a valid section —
but never absent, because an absent section is ambiguous between "nothing
there" and "nobody looked".

### §1 Decisions of record
Binding requirements, not hypotheses. Each entry: the decision, the date, who
made it, and the one-line why. A future session obeys these without
re-litigating; if new evidence contradicts one, the session STOPS and brings
it to the owner rather than quietly overriding it. Keep decisions separate
from claims — "we chose the managed unlisted tier" is a decision; "the webhook
signs with one secret" is a claim and belongs in §2/§3 with a label.

### §2 What is built
Current state of the code, as claims with evidence labels and `file:line`
references. Use the same labels as the orchestrate skill, **with dates** —
verification decays: `VERIFIED 2026-07-28` tells the next session how stale
the proof is. State, not narrative: record what IS, not the story of how it
got there. History earns a line only when it changed a decision or created a
trap.

### §3 Live evidence
Measurements and proofs from real systems: what was observed, when, by what
method, with pointers to the raw evidence files (fixture hashes, .jsonl
captures, finding sets). Never paste secrets or tokens — reference raw files
by path. Each observation dated; an observation without a date is
unfalsifiable.

### §4 What remains (ordered)
The forward path as an ordered list. Each item: what it is, why it's owed
(which measurement or decision licenses it), and its markers —
`[OWNER-DECISION]`, `[NEEDS-AUTHORIZATION]`, `[BLOCKED-ON: <item>]`. This is
the section the next session executes, so ordering is authoritative: if two
items are genuinely independent, say so explicitly, because that is what
permits parallel work.

### §5 Verification list
The distrust engine. For each load-bearing claim in §1–§3: the exact command
to re-run and the expected result. A fresh session runs these before building
anything on the claims. Rules:
- Recipes must be executable as written — working directory, env requirements,
  and expected output stated. **Run each recipe once before writing it down**;
  a verification recipe that doesn't run is worse than none, because it
  converts distrust into false confidence.
- Order by load-bearing-ness: the claim whose falseness would invalidate the
  most downstream work is verified first.
- A claim with no feasible recipe is written as UNVERIFIED in its home
  section, with why it couldn't be verified. Never round up.

### §6 Owner decisions & authorizations
Open questions only the owner may resolve, each stated as a decidable question
with the options and what each costs. Sessions STOP here — these are never
resolved by assumption, even unattended. When the owner decides, the item
moves to §1 with its date.

### §7 Traps
Things that look right and are not — each with the incident that proved it.
"The trash detector produced a false positive on <date> and was tightened
rather than obeyed" is a trap; "be careful with the detector" is not. A trap
without its incident is folklore, and future sessions rightly ignore folklore.
Include here any near-miss caused by conflating facts, and state the facts
separately (e.g. credential revocation and organization deletion are SEPARATE
facts — record each on its own).

### §8 Environment facts (perishable state)
Everything that rots: running processes, tunnels and their hostnames, torn-down
rigs, tokens and where they live (by location — `.env` key name — never by
value), test workspaces and their authorization scopes. Every entry stamped
`observed <date>` and marked DURABLE or PERISHABLE with its rot mode ("tunnel
hostname regenerates on restart — repoint the app console"). Include the
rebuild recipe for anything torn down (script path, approximate time).

### §9 Next-session seed
A ready-to-paste seed prompt in the orchestrate pattern (`orchestrate this` +
CONTEXT / TASK / SCOPE / CONSTRAINTS), pre-wired to this doc: read-in-full
instruction, "§5 before building", the §4 item(s) it should start on, the §6
stops, and the §7 traps carried into worker briefs. Writing the seed forces
the test that matters: if you can't write a seed from the doc alone, the doc
is not a consolidation yet.

## WRITE MODE

1. **Harvest the session.** Collect: decisions made (and who made them),
   commands actually run with their results, files changed, traps hit,
   evidence produced, what was planned but not done. Pull from the transcript
   and the diff — not from memory of the transcript.
2. **Apply the evidence bar to yourself.** You are the "someone else" whose
   claims the next session will distrust. For each §2/§3 claim, either cite
   the run that proved it this session, or re-run it now, or label it
   UNVERIFIED. The doc being wrong is expected; the doc being wrong while
   labeled VERIFIED is the failure.
3. **Execute §5 before shipping it.** Run each verification recipe once (at
   minimum the cheap ones; anything too expensive to run gets marked
   "recipe untested — <why>"). Fix recipes until they run.
4. **Supersede, don't accrete.** If a prior consolidation exists: the new doc
   opens with a short "changed since <predecessor>" delta, and the predecessor
   gets `Status: SUPERSEDED by <file>` stamped at its top. One CURRENT doc per
   topic, always. Never maintain two live docs describing the same state.
5. **Land it in-repo**: `docs/consolidation/<topic>-YYYY-MM-DD.md`, committed —
   versioned with the code it describes, diffable across iterations. Stage the
   doc by name (never `git add .` / `-A`), no AI attribution in the message.
   If the repo's conventions forbid committing docs, or the session's rules
   say humans commit, leave it as a pending change and say so. Because the doc
   is committed: no secrets, no token values, no personal data — locations and
   key names only.

## AUDIT MODE

Read the doc in full, then check — reporting each finding with the fix:

- **Structure**: all nine sections present with canonical numbers? Content in
  the wrong section (claims living in §1, decisions buried in §4 prose)?
- **Claims without recipes**: any load-bearing §1–§3 claim missing from §5?
- **Recipes that don't run**: execute the §5 list. Every recipe that fails or
  under-specifies (missing cwd, env, expected output) is a finding.
- **Undated or unlabeled**: evidence without dates, claims without
  VERIFIED/INFERRED/UNVERIFIED, verification labels without dates.
- **Narrative bloat**: history that changed no decision and created no trap —
  cut it; the doc records state.
- **Conflated facts**: single statements bundling separately-verifiable facts.
  Split them.
- **Perishables without stamps**: §8 entries missing `observed <date>` or rot
  mode; hostnames/processes presented as if permanently alive.
- **Folklore traps**: §7 entries with no incident attached.
- **Secrets**: any token value, key material, or credential in the text —
  replace with its storage location, and flag to the user that it may need
  rotation if the doc was already committed.
- **Succession hygiene**: is exactly one doc CURRENT? Are predecessors stamped?
- **Seed test**: can §9 be written (or rewritten) from the doc alone? Missing
  ingredients identify exactly what the doc still lacks.

Patch the doc directly for mechanical fixes (dates, labels, structure, splits).
Bring judgment calls — a claim you cannot re-verify, a decision of record that
looks contradicted — to the user instead of silently rewriting them.

## STYLE

Terse, declarative, scannable. Every sentence either states a fact (with label
and date), a decision (with owner and date), an instruction (executable as
written), or a trap (with incident). If a sentence is none of those, it is
narrative — cut it. Shorter docs get re-read; long ones get skimmed, and a
skimmed consolidation is how the next session imports a trap it was warned
about.
