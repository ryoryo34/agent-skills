---
name: kintone-design
description: kintone（およびローコード基盤）のアプリ設計を DDD 視点で行う際の、概念マッピング・用語の誤用回避・物理設計の地雷回避を支援する。ドメインモデルから kintone アプリ群への正しい翻訳（Aggregate=アプリ、Materialized View=集計アプリ、Audit Log=履歴アプリ）、サブテーブル / ルックアップ / 関連レコード / 採番の判断基準、CQRS/Event Sourcing と名乗らないための用語警告、プラグイン vs カスタマイズ JS の選択ロジック、そして「ノーコード地獄」予防のガバナンス原則までを網羅する。"kintone", "kintone設計", "kintone アプリ", "サブテーブル", "ルックアップ", "関連レコード", "kintone DDD", "マスタアプリ", "ノーコード設計", "low-code design", "Aggregate を kintone に" 等のキーワードや、kintone 上での業務アプリ設計・リアーキテクト依頼時に必ず発動する。
allowed-tools: Read, Glob, Grep, Edit, Write, AskUserQuestion
---

# kintone-design — kintone 設計の DDD マッピング + 物理地雷回避

## なぜこのスキルが必要か

kintone は「データベース」ではなく「**アプリ = マイクロサービス = Aggregate Root**」として設計すべきプラットフォーム（R3 Institute）。しかし実務では、DDD / CQRS / Event Sourcing の用語が kintone 文脈で**誤用される**ケースが多い。本スキルは:

1. **正しい概念マッピング** を提示する
2. **用語の誤用** を警告する（「CQRS」「Event Sourcing」を安易に使わせない）
3. **物理設計の地雷**（サブテーブル・関連レコード・採番・プラグイン選定）を回避させる
4. **ノーコード地獄** を予防する（アプリ爆発・マスタ重複）

公式パートナーを含め、この領域は**論述空白**。Cybozu 公式は「データ設計の基本」を述べるが DDD 用語は使わず、R3 Institute は「マイクロサービス論」までで Aggregate 等には踏み込まない。Salesforce の Apex Enterprise Patterns が唯一の「ローコード × DDD」体系化事例。

このスキルは、これらの空白を埋める**実務家向けの設計ガイドライン**として機能する。

---

## 最初に叩き込む 5 つの原則

### 原則1: kintone アプリ = Aggregate Root

各 kintone アプリのレコードは DDD の Aggregate Root として扱う。マスタ（Company）もトランザクション（Case）も**対等な Aggregate**。「マスタだから偉い / 軽い」はない。

### 原則2: マスタ / トランザクション軸と Aggregate 軸は **直交**

| 軸 | 意味 |
|----|------|
| マスタ/トランザクション | データの寿命・更新頻度・参照方向 |
| Aggregate | 不変条件の保護とトランザクション境界 |

両者は別次元。マスタでも Aggregate、トランザクションでも Aggregate。**「マスタ = 正規化済みデータ」と単純化しない**。

### 原則3: kintone は **CRUD ベース**、CQRS / ES ではない

用語警告（最重要）:

| ❌ 誤用 | ✅ 正しい呼び名 | 根拠 |
|--------|--------------|------|
| 「集計アプリは CQRS Read Model」 | **Materialized View / Data Mart** | Fowler の CQRS 定義は「同じデータの異なるモデル」で、派生データの別モデル化とは別物 |
| 「活動履歴アプリは Event Store」 | **Audit Log** | ES は「全状態変更がイベント由来」「イベントから状態再構築可能」が必須。kintone は直接更新できる |
| 「kintone は CQRS + ES みたいなもの」 | **Aggregate 中心 CRUD + Materialized View 併用 + Audit Log** | 正確には上記 |

### 原則4: スペース = Bounded Context

運用で最も妥当な物理化。スペース越境のルックアップは警戒（Bounded Context の崩壊）。

### 原則5: ルックアップは **Snapshot 参照**、関連レコードは集計不可

公式制約を機械的に運用する:
- 集計 / グラフ / CSV / 一覧フィルタが必要 → **ルックアップ**
- マスタ変更追随が必要 + 集計不要 → **関連レコード**
- 両方必要 → **別アプリ化（Materialized View）**

---

## DDD ↔ kintone マッピング表

| DDD 概念 | kintone 実装 | 評価 | 注意 |
|---------|-------------|:----:|------|
| Bounded Context | スペース | ○ | 運用上最適 |
| Aggregate Root | アプリのレコード | △ | UI/JS/API 3経路で更新可能。不変条件の強制は JS で担保 |
| Entity | レコード（ID = identity） | ○ | OK |
| Value Object | フィールド | △ | 不変性保証なし |
| Repository | REST API `/k/v1/records` | △ | コレクション的だが純粋な Repo ではない |
| Domain Service | カスタマイズ JS の純粋関数 | △ | UI 層と混在しがち |
| Application Service | submit ハンドラ / Webhook レシーバ | ○ | OK |
| Domain Event | Webhook（発火のみ） | △ | 一次ストアではない |
| **Materialized View** | 集計アプリ（収支/サマリ等） | ✅ | CQRS じゃなくこっち |
| **Audit Log** | 変更履歴 / 活動履歴 | ✅ | ES じゃなくこっち |

詳細は `references/ddd-mapping.md` を参照。

---

## 物理設計チェックリスト

設計レビュー時、以下を**機械的に**適用する。

### Check 1: サブテーブル設計

| 条件 | 判断 |
|------|------|
| 想定行数 > 100 | ⚠️ 別アプリ化を検討 |
| 想定行数 > 数百 | ❌ 別アプリ必須（R3 Institute 警告） |
| 他アプリから参照する必要あり | ❌ 別アプリ（SUM 関数外で参照不可） |
| 集計・グラフ・CSV 出力 | ❌ 別アプリ |
| Zapier 等の外部連携で直接扱う | ❌ 別アプリ（サブテーブルは扱えない） |
| 上記すべて該当しない | ✅ サブテーブルで OK |

### Check 2: ルックアップ vs 関連レコード（公式比較表）

| 要件 | ルックアップ | 関連レコード |
|------|-----------|------------|
| 集計・グラフ化 | ✅ | ❌ |
| 一覧画面への表示 | ✅ | ❌ |
| CSV 出力 | ✅ | ❌ |
| マスタ変更の自動反映 | ❌ | ✅ |
| 複数件を一覧表示 | ❌ | ✅ |

**判断フロー**:
1. 単一参照 + 集計/検索が必要 → ルックアップ
2. 複数件表示 + マスタ追随が必要（集計不要） → 関連レコード
3. 両方必要 → **別アプリ（Materialized View）化**

#### Check 2.1: N:1 リレーションの実装鉄則

N:1（多対一）の関係を実装する際、**どちら側にどの機能を置くか**を以下で決め打ちする:

```
  [1 側: マスタ / Knowledge]               [N 側: トランザクション / Case]
        id (unique)                              foreign_id
        ↑ ←──── LOOKUP ────────────────── foreign_id ← 値コピー元
        ↑
        └───── REFERENCE_TABLE ──────── 逆引き一覧として 1 側に配置
```

- **N 側に LOOKUP**: N レコードは親（1 側）の値をコピーして持つ。変更追随や集計に使う
- **1 側に REFERENCE_TABLE**: 1 レコードから関連する N 件を逆引きで表示（データ重複なし）
- **subtable で N を保持するのは NG**: 1 側 app にサブテーブルで N 側情報を重複して持たせると、N 側との二重管理になり同期が取れない（アンチパターン AP-11）

#### Check 2.2: LOOKUP の参照先は unique 必須

LOOKUP の `relatedKeyField` に指定するフィールドは **値の重複を禁止する** 設定が必須（kintone 仕様）。

- 一般的には 1 側の `id` フィールドが unique になっている前提
- レコード番号（`$id`）は自動的に unique だが、マイグレーションで非連番化するため業務キーには使わない（Check 3 参照）
- 業務キー（`CASE-0001` 等）を SINGLE_LINE_TEXT で作る場合、**unique: true を明示的に設定**する

⚠️ MCP ツール経由で `unique: true` を指定しても silent drop するバグあり（`kintone-app-deploy` スキル参照）。UI で手動設定が必要なケースがある。

#### Check 2.3: 選択肢系フィールドの初期化

DROP_DOWN / RADIO_BUTTON / CHECK_BOX / MULTI_SELECT を作成する際、`options` を**空のまま作成できない**（API が 400 を返す）。

「選択肢は後から追加」の場合もプレースホルダを 1 件以上入れる:

```json
"options": {
  "未分類": { "label": "未分類", "index": "0" }
}
```

### Check 3: 採番ルール

| 観点 | 判断 |
|------|------|
| レコード番号を一意キーに使う | ❌ **公式警告**（データ移行で非連番化） |
| プラグイン（joyzo 等）を使う | ○ 最も堅牢 |
| JS + REST API で採番 | ○ 競合対策（リトライ）があれば OK |
| プレフィックス付き業務コード | ✅ 推奨（`C-00001`, `DD-2026-0001` 等） |

### Check 4: 粗利・集計ロジックの配置

| 実装方式 | 評価 |
|---------|------|
| Case アプリ側で関連レコード集計 | ❌ 標準機能で集計不可、プラグイン必須（脆弱） |
| 別アプリ（Materialized View）＋ Webhook | ○ リアルタイム性あり |
| 別アプリ ＋ 日次バッチ（Azure Functions 等） | ✅ Phase 1 推奨（堅牢・実装単純） |

### Check 5: プラグイン vs カスタマイズ JS

| 基準 | プラグイン | カスタマイズ JS |
|------|----------|--------------|
| 実装工数 | 低い | 高い |
| ベンダーロック | あり | なし |
| 月額コスト | あり | なし |
| 長期運用 3 年+ | △ | ✅ |
| PoC / MVP | ✅ | △ |

選定は **(a) プラグイン稟議可否 × (b) 長期運用視点** で決める。

詳細は `references/physical-checklist.md` を参照。

---

## 設計フロー（Phase 1-5）

### Phase 1: ユビキタス言語とアクター特定
`domain-model` スキル相当。ドメインの用語・アクター・ユースケースを洗い出す。

### Phase 2: Aggregate 境界の特定
- Small Aggregates 原則（Vernon）
- マスタ / トランザクション分類を**別軸**で付与
- 1 Aggregate = 1 kintone アプリ、と機械的に割り当てる

### Phase 3: kintone アプリへのマッピング
- スペース = Bounded Context
- アプリ = Aggregate Root
- フィールド = Entity 属性 / Value Object
- **集計が必要な派生データは Materialized View アプリとして別出し**
- **履歴は Audit Log として別アプリ化**

### Phase 4: 物理設計チェックリスト適用
上記 Check 1-5 を機械的に走らせる。

### Phase 5: カスタマイズ方針決定
- プラグイン採用可否
- JS 共通モジュール構成（auto-numbering / normalize / duplicate-check）
- 集計バッチの配置（Azure Functions / GAS / Webhook）

---

## アンチパターン集

| アンチパターン | なぜ悪い | 代替 |
|------------|---------|------|
| 集計アプリを「CQRS Read Model」と呼ぶ | Fowler の CQRS 定義を満たさない。用語の濫用 | Materialized View と呼ぶ |
| 履歴アプリを「Event Store」と呼ぶ | ES は一次ストア、kintone 履歴は二次的な副産物 | Audit Log と呼ぶ |
| Case アプリ内で関連レコード集計 | 標準機能で集計・グラフ化・CSV 不可 | 集計専用アプリに分離（Materialized View） |
| サブテーブル 500 行超 | 編集 UI 遅延・他アプリから参照不可 | 別アプリ + ルックアップ |
| 商品マスタ 3 個並立 | ノーコード地獄（Cybozu 公式ガバナンス事例） | マスタ単一化 + 命名規則 + 管理者統制 |
| レコード番号を一意キー | データ移行で非連番化（公式警告） | プラグイン or JS 採番（プレフィックス付） |
| スペース越境の乱用ルックアップ | Bounded Context の崩壊 | スペース内で完結 or Anti-Corruption Layer |
| 「DDD やります」と言ってフィールド設定だけで終わる | Aggregate 境界・不変条件の設計なしに物理から入ると地獄 | 先にドメインモデリング、後に物理 |
| **AP-11: N:1 の 1 側に subtable で N 情報を抱える** | N 側レコード（独立した Aggregate）と二重管理になり同期破綻 | LOOKUP(N 側) + REFERENCE_TABLE(1 側) の鉄則を適用 |
| **AP-12: 業務キー（id）に unique を立てない** | LOOKUP の参照先に使うと `GAIA_LO03` でレコード追加が失敗する | 作成時から `unique: true`、MCP で silent drop する場合は UI 手動設定 |

詳細は `references/anti-patterns.md` を参照。

---

## 使い方

### ケース1: 新規 kintone 設計を DDD 視点で始める
1. まず `domain-model` スキルでユビキタス言語とアクター整理
2. 本スキルの「設計フロー Phase 2-5」を適用
3. 物理設計チェックリスト（Check 1-5）で地雷回避
4. 最終成果物として物理設計書 + ER 図（drawio）

### ケース2: 既存 kintone 設計のレビュー
1. 既存アプリ構成を Check 1-5 に照らして評価
2. アンチパターンに該当する箇所を洗い出し
3. リファクタリング案を提示（サブテーブル分離、集計別アプリ化等）

### ケース3: 「CQRS + ES っぽく作りたい」要望への回答
1. **まず用語警告**を提示（原則3参照）
2. 何が本当に欲しいかを対話で掘る（集計の高速化? 履歴の保全?）
3. 要望を正しい概念（Materialized View / Audit Log）に翻訳
4. 実装方式を提案

---

## 出典（Reliability Tier）

### Tier S（一次定義・公式）
- Fowler "CQRS" (2011) https://martinfowler.com/bliki/CQRS.html
- Fowler "Event Sourcing" (2005) https://martinfowler.com/eaaDev/EventSourcing.html
- Evans "DDD Reference" (2015) https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf
- Vernon "Effective Aggregate Design" (2011) https://www.dddcommunity.org/library/vernon_2011/
- Cybozu DevNet "kintone データ設計の基本" https://cybozu.dev/ja/kintone/tips/best-practices/colum/basic-data-design-in-kintone/
- Cybozu SIGNPOST パターン集 https://kintone.cybozu.co.jp/kintone-signpost/
- Salesforce Trailhead "Apex Enterprise Patterns"

### Tier A（認定パートナー・著名実装）
- R3 Institute "データベースとしての kintone" https://www.r3it.com/column/kintone-as-a-database
- Kurrent "Event Sourcing vs Audit Log" https://www.kurrent.io/blog/event-sourcing-audit
- Greg Young "CQRS and Event Sourcing" (2014)
- Cybozu セキュリティ室 "kintone ガバナンスガイドライン" note

全出典は `references/sources.md` を参照。

---

## 参考: 詳細リファレンス

このスキル配下の `references/` に以下の詳細リファレンスを格納:

| ファイル | 内容 |
|---------|------|
| `ddd-mapping.md` | DDD 概念 ↔ kintone 実装 の詳細マッピング、各項目の根拠と限界 |
| `terminology-warnings.md` | CQRS/ES 誤用の具体例と反例、正しい言い換え |
| `physical-checklist.md` | Check 1-5 の深掘り、実装サンプル JS |
| `anti-patterns.md` | 実例アンチパターン集、リファクタ案 |
| `sources.md` | 全出典（Tier S/A/B）の詳細 |

## Limits（このスキルの限界）

- **kintone を DDD の正統実装として扱うには根本的な制約がある**: UI/JS/API の3経路で Aggregate を迂回して更新可能。「Aggregate Root 経由以外で状態を変えられない」保証を作ることは原理的に困難。
- このスキルの概念対応は「比喩」として有用だが、「kintone ≒ DDD」と断言するのは避ける。
- 公式・認定パートナーでの体系化事例は乏しい（論述空白領域）。本スキルは実務家向けガイドラインとして機能するが、唯一の正解ではない。

## 関連エージェント: `kintone-architect`

要件・ユースケースから一気に kintone アプリ構成まで落とし込みたい場合は、本スキルを内部で参照する **`kintone-architect` エージェント**（`agents/kintone-architect.md`）を利用する。5 フェーズで以下を実行:

1. 要件取得（AskUserQuestion）
2. ドメインモデル導出（`domain-model` スキル利用）
3. kintone アプリへの翻訳（本スキルの原則 + Check 1-5 を機械適用）
4. 物理設計チェックリスト適用
5. 成果物生成（アプリ一覧 / フィールド設計 / ER 図 / 判断ログ）

使い分け: 本スキル単体は「設計レビュー」「用語警告」「物理チェック」の局所用途、`kintone-architect` エージェントは「要件からアプリ構成までのパイプライン」用。

## 実装フェーズへの橋渡し

本スキルで設計が固まったら、**実装・デプロイ・レイアウトの物理化**は以下のスキル / エージェントに引き継ぐ:

- `kintone-app-deploy` — フィールド追加・変更・削除のデプロイ順序、破壊的変更の 2 段階デプロイ、MCP ツール silent drop 回避策
- `kintone-app-layout` — レイアウト設計（LABEL 幅の明示、HTML/CSS 装飾、セクション構造化、フィールド幅統一）
- `kintone-engineer` エージェント — 上記 2 スキルをオーケストレートする実装担当。`kintone-architect` の下流として配置

設計 → 実装の流れ:

```
[kintone-architect]           設計フェーズ（本スキル + domain-model を利用）
       ↓ アプリ一覧・フィールド設計・ER 図を引き渡し
[kintone-engineer]        実装フェーズ（kintone-app-deploy + kintone-app-layout を利用）
       ↓ 実アプリに物理化・レイアウト仕上げ
       → デプロイ完了
```

## Eval 結果

iteration-2（3 走行/設定）で with_skill **100% (57/57, stddev 0.00)** / without_skill 66.7% (38/57, stddev 0.03)。用語警告（+50pt）と DDD マッピング（+47.6pt）で大きな効果、再現性完全一致。詳細は `BENCHMARK.md` 参照。
