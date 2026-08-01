#!/usr/bin/env bash
# contract_check.sh — mechanical contract checks for the JsonUI agent pack.
#
#   1. Every mcp__jui-tools__* tool referenced in an agent body is declared
#      in that agent's frontmatter `tools:` list.
#   2. Every jsonui-* name reference (agents, skills, rules, workflow,
#      command) resolves to an agent file, a skill directory, an
#      agent-family prefix, or the documented allowlist below.
#   3. Every examples/ file referenced by a SKILL.md exists on disk.
#   4. The per-agent inventory table in mcp-policy.md matches the agent
#      frontmatter (the table is generated — frontmatter is canonical).
#
# Usage:
#   scripts/contract_check.sh          # verify (CI mode)
#   scripts/contract_check.sh --fix    # also regenerate the inventory table
#
# The Codex mirror runs the same checks via scripts/contract_check.py
# (TOML packaging there; keep the two in sync when changing check logic).
set -uo pipefail

FIX=0
ROOT=""
for arg in "$@"; do
  case "$arg" in
    --fix) FIX=1 ;;
    *) ROOT="$arg" ;;
  esac
done
if [ -n "$ROOT" ]; then cd "$ROOT"; else cd "$(dirname "$0")/.."; fi

FAIL=0
err() { printf 'FAIL %s\n' "$*" >&2; FAIL=1; }

frontmatter() { awk '/^---$/{n++;next} n==1' "$1"; }

# ---- 1. frontmatter tools: superset of body-referenced MCP tools ---------
for f in .claude/agents/*.md; do
  fm=$(frontmatter "$f")
  body=$(awk '/^---$/{n++;next} n>=2' "$f")
  while IFS= read -r tool; do
    [ -z "$tool" ] && continue
    if ! printf '%s\n' "$fm" | grep -qE "(^|[^a-z_])${tool}([^a-z_]|\$)"; then
      err "$f: body uses $tool but frontmatter tools: lacks it (add it, or drop the mcp__ prefix if this is a non-call mention)"
    fi
  done < <(printf '%s\n' "$body" | grep -oE 'mcp__jui-tools__[a-z_]+' | sort -u)
done

# ---- 2. jsonui-* name references resolve ---------------------------------
# Known non-agent, non-skill names. An entry also covers "<entry>-*" suffixed
# forms (e.g. jsonui-test-runner covers jsonui-test-runner-ios).
#   jsonui-cli / jsonui-mcp-server / jsonui-test-runner — sibling repos
#   jsonui-doc                — CLI (also .jsonui-doc-rules.json via prefix)
#   jsonui-type-map           — .jsonui-type-map.json
#   jsonui-workflow           — .claude/jsonui-workflow.md
#   jsonui-rules              — .claude/jsonui-rules/
#   jsonui-test-setup         — legacy fallback skills (ground agent)
ALLOW="
jsonui-cli
jsonui-doc
jsonui-type-map
jsonui-workflow
jsonui-rules
jsonui-mcp-server
jsonui-test-runner
jsonui-test-setup
"
for f in .claude/agents/*.md skills/*/SKILL.md .claude/jsonui-rules/*.md .claude/jsonui-workflow.md .claude/commands/jsonui.md; do
  [ -f "$f" ] || continue
  while IFS= read -r name; do
    [ -z "$name" ] && continue
    [ -f ".claude/agents/$name.md" ] && continue
    [ -d "skills/$name" ] && continue
    # family form (jsonui-navigation-{ios,android,web} → stem "jsonui-navigation")
    if ls ".claude/agents/$name"-*.md >/dev/null 2>&1; then continue; fi
    allowed=0
    for a in $ALLOW; do
      case "$name" in "$a"|"$a"-*) allowed=1; break;; esac
    done
    [ "$allowed" -eq 1 ] && continue
    err "$f: reference '$name' resolves to no agent file, skill dir, or allowlist entry"
  done < <(grep -ohE '(^|[^a-z])jsonui-[a-z]+(-[a-z]+)*' "$f" | sed 's/^[^j]*//' | sort -u)
done

# ---- 3. SKILL.md example references exist on disk ------------------------
for s in skills/*/SKILL.md; do
  d=$(dirname "$s")
  # cross-skill form: skills/<x>/examples/<file>
  while IFS= read -r ref; do
    [ -z "$ref" ] && continue
    [ -f "$ref" ] || err "$s: references $ref — not on disk"
  done < <(grep -ohE 'skills/[a-z-]+/examples/[A-Za-z0-9._-]*[A-Za-z0-9_-]' "$s" | sort -u)
  # local form: examples/<file> (not inside a skills/... path)
  while IFS= read -r ref; do
    [ -z "$ref" ] && continue
    [ -f "$d/$ref" ] || err "$s: references $ref — not in $d/"
  done < <(grep -ohE '(^|[^/a-z])examples/[A-Za-z0-9._-]*[A-Za-z0-9_-]' "$s" | sed 's/^[^e]*//' | sort -u)
done

# ---- 4. per-agent inventory table in mcp-policy.md -----------------------
POLICY=.claude/jsonui-rules/mcp-policy.md
gen_inventory() {
  printf '<!-- inventory:begin — generated from agent frontmatter; edit frontmatter, then run scripts/contract_check.sh --fix -->\n'
  printf '| Agent | MCP tools |\n'
  printf '|---|---|\n'
  for f in .claude/agents/jsonui-*.md; do
    short=$(basename "$f" .md)
    short=${short#jsonui-}
    tools=$(frontmatter "$f" | grep -oE 'mcp__jui-tools__[a-z_]+' | sed 's/^mcp__jui-tools__//' | sort -u \
      | awk -v q='`' '{printf "%s%s%s%s", sep, q, $0, q; sep=", "} END {print ""}')
    [ -z "$tools" ] && tools='—'
    printf '| `%s` | %s |\n' "$short" "$tools"
  done
  printf '<!-- inventory:end -->\n'
}
if ! grep -q '<!-- inventory:begin' "$POLICY"; then
  err "$POLICY: inventory markers missing (<!-- inventory:begin/end -->)"
else
  expected=$(gen_inventory)
  current=$(awk '/<!-- inventory:begin/,/<!-- inventory:end -->/' "$POLICY")
  if [ "$current" != "$expected" ]; then
    if [ "$FIX" -eq 1 ]; then
      # BSD awk rejects newlines in -v strings, so feed the block via a file
      printf '%s\n' "$expected" > "$POLICY.block"
      awk -v blk="$POLICY.block" '
        /<!-- inventory:begin/ {while ((getline line < blk) > 0) print line; skip=1; next}
        /<!-- inventory:end -->/ {skip=0; next}
        !skip {print}
      ' "$POLICY" > "$POLICY.tmp" && mv "$POLICY.tmp" "$POLICY"
      rm -f "$POLICY.block"
      echo "regenerated: $POLICY inventory table"
    else
      err "$POLICY: inventory table does not match agent frontmatter — run scripts/contract_check.sh --fix"
    fi
  fi
fi

if [ "$FAIL" -ne 0 ]; then
  echo "contract check: FAILED" >&2
  exit 1
fi
echo "contract check: OK"
