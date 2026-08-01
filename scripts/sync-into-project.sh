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
# jsonui-workflow.md, plus ALREADY-INSTALLED skills. Never touches the
# consumer's settings*.json,
# or anything else under .claude/.
#
# Fail-soft by design: a sync problem must never break a session, so all
# errors exit 0 after printing a warning to stderr.

set -u

REPO_ROOT="$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)"
SRC="$REPO_ROOT/.claude"
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

# Machine-local freeze list: projects whose tooling must stay at its pinned
# state (one absolute project path per line, comments with #). Kept outside
# this repo on purpose — consumer paths never belong in the public pack.
BLOCKLIST="$HOME/.jsonui-agents-sync/blocklist"
if [[ -f "$BLOCKLIST" ]]; then
  TARGET_REAL="$(cd "$TARGET" 2>/dev/null && pwd)"
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    if [[ "$TARGET_REAL" == "$line" ]]; then
      warn "target is on the sync freeze list — skipping"
      exit 0
    fi
  done < "$BLOCKLIST"
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

# Skills are updated but never ADDED or REMOVED.
#
# They live outside .claude/ in this repo and each consumer chooses which ones
# to install (install.sh downloads a subset), so a plain `rsync --delete` would
# both force skills onto projects that never wanted them and delete any the
# consumer authored. Updating in place is the only safe automatic behaviour —
# and it has to be automatic, because skills were previously excluded outright
# and so silently went stale on every consumer until someone re-ran install.sh.
sync_existing_skills() {
  local src_skills="$REPO_ROOT/skills"
  local dst_skills="$DST/skills"
  [[ -d "$src_skills" && -d "$dst_skills" ]] || return 0
  local skill name out
  for skill in "$src_skills"/*/; do
    name="$(basename "$skill")"
    [[ -d "$dst_skills/$name" ]] || continue   # not installed here — leave alone
    out=$(rsync -a --itemize-changes "$skill" "$dst_skills/$name/" 2>&1) || {
      warn "rsync skills/$name failed: $out"
      continue
    }
    [[ -n "$out" ]] && CHANGED=1
  done
}

sync_dir agents
sync_dir jsonui-rules
sync_dir commands
sync_existing_skills
if [[ -f "$SRC/jsonui-workflow.md" ]] && ! cmp -s "$SRC/jsonui-workflow.md" "$DST/jsonui-workflow.md" 2>/dev/null; then
  cp "$SRC/jsonui-workflow.md" "$DST/jsonui-workflow.md" 2>/dev/null || warn "copy jsonui-workflow.md failed"
  CHANGED=1
fi

if [[ "$CHANGED" == "1" ]]; then
  warn "updated $DST from canonical pack"
fi
exit 0
