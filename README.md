# master-kit

A Claude Code plugin for running **many Claude sessions at once without losing the plot**.

When work outgrows one session — three or four tracks in flight, merges queueing behind
each other, a deploy that must not land before a migration, children reporting results you
have no way to check — the failure is rarely any one session's code. It is that nobody owns
the picture. `master-kit` gives one session that job, with the doctrine to do it honestly.

## What's in it

### The `master-session` skill

Air traffic control plus institutional memory for a fleet of independent sessions. Five
jobs — evidence reconciliation, sequencing, authorization brokering, knowledge hygiene,
watchdog persistence — and two explicit non-jobs: **it does not implement, and it does not
decompose problems it hasn't scouted.**

Its governing principle is the one that survives contact with reality: *your view of the
world is a cache; the children and git are ground truth.* Refetch before acting on anything
you "know."

Six reference files carry the parts that are easy to get wrong:

| Reference | What it covers |
| --- | --- |
| `monitoring.md` | Reading fleet state from authoritative objects, because summary fields lie |
| `review-gauntlet.md` | Rounds-until-clean review: second-model reviewer, refuter mandate, live smoke |
| `consolidation.md` | The handoff artifact that lets a fresh session rehydrate without loss |
| `templates.md` | Dispatch briefs, seed prompts, report shapes |
| `codex-adversarial-verification.md` | Codex as an uncorrelated skeptic — never as capacity |
| `codex-execution-track.md` | The owner-toggled track where Codex runs executor children |

Every rule in it was earned by a specific failure — spawned sessions inheriting nothing,
builders answering into a dead message leg, concurrent reviewers colliding in one worktree,
a session-list that reported idle for a child that had died. The skill says which failure,
so you can judge whether the rule applies to you.

### The `consolidate` skill

The handoff artifact the master-session doctrine depends on. It writes and audits
consolidation docs — the single document that lets a fresh session rehydrate a
multi-session effort without loss: fixed section numbering, evidence labels with dates,
executable re-verification recipes, and a ready-to-paste seed prompt for the successor.
`master-session` routes its succession path through this; shipping them together means the
handoff never dangles.

### Four companion commands

- `/master-check` — full fleet sweep. Census, every child's wait verified *intentional*
  (unintentional ones fixed before reporting), live PR/queue/deploy refetch, ending in an
  explicit "Needed from you" list — or a plain "nothing is blocked on you".
- `/master-handoff` — refresh live state, settle the handoff doc, emit a paste-ready
  successor seed prompt, hold the interregnum until takeover confirms.
- `/master-learn` — end-of-campaign extraction: mine the ledger for generalizable lessons
  (errors first, the master's own included), separate campaign-specific from skill-worthy,
  fold the skill-worthy back in with the incident attached.
- `/master-codex` — owner toggle for the optional Codex execution track.

### The commandments

The plugin ships an opinionated set of cross-project engineering rules, in
`COMMANDMENTS.md`, and loads them into every session it runs in. They are short, and
each one exists because its absence costs something specific:

- **Ask, don't assume** — and when running unattended, pick the most reasonable reading,
  proceed, and *record the assumption* rather than blocking.
- **Simplest solution for simple problems.** No flexibility that isn't needed yet.
- **Don't touch unrelated code** — but surface the smells you find, as separate issues.
- **Flag uncertainty explicitly.** Confidence without certainty does more damage than
  admitting a gap.
- **Reproduce before fixing.** Write the test that fails, fix, run it. Only then is it fixed.
- **Define "done" in terms a machine can verify**, before any code is written.
- **Read the full stack trace. Change one variable at a time.**
- **Ask what the standard library does** before reaching for a dependency; document the
  decision if you add one.
- **Named failure modes to avoid** — Kitchen Sink, Wrong Abstraction, Optimistic Path,
  Runaway Refactor.

Plus two on git hygiene: no AI attribution in commit messages, and never `git add .` or
`git add -A` — review `git status` and stage explicit paths.

They pair naturally with the master-session doctrine: the skill governs how a fleet reports
evidence, and these govern what any one session is allowed to conclude from it.

**How they reach sessions that can't read your home directory.** Claude Code loads
`~/.claude/CLAUDE.md` from the machine it runs on. Sessions running elsewhere — a cloud VM,
Cowork — start from a fresh filesystem, so a project's `CLAUDE.md` loads and personal
standards quietly stop applying, exactly where you are least able to notice.
`hooks/global-instructions.sh` prints them at SessionStart, which Claude Code injects into
context. It emits nothing when `~/.claude/CLAUDE.md` exists, because there they are already
loaded and printing them again would duplicate every rule. The guard is that file's own
presence, so there is no flag to keep in sync and the hook is inert wherever it isn't needed.

To run a different set, fork and replace `COMMANDMENTS.md`.

## Install

```bash
claude marketplace add https://github.com/arch1904/claude-master-kit
claude plugin install master-kit@claude-master-kit
```

The repository is both the marketplace and the plugin — `.claude-plugin/marketplace.json`
points at `./`.

To scope it to one project instead, declare it in that repo's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "claude-master-kit": {
      "source": { "source": "github", "repo": "arch1904/claude-master-kit" }
    }
  },
  "enabledPlugins": { "master-kit@claude-master-kit": true }
}
```

## Notes

**Command names.** Installed as a plugin, the commands may need the namespaced form —
`/master-kit:master-check` rather than `/master-check`. The skill spells the bare names
throughout, since that is how they resolve from `~/.claude/commands/`.

**Cloud and Cowork sessions.** This plugin is one of the few ways to get a personal skill
into a session that runs off your machine: `~/.claude/skills/`, `~/.claude/commands/` and
`~/.claude/CLAUDE.md` do not travel there, but an enabled plugin does. Note that the skill's
fleet mechanics — git worktrees, `ps`/`lsof`, cross-session messaging — assume sibling
sessions on one machine. In an isolated cloud VM you get the doctrine, applied to subagents
and workflows; you do not get a fleet to govern. Cast such a session as a child, not the
master.

**Keep it public if you fork it.** In an Anthropic-hosted cloud session, GitHub traffic goes
through a proxy scoped to the repositories attached to that session, so a private marketplace
repo returns 403 when the session tries to install from it.

## License

MIT.
