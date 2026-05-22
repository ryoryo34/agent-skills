# DDD ↔ kintone 詳細マッピング

各 DDD 概念について、kintone での最適対応・限界・実装サンプルを詳述する。

## 1. Bounded Context → スペース

### 評価: ○ 最適

kintone のスペースは複数アプリを束ねる単位で、**組織の Sub-Domain 境界と一致させるのが最良**。

### 実装例
- 「営業スペース」: 案件管理・企業マスタ・担当者マスタ・活動履歴
- 「経理スペース」: 請求管理・入金消込・原価管理
- 「HR スペース」: 勤怠・経費精算・社員マスタ

### 注意
- スペース越境のルックアップは **Bounded Context の崩壊**。Anti-Corruption Layer（ACL）として別途マスタ同期アプリを作るか、重複登録を許容する。

---

## 2. Aggregate Root → アプリのレコード

### 評価: △ 限定的

kintone のレコードは Aggregate Root として扱えるが、**不変条件の強制が弱い**。

### 理由
kintone はレコードを以下 3 経路で更新可能:
1. UI（画面操作）
2. カスタマイズ JS（`app.record.edit.submit` 等）
3. REST API（外部から）

「Aggregate Root を経由した更新のみ許可」という DDD の本質的保護は、上記 3 経路すべてに JS バリデーションをかけないと実現できない。

### 限界と対処
- **UI**: `app.record.create.submit` / `edit.submit` で `event.error` を返す
- **API**: Webhook で post-validation。失敗時はレコード削除 or ステータスで「不正」マーク
- **完全な保護は不可能**: 運用でカバー（管理者権限制御・監査ログ）

### 実装サンプル
```javascript
// 不変条件: 契約額 > 0, 買手 ≠ 売手
kintone.events.on(['app.record.create.submit', 'app.record.edit.submit'], (event) => {
  const r = event.record;
  if (Number(r.契約額.value) <= 0) {
    event.error = '契約額は正の数である必要があります';
    return event;
  }
  if (r.買手企業.value === r.DD対象会社.value) {
    event.error = '買手と売手は異なる企業である必要があります';
    return event;
  }
  return event;
});
```

---

## 3. Entity → レコード（ID = identity）

### 評価: ○

kintone のレコード番号（`$id`）とアプリ内 ID（業務コード）でエンティティの同一性が保たれる。

### 推奨
- アプリ内 ID は**プレフィックス付き**で生成（`C-00001`, `DD-2026-0001`）
- レコード番号を業務キーに使わない（公式警告）

---

## 4. Value Object → フィールド

### 評価: △

フィールドは Value Object の候補だが、**不変性が保証されない**（個別に更新可能）。

### 代替
- Value Object 的に扱いたい属性群は**まとめて更新するカスタマイズ JS**で扱う
- 例: 住所 VO = 郵便番号 + 都道府県 + 市区町村 を1つの編集ダイアログで扱う

---

## 5. Repository → REST API `/k/v1/records`

### 評価: △

kintone REST API はコレクション的インターフェースを提供するが、**DDD の Repository パターンそのものではない**。

### 違い
- Repository は**ドメインオブジェクトの永続化を抽象化**し、クエリ言語を隠蔽する
- kintone REST API は直接的な CRUD + kintone クエリ言語を露出する

### 対処
- JS で Repository 層を自作する（推奨）:
```typescript
// repositories/company-repository.ts
export class CompanyRepository {
  async findByCorporateNumber(num: string): Promise<Company | null> { ... }
  async save(company: Company): Promise<void> { ... }
  async delete(companyId: string): Promise<void> { ... }
}
```

---

## 6. Domain Service → カスタマイズ JS の純粋関数

### 評価: △

ドメインサービス（Entity/VO に属さないロジック）は JS で書けるが、**UI 層と混在しがち**。

### 推奨構造
```
customizations/
├── common/
│   ├── domain-services/
│   │   ├── normalize-company-name.ts   # 純粋関数
│   │   ├── calculate-profit.ts         # 純粋関数
│   │   └── detect-duplicate.ts
│   └── repositories/
└── apps/
    └── company/
        └── main.ts  # submit ハンドラでドメインサービスを呼ぶ
```

---

## 7. Application Service → submit ハンドラ / Webhook レシーバ

### 評価: ○

ユースケース起点の orchestration は、以下で実装可能:
- **UI 起点**: `app.record.create.submit` ハンドラ
- **イベント起点**: Webhook → Azure Functions
- **定期起点**: cron バッチ

これは DDD の Application Service とほぼ同じ粒度。

---

## 8. Domain Event → Webhook（発火のみ）

### 評価: △

kintone の Webhook はレコード作成・更新・削除で発火するが、**一次ストアではない**。

### ES との違い
- Domain Event は本来「**それ自体が真実**」（状態 = イベントから再構築）
- kintone Webhook は「**状態変更後の通知**」（状態はレコードに既に保存済み）

### 使い方
- Webhook は「**プロセス駆動**」に使う（他アプリへの連携、集計バッチトリガ、通知）
- ES 的な「全イベントから状態再構築」は kintone では設計しない

---

## 9. Materialized View → 集計アプリ

### 評価: ✅ 推奨

派生データ（粗利・月次サマリ・顧客ランキング等）は**専用アプリに分離**するのが kintone での正解。

### 理由
- kintone の関連レコードは集計・グラフ・CSV 出力が**できない**
- 別アプリにしてルックアップで参照すれば、集計・可視化が標準機能で可能

### 実装
- Source アプリの作成・更新・削除 Webhook で集計アプリを更新
- または定期バッチ（Azure Functions / GAS）で全件再計算

### 重要
これは **CQRS の Read Model ではなく Materialized View**。Fowler の CQRS 定義とは異なる（同じデータの異なるモデルではなく、派生データの別モデル）。

---

## 10. Audit Log → 変更履歴 / 活動履歴アプリ

### 評価: ✅ 推奨

変更履歴・活動履歴は**監査ログ**として扱う。**Event Sourcing ではない**。

### Kurrent の定義（引用）
> "Audit Log は変更の説明（歴史書）、Event Sourcing のイベントは変更そのもの（事実）"

### 使い方
- 活動履歴アプリ: 面談・電話・訪問の記録（人間が書く）
- kintone 標準のレコード更新履歴: フィールド値の前後差分（自動記録）

いずれも**現在の状態を再構築する元データではない**。

---

## まとめ

| 分類 | kintone 実装 | DDD 適合度 |
|------|-------------|:---------:|
| ✅ よく合う | Bounded Context（スペース）, Entity（レコード）, Application Service（submit） | ○ |
| ✅ 専用アプリとして独立化が推奨 | Materialized View（集計）, Audit Log（履歴） | ✅ |
| △ 限定的 | Aggregate Root, Value Object, Repository, Domain Service, Domain Event | △ |

kintone は DDD の「完全実装」ではないが、**原則を理解した上で比喩として使えば**、混沌としたアプリ群に秩序をもたらす設計ツールになる。
