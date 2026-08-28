# claude-master-kit

One Claude Code plugin that carries three things into **cloud sessions**, where
`~/.claude/` never reaches:

| Component | What it is |
| --- | --- |
| `skills/master-session/` | The master-session fleet-governance skill, with its six reference files |
| `commands/master-*.md` | `/master-check`, `/master-codex`, `/master-handoff`, `/master-learn` |
| `GLOBAL-INSTRUCTIONS.md` | Personal global engineering instructions, injected by a SessionStart hook |

The repository is both the marketplace and the plugin — `.claude-plugin/marketplace.json`
points at `./`.

## Why a plugin and not committed files

A cloud session starts from a fresh clone on a fresh VM. `~/.claude/skills/`,
`~/.claude/commands/` and `~/.claude/CLAUDE.md` all live on the machine, so none of
them arrive. The two transports that do work are committing into a repo's `.claude/`
directory — which pushes personal workflow into every project that uses it — or a
plugin, which follows the account instead of the codebase.

This repo is **public** on purpose. In an Anthropic-hosted cloud session, GitHub
requests go through a proxy scoped to the repositories attached to the session, so a
private marketplace repo returns 403 when the session tries to install the plugin.

## Install

```bash
claude marketplace add https://github.com/arch1904/claude-master-kit
claude plugin install master-kit@claude-master-kit
```

For a specific project's cloud sessions, declare it in that repo's
`.claude/settings.json` instead — two keys, no personal files in the tree:

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

## The global-instructions hook

`hooks/global-instructions.sh` prints `GLOBAL-INSTRUCTIONS.md` to stdout at
SessionStart, which Claude Code injects into context. It exits silently when
`~/.claude/CLAUDE.md` exists, because there Claude Code has already loaded those rules
and printing them again would duplicate every one of them. So the guard is the file's
own presence — nothing to keep in sync, and the hook is inert wherever it isn't needed.

To change the rules, edit `GLOBAL-INSTRUCTIONS.md` here and keep `~/.claude/CLAUDE.md`
in step; they are two copies by necessity, since the local one must stay where Claude
Code reads it.
