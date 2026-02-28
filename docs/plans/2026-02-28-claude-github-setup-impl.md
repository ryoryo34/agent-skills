# claude-github-setup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Claude Code Action を使った GitHub 自動化（PRレビュー、Issue自動実装、レビュー指摘の自動修正）を任意のプロジェクトに対話的にセットアップするスキルを作成する。

**Architecture:** `skills/claude-github-setup/` に SKILL.md と references/ テンプレート群を配置。SKILL.md が対話フローを制御し、プロジェクト検出 → モジュール選択 → レビュープロンプトカスタマイズ → ファイル生成 → 後処理ガイドの5フェーズで進行する。

**Tech Stack:** Claude Code Skills（SKILL.md）、GitHub Actions YAML（anthropics/claude-code-action）、agent-skills/code-review の9基準

---

### Task 1: ディレクトリ構造の作成

**Files:**
- Create: `skills/claude-github-setup/SKILL.md` (frontmatter のみ)
- Create: `skills/claude-github-setup/references/workflows/` (ディレクトリ)
- Create: `skills/claude-github-setup/references/issue-templates/` (ディレクトリ)

**Step 1: ディレクトリを作成**

```bash
mkdir -p skills/claude-github-setup/references/workflows
mkdir -p skills/claude-github-setup/references/issue-templates
```

**Step 2: SKILL.md に frontmatter を書く**

```markdown
---
name: claude-github-setup
description: Claude Code Action を使った GitHub 自動化（PR自動レビュー、Issue自動実装、レビュー指摘の自動修正）を対話的にセットアップする。Triggers include "claude-github-setup", "setup claude github", "Claude GitHub 自動化", "PRレビュー自動化", "claude-code-action setup".
allowed-tools: Read, Glob, Grep, Write, Bash, AskUserQuestion
context: fork
---

(Phase 実装は後続タスクで追加)
```

**Step 3: コミット**

```bash
git add skills/claude-github-setup/
git commit -m "feat: scaffold claude-github-setup skill directory"
```

---

### Task 2: テンプレート — claude.yml (Claude Code Action メンション & ラベルトリガー)

**Files:**
- Create: `skills/claude-github-setup/references/workflows/claude.yml`

**Step 1: テンプレートファイルを作成**

ai-sentinel の `.github/workflows/claude.yml` をベースに汎用化。`@claude` メンション対応と `claude-task` ラベルトリガーを含む。

```yaml
name: Claude Code

on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  issues:
    types: [labeled]
  pull_request_review:
    types: [submitted]

jobs:
  claude:
    if: |
      (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review' && contains(github.event.review.body, '@claude')) ||
      (github.event_name == 'issues' && github.event.action == 'labeled' && github.event.label.name == 'claude-task')
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: write
      id-token: write
      actions: read
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 1

      - name: Run Claude Code
        id: claude
        uses: anthropics/claude-code-action@v1
        with:
          claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
          allowed_bots: "claude[bot]"
          label_trigger: claude-task
```

**Step 2: コミット**

```bash
git add skills/claude-github-setup/references/workflows/claude.yml
git commit -m "feat: add claude.yml workflow template"
```

---

### Task 3: テンプレート — claude-code-review.yml (Claude PR自動レビュー)

**Files:**
- Create: `skills/claude-github-setup/references/workflows/claude-code-review.yml`

**Step 1: テンプレートファイルを作成**

レビュープロンプト部分に `{{BASE_REVIEW_CRITERIA}}` と `{{PROJECT_SPECIFIC_CHECKS}}` のプレースホルダーを含めた汎用テンプレート。

```yaml
name: Claude Code Review

on:
  pull_request:
    types: [opened, synchronize, ready_for_review, reopened]

jobs:
  claude-review:
    runs-on: ubuntu-latest
    if: github.event.pull_request.user.type != 'Bot'
    permissions:
      contents: read
      pull-requests: write
      issues: write
      id-token: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 1

      - name: Run Claude Code Review
        id: claude-review
        uses: anthropics/claude-code-action@v1
        with:
          claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
          track_progress: true
          prompt: |
            REPO: ${{ github.repository }}
            PR NUMBER: ${{ github.event.pull_request.number }}
            EVENT ACTION: ${{ github.event.action }}

            このPRを日本語でレビューしてください。

            ## レビュールール

            1. まず `gh pr diff` で変更ファイルのパスを確認し、関連するセクションのみチェックすること
            2. 問題が見つかった項目だけ報告すること（問題のない項目は報告しない）
            3. 各指摘には重要度を付与すること：
               - 🔴 **必須修正**: バグ、セキュリティリスク、データ損失の可能性
               - 🟡 **推奨**: コード品質・パフォーマンス・保守性の改善
               - 🟢 **提案**: より良い書き方やスタイルの提案
            4. 問題が見つからなかった場合は「レビュー完了：特に問題は見つかりませんでした 👍」とだけコメントすること

            ## チェック観点（ベース基準）

            {{BASE_REVIEW_CRITERIA}}

            {{PROJECT_SPECIFIC_CHECKS}}

            ## 再レビュー時のスレッド解決（EVENT ACTION が `synchronize` の場合のみ）

            EVENT ACTION が `synchronize` の場合、通常のレビューに加えて以下を実行すること：

            1. GraphQL で PR の未解決レビュースレッドを取得する
            2. `claude[bot]` が投稿した未解決スレッドのみを対象とする
            3. 各スレッドの `path` と `line` を参照し、現在のコードと比較して指摘が解消されたか判断する
            4. 解消済みスレッドを GraphQL mutation で Resolve する
            5. 通常レビュー結果と統合し、解決済みスレッドと未解決スレッドを明記する

            EVENT ACTION が `opened` や `reopened` の場合はこのセクションをスキップすること。

            ## レビュー方法
            - PRブランチは作業ディレクトリにチェックアウト済み
            - トップレベルのフィードバックは `gh pr comment` を使用
            - コード行ごとの指摘は `gh api` で inline comment を作成
            - GitHub コメントのみ投稿し、メッセージとしては返さないこと

          claude_args: |
            --allowedTools "Bash(gh pr comment:*),Bash(gh pr diff:*),Bash(gh pr view:*),Bash(gh api:*)"
```

**Step 2: コミット**

```bash
git add skills/claude-github-setup/references/workflows/claude-code-review.yml
git commit -m "feat: add claude-code-review.yml template with review prompt placeholders"
```

---

### Task 4: テンプレート — auto-fix.yml (Claude 自動修正)

**Files:**
- Create: `skills/claude-github-setup/references/workflows/auto-fix.yml`

**Step 1: テンプレートファイルを作成**

Claude Code Review の指摘を自動修正する workflow。

```yaml
name: Auto Fix After Claude Code Review

on:
  workflow_run:
    workflows: ["Claude Code Review"]
    types: [completed]

jobs:
  auto-fix:
    runs-on: ubuntu-latest
    if: |
      github.event.workflow_run.conclusion == 'success' &&
      github.event.workflow_run.pull_requests[0] != null

    permissions:
      contents: write
      pull-requests: write
      issues: write
      id-token: write

    steps:
      - name: Get PR info
        id: pr-info
        env:
          PR_NUMBER: ${{ github.event.workflow_run.pull_requests[0].number }}
          HEAD_REF: ${{ github.event.workflow_run.pull_requests[0].head.ref }}
        run: |
          echo "pr_number=$PR_NUMBER" >> $GITHUB_OUTPUT
          echo "head_ref=$HEAD_REF" >> $GITHUB_OUTPUT

      - name: Check if review found issues
        id: check-issues
        env:
          GH_TOKEN: ${{ github.token }}
          PR_NUMBER: ${{ steps.pr-info.outputs.pr_number }}
          REPO: ${{ github.repository }}
        run: |
          LATEST_COMMENT=$(gh pr view "$PR_NUMBER" \
            --repo "$REPO" \
            --json comments \
            --jq '[.comments[] | select(.author.login == "claude[bot]")] | last | .body // ""')
          if echo "$LATEST_COMMENT" | grep -q "特に問題は見つかりませんでした"; then
            echo "has_issues=false" >> $GITHUB_OUTPUT
            echo "::notice::No issues found in review, skipping auto-fix"
          else
            echo "has_issues=true" >> $GITHUB_OUTPUT
          fi

      - name: Checkout PR branch
        if: steps.check-issues.outputs.has_issues == 'true'
        uses: actions/checkout@v4
        with:
          ref: ${{ steps.pr-info.outputs.head_ref }}
          fetch-depth: 0

      - name: Run Claude to fix issues
        if: steps.check-issues.outputs.has_issues == 'true'
        uses: anthropics/claude-code-action@v1
        with:
          claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
          allowed_bots: "claude[bot]"
          claude_args: |
            --allowedTools "Read,Edit,Write,Glob,Grep,Bash(git add *),Bash(git commit *),Bash(git push *),Bash(gh pr view *),Bash(gh pr comment *),Bash(gh api *)"
          prompt: |
            REPO: ${{ github.repository }}
            PR NUMBER: ${{ steps.pr-info.outputs.pr_number }}

            このPRに投稿された Claude のコードレビューコメントを読んで、指摘された問題を修正してください。

            ## 手順

            1. `gh pr view ${{ steps.pr-info.outputs.pr_number }} --json comments` でトップレベルコメントを取得
            2. `gh api /repos/${{ github.repository }}/pulls/${{ steps.pr-info.outputs.pr_number }}/comments` でインラインレビューコメントを取得
            3. 🔴 **必須修正** と 🟡 **推奨** の指摘事項を修正する（🟢 提案はスキップしてよい）
            4. 修正内容を git commit する（メッセージ: `fix: apply code review suggestions from Claude`）
            5. `git push` でPRブランチに反映
            6. `gh pr comment ${{ steps.pr-info.outputs.pr_number }} --body` で修正完了を報告

            ## 修正完了コメントのフォーマット

            ```
            ## 🤖 自動修正完了

            レビューで指摘された以下の問題を修正しました：

            - （修正した内容をリストアップ）

            🟢 提案事項はスキップしています。必要であれば手動で対応してください。
            ```
```

**Step 2: コミット**

```bash
git add skills/claude-github-setup/references/workflows/auto-fix.yml
git commit -m "feat: add auto-fix.yml workflow template"
```

---

### Task 5: テンプレート — Issue Templates & PR Template

**Files:**
- Create: `skills/claude-github-setup/references/issue-templates/bug.yml`
- Create: `skills/claude-github-setup/references/issue-templates/feature.yml`
- Create: `skills/claude-github-setup/references/issue-templates/task.yml`
- Create: `skills/claude-github-setup/references/issue-templates/config.yml`
- Create: `skills/claude-github-setup/references/pr-template.md`

**Step 1: 5つのテンプレートファイルを作成**

Bug Report:
```yaml
name: Bug Report
description: バグの報告
labels: ["bug"]
body:
  - type: textarea
    id: description
    attributes:
      label: バグの説明
      description: 何が起きているか、簡潔に説明してください
    validations:
      required: true
  - type: textarea
    id: reproduction
    attributes:
      label: 再現手順
      description: バグを再現するための手順
  - type: textarea
    id: expected
    attributes:
      label: 期待する動作
      description: 本来どうなるべきか
  - type: textarea
    id: actual
    attributes:
      label: 実際の動作
      description: 実際に起きていること
```

Feature Request:
```yaml
name: Feature Request
description: 新機能のリクエスト
labels: ["enhancement"]
body:
  - type: textarea
    id: summary
    attributes:
      label: 概要
      description: どんな機能がほしいか、簡潔に説明してください
    validations:
      required: true
  - type: textarea
    id: motivation
    attributes:
      label: 背景・動機
      description: なぜこの機能が必要なのか
  - type: textarea
    id: acceptance-criteria
    attributes:
      label: 完了条件
      description: この機能が「完了」と言える条件
  - type: textarea
    id: technical-notes
    attributes:
      label: 技術メモ
      description: 実装に関するヒントや制約
```

Claude Task:
```yaml
name: Claude Task
description: Claude に直接実行させるタスク
labels: ["claude-task"]
body:
  - type: textarea
    id: task
    attributes:
      label: タスク内容
      description: Claude に実行してほしいタスクを具体的に記述してください
    validations:
      required: true
  - type: textarea
    id: related-files
    attributes:
      label: 関連ファイル
      description: 変更対象のファイルやディレクトリがあれば記載
```

config.yml:
```yaml
blank_issues_enabled: true
```

PR Template:
```markdown
## 概要

<!-- このPRで何をしたか簡潔に -->

## 変更内容

<!-- 主な変更点をリストで -->

-

## 関連 Issue

<!-- Closes #XX -->

## テストチェックリスト

- [ ] ローカルでビルドが通る
- [ ] 既存機能に影響がない
```

**Step 2: コミット**

```bash
git add skills/claude-github-setup/references/issue-templates/ skills/claude-github-setup/references/pr-template.md
git commit -m "feat: add issue templates and PR template"
```

---

### Task 6: SKILL.md — 全 Phase 実装

**Files:**
- Modify: `skills/claude-github-setup/SKILL.md`

**Step 1: SKILL.md の全内容を書く**

frontmatter + Phase 1〜5 を一括で実装する。ポイント:

- Phase 1: プロジェクト検出（言語、フレームワーク、linter、既存 .github/ 構成、CLAUDE.md ルール）
- Phase 2: モジュール選択（AskUserQuestion multiSelect）
- Phase 3: レビュープロンプトカスタマイズ（code-review の9基準注入 + プロジェクト固有チェック + ユーザー追加観点）
- Phase 4: ファイル生成（テンプレート読み取り → プレースホルダー置換 → Write）
- Phase 5: 後処理ガイド（CLAUDE_CODE_OAUTH_TOKEN 設定手順）

```markdown
---
name: claude-github-setup
description: Claude Code Action を使った GitHub 自動化（PR自動レビュー、Issue自動実装、レビュー指摘の自動修正）を対話的にセットアップする。Triggers include "claude-github-setup", "setup claude github", "Claude GitHub 自動化", "PRレビュー自動化", "claude-code-action setup".
allowed-tools: Read, Glob, Grep, Write, Bash, AskUserQuestion
context: fork
---

# Claude GitHub Setup

Claude Code Action を使った GitHub 自動化を、任意のプロジェクトに対話的にセットアップする。

## 前提

- 対象プロジェクトが git リポジトリであること
- GitHub にリモートリポジトリがあること
- Claude Code の OAuth トークンが取得済み or 取得可能であること

## Phase 1: プロジェクト検出

対象プロジェクトの技術スタックと既存構成を自動検出する。

1. リポジトリのルートで以下を確認:
   - `package.json` → Node.js/TypeScript、使用フレームワーク・linter を検出
   - `requirements.txt` / `pyproject.toml` / `setup.py` → Python
   - `go.mod` → Go
   - `Cargo.toml` → Rust
   - `pom.xml` / `build.gradle` → Java
   - その他の言語ファイル拡張子を Glob で検出
2. 既存の `.github/workflows/` を確認
   - 既に claude 系 workflow がある場合は警告して上書き確認
3. `.github/ISSUE_TEMPLATE/` と `.github/PULL_REQUEST_TEMPLATE.md` の有無を確認
4. `CLAUDE.md` と `.claude/rules/` があれば読み取り、プロジェクト固有ルールを収集
5. linter / formatter 設定を検出:
   - `.eslintrc*`, `biome.json`, `.prettierrc*` (JS/TS)
   - `ruff.toml`, `.flake8`, `pyproject.toml [tool.ruff]` (Python)
   - `.golangci.yml` (Go)
   - `clippy.toml` (Rust)

検出結果をユーザーに表示:

```
## プロジェクト検出結果
- 言語: [検出された言語]
- フレームワーク: [検出されたフレームワーク]
- Linter/Formatter: [検出されたツール]
- 既存 GitHub 設定: [あり/なし、詳細]
- CLAUDE.md ルール: [検出された固有ルール、要約]
```

## Phase 2: モジュール選択

AskUserQuestion（multiSelect: true）でセットアップするモジュールをユーザーに選ばせる。

選択肢:
1. **claude.yml** — @claude メンション対応 & claude-task ラベル自動実装
2. **claude-code-review.yml** — Claude による PR 自動レビュー（レビュープロンプトは Phase 3 でカスタマイズ）
3. **auto-fix.yml** — Claude レビュー指摘の自動修正（claude-code-review.yml が前提）
4. **Issue Templates** — Bug Report / Feature Request / Claude Task テンプレート
5. **PR Template** — Pull Request テンプレート

auto-fix.yml が選ばれて claude-code-review.yml が選ばれていない場合は、依存関係を説明して claude-code-review.yml も追加するか確認する。

## Phase 3: レビュープロンプトのカスタマイズ

claude-code-review.yml が選択された場合のみ実行する。選択されていない場合は Phase 4 へスキップ。

### Step 3.1: ベース基準の読み取り

このスキルと同じリポジトリ内の `skills/code-review/references/review-criteria.md` を読み取り、9つのレビュー基準を取得する。

以下の形式に整形して `{{BASE_REVIEW_CRITERIA}}` の置換に使用:

```
### 1. 仕様一致（Spec-Code Alignment）
- 実装がPR説明文 / リンクされた Issue と一致しているか
- エッジケースが処理されているか
- 関連テストが追加・更新されているか

### 2. セキュリティ
- ユーザー入力がバリデーション・サニタイズされているか
- SQLクエリがパラメタライズされているか
- ハードコードされた秘密情報がないか
- ログに PII やトークンが含まれていないか

### 3. RASIS（信頼性・可用性・保守性・完全性・安全性）
- エラーが適切にキャッチ・処理されているか（サイレントスワローなし）
- リソースが適切にクリーンアップされているか
- 外部呼び出しにタイムアウト・リトライがあるか

### 4. コスト効率
- アルゴリズム計算量が適切か（ホットパスの O(n^2)+ に注意）
- N+1 クエリパターンがないか
- 不要なネットワーク呼び出しがないか

### 5. SOLID 原則
- 単一責任: 各関数/クラスが一つの責務
- 依存関係の方向が正しいか

### 6. YAGNI
- 現在の要件を超えた機能がないか
- 投機的な設定可能性がないか

### 7. DRY
- 重複ロジックがないか
- マジックナンバー/文字列が定数化されているか

### 8. ベストプラクティス
- 言語固有のイディオムに従っているか
- フレームワーク推奨パターンに従っているか
- 非推奨APIを使用していないか

### 9. 可読性
- 変数名・関数名が意図を伝えているか
- コメントが「Why」を説明しているか
- 関数の認知的複雑性が管理可能か
```

### Step 3.2: プロジェクト固有チェックの生成

Phase 1 の検出結果をもとに、プロジェクト固有のレビュー観点を自動生成する。

例:
- TypeScript → 「`any` の回避、`import type` の使用、strict mode 準拠」
- React → 「不要な再レンダリングパターン、hooks ルール準拠、`React.memo()` の適切な使用」
- Biome 使用 → 「Biome ルール準拠」
- Python/Ruff 使用 → 「Ruff ルール準拠」
- Go → 「error ラップ、goroutine リーク、context 伝播」

`{{PROJECT_SPECIFIC_CHECKS}}` の置換に使用する。プロジェクト固有チェックが何もない場合はセクションごと省略。

### Step 3.3: ユーザーへの追加観点確認

AskUserQuestion で:
「プロジェクト固有のレビュー観点を追加しますか？（例: D1 SQLインジェクション、特定のコーディング規約など）」
- 「はい、追加する」 → 自由入力で観点を記述してもらい、Step 3.2 の結果に追記
- 「自動検出分で十分」 → そのまま Phase 4 へ

### Step 3.4: 最終プロンプト組み立て

1. `references/workflows/claude-code-review.yml` を Read で読み取る
2. `{{BASE_REVIEW_CRITERIA}}` を Step 3.1 の結果で置換
3. `{{PROJECT_SPECIFIC_CHECKS}}` を Step 3.2 + 3.3 の結果で置換（観点がある場合は `## プロジェクト固有のチェック観点` セクションとして挿入）
4. 組み立て結果を内部に保持し Phase 4 で使用

## Phase 4: ファイル生成

選択されたモジュールのテンプレートを読み取り、対象プロジェクトに書き出す。

### ファイルマッピング

| テンプレート（references/） | 書き出し先 |
|---------------------------|----------|
| `workflows/claude.yml` | `.github/workflows/claude.yml` |
| `workflows/claude-code-review.yml` | `.github/workflows/claude-code-review.yml` |
| `workflows/auto-fix.yml` | `.github/workflows/auto-fix.yml` |
| `issue-templates/bug.yml` | `.github/ISSUE_TEMPLATE/bug.yml` |
| `issue-templates/feature.yml` | `.github/ISSUE_TEMPLATE/feature.yml` |
| `issue-templates/task.yml` | `.github/ISSUE_TEMPLATE/task.yml` |
| `issue-templates/config.yml` | `.github/ISSUE_TEMPLATE/config.yml` |
| `pr-template.md` | `.github/PULL_REQUEST_TEMPLATE.md` |

### 書き出しルール

1. 各テンプレートを Read で読み取る
2. claude-code-review.yml の場合は Phase 3 で組み立てたプロンプト済みの内容を使用
3. 書き出し先に既存ファイルがある場合は AskUserQuestion で上書き確認
4. Write でファイルを作成
5. 書き出し先のディレクトリが存在しない場合は Bash mkdir -p で作成

### 生成完了の報告

```
## 生成完了

以下のファイルを作成しました:
- `.github/workflows/claude.yml` ✅
- `.github/workflows/claude-code-review.yml` ✅
- ...
```

## Phase 5: 後処理ガイド

セットアップに必要な手動手順をユーザーに案内する。

出力:

```
## 次のステップ

### 1. GitHub Secrets の設定

リポジトリの Settings → Secrets and variables → Actions で以下を設定してください:

| Secret 名 | 説明 |
|-----------|------|
| `CLAUDE_CODE_OAUTH_TOKEN` | Claude Code の OAuth トークン |

### トークンの取得方法

1. ターミナルで `claude` を実行
2. `/login` コマンドでログイン
3. `claude oauth token` でトークンを取得

詳細: https://docs.anthropic.com/en/docs/claude-code/github-actions

### 2. claude-task ラベルの作成（claude.yml を使う場合）

リポジトリに `claude-task` ラベルがなければ作成してください:
gh label create claude-task --description "Claude に直接実行させるタスク" --color "7057ff"

### 3. 動作確認

- Issue に `claude-task` ラベルを付けて Claude が反応するか確認
- PR を作成して自動レビューが走るか確認
- レビュー指摘後に自動修正が走るか確認（auto-fix.yml を使う場合）
```

## 注意事項

- このスキルは Claude Code Action（anthropics/claude-code-action）専用
- レビュープロンプトのベース基準は `skills/code-review/references/review-criteria.md` に依存
- auto-fix.yml は claude-code-review.yml の workflow 名 "Claude Code Review" に依存。レビュー workflow 名を変更した場合は auto-fix.yml の `workflows:` も更新すること
```

**Step 2: コミット**

```bash
git add skills/claude-github-setup/SKILL.md
git commit -m "feat: implement full SKILL.md with Phase 1-5"
```

---

### Task 7: 最終確認

**Step 1: ファイル構成を確認**

```bash
find skills/claude-github-setup/ -type f | sort
```

期待する出力:
```
skills/claude-github-setup/SKILL.md
skills/claude-github-setup/references/issue-templates/bug.yml
skills/claude-github-setup/references/issue-templates/config.yml
skills/claude-github-setup/references/issue-templates/feature.yml
skills/claude-github-setup/references/issue-templates/task.yml
skills/claude-github-setup/references/pr-template.md
skills/claude-github-setup/references/workflows/auto-fix.yml
skills/claude-github-setup/references/workflows/claude-code-review.yml
skills/claude-github-setup/references/workflows/claude.yml
```

**Step 2: テンプレート YAML の構文チェック**

```bash
python3 -c "import yaml; yaml.safe_load(open('skills/claude-github-setup/references/workflows/claude.yml'))" && echo "OK"
python3 -c "import yaml; yaml.safe_load(open('skills/claude-github-setup/references/workflows/auto-fix.yml'))" && echo "OK"
python3 -c "import yaml; yaml.safe_load(open('skills/claude-github-setup/references/issue-templates/bug.yml'))" && echo "OK"
python3 -c "import yaml; yaml.safe_load(open('skills/claude-github-setup/references/issue-templates/feature.yml'))" && echo "OK"
python3 -c "import yaml; yaml.safe_load(open('skills/claude-github-setup/references/issue-templates/task.yml'))" && echo "OK"
```

注: claude-code-review.yml はプレースホルダー `{{...}}` を含むため YAML パースに失敗する可能性がある。これは想定通り（スキル実行時に置換される）。

**Step 3: SKILL.md の構造確認**

SKILL.md が以下を含むことを目視確認:
- frontmatter（name: claude-github-setup, description に Claude Code Action 明記, allowed-tools, context: fork）
- Phase 1〜5 の全セクション
- code-review スキルへの参照パス
- ファイルマッピングテーブル
- 後処理ガイド（CLAUDE_CODE_OAUTH_TOKEN 設定手順）
