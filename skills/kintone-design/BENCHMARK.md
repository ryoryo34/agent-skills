# kintone-design Skill — Benchmark Report

## 実行概要

| 項目 | iteration-1 | **iteration-2 (採用)** |
|------|:-----:|:-----:|
| 走行数/設定 | 1 | **3** |
| 総アサーション | 19 | **57** (19×3) |
| 総走行数 | 6 | **18** |
| 実施日 | 2026-04-23 | 2026-04-24 |

iteration-2 は統計的頑健性を高めるため 3 走行/設定に拡大。iteration-1 の結果を Run 1 として再利用し、Run 2/3 を追加で 12 エージェント実行。

## 📊 集計結果（iteration-2 / 3 走行平均）

| 指標 | with_skill | without_skill | Δ |
|------|:---------:|:------------:|:---:|
| 平均合格率 | **100%** | 66.7% | **+33.3pt** |
| 合格アサーション | 57/57 | 38/57 | +19 |
| 標準偏差 | **0.00** | 0.03 | - |
| 結果の再現性 | 完全一致 (全3走行100%) | ほぼ安定 (Test 3 で軽微な揺らぎ) | - |

## テストケース別（3 走行平均）

| テスト | with_skill | without_skill | Δ | with stddev | without stddev |
|-------|:---------:|:------------:|:---:|:---:|:---:|
| eval-cqrs-es-misuse | **100% (6/6 × 3)** | 50% (3/6 × 3) | **+50pt** | 0.00 | 0.00 |
| eval-subtable-overuse | **100% (6/6 × 3)** | 100% (6/6 × 3) | ±0pt | 0.00 | 0.00 |
| eval-aggregate-design | **100% (7/7 × 3)** | 52.4% (3.67/7 × 3) | **+47.6pt** | 0.00 | 0.067 |

## 3 走行の詳細（全 18 run の合格率）

| テスト | config | Run 1 | Run 2 | Run 3 |
|-------|--------|:---:|:---:|:---:|
| cqrs-es-misuse | with | 100% | 100% | 100% |
| cqrs-es-misuse | without | 50% | 50% | 50% |
| subtable-overuse | with | 100% | 100% | 100% |
| subtable-overuse | without | 100% | 100% | 100% |
| aggregate-design | with | 100% | 100% | 100% |
| aggregate-design | without | 43% | 57% | 57% |

## 🔑 iteration-2 で新たに判明した知見

### 1. with_skill の**再現性が完全**（3 走行全て 100%）
標準偏差 0.00。skill の内容が具体的で機械的に判定しやすい構造のため、出力がブレない。

### 2. without_skill の**揺らぎは 1 領域に集中**
Test 3 (eval-aggregate-design) のみ stddev 0.067 で変動あり:
- Run 1: 43% (3/7)
- Run 2: 57% (4/7)
- Run 3: 57% (4/7)

変動の原因は `avoids-cqrs-es-misuse` assertion の通過判定。**モデルは時に「CQRS の Read Model」と誤用し、時に用語を使わない**という**確率的な挙動**を示す。skill はこの確率を 0% に固定する効果を持つ。

### 3. ベースライン（without_skill）の安定失敗
Test 1 の 3 失敗 assertion は **3 走行すべて同じ**:
- ❌ warns-against-cqrs-label
- ❌ proposes-materialized-view
- ❌ provides-correct-mental-model

つまり、skill なしでは**構造的に埋められない**弱点である。

## 分析

### 🌟 スキルの価値が高い領域（大きな差分）

1. **CQRS / Event Sourcing 用語警告（+50pt、再現率 100%）**
   - without_skill は ES の実装困難性は毎回指摘できるが、「CQRS という用語自体の誤用」は毎回見逃す
   - Materialized View という**代替用語の提案**が skill なしでは出ない（3 走行 0 件）

2. **Aggregate ↔ kintone アプリ マッピング（+47.6pt）**
   - without_skill の `avoids-cqrs-es-misuse` が確率的に失敗（3 走行中 1 走行で CQRS 誤用）
   - skill は用語規律を 100% 維持

### ➖ スキルなしでも十分な領域（差分なし）

- **サブテーブル乱用（±0pt、両方 100%）**
  - Claude の事前知識が強固で、3 走行全てで公式 100 行制限・他アプリ参照不可を正しく警告
  - skill の価値は**用語の正確性と DDD マッピング**に集中する

### 📉 without_skill の典型的な失敗パターン（3 走行を通じて）

| 失敗 | 頻度 | 事例 |
|------|:---:|------|
| 「CQRS Read Model」を肯定的に提案 | 1/3 走行 | Test 3 run-1 「DDD 的には CQRS の Read Model です」; Test 3 run-3 「Power BI 連携は CQRS に近い責務分離」 |
| Materialized View への言い換え不足 | **3/3 走行** | 「集計系」「集計アプリ」等の機能名どまり、代替用語を提案できず |
| kintone 固有のメンタルモデル不足 | **3/3 走行** | 「3層分割」「単一アプリ+集計」「BI外出し」など一般論、kintone Aggregate+MV+Audit Log モデルは提示されず |
| 「スペース = Bounded Context」への言及 | 1/3 走行のみ | Test 3 run-3 のみ触れる |

## 制約・今後の改善点

### iteration-2 の制約

- **with_skill の条件差**: SKILL.md 抜粋をプロンプト注入する方式で擬似的に skill を再現（実際の auto-loading 挙動とは微差あり）
- **採点者バイアス**: 自己採点。別レビュアーによる盲目採点は未実施
- **アサーション設計**: binary pass/fail のみ。部分的達成の定量評価は未対応

### 今後の改善案 (iteration-3 以降)

1. **採点基準の明文化** → `evals/rubric.md` で assertion 通過判定を固定
2. **ケース追加**:
   - マスタ重複（ノーコード地獄）検知ケース
   - レコード番号を一意キーに使おうとするケース
   - 粗利計算を Case アプリ内で完結させようとするケース
3. **盲目採点**: 別エージェント/モデルで独立採点
4. **部分点制**: 0/1 ではなく 0/0.5/1 の 3 段階

## 結論

**kintone-design スキルは、iteration-2 の 3 走行テストで以下を実証:**

1. **+33.3pt の一貫した改善**（100% vs 66.7%、標準偏差 0.00）
2. **用語規律の完全維持**: CQRS/ES を誤用する確率を 0% に固定（without_skill は 33% の確率で誤用）
3. **DDD マッピングの完全性**: Aggregate / BC / Materialized View / Audit Log のマッピングを 3 走行すべてで一貫適用

**`kintone-architect` エージェント**は、この skill を内部で参照しつつ、さらに `domain-model` と組み合わせて要件 → アプリ構成までの一貫したオーケストレーションを提供。単発の skill 利用では繋ぎきれないパイプライン価値を提供する。

### 一言で言うと

> **Skill なしだと「CQRS と言いそうになる確率が 33%」。Skill ありだと「0%」。**
> これは業務システム設計の知的衛生として十分に投資価値がある差分。
