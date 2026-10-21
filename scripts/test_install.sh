#!/usr/bin/env bash
# test_install.sh — install.sh's -s (one skill) against a pack built from this checkout, offline.
#
#   bash scripts/test_install.sh
#
# The pack tarball is made from the files git knows here (tracked and new, not ignored), served through
# JSONUI_AGENTS_TARBALL_URL=file://… (install.sh's own testing hook). Each case runs install.sh in a fresh temp
# project and compares what it should and should not have written, by content (sha256), not by time.
set -uo pipefail
cd "$(dirname "$0")/.."
ROOT="$(pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
FAIL=0
fail() { printf 'FAIL %s\n' "$*" >&2; FAIL=1; }
ok() { printf 'ok   %s\n' "$*"; }

mkdir -p "$WORK/pack/x"
git ls-files -co --exclude-standard -z | (cd "$ROOT" && xargs -0 tar -cf -) | tar -xf - -C "$WORK/pack/x"
tar -czf "$WORK/pack.tar.gz" -C "$WORK/pack" x
export JSONUI_AGENTS_TARBALL_URL="file://$WORK/pack.tar.gz"
SKILL="$(basename "$(ls -d "$ROOT"/skills/*/ | head -1)")"
OTHER="$(basename "$(ls -d "$ROOT"/skills/*/ | sed -n 2p)")"

if command -v sha256sum >/dev/null; then SUM=(sha256sum); else SUM=(shasum -a 256); fi

# every file under .claude except one skill's folder, by content
snapshot() { (cd "$1/.claude" && find . -type f ! -path "./skills/$2/*" -print0 | sort -z | xargs -0 "${SUM[@]}"); }

project() {   # a project with the whole pack installed, then made its own: settings.json in the user's own form,
  local p="$WORK/$1"   # a file of theirs in another skill, an agent edited, the target skill removed
  mkdir -p "$p" && (cd "$p" && bash "$ROOT/install.sh" >/dev/null) || { fail "full install for $1"; return 1; }
  printf '{\n    "permissions": {"allow": ["Bash(ls:*)"]},\n    "hooks": {"SessionStart": [{"hooks": [{"type": "command", "command": "cat .claude/jsonui-workflow.md 2>/dev/null || true"}]}]}\n}\n' > "$p/.claude/settings.json"
  echo "mine" > "$p/.claude/skills/$OTHER/notes.md"
  echo "<!-- local edit -->" >> "$p/.claude/agents/jsonui-define.md"
  rm -rf "$p/.claude/skills/$SKILL"
  echo "$p"
}

# 1. -s adds the one skill, byte for byte, and nothing else changes (settings.json included)
p="$(project one)" && {
  before="$(snapshot "$p" "$SKILL")"
  out="$(cd "$p" && bash "$ROOT/install.sh" -s "$SKILL" 2>&1)" || fail "-s $SKILL exited $?: $out"
  diff -r "$ROOT/skills/$SKILL" "$p/.claude/skills/$SKILL" >/dev/null && ok "-s writes skills/$SKILL as the pack has it" \
    || fail "skills/$SKILL differs from the pack"
  [ "$before" = "$(snapshot "$p" "$SKILL")" ] && ok "-s leaves every other file under .claude byte for byte (settings.json, agents, other skills)" \
    || fail "-s changed a file outside skills/$SKILL: $(diff <(echo "$before") <(snapshot "$p" "$SKILL") | head -3)"
}

# 2. a name the pack does not have writes nothing and lists the pack's skills
p="$(project unknown)" && {
  before="$(cd "$p/.claude" && find . -type f -print0 | sort -z | xargs -0 "${SUM[@]}")"
  out="$(cd "$p" && bash "$ROOT/install.sh" -s "$SKILL" -s no-such-skill 2>&1)"; code=$?
  after="$(cd "$p/.claude" && find . -type f -print0 | sort -z | xargs -0 "${SUM[@]}")"
  [ "$code" -eq 1 ] && [ "$before" = "$after" ] && [ ! -e "$p/.claude/skills/$SKILL" ] \
    && ok "an unknown name exits 1 and writes nothing (not even the known one beside it)" \
    || fail "unknown name: exit $code, changed: $([ "$before" = "$after" ] && echo no || echo yes)"
  grep -q "no skill named 'no-such-skill'" <<<"$out" && grep -q "^  $SKILL$" <<<"$out" && ok "it names the skills the pack has" \
    || fail "unknown name's message: $out"
}

# 3. a name that is a path is refused like an unknown one
p="$(project path)" && {
  out="$(cd "$p" && bash "$ROOT/install.sh" -s "../.claude/agents" 2>&1)"; code=$?
  [ "$code" -eq 1 ] && [ ! -e "$p/.claude/skills/../.claude" ] \
    && ok "-s ../.claude/agents (a folder the pack has, outside skills/) is refused" || fail "-s ../.claude/agents exited $code"
}

# 4. -s repeats; a project with no .claude gets only .claude/skills/<names>
p="$WORK/bare" && mkdir -p "$p" && {
  out="$(cd "$p" && bash "$ROOT/install.sh" -s "$SKILL" -s "$OTHER" 2>&1)" || fail "-s twice exited $?: $out"
  got="$(cd "$p" && find . -type f | sed 's#^\./##' | cut -d/ -f1-3 | sort -u | tr '\n' ' ')"
  [ "$got" = ".claude/skills/$SKILL .claude/skills/$OTHER " ] && ok "-s twice writes the two skills and nothing else" \
    || fail "-s twice wrote: $got"
}

# 5. without -s the installer still installs the whole pack (the full install is unchanged)
p="$WORK/full" && mkdir -p "$p" && (cd "$p" && bash "$ROOT/install.sh" >/dev/null) && {
  [ "$(ls "$p/.claude/skills" | wc -l | tr -d ' ')" = "$(ls -d "$ROOT"/skills/*/ | wc -l | tr -d ' ')" ] \
    && [ -f "$p/.claude/settings.json" ] && [ -f "$p/.claude/jsonui-workflow.md" ] \
    && ok "without -s: every skill, the workflow and settings.json, as before" || fail "the full install changed"
}

[ "$FAIL" -eq 0 ] && echo "install test: OK" || { echo "install test: FAILED" >&2; exit 1; }
