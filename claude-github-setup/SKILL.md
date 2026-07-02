---
name: claude-github-setup
description: Claude Code Action を使った GitHub 自動化（PR自動レビュー、Issue自動実装）を対話的にセットアップする。Triggers include "claude-github-setup", "setup claude github", "Claude GitHub 自動化", "PRレビュー自動化", "claude-code-action setup".
allowed-tools: Read, Glob, Grep, Write, Bash, AskUserQuestion
context: fork
license: MIT
---

# Claude GitHub Setup

Claude Code Action（anthropics/claude-code-action）を使った GitHub 自動化を、任意のプロジェクトに対話的にセットアップするスキル。

## 前提

- 対象プロジェクトが git リポジトリであること
- GitHub にリモートリポジトリがあること
- Claude Code の OAuth トークンが取得済み or 取得可能であること

---

## Phase 1: プロジェクト検出

対象プロジェクトの技術スタックと既存構成を自動検出する。

### 検出手順

1. リポジトリのルートで以下のファイルを Glob で確認し、言語・フレームワークを特定:
   - `package.json` → Node.js/TypeScript。中身を Read して dependencies からフレームワーク（React, Vue, Next.js, Express, Hono 等）を検出
   - `requirements.txt` / `pyproject.toml` / `setup.py` → Python
   - `go.mod` → Go
   - `Cargo.toml` → Rust
   - `pom.xml` / `build.gradle` → Java/Kotlin
   - 上記に該当しない場合は `**/*.{py,go,rs,java,kt,rb,php,cs,swift}` で言語を推定

2. 既存の `.github/workflows/` を Glob で確認:
   - `claude*.yml` や `claude*.yaml` があれば「既に Claude 系 workflow が存在する」と警告
   - その他の workflow ファイルがあれば一覧をメモ

3. `.github/ISSUE_TEMPLATE/` と `.github/PULL_REQUEST_TEMPLATE.md` の有無を確認

4. `CLAUDE.md` と `.claude/rules/*.md` があれば Read し、プロジェクト固有のルール・コーディング規約を収集

5. linter / formatter 設定を Glob で検出:
   - JS/TS: `.eslintrc*`, `eslint.config.*`, `biome.json`, `biome.jsonc`, `.prettierrc*`
   - Python: `ruff.toml`, `.flake8`, `pyproject.toml`（`[tool.ruff]` セクション）
   - Go: `.golangci.yml`
   - Rust: `clippy.toml`, `.clippy.toml`

### 検出結果の出力

検出が完了したら、以下の形式でユーザーに表示:

```
## プロジェクト検出結果
- 言語: [検出された言語]
- フレームワーク: [検出されたフレームワーク]
- Linter/Formatter: [検出されたツール]
- 既存 GitHub 設定: [あり/なし、詳細]
- CLAUDE.md ルール: [検出された固有ルール、要約]
```

---

## Phase 2: モジュール選択

AskUserQuestion（multiSelect: true）でセットアップするモジュールをユーザーに選ばせる。

### 選択肢

| # | モジュール | 説明 |
|---|-----------|------|
| 1 | **claude.yml** | Issue/PR で `@claude` メンション対応 & `claude-task` ラベルで自動実装 |
| 2 | **claude-code-review.yml** | PR 作成時に Claude が自動レビュー（レビュー基準は Phase 3 でカスタマイズ） |
| 3 | **Issue Templates** | Bug Report / Feature Request / Claude Task の3テンプレート |
| 4 | **PR Template** | Pull Request テンプレート |

---

## Phase 3: レビュープロンプトのカスタマイズ

**claude-code-review.yml が選択された場合のみ実行。選択されていない場合は Phase 4 へスキップ。**

### Step 3.1: ベース基準の読み取り

このスキルと同じリポジトリ内の `code-review/references/review-criteria.md` を Read で読み取る。

読み取った9基準を以下の形式に整形し、`{{BASE_REVIEW_CRITERIA}}` の置換値とする:

```
### 1. 仕様一致（Spec-Code Alignment）
- 実装がPR説明文 / リンクされた Issue と一致しているか
- エッジケースが処理されているか（null, empty, 境界値）
- 関連テストが追加・更新されているか
- 既存動作への意図しない副作用がないか

### 2. セキュリティ
- ユーザー入力がバリデーション・サニタイズされているか
- SQLクエリがパラメタライズされているか（文字列結合なし）
- ハードコードされた秘密情報（APIキー、パスワード）がないか
- ログに PII やトークンが含まれていないか

### 3. RASIS（信頼性・可用性・保守性・完全性・安全性）
- エラーが適切にキャッチ・処理されているか（空の catch ブロックなし）
- リソース（DB接続、ファイルハンドル）が適切にクリーンアップされているか
- 外部呼び出しにタイムアウト・リトライがあるか
- 並行性の安全性（競合状態、デッドロック）

### 4. コスト効率
- アルゴリズム計算量が適切か（ホットパスの O(n^2)+ に注意）
- N+1 クエリパターンがないか
- 不要なネットワーク呼び出し・API呼び出しがないか
- メモリリークや不要なオブジェクト保持がないか

### 5. SOLID 原則
- 単一責任: 各関数/クラスが一つの変更理由を持つ
- 依存関係の方向が正しいか（高レベルが低レベルに依存していないか）
- 抽象レベルが適切か

### 6. YAGNI
- 現在の要件を超えた機能がないか
- 投機的な設定可能性が追加されていないか
- 仮想の将来要件のためのコードがないか

### 7. DRY
- 重複ロジックが複数箇所にないか
- マジックナンバー/文字列が定数化されているか

### 8. ベストプラクティス
- 言語固有のイディオムに従っているか
- フレームワーク推奨パターンに従っているか
- 非推奨APIを使用していないか

### 9. 可読性
- 変数名・関数名が意図を明確に伝えているか
- コメントが「Why」を説明しているか（「What」ではなく）
- 関数の認知的複雑性が管理可能か（深いネスト、100行超の関数がないか）
```

`review-criteria.md` が見つからない場合は、上記のデフォルト基準をそのまま使用する。

### Step 3.2: プロジェクト固有チェックの生成

Phase 1 の検出結果をもとに、プロジェクト固有のレビュー観点を自動生成する。

| 検出結果 | 追加するチェック観点 |
|---------|-------------------|
| TypeScript | `any` の回避、`import type` の使用、strict mode 準拠 |
| React | 不要な再レンダリングパターン、hooks ルール準拠、`React.memo()` の適切な使用 |
| Next.js | Server Components / Client Components の適切な使用、`use client` の最小化 |
| Vue | Composition API パターン準拠、reactive/ref の適切な使用 |
| Biome | Biome ルール準拠（2スペースインデント、ダブルクォート等） |
| ESLint | ESLint ルール準拠 |
| Python | 型ヒントの使用、PEP 8 準拠 |
| Ruff | Ruff ルール準拠 |
| Go | error ラップ（`fmt.Errorf` + `%w`）、goroutine リーク、context 伝播 |
| Rust | unsafe の最小化、lifetime 注釈の適切さ、clippy 警告 |
| Hono | ミドルウェアパターン準拠 |
| Express | ミドルウェアのエラーハンドリング、async handler のラップ |

検出されたものだけを `## プロジェクト固有のチェック観点` セクションとして組み立て、`{{PROJECT_SPECIFIC_CHECKS}}` の置換値とする。

何も検出されない場合は `{{PROJECT_SPECIFIC_CHECKS}}` を空文字で置換（セクションごと省略）。

### Step 3.3: ユーザーへの追加観点確認

AskUserQuestion で追加のレビュー観点をユーザーに聞く:

質問: 「プロジェクト固有のレビュー観点を追加しますか？」

選択肢:
- 「はい、追加する」 → 自由入力で観点を記述してもらい、Step 3.2 の結果に追記
- 「自動検出分で十分」 → そのまま Phase 4 へ

### Step 3.4: 最終プロンプト組み立て

1. `references/workflows/claude-code-review.yml` を Read で読み取る
2. `{{BASE_REVIEW_CRITERIA}}` を Step 3.1 の結果で置換
3. `{{PROJECT_SPECIFIC_CHECKS}}` を Step 3.2 + 3.3 の結果で置換
   - 観点がある場合: `## プロジェクト固有のチェック観点\n\n` + 観点リスト
   - 観点がない場合: 空文字（セクションごと削除）
4. 組み立て結果を内部に保持し Phase 4 で使用

---

## Phase 4: ファイル生成

選択されたモジュールのテンプレートを読み取り、対象プロジェクトに書き出す。

### ファイルマッピング

| テンプレート（references/） | 書き出し先 |
|---------------------------|----------|
| `workflows/claude.yml` | `.github/workflows/claude.yml` |
| `workflows/claude-code-review.yml` | `.github/workflows/claude-code-review.yml` |
| `issue-templates/bug.yml` | `.github/ISSUE_TEMPLATE/bug.yml` |
| `issue-templates/feature.yml` | `.github/ISSUE_TEMPLATE/feature.yml` |
| `issue-templates/task.yml` | `.github/ISSUE_TEMPLATE/task.yml` |
| `issue-templates/config.yml` | `.github/ISSUE_TEMPLATE/config.yml` |
| `pr-template.md` | `.github/PULL_REQUEST_TEMPLATE.md` |

### 書き出しルール

1. 書き出し先のディレクトリが存在しない場合は `Bash: mkdir -p` で作成
2. 選択されたモジュールに対応するテンプレートを Read で読み取る
3. **claude-code-review.yml の場合**: Phase 3 で組み立てたプロンプト置換済みの内容を使用（テンプレートを直接コピーしない）
4. **その他のファイル**: テンプレートをそのままコピー
5. 書き出し先に既存ファイルがある場合は AskUserQuestion で上書き確認:
   - 「上書きする」→ Write で上書き
   - 「スキップ」→ そのファイルはスキップ
6. Write ツールでファイルを作成

### 生成完了の報告

すべてのファイル生成が完了したら、以下の形式でユーザーに報告:

```
## 生成完了

以下のファイルを作成しました:
- `.github/workflows/claude.yml` ✅
- `.github/workflows/claude-code-review.yml` ✅
- `.github/ISSUE_TEMPLATE/bug.yml` ✅
- `.github/ISSUE_TEMPLATE/feature.yml` ✅
- `.github/ISSUE_TEMPLATE/task.yml` ✅
- `.github/ISSUE_TEMPLATE/config.yml` ✅
- `.github/PULL_REQUEST_TEMPLATE.md` ✅

（スキップしたファイルがあれば ⏭️ で表示）
```

---

## Phase 5: 後処理ガイド

セットアップに必要な手動手順をユーザーに案内する。

### 出力内容

```
## 次のステップ

### 1. GitHub Secrets の設定

リポジトリの Settings → Secrets and variables → Actions で以下を設定してください:

| Secret 名 | 説明 |
|-----------|------|
| `CLAUDE_CODE_OAUTH_TOKEN` | Claude Code の OAuth トークン |

#### トークンの取得方法

1. ターミナルで `claude` を実行
2. `/login` コマンドでログイン（未ログインの場合）
3. `claude setup-token` でトークンを取得してコピー（要 Claude サブスクリプション）

詳細: https://docs.anthropic.com/en/docs/claude-code/github-actions
```

claude.yml を選択した場合は以下も追加:

```
### 2. claude-task ラベルの作成

リポジトリに `claude-task` ラベルがなければ作成してください:

  gh label create claude-task --description "Claude に直接実行させるタスク" --color "7057ff"
```

最後に動作確認手順:

```
### 動作確認

セットアップ後、以下で正常動作を確認してください:

1. **@claude メンション**: Issue や PR コメントで `@claude こんにちは` と投稿 → Claude が反応するか
2. **claude-task ラベル**: Issue に `claude-task` ラベルを付与 → Claude が Issue 内容を実行するか
3. **PR 自動レビュー**: PR を作成 → Claude がレビューコメントを投稿するか

問題がある場合は GitHub Actions のログ（Actions タブ）を確認してください。
```

---

## 注意事項

- このスキルは **Claude Code Action（anthropics/claude-code-action）専用**
- レビュープロンプトのベース基準は `code-review/references/review-criteria.md` に依存（ファイルがない場合はデフォルト基準を使用）
- テンプレートの中身を更新する場合は `references/` 配下のファイルを直接編集すること
