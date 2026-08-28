# Master Session — templates

Fill-ins are in ALL-CAPS. Trim sections that don't apply; never trim the
authorization or verification lines.

## 1. Charter message (how the owner appoints a master)

Paste as the first message of the master session:

```
You are the MASTER SESSION for PROJECT. Invoke the master-session skill and
hold its doctrine for the whole session.

Problem(s): THE BIG PROBLEM(S), one paragraph each.

Standing authorizations (first-hand, to you):
- ACTION CLASS + CONDITION, e.g. "merge docs-only PRs when green"
- ACTION CLASS + CONDITION, e.g. "merge PRs I've named when green on a
  current base"
Everything else comes back to me before execution.

Cadence: drive continuously; update me on real changes only.
```

## 2. Chip / child-session brief

Every brief is self-contained — the child has none of your context. The six
load-bearing sections:

```
CONTEXT: What is true right now, with refs (commit SHAs, PR numbers, doc
paths). Date-stamp facts that can go stale. State which claims the child
must RE-VERIFY rather than trust (default: all of them).

SCOPE: The deliverable and its boundary. Name what is explicitly OUT of
scope, especially adjacent temptations.

DISCIPLINE: The non-negotiables for this repo (e.g. TDD red-first, migration
lint, skip-list diff, no migrations on this track).

REPORTING: "Report to the master session at PR-open and at merge-readiness;
report blockers plainly instead of grinding. Never AskUserQuestion — every
question, decision point, or blocker routes to the master, who brokers to
the owner; attach your recommendation to each question." (Spawned sessions
inherit no fleet doctrine — a chip prompt that omits this line produces a
child interrogating the owner directly.)

AUTHORIZATION: Which of the child's actions need the owner's word, in which
form (in-session / first-hand-to-master), and which are pre-authorized under
what condition.

COORDINATION: Who else is working near which files; the one-branch-one-writer
rule; where sequencing decisions live (the master).
```

## 3. Standing-authorization one-liner (owner → child session)

The friction-free form. The owner pastes into the child's session:

```
Standing in-session authorization: once PRECONDITION, and when all required
checks are green on a current base, ACTION (e.g. merge PR #N, merge commit)
— no further confirmation needed. This covers the deploy that follows; the
master session watches it.
```

## 3.5 PR declaration (what a child sends at PR-open — the artifact every
review anchors to)

```
PR #N OPEN, UNPRESSED — URL
TIP: FULL-SHA  (state=OPEN, base=BRANCH, autoMergeRequest=null — and state
plainly "I never pressed"; the null field alone proves nothing)
COMMITS: one line each — SHA + what it carries.
EVIDENCE (measured at the tip, with LITERAL invocations — a count without
its exact command and cwd is unverifiable):
  - suite: THE COMMAND → N passed / M skipped (name each skip's cause)
  - gates run: lint / types / migration-lint as applicable, each with result
  - probes: each mutation applied ALONE, its red SET named (tests by name,
    not counts)
SEAMS: files/surfaces shared with any other OPEN PR, including test-file
imports; who re-verifies on second landing.
CHANGED SINCE LAST DECLARATION: delta scope, or "first declaration".
OPEN QUESTIONS: anything unsettled, framed as options — never buried as
settled.
```

The declared tip is the reviewer's contract: announce before any further
push, and re-declare after it.

## 4. Child closing report (what the master demands before archiving)

```
- Outcome: what shipped/landed, with SHAs and run IDs.
- Verification: what was run, honest numbers, skip-list vs baseline.
- Worktree state: clean? unpushed commits? stashes worth keeping?
- Follow-ups: listed, not started — each self-contained enough to chip.
- Corrections: anything the brief or the master got wrong, stated plainly.
```

## 5. Master's board update (to the owner)

Lead with what changed and what needs the owner; table for enumerable state;
one explicit "needs you" list, even when empty. Never bury a decision request
mid-paragraph.
