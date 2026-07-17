#!/bin/bash
#
# sync-into-project.sh — mirror the canonical JsonUI agent pack into a
# consumer project's .claude/, so per-project copies can never drift.
#
# Intended to run as a SessionStart hook in the consumer project:
#
#   "hooks": { "SessionStart": [{ "hooks": [
#     { "type": "command",
#       "command": "\"$HOME/resource/JsonUI-Agents-for-claude/scripts/sync-into-project.sh\" \"${CLAUDE_PROJECT_DIR:-.}\" || true" },
#     { "type": "command", "command": "cat .claude/jsonui-workflow.md 2>/dev/null || true" }
#   ]}]}
#
# Scope: ONLY what this repo owns — agents/, jsonui-rules/, commands/,
# jsonui-workflow.md. Never touches the consumer's settings*.json, skills/,
# or anything else under .claude/.
#
# Fail-soft by design: a sync problem must never break a session, so all
# errors exit 0 after printing a warning to stderr.

set -u

SRC="$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)/.claude"
TARGET="${1:-}"

warn() { echo "[jsonui-agents sync] $*" >&2; }

if [[ -z "$TARGET" ]]; then
  warn "no target project dir given — skipping"
  exit 0
fi
if [[ ! -d "$SRC/agents" ]]; then
  warn "canonical pack not found at $SRC — skipping"
  exit 0
fi
DST="$TARGET/.claude"
if [[ ! -d "$DST" ]]; then
  warn "$DST does not exist — skipping (not a claude project?)"
  exit 0
fi
# Don't sync the canonical repo onto itself.
if [[ "$(cd "$DST" 2>/dev/null && pwd)" == "$SRC" ]]; then
  exit 0
fi

CHANGED=0
sync_dir() {
  local name="$1"
  [[ -d "$SRC/$name" ]] || return 0
  local out
  out=$(rsync -a --delete --itemize-changes "$SRC/$name/" "$DST/$name/" 2>&1) || {
    warn "rsync $name failed: $out"
    return 0
  }
  [[ -n "$out" ]] && CHANGED=1
}

sync_dir agents
sync_dir jsonui-rules
sync_dir commands
if [[ -f "$SRC/jsonui-workflow.md" ]] && ! cmp -s "$SRC/jsonui-workflow.md" "$DST/jsonui-workflow.md" 2>/dev/null; then
  cp "$SRC/jsonui-workflow.md" "$DST/jsonui-workflow.md" 2>/dev/null || warn "copy jsonui-workflow.md failed"
  CHANGED=1
fi

if [[ "$CHANGED" == "1" ]]; then
  warn "updated $DST from canonical pack"
fi
exit 0
