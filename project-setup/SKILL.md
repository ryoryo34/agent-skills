---
name: project-setup
description: 新規・既存プロジェクトに AI エージェント作業環境（AGENTS.md / CLAUDE.md / .claude/rules / .codex 連携）の推奨構成を対話的にセットアップする。正本の一元化・symlink による Codex/Claude 共有・タスク別必読導線・スターター規律ルールを整備し、既存構成の乖離や壊れ参照も検出・修復する。Triggers include "project-setup", "プロジェクトセットアップ", "AGENTS.md 作って", "CLAUDE.md 作って", ".claude をセットアップ", "エージェント環境を整えて", "新しいリポジトリの AI 設定", "Codex と Claude 両対応にして". プロジェクトの立ち上げ時、AI エージェントで開発を始める時、AGENTS.md と CLAUDE.md の二重管理を解消したい時は必ずこのスキルを使うこと。
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
context: fork
license: MIT
---

# Project Setup

プロジェクトに AI エージェント（Claude Code / Codex、その他 AGENTS.md 準拠エージェント）の作業環境をセットアップするスキル。

設計原則（過去10ヶ月・複数プロジェクトの運用失敗から導出）:

1. **正本は 1 つ** — AGENTS.md と CLAUDE.md を手動ミラーすると必ず乖離する（実際に乖離事故が発生済み）。AGENTS.md を正本とし、CLAUDE.md は import で参照する。
2. **rules は symlink で共有** — `.claude/rules/` を正本とし、Codex 側からは symlink で参照する。存在しないディレクトリへの参照（壊れ導線）は「ルールがあるのに読まれない」状態を生む。
3. **ドキュメントは導線がないと読まれない** — ルールや docs が充実していても、「いつ読むか」の routing がなければ毎セッション同じ説明が繰り返される。AGENTS.md にタスク別必読表を置く。
4. **常時ルールと手順書を分離する** — `.claude/rules/` は「常時適用される短い規律」だけ。長い手順書は `docs/` へ、繰り返しワークフローはスキルへ。

---

## Phase 1: 検出

対象プロジェクトの現状を棚卸しする。既存ファイルを壊さないため、生成より先に必ず実施する。

1. 以下を Glob / Bash で確認:
   - `AGENTS.md`, `CLAUDE.md`, `CLAUDE.local.md`
   - `.claude/`（`CLAUDE.md`, `rules/`, `skills/`, `hooks/`, `settings.json`）
   - `.codex/` または `.Codex/` または `.agents/`（プロジェクトによって表記が異なる。既存表記があればそれに従う）
   - git リポジトリか（`git rev-parse --is-inside-work-tree`）
2. 技術スタックを検出: `package.json` / `pyproject.toml` / `go.mod` / `Cargo.toml` 等から言語・テスト/ビルドコマンドを特定する（AGENTS.md の Commands セクションに使う）
3. **健全性チェック**（既存構成がある場合）:
   - AGENTS.md と CLAUDE.md が両方実体ファイルとして存在する場合、diff を取り乖離を検出する
   - AGENTS.md / CLAUDE.md 内の `@path` import・`〜を参照` 記述の参照先が実在するか確認する
   - `.claude/` `.codex/` 配下の symlink が解決するか確認する（`find -L . -maxdepth 3 -type l` で壊れ symlink 検出）
4. `~/.claude/CLAUDE.md`・`~/.claude/rules/`・`~/.codex/AGENTS.md` にあるグローバルルールを確認する。**グローバルに既にある一般則をプロジェクトへ複製しない**（二重管理の芽になる）。

検出結果を「現状 / 問題点（乖離・壊れ参照）/ 提案」の形で簡潔にユーザーへ提示する。

## Phase 2: 対話

AskUserQuestion で以下を確認する（検出結果から自明な項目は聞かない）:

1. **使用エージェント**: Claude Code のみ / Codex のみ / 両方（既定: 両方）
2. **導入するスターター規律**（複数選択）:
   - `verification-before-report` — 報告前にビルド・テスト・動作確認を自走する規律
   - `branch` — ブランチ運用（常設ブランチ、命名、hotfix の扱い）
   - `investigation` — バグ調査の初動手順（症状把握 → 空間 → 時系列）
3. **既存乖離の扱い**（Phase 1 で乖離検出時のみ）: 新しい方へ統合 / 手動レビュー用に diff 提示のみ

## Phase 3: 生成

テンプレートは `references/templates.md` を Read して使う。既存ファイルがある場合は上書きせず、不足セクションの追記に留める。

### 3-1. 正本: AGENTS.md

テンプレートに沿って生成。必須セクション:

- **Project Context** — 1〜3 行の説明
- **Commands** — 検出したテスト/ビルド/開発コマンド
- **Task → Must-Read Routing** — タスク種別 → 必読ドキュメントの表。最初は行が少なくてよい。「ドキュメントを書いたらこの表に行を足す」運用を根付かせることが目的
- **Verification Before Reporting** — 選択された場合
- **Rules** — `.claude/rules/` 配下への参照

### 3-2. CLAUDE.md（Claude Code 使用時）

実体の複製は作らない。以下の 1 行 import ファイルとして生成する:

```markdown
@AGENTS.md
```

Claude Code 固有の指示（サブエージェント運用、スキル指定など）が必要になったら、この import の下に追記する。既に実体 CLAUDE.md がある場合は、AGENTS.md へ内容を統合してから import 形式に置き換える（Phase 2 の回答に従う）。

### 3-3. rules（正本: `.claude/rules/`）

選択されたスターター規律を `references/templates.md` のテンプレートから生成する。プロジェクトの実コマンド名（`pnpm test` 等）に置換すること。

### 3-4. Codex 連携（Codex 使用時）

- `.codex/rules` → `../.claude/rules` の symlink を作成（skills があれば同様に）。既存プロジェクトで `.Codex` 等の表記が使われていればそれに合わせる
- Codex は AGENTS.md を直接読むため追加ファイルは不要

### 3-5. .gitignore 確認

`.claude/settings.local.json`, `CLAUDE.local.md` が ignore されているか確認し、なければ追記を提案する。

## Phase 4: 検証と報告

1. 作成した symlink が解決することを確認する（`ls -L`）
2. AGENTS.md / CLAUDE.md 内の全参照先が実在することを確認する
3. 生成・変更したファイル一覧と、「今後の運用」を報告する:
   - ルールを足すときは `.claude/rules/` に置けば Claude / Codex 両方に効く
   - ドキュメントを書いたら AGENTS.md の Routing 表に行を足す
   - 繰り返しワークフローに気づいたらルールではなくスキル化を検討する

## してはいけないこと

- 既存の AGENTS.md / CLAUDE.md / rules を無断で上書き・削除しない。統合は必ず diff を見せてから
- AGENTS.md と CLAUDE.md の実体二重管理を新たに作らない
- グローバル（`~/.claude/`, `~/.codex/`）の設定ファイルを変更しない（このスキルの対象はプロジェクトスコープのみ）
- 長大なベストプラクティス集を rules に書かない。常時適用の短い規律のみ
