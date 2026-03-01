---
name: optimize-skill
description: Skillを自動最適化する。テキスト勾配アプローチで正解データとの差分を分析し、Skillを自動改訂するループを実行する。Triggers include "optimize-skill", "スキル最適化", "skill optimization".
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent, AskUserQuestion, Skill
context: fork
---

# Skill自動最適化（optimize-skill）

ProTeGi/APO のテキスト勾配アプローチを Claude Code Skills に適用し、正解データとの差分比較によるイテレーティブな自動改善ループを実行する。

## 処理概要

```
Phase 1: セットアップ（対話2回のみ）
Phase 2: ベースライン計測（自動）
Phase 3: 最適化ループ × 最大4回（自動）
Phase 4: レポート出力（自動）
```

## Phase 1: セットアップ

### Step 1: 対象スキルの選択

AskUserQuestion でインストール済みスキルの一覧を表示し、最適化対象を選ばせる。

スキル一覧は以下で取得:
- Glob で `skills/*/SKILL.md`、`~/.claude/skills/*/SKILL.md`、`~/.claude/plugins/**/SKILL.md` を検索
- 各 SKILL.md のフロントマターから name と description を抽出

### Step 2: データセットディレクトリの指定

AskUserQuestion でデータセットのディレクトリパスを入力させる。

### Step 3: データセット検証（自動）

指定ディレクトリ内のサブディレクトリを走査し、以下を検証：
- 各サブディレクトリに `prompt.md` が存在すること
- 各サブディレクトリに `expected.md` が存在すること
- `context/` ディレクトリは任意（存在しなくてもOK）
- 最低2つのデータセットが必要（1つでは過適合リスク）

検証に失敗した場合はエラーメッセージを表示して終了。

**セットアップ完了後、以降は完全自動で実行する。途中でユーザーに確認を取らない。**

## Phase 2: ベースライン計測

### Step 1: 初期化

データセットディレクトリに `.optimize-history/iteration-0/` を作成する。
対象スキルの SKILL.md を `.optimize-history/iteration-0/skill-snapshot.md` にコピーする。

### Step 2: 各データセットで成果物を生成

**各データセットごとに** Agent ツール（subagent_type: general-purpose）を起動する。

サブエージェントへのプロンプト構成:
1. `references/prompts/generate.md` のテンプレートを読み込む
2. `{{SKILL_NAME}}` を対象スキル名に置換
3. `{{PROMPT}}` を該当データセットの `prompt.md` の内容に置換
4. `{{CONTEXT_DIR}}` を該当データセットの `context/` パスに置換（存在しない場合はデータセットディレクトリ自体）
5. `{{OUTPUT_PATH}}` を `.optimize-history/iteration-0/XX-output.md` に置換

**重要**: サブエージェントには expected.md のパスを渡さない。

独立したデータセットは並列実行可能（Agent ツールを複数同時呼び出し）。

### Step 3: ベースライン評価

評価サブエージェント（Agent ツール、subagent_type: general-purpose）を起動:
1. `references/prompts/evaluate.md` のテンプレートを読み込む
2. 各データセットの output と expected のパスを渡す
3. `references/evaluation-criteria.md` の内容を渡す
4. 出力先: `.optimize-history/iteration-0/scores.json` と `.optimize-history/iteration-0/text-gradient.md`

ベースラインスコアをログに記録する。

## Phase 3: 最適化ループ

以下を最大4回繰り返す。イテレーション番号は1から開始。

### Step A: 生成

Phase 2 Step 2 と同じ手順で、**現在のSKILL.md** を使って各データセットの成果物を生成する。
出力先: `.optimize-history/iteration-N/XX-output.md`

### Step B: 評価 + テキスト勾配生成

Phase 2 Step 3 と同じ手順で評価。
出力先: `.optimize-history/iteration-N/scores.json` と `.optimize-history/iteration-N/text-gradient.md`

### Step C: 退行チェック

scores.json を読み込み、前回イテレーションと比較:

1. **退行検出**: 平均スコア（average.total）が前回より低下 → 前回の skill-snapshot.md で SKILL.md を復元し、ループ終了
2. **収束検出**: 平均スコア改善が +1.0 未満 → 収穫逓減と判断し、ループ終了
3. **過学習検出**: あるデータセットのスコア合計が +5 以上上昇し、別のデータセットのスコア合計が -3 以上低下 → 警告ログを出力し、ループ終了

いずれにも該当しなければ Step D へ。

### Step D: Skill 改訂

**改訂前に必ず**現在の SKILL.md を `.optimize-history/iteration-N/skill-snapshot.md` にコピーする。このスナップショットは退行検出時のロールバック先となるため、改訂エージェント起動前に保存を完了すること。

改訂サブエージェント（Agent ツール、subagent_type: general-purpose）を起動:
1. `references/prompts/revise.md` のテンプレートを読み込む
2. `{{SKILL_PATH}}` を対象 SKILL.md のパスに置換
3. `{{GRADIENT_PATH}}` を今回の text-gradient.md のパスに置換
4. `{{SNAPSHOT_PATH}}` を `.optimize-history/iteration-N/skill-snapshot.md` に置換

改訂後、次のイテレーションへ。

## Phase 4: レポート出力

全イテレーション完了後（または自動停止後）、以下のレポートを生成して `.optimize-history/summary.md` に保存する。

### レポート内容

1. **対象スキル**: スキル名とパス
2. **実行結果**: イテレーション数と停止理由（完了 / 退行検出 / 収束検出 / 過学習検出）
3. **スコア推移**: 全イテレーションの各軸スコアを表形式で表示
4. **各イテレーションの変更点**: text-gradient.md の要約
5. **最終Skillの主な改善点**: 箇条書きで列挙

レポート生成後、結果をユーザーにテキスト出力で表示する:

```
最適化完了！
📊 スコア推移: [ベースライン] → [最終] （+[改善幅]点）
🔄 イテレーション: [実行数]/[最大数]（[停止理由]）
📁 詳細: .optimize-history/summary.md
```

## 設計上の重要原則

1. **生成時に正解を参照しない**: Skill の改善が出力品質向上として純粋に現れるようにする
2. **複数データセットで評価**: 単一案件への過適合を防ぐ
3. **テキスト勾配は「何が違うか」+「なぜ違うか」**: 表面的な差分ではなく根本原因を分析
4. **改訂は勾配のみで行う**: expected.md を直接見て Skill を書くのではなく、テキスト勾配の改善提案に基づいて改訂
