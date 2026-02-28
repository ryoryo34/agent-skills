# claude-github-setup — Design

## 概要

Claude Code Action を使った GitHub 自動化（PRレビュー、Issue自動実装、レビュー指摘の自動修正）を、任意のプロジェクトに対話的にセットアップするスキル。Claude Code 専用。

ai-sentinel で運用実績のある構成をテンプレート化し、プロジェクトの技術スタックに合わせてカスタマイズして適用する。

## 要件

- 新規・既存プロジェクト両対応
- 配置先: `agent-skills/skills/claude-github-setup/`
- テンプレート + 対話的モジュール選択方式
- レビュープロンプトは agent-skills/code-review の9基準をベースに、プロジェクト固有ルールを注入可能
- 日本語テンプレート・プロンプト

## ディレクトリ構成

```
skills/claude-github-setup/
├── SKILL.md
└── references/
    ├── workflows/
    │   ├── claude.yml
    │   ├── claude-code-review.yml
    │   └── auto-fix.yml
    ├── issue-templates/
    │   ├── bug.yml
    │   ├── feature.yml
    │   ├── task.yml
    │   └── config.yml
    └── pr-template.md
```

## SKILL.md 対話フロー

### Phase 1: プロジェクト検出

- リポジトリの言語・フレームワーク・linter 設定を自動検出
- 既存の `.github/` 構成を確認（競合回避）
- CLAUDE.md や `.claude/rules/` からプロジェクト固有ルールを読み取る

### Phase 2: モジュール選択

AskUserQuestion でユーザーが以下から選択（multiSelect）:

- `claude.yml` — @claude メンション & claude-task ラベル対応
- `claude-code-review.yml` — PR 自動レビュー
- `auto-fix.yml` — レビュー指摘の自動修正
- Issue Templates — Bug / Feature / Claude Task
- PR Template

### Phase 3: レビュープロンプトのカスタマイズ

1. `agent-skills/skills/code-review/references/review-criteria.md` の9基準をベースプロンプトに注入
2. Phase 1 で検出した技術スタック情報を追加
3. ユーザーにプロジェクト固有のレビュー観点を聞く
4. 最終プロンプトを組み立て

### Phase 4: ファイル生成

- references/ のテンプレートを読み取り
- プレースホルダーを実際の値に置換して Write
- 既存ファイルがあれば上書き確認

### Phase 5: 後処理ガイド

- `CLAUDE_CODE_OAUTH_TOKEN` の設定手順を案内
- 必要な GitHub secrets の一覧を表示

## レビュープロンプト構造

```yaml
prompt: |
  # ベースレビュー基準
  {{BASE_REVIEW_CRITERIA}}

  # プロジェクト固有のチェック観点
  {{PROJECT_SPECIFIC_CHECKS}}

  # レビュー方法（固定）
  ...
```

## テンプレートのベース

ai-sentinel の以下ファイルを汎用化:

- `.github/workflows/claude.yml`
- `.github/workflows/claude-code-review.yml`
- `.github/workflows/auto-fix.yml`
- `.github/ISSUE_TEMPLATE/bug.yml`
- `.github/ISSUE_TEMPLATE/feature.yml`
- `.github/ISSUE_TEMPLATE/task.yml`
- `.github/ISSUE_TEMPLATE/config.yml`
- `.github/PULL_REQUEST_TEMPLATE.md`
