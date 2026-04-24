# 用語警告: CQRS / Event Sourcing の誤用

kintone・ローコード文脈で頻出する用語の誤用を解説し、正しい言い換えを示す。

---

## 警告 1: 「CQRS っぽい」という表現は避ける

### 誤用例
> 「案件管理アプリ（書き込み）と案件収支アプリ（集計・読み取り）で分離しているので、CQRS っぽい構成です」

### なぜ誤りか

Fowler の **CQRS 一次定義**（2011-07）は明確:

> "The change that CQRS introduces is to **split that conceptual model into separate models for update and display**, which it refers to as Command and Query respectively following the vocabulary of Command Query Separation."

重要なのは:
1. **同じ概念モデル**を Command / Query に分割する（コンテキスト上は同一の「案件」を扱う）
2. Command と Query は**異なるデータ構造**を持ち得る
3. **異なる論理プロセス / 場合によっては異なるハードウェア**で動く

kintone の「案件収支アプリ」は:
- **派生データ**（外注費合計 / 工数原価合計 / 粗利）を持つ別モデル
- 案件アプリのデータ構造を Query 用に再構築したものではなく、**計算結果を別エンティティとして保存**しているだけ
- Command Bus / Event Handler のような**構造的分離**はない

### 正しい呼び名: **Materialized View** または **Data Mart**

マテリアライズドビュー（事前計算済みの派生データを別テーブルに持つ）が最も近い概念。

### さらに Fowler の警告

> "Like any pattern, CQRS is useful in some places, but not in others. Many systems do fit a CRUD mental model, and so should be done in that style. CQRS requires a shift in mentality, and thus **adds a large learning curve**. Coupled with the extra complexity of complexity of the CQRS infrastructure, and you have **an approach that will slow down the team**."

つまり Fowler 自身が「CQRS の誤適用」を警告している。ローコードに「CQRS っぽい」と表現するのは、この警告が懸念するまさにその誤用。

---

## 警告 2: 「活動履歴 = Event Store」という表現は技術的に誤り

### 誤用例
> 「kintone の活動履歴アプリをイベントストアとして使って、過去のデータから状態を再構築できます」

### なぜ誤りか

Fowler の **Event Sourcing 一次定義**（2005-12）:

> "The fundamental idea of Event Sourcing is that **every change to the state of an application is captured in an event object**, and that **these event objects are themselves stored in the sequence they were applied for the same lifetime as the application state itself**."

Event Sourcing の**必須 3 要件**:

1. **全ての状態変更がイベント由来**である
2. **イベントから状態を完全再構築**可能（Replay）
3. **Temporal Query**（過去の任意時点の状態を取得）ができる

kintone のレコード更新履歴・活動履歴アプリは:

| ES 要件 | kintone の状況 | 評価 |
|--------|------------|------|
| 全ての状態変更がイベント由来 | レコードは**直接更新**される。履歴は副産物 | ❌ |
| イベントから状態完全再構築 | 現在値は独立に保存される。履歴を消しても現在値は残る | ❌ |
| Temporal Query | 標準 UI でステータス履歴は見られるが、任意時点の全フィールド状態の復元は不可 | ❌ |
| 訂正可能なイベント列 | 履歴の訂正は想定されていない | ❌ |

**ES の 4 要件をすべて満たさない**。

### 正しい呼び名: **Audit Log**

Kurrent（Event Store 開発元）の記事が明確に区別している:

> "**Audit Log は変更の説明（歴史書）、Event Sourcing のイベントは変更そのもの（事実）**"

kintone の履歴は「歴史書」。ES は「事実の連鎖」。

### Oskar Dudycz の警告

> "Is the audit log a proper architecture driver for Event Sourcing? No. It's a common anti-pattern."

監査ログ要件を理由に ES を採用するのはアンチパターンとして知られている。

---

## 警告 3: 「マスタ = 正規化データ」という単純化は避ける

### 誤用例
> 「データベース正規化したものがマスタデータ」

### なぜ粗い表現か

「マスタ」と「正規化」は**別次元の関心事**:

| 用語 | 何を指すか |
|------|----------|
| マスタ/トランザクション | データの**寿命・更新頻度・参照方向**に関する分類 |
| 正規化（3NF/BCNF） | **関数従属性の解消**に関する設計プロセス |
| Aggregate | **不変条件・トランザクション境界**に関する分類 |

トランザクションテーブルも正規化される。マスタテーブルも正規化される。**「正規化 = マスタだけ」は事実誤認**。

### 正しい表現
- 「マスタアプリ: 寿命が長く、低更新・多参照される Aggregate」
- 「トランザクションアプリ: 業務プロセスの実行記録としての Aggregate」
- 「どちらも正規化の対象になるし、どちらも Aggregate Root を持つ」

---

## 警告 4: 「ドメインモデル → DB 正規化 → DB 保存」という単純化は避ける

### 誤用例
> 「フルスクラッチは、ドメインモデル → DB 正規化 → DB 保存の流れ」

### なぜ粗いか

実務では少なくとも以下の層がある:

```
[1] ユビキタス言語 / ドメインモデル (Entity/VO/Aggregate)
     ↓ （ドメイン層は永続化を知らない）
[2] Repository インターフェース (Domain 層に定義)
     ↓
[3] Repository 実装 / Data Mapper (Infrastructure 層)
     ↓
[4] ORM マッピング / 論理スキーマ
     ↓
[5] 物理スキーマ (3NF/BCNF, index, partition)
     ↓
[6] RDBMS / ストレージエンジン
```

「ドメインモデル → 正規化」と直結させることの問題:

1. **Impedance Mismatch の無視**: オブジェクトモデルと関係モデルは継承・関連・複合型の扱いが違う
2. **Anemic Domain Model の誘発**: 正規化済みテーブル構造をそのままクラス化するとドメインロジックが消える
3. **Aggregate 境界 ≠ Table 境界**: 1 Aggregate が複数テーブルに分割保存、複数 Aggregate が 1 テーブル同居もある
4. **3NF 至上主義の硬直**: 読み取り最適化で非正規化する場面は多い

---

## 警告 5: 「kintone は CQRS + ES みたいなもの」

上記 1-4 を合体した最悪の誤用。完全に誤り。

### 正しい表現
> 「kintone は **Aggregate 中心 + Materialized View 併用 + Audit Log** の CRUD ベースアーキテクチャ」

もっと短く:
> 「**Aggregate Root ごとにアプリ、集計は別アプリ、履歴は監査ログ**」

---

## チートシート

| ❌ 誤用 | ✅ 正しい呼び名 |
|--------|--------------|
| CQRS Read Model | Materialized View / Data Mart |
| Event Store / Event Sourcing | Audit Log |
| 「CQRS + ES っぽい」 | Aggregate 中心 CRUD + Materialized View + Audit Log |
| マスタ = 正規化データ | マスタ/トランザクションと正規化は別軸 |
| ドメインモデル → 正規化 → 保存 | ドメインモデル → Repository 抽象 → 論理スキーマ → 物理スキーマ |

---

## 出典

- Fowler "CQRS" (2011) https://martinfowler.com/bliki/CQRS.html
- Fowler "Event Sourcing" (2005) https://martinfowler.com/eaaDev/EventSourcing.html
- Greg Young "CQRS and Event Sourcing" (Code on the Beach 2014) https://www.kurrent.io/blog/transcript-of-greg-youngs-talk-at-code-on-the-beach-2014-cqrs-and-event-sourcing
- Kurrent "Event Sourcing vs Audit Log" https://www.kurrent.io/blog/event-sourcing-audit
- Oskar Dudycz "audit_log_event_sourcing" https://event-driven.io/en/audit_log_event_sourcing/
- little-hands "CQRS 実践入門" https://little-hands.hatenablog.com/entry/2019/12/02/cqrs
