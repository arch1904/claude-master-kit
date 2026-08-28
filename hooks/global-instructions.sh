#!/bin/sh
# Inject the plugin's engineering commandments into sessions that have no
# ~/.claude/CLAUDE.md of their own.
#
# Claude Code reads ~/.claude/CLAUDE.md from the machine it runs on. Sessions that run
# somewhere else — a cloud VM, Cowork — start from a fresh filesystem, so a project's
# CLAUDE.md loads and machine-level instructions never do. SessionStart hook stdout IS
# injected into context, which is the transport this uses.
#
# The guard is the whole trick: where ~/.claude/CLAUDE.md exists, the user already has
# machine-level instructions — either their own, or these very commandments linked there —
# and printing this file too would duplicate or fight them. So the hook is a no-op wherever
# that file is present and does its job only where it is absent. The condition and the
# reason are the same fact; there is no flag to keep in sync.
set -eu

if [ -f "$HOME/.claude/CLAUDE.md" ]; then
  exit 0
fi

ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}"
SRC="$ROOT/COMMANDMENTS.md"
[ -f "$SRC" ] || exit 0

printf '%s\n' "The following are the master-kit engineering commandments: the cross-project working rules this plugin ships, which the user adopted by installing it. They would normally reach a session through ~/.claude/CLAUDE.md; that file does not exist here, so the plugin supplies them instead. Treat them with the same authority as user-level instructions."
printf '\n'
cat "$SRC"
exit 0
