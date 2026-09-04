# Invariants — The 4 Core Rules + 4 API Model Rules

The first four invariants apply to **every** JsonUI task. A task is not complete until all four hold. Everything else in this project is a means to satisfy them.

Invariants 5–8 apply when the project uses swagger-driven Data Model codegen (any project with `docs/api/*.json` files).

---

## 1. `jui build` must pass with **zero warnings**

`jui build` detects Layout JSON mistakes: unknown attributes, invalid bindings, type mismatches, broken path resolution, missing files, `platform` / `responsive` structure errors.

- One or more warnings → the task is not done
- Fix the root cause (spec, Layout JSON, Styles, strings.json, VM impl) — **never suppress or ignore**
- Loop: edit → `jui build` → read warnings → fix → repeat until zero

```bash
jui build 2>&1 | grep -iE 'warning \[|warning:|\[warn|⚠' | grep -vic 'warnings found'
# 0 ← required
```

The second filter drops the build's own summary line (`[WARN] Validation warnings found: N`), which is printed through the same logger and would otherwise count as one more finding than there are (measured on real build logs: 2/2/0/4 against 1/1/0/3 findings).

The filter is a heuristic and errs on the low side: a finding whose own text contains "warnings found" is dropped together with the summary, so read the number as a floor and, whenever it is not 0, read the lines themselves. Keep the `-c` at the end and only there — a `-c` earlier in the pipe turns every later stage into a count of one line, and the expression then reports 1 whether there are five findings or none. Other tools print their own summaries in other spellings (`jsonui-test validate` ends with `Warnings: 0`, which this expression does not match but a looser `warn` pattern does), so an expression borrowed for another command has to be checked against that command's output first.

**The build does not count for you.** `jui build` prints its findings and exits 0 whether there are none or fifty — it keeps no warning tally, has no line that fails on one, and the "zero warnings" rule lives *here*, in this rulebook, not in the process's exit code. So the gate is you reading the output. Warnings arrive in four spellings, and a narrow pattern silently counts a different thing each time (measured on a consumer's logs, 2026-09-04):

| spelling | where it comes from | trap |
|---|---|---|
| `WARNING [origin]: …` | the Python build itself (`WARNING [lint-strings]:`, `WARNING [normalize]:`) — the most common | the colon follows the bracketed origin, so `warning:` never matches it; `\[WARN` matches `[WARN]` but not `[lint-strings]` |
| `WARNING: …` / `warning: …` | other Python and Ruby paths | case-sensitive `warning:` misses the upper-case form |
| `⚠` | attribute / design warnings | not matched by any `warn` pattern |
| `[WARN]` | Ruby logger, **with ANSI colour before it** (`\e[33m[WARN]\e[0m`) | `^\[WARN` anchored at column 0 is always 0 |

Count with the unanchored, case-insensitive expression above — it matches all four shapes and none of the prose lines the build also prints ("no warnings", "Warnings: 0"). The first version of this rule shipped `'warning:|\[WARN|⚠'`, which misses the most common shape; it lasted one hour before a lane measured it against the actual print sites. Accepted warnings (a consumer's baseline of 14 `⚠` it has chosen to live with) are not "zero" — write the number and the reason, never "0 warnings".

**What `jui build` does in order** (relevant for diagnosing failures):
1. Distributes shared `layouts/` / `styles/` / `resources/` / `images/` to each platform.
2. Syncs ViewModel Protocol/Base files from spec + Impl markers (hard-errors on drift).
3. Runs `sjui build` / `kjui build` / `rjui build` per active platform.

**`jui build` does NOT scaffold converters.** If a custom component's `type` appears in a Layout JSON but no converter exists for it, the build emits warnings / errors per platform. Run `jui g converter --from <name>.component.json` (or `--all`) explicitly to scaffold before building.

---

## 2. `jui verify --fail-on-diff` must pass with **no drift**

`jui verify` compares the Layout JSON that `jui generate project` *would* produce from the current spec against what's actually on disk. A diff means spec and Layout have drifted apart.

- Diff found → decide which side is correct:
  - Spec is wrong → fix spec (`define` agent)
  - Layout is wrong → fix Layout JSON (`implement` agent)
- Do not silence the check or accept drift

```bash
jui verify --fail-on-diff
# Exit 0 ← required
```

### ⚠️ Exit 0 is not the whole result — read the denominator

`jui verify` only compares screens whose Layout JSON it could have generated. A screen whose spec points at a hand-authored layout is **skipped**, and skipped screens do not affect the exit code. So a face where every screen is authored externally passes this invariant while comparing nothing.

This is not a corner case. Across six projects measured together, the count of screens
actually compared was zero in every one — 47, 30, 19, 18, 11 and 2 screens respectively,
all of them skipped with the reason `layout authored externally`.

**Satisfying this invariant is therefore not by itself evidence that spec and Layout agree.** Read the line `jui verify` prints (1.8.5 and later name the denominator: `verified N of M screen(s) — K skipped (reason)`), and treat `verified 0` as *this check did not run*, not as *this check passed*. `--json PATH` writes the same numbers as `verified` / `skipped` / `total` / `skippedByReason` for a gate to assert on.

When `verified` is 0, spec–Layout agreement has to come from somewhere else — review of the authored Layout against the spec, or a test that exercises the screen. Do not report the screen as verified.

---

## 3. `@generated` files are **never edited by hand**

The following files carry `@generated` markers and are regenerated by `jui build`:

- iOS: `*ViewModelProtocol.swift`, Repository/UseCase protocols
- Android: `*ViewModelProtocol.kt`, Repository/UseCase interfaces
- Web: `*ViewModelBase.ts`, Repository/UseCase bases
- Method / var signatures come from `dataFlow.viewModel` and `dataFlow.{repositories,useCases}[].methods`
- Impl inheritance list completion, Kotlin `override` insertion

**To change any of these, edit the spec.** Then `jui build` regenerates.

`jui lint-generated` detects hand-edits of generated files. CI should run it.

```bash
jui lint-generated
# Exit 0 ← required for CI
```

---

## 4. Localization — the layout half is machine-checked, **the VM half is not**

`jui lint-strings` scans the Layout JSON (style-merged, alias-canonicalized) for user-visible string attributes whose value is a raw literal that does not resolve through `strings.json`. Exit 0 is the gate; the `jsonui-localize` skill is the **repair tool** you run when the lint reports findings.

```bash
jui lint-strings
# Exit 0 ← required. 2 = raw literals / stale allowlist entries
```

- Every screen completion must end with a clean `jui lint-strings` (and a `jsonui-localize` pass for the VM-side strings the layout scan cannot see)
- Intentional non-localized literals (brand names, format scaffolding) go in `.jui-strings-allowlist.json` — one entry per (layout, path, value), **reason required**. The ledger fails in both directions: an unlisted raw literal, and a stale entry whose literal is gone
- `jui build --lint-strings` (or `"lint": {"strings": true}` in jui.config.json) runs the same check inside the build, where findings are **printed** as build warnings — the build's exit code does not change (it has no warning tally), so they gate only through invariant 1, i.e. through you counting them. The hard gate that actually fails is `jui lint-strings` run on its own (exit 2)
- VM-side strings (error messages, alert titles) are still the `jsonui-localize` skill's territory — the lint covers the layout surface

### ⛔ The VM half has no gate at all — the sweep is the gate

`jui lint-strings` proves **layout** literals resolve. `--usage` compares the
**key sets** between `strings.json` and code that references keys. A display
string written straight into VM source **references no key**, so neither sees
it: build clean, verify no drift, lint exit 0, and the untranslated text ships.
This is the one invariant whose violation produces **no red anywhere**.

So the VM side is a **procedure**, not a check, and it must be executed rather
than intended:

- **Every string literal in VM/Repository/UseCase source is display text
  unless** it is a dictionary/JSON key or param name, an API path or URL, an
  enum raw value / state id / screen id, log output that is never rendered, or
  a word-free format specifier (`"%.2f"`, `", "`). **When unsure, it is display
  text** — a redundant key costs one entry; an inlined display string ships
  untranslated and nothing reports it.
- Do not decide "is this user-visible?" literal by literal while writing logic.
  That is where it leaks: an error message does not feel like UI text while you
  are writing error handling. **Sweep mechanically and account for every hit.**
- **Report the denominator**: "swept N literals across these files, localized
  M". A bare "0 strings found" from reading the wrong file is indistinguishable
  from a screen that was already clean — and so are all four green gates.

Most-missed, all display text: error/validation messages, empty-state text,
alert titles/bodies/buttons (`"OK"`, `"キャンセル"`), status labels assigned in
code, units concatenated onto numbers (`"\(count)件"`), accessibility labels,
and words produced by a `switch`/`when` over a state.

---

## 5. DTO files are **regenerated** every build — never edit

Files under the per-platform DTO directory carry `@generated` markers and are rewritten on every `jui build` from the swagger source:

- iOS: `Model/Generated/*Dto.swift` (and `Model/Generated/{EnumName}.swift` for standalone enums)
- Android: `<source_directory>/kotlin/<package_path>/<model_subpackage>/generated/*Dto.kt`
- Web: `<source_directory>/models/generated/*Dto.ts`

To change a DTO field shape, edit the swagger schema (`docs/api/*.json`). The DTO regenerates on the next build.

---

## 6. Domain scaffolds are **user-owned after first emit**

Files at the Domain level — `Model/{Name}.swift` / `<package>/model/{Name}.kt` / `models/{Name}.ts` — are scaffolded **once** by `jui build` (containing just `let dto: {Name}Dto` + init/factory) and then **never touched** by codegen.

- Add proxy properties, computed properties, stored properties, and methods directly to the Domain file
- To regenerate a Domain scaffold from scratch (rare), delete the file and rerun `jui build`
- `jui verify --fail-on-diff` does NOT check Domain drift — user editing is expected

---

## 7. `jui verify --fail-on-diff` checks **DTO drift only**

`jui verify` regenerates the DTO bytes in memory and compares against the on-disk DTO files. A diff means swagger changed but `jui build` wasn't re-run, or someone hand-edited a DTO (violation of invariant 5).

- Drift detected → run `jui build` (or `jui g api --dry-run --json` to see what would change without writing)
- The drift check is independent of `jui build`; it runs even when the build pipeline hasn't been executed

---

## 8. Filter changes can **delete DTOs** via orphan prune

`api.schemas.include_paths` / `exclude_paths` / `include_schemas` / `exclude_schemas` modifications change the kept schema set. DTOs that fall out of the kept set are **deleted on the next `jui build`** (orphan prune).

- Domain scaffolds for those schemas are NOT auto-deleted (user code may still reference them)
- `jui lint-generated --fail-on-orphan` (Phase 4 deliverable) flags orphan Domain scaffolds for cleanup
- Filter changes are reversible — restore the previous filter and `jui build` regenerates the DTOs

---

## Gate summary (CI triad + process gate + API model)

| # | Gate | Check | Enforced by |
|---|------|-------|-------------|
| 1 | Layout correctness | `jui build` 0 warnings | build toolchain |
| 2 | Spec ↔ Layout alignment | `jui verify --fail-on-diff` | verify |
| 3 | Generated file integrity | `jui lint-generated` | lint |
| 4 | Localization complete | `jui lint-strings` exit 0 (layout) + **VM literal sweep, accounted for** (VM strings — **no gate**) | lint + **procedure only** |
| 5 | DTO files unmodified by hand | `jui lint-generated` | lint |
| 6 | Domain scaffold preservation | `jui build` skips existing | build toolchain |
| 7 | DTO drift detection | `jui verify --fail-on-diff` | verify |

A screen is "done" only when invariants 1-4 hold (and 5-7 hold whenever the project uses swagger-driven Data Models).
