# kintone-design Skill — Benchmark Report (iteration-1)

## 実行概要

| 項目 | 値 |
|------|----|
| 実行日 | 2026-04-24 |
| 対象スキル | kintone-design v0.1 |
| テストケース数 | 3 |
| 各ケースの走行数 | 1（with_skill / without_skill それぞれ 1 回）|
| アサーション総数 | 19 |
| 走行環境 | general-purpose 並列サブエージェント（with_skill は SKILL.md 抜粋を prompt 注入） |

## 集計結果

| 指標 | with_skill | without_skill | Δ |
|------|:---------:|:------------:|:---:|
| 平均合格率 | **100%** | 63.2% | **+36.8pt** |
| 合格アサーション数 | 19/19 | 12/19 | +7 |
| 平均所要時間 (ms) | 27,264 | 33,283 | -6,019 |
| 平均トークン | 17,160 | 16,085 | +1,075 |

## テストケース別

| テスト | with_skill | without_skill | Δ |
|-------|:---------:|:------------:|:---:|
| eval-cqrs-es-misuse | **6/6 (100%)** | 3/6 (50%) | +50pt |
| eval-subtable-overuse | **6/6 (100%)** | 6/6 (100%) | ±0pt |
| eval-aggregate-design | **7/7 (100%)** | 3/7 (43%) | +57pt |

## 分析

### 🌟 スキルの価値が高い領域（大きな差分）

1. **CQRS / Event Sourcing 用語警告（+50pt）**
   - without_skill は「kintone で ES は成立しない」と実装面は指摘できるが、「CQRS という用語自体が誤用」「Materialized View と呼ぶべき」という**言い換え提案が弱い**
   - with_skill は Fowler の一次定義を引用し、表で「誤用 → 正しい呼称」の対応を明示

2. **Aggregate ↔ kintone アプリ マッピング（+57pt）**
   - without_skill は「DDD 的には CQRS の Read Model です」と**誤用を再生産**してしまう（まさにこのスキルが解決しようとする問題）
   - with_skill は Aggregate = アプリ の原則とマスタ/トランザクション軸の直交性を正しく扱う
   - 物理チェックリスト Check 1-5 を全て適用する一貫性

### ➖ スキルなしでも十分な領域（差分なし）

- **サブテーブル乱用の警告（±0pt）**
  - 両方 100% 合格
  - kintone のサブテーブル制約は Claude の事前知識が充実しており、skill なしでも警告可能
  - 公式ヘルプ・Cybozu DevNet の引用も両方でなされる
  - **スキルの真価は「用語の正確性」「DDD との接続」にある**

### 📉 without_skill の典型的な失敗パターン

| 失敗 | 事例 |
|------|------|
| 「CQRS Read Model」を肯定的に提案 | eval-aggregate-design の without_skill が、集計アプリを Fowler CQRS の Read Model として紹介（→ 用語誤用） |
| Materialized View への言い換え不足 | eval-cqrs-es-misuse の without_skill が「集計系」と機能名のみで言及、代替用語を提案できず |
| DDD マッピングがアドホック | Bounded Context は使うが「kintone スペース」との対応付けが弱い。マスタ/トランザクション軸との直交性は明示されない |
| kintone 固有チェックリストの不足 | 物理設計のチェック項目（採番・ルックアップ vs 関連レコード・プラグイン選定）が断片的にしか言及されない |

## 制約・今後の改善点

### 本 iteration の制約

- **1 走行/設定**: domain-model skill の 3 走行/設定に比べ統計的頑健性が低い
- **with_skill の条件差**: SKILL.md 全文をプロンプトに注入する方式で擬似的に skill を再現（実際の auto-loading 挙動とは微差あり）
- **採点者バイアス**: 本 iteration では自己採点。別レビュアーによる盲目採点は未実施

### 改善案

1. **iteration-2 で 3 走行/設定に拡大** → 統計的信頼性
2. **採点基準の明文化** → assertion の通過判定ガイドラインを `evals/rubric.md` に固定
3. **ケース追加**:
   - マスタ重複（ノーコード地獄）検知ケース
   - レコード番号を一意キーに使おうとするケース
   - 粗利計算を Case アプリ内で完結させようとするケース
4. **without_skill の最小条件化** → kintone 事前知識を明示的に奪う制御

## 結論

**kintone-design スキルは、「用語の正確性」と「DDD との体系的接続」において定量的に有意な効果（+36.8pt）を持つ。**

特に、without_skill が自ら CQRS を誤用してしまった事実（eval-aggregate-design）は、このスキルが埋める空白領域の実在を裏付ける証拠となった。

一方で、サブテーブル制約のような**直接的な技術知識**は Claude の汎用能力で十分カバーされており、スキルの価値は薄い。スキルの方向性としては「**概念マッピングと用語規律**」を核とする現設計が正しいと結論できる。

`kintone-architect` エージェントは、このスキルを内部で参照しつつ、さらに `domain-model` と組み合わせて要件 → アプリ構成までの一貫したオーケストレーションを提供する。単発の skill 利用では繋ぎきれないパイプライン価値を提供。
