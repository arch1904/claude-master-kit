#!/bin/sh
# Emit the personal global instructions into session context.
#
# WHY THIS EXISTS: ~/.claude/CLAUDE.md is read from the machine Claude Code runs on.
# A cloud session runs on a fresh Anthropic-managed VM, so that file is simply not
# there — the repo's CLAUDE.md loads, the global one never does. SessionStart hook
# stdout IS injected into context, so this is the transport.
#
# The guard is the whole trick: where ~/.claude/CLAUDE.md exists, Claude Code has
# already loaded it and printing it again would duplicate every rule in context.
# So this is a no-op locally and does its job only where the file is absent, which
# is exactly the cloud. No environment flag to keep in sync with anything.
set -eu

if [ -f "$HOME/.claude/CLAUDE.md" ]; then
  exit 0
fi

ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}"
SRC="$ROOT/GLOBAL-INSTRUCTIONS.md"
[ -f "$SRC" ] || exit 0

printf '%s\n' "The following are the user's personal global engineering instructions. They normally live in ~/.claude/CLAUDE.md and apply to every project; this session is running where that file does not exist, so they are supplied here instead. Treat them with the same authority as user-level instructions."
printf '\n'
cat "$SRC"
exit 0
