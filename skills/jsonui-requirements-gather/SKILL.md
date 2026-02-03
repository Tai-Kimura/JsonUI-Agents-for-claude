---
name: jsonui-requirements-gather
description: Gathers detailed app requirements through friendly dialogue and creates structured requirement documents.
tools: Read, Write, Glob, Grep
---

# JsonUI Requirements Gather Skill

## Purpose

Gather detailed requirements from users (including non-engineers) through friendly dialogue and create structured requirement documents.

## Input Variables

- `platforms` - Target platforms (iOS, Android, Web)
- `app_concept` - Basic app idea from user
- `project_directory` - Where to save requirement documents

## Workflow

### Phase 1: Understand the Core Purpose

Ask about the main goal:

```
「{app_concept}」について、もう少し教えてください。

このアプリを使う人は誰ですか？
例：「お店のスタッフ」「一般のお客さん」「会社の従業員」など
```

Then ask:

```
このアプリで一番大事な機能は何ですか？
「これができないと意味がない」というものを教えてください。
```

### Phase 2: Identify Users (Actors)

Ask about different types of users:

```
このアプリを使う人の種類を教えてください。

例えばカフェ予約アプリなら：
- お客さん（予約する人）
- お店のスタッフ（予約を管理する人）
- 店長（売上を見る人）

あなたのアプリでは、どんな人が使いますか？
```

### Phase 3: List Main Features

For each user type, ask:

```
{user_type}さんは、このアプリで何ができる必要がありますか？

やりたいことを箇条書きで教えてください。
例：
- 空いている時間を確認する
- 予約を入れる
- 予約をキャンセルする
```

### Phase 4: Screen Flow

Ask about the journey:

```
{user_type}さんがアプリを開いてから、目的を達成するまでの流れを教えてください。

例：
1. アプリを開く
2. ログインする
3. 日付を選ぶ
4. 時間を選ぶ
5. 予約を確定する
```

### Phase 5: Data Requirements

Ask about important information:

```
このアプリで管理する必要がある情報は何ですか？

例（カフェ予約アプリの場合）：
- お客さんの情報（名前、電話番号、メール）
- 予約情報（日時、人数、席の種類）
- お店の情報（営業時間、席数）
```

### Phase 6: Special Requirements

Ask about any special needs:

```
他に気になることはありますか？

例：
- ログインは必要？（メール、SNS、電話番号）
- 通知は必要？（予約リマインダーなど）
- オフラインでも使えるべき？
- 複数言語対応は必要？
```

### Phase 7: Confirm and Create Documents

Summarize and confirm:

```
ここまでの内容を整理しました。確認してください。

【アプリ概要】
{summary}

【ユーザー】
{user_types}

【主な機能】
{features}

【画面の流れ】
{screen_flow}

これで合っていますか？修正があれば教えてください。
```

After confirmation, create the documents.

---

## Output Documents

### 1. requirements.md

Location: `{project_directory}/docs/requirements/requirements.md`

```markdown
# {App Name} 要件定義書

## 概要
- アプリ名: {name}
- プラットフォーム: {platforms}
- 概要: {description}

## ユーザー種別
| ユーザー | 説明 |
|---------|------|
| {user1} | {description1} |

## 機能要件
### {User Type 1}
- [ ] {feature1}
- [ ] {feature2}

## 非機能要件
- ログイン方式: {login_method}
- 通知: {notifications}
- 対応言語: {languages}

## 制約事項
- {constraints}
```

### 2. screens.md

Location: `{project_directory}/docs/requirements/screens.md`

```markdown
# 画面一覧

## {User Type 1} 向け画面

| 画面名 | 説明 | 主な機能 |
|--------|------|----------|
| {screen1} | {desc} | {features} |

## 画面遷移

{User Type 1}:
1. {screen1} → {screen2} （{action}）
2. {screen2} → {screen3} （{action}）
```

### 3. features.md

Location: `{project_directory}/docs/requirements/features.md`

```markdown
# 機能一覧

## 必須機能（MVP）
| 機能 | 説明 | 優先度 |
|------|------|--------|
| {feature1} | {desc} | 高 |

## 追加機能（将来）
| 機能 | 説明 | 優先度 |
|------|------|--------|
| {feature2} | {desc} | 中 |
```

---

## Important Rules

- **One question at a time** - Never ask multiple questions together
- **Simple language** - Avoid technical jargon
- **Use examples** - Always provide concrete examples
- **Confirm understanding** - Summarize and confirm before proceeding
- **User's language** - Respond in the language the user uses
- **Be patient** - Allow users to think and respond at their pace
- **Be flexible** - If user doesn't know, suggest options

---

## If User Doesn't Know

When user is unsure, provide suggestions:

```
わからない場合は、いくつか提案しますね。

よくあるパターンは：
1. {option1}
2. {option2}
3. {option3}

どれが近いですか？または「わからない」でも大丈夫です。
```

---

## Completion

After creating all documents:

```
要件定義書を作成しました！

作成したファイル：
- docs/requirements/requirements.md（要件定義書）
- docs/requirements/screens.md（画面一覧）
- docs/requirements/features.md（機能一覧）

次のステップ：
この内容をもとに、画面の詳細設計に進みます。
オーケストレータに戻って、「要件定義完了」と伝えてください。
```
