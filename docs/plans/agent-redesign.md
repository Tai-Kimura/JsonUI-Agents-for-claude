# エージェント構成刷新計画

作成日: 2026-04-20
対象: `JsonUI-Agents-for-claude` / `JsonUI-Agents-for-Codex`
関連: `/Users/like-a-rolling_stone/resource/jsonui-cli/docs/jui_tools_README.md`

## 背景と目的

現行構成（10 エージェント + 27 スキル）は以下の課題を抱える:

- 責務重複（orchestrator / setup / screen-impl が platform/mode を各自で質問）
- スキルの強制チェーン（generator→layout→refactor→data→build→viewmodel→localize）が spec 駆動の本来の姿と乖離
- MCP 28 ツールが整備済みなのに、全エージェントが `jui` を Bash でシェルアウト
- 「FORBIDDEN 12 項目」のゲートキーピング過多で単純タスクも重い
- Codex 版は 9 ワークフローのうち 3 しか対応していない

**本計画の方針:**

1. **spec 駆動を徹底** — spec が本体、生成物は触らない、Layout JSON は SSoT として手で育てる
2. **MCP-first** — Bash シェルアウトは MCP 未カバーの 4 コマンドだけに限定
3. **薄いオーケストレーション** — 9 エージェント（うち 1 個は READ-ONLY デバッグ）に集約
4. **ゲートは 4 本** — build 0 警告 / verify diff なし / @generated 不可触 / localize 必須
5. **Claude と Codex は中身共通、invocation 記法だけ差し替え**

---

## 仕様駆動ワークフローの整理

README を精読して確定した「人間/エージェントが手で書くべき対象」:

| 対象 | ファイル | 担当フェーズ |
|---|---|---|
| spec 本体 | `docs/screens/json/*.spec.json` | define |
| Layout JSON（SSoT） | `docs/screens/layouts/*.json` | implement |
| Styles / includes | `docs/screens/layouts/Styles/*.json` ほか | implement |
| strings.json | `docs/screens/layouts/Resources/strings.json` | implement |
| VM method 中身 | 各プラットフォームの `*ViewModel.*` | implement |
| Repository / UseCase 中身 | 生成された Impl の method body | implement |
| Navigation | NavigationStack / NavHost / Router（spec 外） | navigation-{ios/android/web} |
| テスト | `tests/screens/*` | test |
| `@jui:protocol` marker | VM Impl コメント | implement（稀） |

**触らない（`@generated`）:**
- Protocol / Interface / ViewModelBase
- ViewModel の method/var **シグネチャ**（spec 側の `dataFlow.viewModel` を直す）
- Repository / UseCase のシグネチャ
- 継承リスト・Kotlin `override`
- SVG 変換物

---

## 4 つのゲート（正しさの担保）

| ゲート | 検出手段 | 内容 |
|---|---|---|
| **Layout の正しさ** | `jui build` **0 警告 MUST** | 属性名・bind 可否・型・platform/responsive 構造・パス解決 |
| **spec ↔ Layout 構造整合** | `jui verify --fail-on-diff` **diff なし MUST** | spec から期待される構造と Layout JSON の差分 |
| **生成物の保護** | `jui lint-generated` | `@generated` marker 破損検知（CI） |
| **ローカライズ** | **`jsonui-localize` skill 実行必須** | build が未ローカライズ文字列を catch しないための process gate |

---

## 最終エージェント構成（9 体）

| # | エージェント | R/W | 責務 |
|---|---|---|---|
| 1 | **conductor** | R | 入口。repo 状態（spec 数・layout 数・`jui.config.json` 有無）を MCP で読み、次のエージェントへ誘導 |
| 2 | **define** | W | spec 作成／修正（screen spec / component spec / swagger / dataFlow）。`doc_validate_spec` + `jui_verify` で合格させて渡す |
| 3 | **ground** | W | `jui_init`、platform setup、type-map 雛形 |
| 4 | **implement** | W | `jui_generate_project` → Layout/Styles 編集 → VM body → localize → `jui_build` (0 警告) → `jui_verify` (diff なし) |
| 5 | **navigation-ios** | W | SwiftUI `NavigationStack` / UIKit `UINavigationController`（mode で分岐） |
| 6 | **navigation-android** | W | Compose Navigation / Fragment + NavGraph（mode で分岐） |
| 7 | **navigation-web** | W | React Router / Next.js App Router |
| 8 | **test** | W | screen/flow test + `doc_generate_html` |
| 9 | **debug** | **R** | **READ-ONLY のバグ調査。spec から逆引き、結果を修正エージェントへルート** |

旧 10 → 新 9。`requirements` / `spec` / `modify` / `responsive` / `investigate` / `feature-plan` は `conductor`・`define`・`implement`・`debug` に吸収、代わりに navigation を 3 分割 + debug 新設。

### `debug` エージェント（詳細）

spec 駆動のバグ調査を強制。ランダムコードサーフィンを禁止し、spec を必ず出発点にする。

**症状 → spec セクションの対応表:**

| 症状タイプ | 起点セクション | 次に見る場所 |
|---|---|---|
| UI が表示されない／崩れ | `structure.components` | Layout JSON / Styles |
| ボタン押しても何も起きない | `stateManagement.eventHandlers` + `dataFlow.viewModel.methods` | VM method body |
| データが表示されない／古い | `dataFlow.viewModel.vars` + binding | Repository/UseCase body |
| 表示/非表示が切り替わらない | `stateManagement.displayLogic` | Layout `visibility` + VM 該当 var |
| API エラー | `dataFlow.apiEndpoints` + `repositories[].methods[].endpoint` | Repository body |
| 画面遷移不具合 | `userActions` / `transitions` + Navigation コード | navigation-{ios/android/web} |
| クラッシュ | 上記 + 型整合 | VM body + 型変換 |
| spec-external（Navigation 固有／infra／runtime race） | ― | 純 impl 調査 |

**標準フロー:**

```
入力: 症状（自然言語）+ optional: スタックトレース / ログ / 再現手順
  1. list_screen_specs で該当画面を絞り込み
  2. read_spec_file で spec 読込
  3. 症状分類し関連セクション特定
  4. 3 ゲートを診断ツールとして並行実行:
     - jui_verify(detail=true)
     - jui_build()
     - doc_validate_spec(file)
  5. ゲート fail → それが根本原因候補 #1
     全 pass → impl 側 logic bug
  6. impl トレース（特定 section に紐づく実装 grep）
  7. 構造化レポート:
     - 症状サマリ / 絞り込んだ spec セクション / ゲート結果
     - 根本原因仮説 / 修正先分類 / 次に起動すべきエージェント
  8. READ-ONLY 終了。修正は別エージェントへ委譲。
```

---

## 最終スキル構成（11 個）

| # | スキル | 備考 |
|---|---|---|
| 1 | `jsonui-screen-spec` | screen_spec 書き方 |
| 2 | `jsonui-component-spec` | component_spec 書き方 |
| 3 | `jsonui-swagger` | API/DB OpenAPI |
| 4 | `jsonui-dataflow` | `dataFlow.{viewModel,repositories,useCases,apiEndpoints}` + Mermaid linkage |
| 5 | `jsonui-layout` | Layout JSON + Styles + include/cellClasses 統合（旧 layout + refactor + generator の一部） |
| 6 | `jsonui-viewmodel-impl` | VM/Repo/UseCase の method **body**（シグネチャ不可触） |
| 7 | **`jsonui-localize`** | **強制実行。未登録文字列検出 + strings.json 登録** |
| 8 | `jsonui-platform-setup` | 旧 5 setup スキルを引数で統合 |
| 9 | `jsonui-screen-test` | 単一画面テスト |
| 10 | `jsonui-flow-test` | マルチ画面フローテスト |
| 11 | `jsonui-test-doc` | テストドキュメント HTML |

旧 27 → 新 11。Navigation は skill ではなくエージェント化。削除:

- `jsonui-generator` → `jui g project` は MCP 1 発
- `jsonui-refactor` / `jsonui-data` → Layout + spec dataFlow に吸収
- `jsonui-spec-review` → `jui verify` で代替
- `jsonui-converter` / `jsonui-doc-rules` → 必要時 define のサブタスク
- `jsonui-requirements-gather` → define に吸収
- `jsonui-binding-validator`（新規提案していたもの）→ `jui build` 0 警告ゲートで代替、不要
- 5 つの platform-setup → `jsonui-platform-setup` 1 本に統合

---

## ルール（4 本）

> 1. `jui build` は **0 警告** で通す（1 つでも警告が出たらタスク未完）
> 2. `jui verify --fail-on-diff` は **diff なし** で通す
> 3. `@generated` ファイル（Protocol / Interface / ViewModelBase / 生成スタブ）は **手で編集しない**
> 4. **`jsonui-localize` skill を完了しない限り画面完了とみなさない**

旧「FORBIDDEN 12 項目」は廃止。

---

## `implement` の定形ループ

```
前提: spec が define を通過（doc_validate_spec ok, jui verify ok）
  1. jui_generate_project(spec_file)       ← MCP / Layout skeleton + VM/Repo/UseCase スタブ
  2. edit: Layout / Styles / strings.json の UI 側
       lookup_component, lookup_attribute, get_binding_rules を MCP で引く
  3. edit: VM method body / Repository body / UseCase body（シグネチャ不可触）
  4. 画面遷移必要 → navigation-{ios|android|web} に委譲
  5. skill: jsonui-localize                 ← MUST。省略不可
  6. jui_build()                            ← 0 警告まで loop
  7. jui_verify(fail_on_diff=true)          ← diff なし
  8. 完了
```

---

## ワークフロー選択の簡素化（CLAUDE.md）

旧 9 択 → 新 4 択:

```
conductor が repo を読んで聞く:

1. 新規に何か作る        → define / ground / implement へ流す
2. 既存を直したい         → (a) バグ? → debug → 修正エージェントへ
                          → (b) 機能追加? → 該当エージェントへ
3. 調査だけしたい         → debug（spec 起点の構造調査）
4. Backend               → 既存ルールを完全 lift
```

---

## MCP ツール宣言方針

### 現状

既存 10 エージェント全員が MCP ツールを宣言していない:

```
jsonui-orchestrator.md    → tools: Read, Glob, Grep, Bash
jsonui-screen-impl.md     → tools: Read, Bash, Glob, Grep
...
```

→ 全員が `jui` を Bash でシェルアウトしている。MCP 28 ツールが遊んでいる状態。

### 方針: **パターン2（明示列挙）**

ワイルドカード (`mcp__jui-tools__*`) はプロンプト読込時に全ツール schema が展開されてトークンを食うため、必要なものだけ列挙:

```yaml
---
name: define
tools: >
  Read, Write, Edit, Glob, Grep,
  mcp__jui-tools__get_project_config,
  mcp__jui-tools__list_screen_specs,
  mcp__jui-tools__read_spec_file,
  mcp__jui-tools__doc_validate_spec,
  mcp__jui-tools__doc_generate_spec,
  mcp__jui-tools__jui_verify,
  mcp__jui-tools__lookup_component,
  mcp__jui-tools__lookup_attribute
---
```

### 各エージェント別 MCP ツール

| エージェント | 必要な MCP ツール |
|---|---|
| conductor | `get_project_config`, `list_screen_specs`, `list_layouts`, `list_component_specs` |
| define | `doc_init_spec`, `doc_init_component`, `doc_validate_spec`, `doc_validate_component`, `doc_generate_spec`, `read_spec_file`, `lookup_component`, `lookup_attribute`, `search_components`, `jui_verify` |
| ground | `jui_init`, `get_project_config` |
| implement | `jui_generate_project`, `jui_build`, `jui_verify`, `read_spec_file`, `read_layout_file`, `list_layouts`, `lookup_component`, `lookup_attribute`, `get_binding_rules`, `get_modifier_order`, `get_platform_mapping` |
| navigation-{ios/android/web} | `read_spec_file`, `read_layout_file`, `list_screen_specs`, `get_platform_mapping` |
| test | `list_screen_specs`, `read_spec_file`, `doc_generate_html` |
| debug | `get_project_config`, `list_screen_specs`, `list_layouts`, `read_spec_file`, `read_layout_file`, `jui_verify`, `jui_build`, `doc_validate_spec`, `lookup_component`, `lookup_attribute`, `search_components` + `Read, Bash, Glob, Grep` |

### Bash が残る 4 ケース

MCP でカバーされない CLI:

- `jui g screen` → `doc_init_spec` で大体代替可、必要時のみ Bash
- `jui migrate-layouts` → 個人プロジェクトなので実質不要
- `jui lint-generated` → CI 側で走らせる、エージェントから呼ばない
- `jui g converter` → 使うとき限定

→ 9 エージェント中 `ground` と `debug` 以外は **Bash 不要** にできる。

---

## MCP 強化（別トラック、並行可）

`jsonui-mcp-server` に spec 側ツールを追加すると、skill プロンプトから「書式ハードコード」を駆逐できて validator と永久同期になる。

### 新規ツール案（7 個）

| ツール | 返すもの | 主な利用者 |
|---|---|---|
| `get_spec_schema` | `screen_spec` / `component_spec` / `screen_parent_spec` の完全 JSON Schema | define, CI |
| `list_spec_sections` | 全セクション名と一行説明 | エージェント一般 |
| `lookup_spec_section` | 指定セクションの schema + フィールド一覧 + 最小/完全サンプル + ルール + related | 各 skill |
| `get_dataflow_linkage_rules` | UC→Repo / Repo→Endpoint 宣言仕様 + Mermaid 描画簡約 | `jsonui-dataflow` |
| `get_viewmodel_protocol_rules` | `dataFlow.viewModel` 仕様、`@jui:protocol` grammar | `jsonui-viewmodel-impl` |
| `get_layoutfile_rules` | `metadata.layoutFile` の役割分担ルール | define, implement |
| `validate_spec_section` | セクション単位で schema チェック（書き込みなし） | ドラフト検証 |

**データソース方針: A 案（既存 validator 再利用）**

`jsonui_doc_cli` の JSON Schema を MCP が読んで配信 + `spec_sections/<section>.yaml` で「例・ルール文・related」だけ追加。schema は自動同期、散文だけ人間管理。

**段階投入:**
1. `lookup_spec_section` 単体実装
2. `jsonui-dataflow` skill を MCP 引きに書き換えて効果検証
3. OK なら他 6 本横展開

---

## Codex 版への適用

中身（9 エージェント + 11 スキル + 4 ルール）は 100% 共通。差分は invocation のみ:

| 項目 | Claude | Codex |
|---|---|---|
| 定義ファイル | `.md` + YAML frontmatter | `.toml` + `AGENTS.md` |
| サブエージェント起動 | Skill ツール自動 | `/agent <role>` でユーザー切替 |
| skill 記法 | `/x` | `$x` |
| MCP 宣言 | `tools:` に列挙 | `.codex/config.toml` で allowed_tools |

ビルドスクリプト 1 本で両形式を生成する設計が活きる。

---

## Phase 計画

| Phase | 内容 | 目安 |
|---|---|---|
| **1** | `rules/` 再編（4 本に整理） + `CLAUDE.md` 簡素化（9 択 → 4 択） + 全エージェントの `tools:` 行に MCP ツール追加方針記載 | 1 セッション |
| **2** | `conductor` 新設、旧 `orchestrator` を deprecate（並走期間設定） | 1 セッション |
| **3** | `define` / `ground` / `implement` / `test` / `debug` の統合版追加。navigation-{ios/android/web} 新設 | 2-3 セッション |
| **4** | skill を 27 → 11 に整理。MCP-first に書き換え | 2 セッション |
| **5** | Codex 版を同じ `rules/` + agents 構造に揃える | 1 セッション |
| **6** | 旧 agents/skills 削除、**install.sh（bootstrap）更新**、README/ドキュメント更新 | 1 セッション |
| **並行** | MCP spec section lookup（`lookup_spec_section` から） | 別トラック |

---

## Bootstrap（install.sh）の更新

### 現状

`JsonUI-Agents-for-claude/install.sh` と `JsonUI-Agents-for-Codex/install.sh` はエージェント／スキル一覧をハードコードで列挙しているインストーラ。`curl` で GitHub から各ファイルを個別 DL する方式。

**現状の問題:**

1. **既にドリフト発生**: install.sh が列挙しているのは 7 agents / 24 skills だが、実際の repo には 10 agents / 27 skills ある。`jsonui-feature-plan` / `jsonui-responsive` / `jsonui-investigate` など新しいエージェントがインストールされない
2. **examples ファイルもハードコード**: `get_skill_examples()` 内に case 文でスキル名→ファイル名リストを全部書いている
3. **スタート手順メッセージも古い**: `Option A / Option B` の 2 択案内で、CLAUDE.md の 9 択ワークフローと不整合
4. **Codex 版も同様の構造**で同じ問題を抱える

### 必要な更新内容

Phase 6 で以下を実施:

| 項目 | 作業 |
|---|---|
| `AGENT_FILES` | 旧 7（実際は 10 あるのにズレ）→ 新 9 体に差し替え（`conductor`, `define`, `ground`, `implement`, `navigation-ios`, `navigation-android`, `navigation-web`, `test`, `debug`） |
| `SKILL_DIRS` | 旧 24（実際は 27）→ 新 11 に差し替え |
| `get_skill_examples()` case 文 | 削除されたスキル分を除去、残存スキル（`jsonui-layout` 統合後のサンプル一覧など）を更新 |
| `RULE_FILES` | 4 本維持だが内容は Phase 1 で書き換え済みのものを配信 |
| スタート手順メッセージ | 旧「Option A / B」→ 新「4 択ワークフロー + conductor 誘導」に書き換え |
| MCP サーバの有無チェック（追加提案） | `jsonui-mcp-server` が未導入ならインストール案内を出す（実行はしないが警告） |

### 自動化案（推奨）

ハードコードをやめて repo の実体から自動列挙する方式に変える:

```bash
# Option A: GitHub API で agents/ skills/ rules/ の中身を動的取得
AGENT_FILES=$(curl -sL "https://api.github.com/repos/Tai-Kimura/JsonUI-Agents-for-claude/contents/agents?ref=$REF" | jq -r '.[].name')

# Option B: repo に manifest.json を置いてそれを読む
curl -sL "$REPO_URL/manifest.json" -o /tmp/manifest.json
AGENT_FILES=$(jq -r '.agents[]' /tmp/manifest.json)
```

**推奨は B 案（manifest.json）**: API rate limit を避けられる、オフラインでも manifest さえキャッシュがあれば動く、バージョンごとに何がインストールされるか明示できる。

### Codex 版 install.sh

同様に `.codex/config.toml` と `agents/*.toml` の列挙も manifest.json ベースに統一する。Claude/Codex で別々の manifest を持つか、1 つの manifest に platform フィールドを持たせるかは Phase 5 で決定。

### 検証項目

- [ ] 新規空ディレクトリで `./install.sh` を走らせて、9 agents / 11 skills / 4 rules / CLAUDE.md が正しく配置される
- [ ] `./install.sh -b develop` のようにブランチ指定オプションがまだ動く
- [ ] Codex 版 `install.sh` も同様に動く
- [ ] アップグレード時（既存 `.claude/agents/` に旧エージェントが残っている）の挙動: 旧ファイルを消すか、新ファイルだけ追加するか明確化。デフォルトは **新ファイル追加のみ、旧は残す**（ユーザーが気づいて削除できるよう warning 出す）
- [ ] スタート手順メッセージが新 4 択ワークフローを案内している

---

## Phase 1 の具体スコープ

- [ ] `rules/` ディレクトリ内のファイルを 4 本のルールに整理
- [ ] `CLAUDE.md` を 4 択 + conductor 誘導 + 4 ゲート明記 に簡素化
- [ ] MCP ツール宣言方針を `rules/` に追加
- [ ] `JsonUI-Agents-for-Codex/AGENTS.md` も同形に書き換え
- [ ] 旧エージェント／スキルは **削除しない**（並走期間）

---

## 未決事項（なし）

全論点決着済み:
- ✅ Layout 編集の正しさ → `jui build` 0 警告で担保
- ✅ localize は build で catch されないため process 強制
- ✅ `jsonui-layout` と `jsonui-styles` は統合（1 スキル）
- ✅ Navigation は各プラットフォーム専用エージェント（3 体）
- ✅ Migration は個人プロジェクトなので対応外
- ✅ MCP ツールは frontmatter `tools:` に明示列挙（パターン2）
- ✅ バグ調査エージェント `debug` 追加（READ-ONLY、spec 起点強制）

---

## 完了条件

Phase 6 完了時:
- 9 エージェント + 11 スキル + 4 ルールで spec 駆動開発が回る
- 全エージェントが MCP-first（Bash シェルアウトは必要最小限の 4 ケース）
- Claude と Codex が同一ルール・同一エージェント集で動作
- `debug` エージェントが spec 起点でバグを追える
- 旧 10 エージェント / 27 スキルが削除されドキュメントが更新されている
- `install.sh`（Claude/Codex 両方）が新構成を配信し、manifest.json ベースで自動列挙化されている
- 既存ユーザーのアップグレード手順が明文化されている

## 関連ドキュメント

- [`jui_tools README`](/Users/like-a-rolling_stone/resource/jsonui-cli/docs/jui_tools_README.md)
- `JsonUI-Agents-for-claude/CLAUDE.md`（現行版）
- `JsonUI-Agents-for-Codex/AGENTS.md`（現行版）
- `jsonui-mcp-server/` — MCP ツール実装
