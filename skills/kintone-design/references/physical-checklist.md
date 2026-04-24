# 物理設計チェックリスト詳細

Check 1-5 の深掘り。各チェック項目に実装サンプル・具体的な境界値・トレードオフを記載。

---

## Check 1: サブテーブル設計

### 公式制約（要点）
- 1 テーブルあたり**10 フィールド・100 行を推奨**（kintone 公式ヘルプ）
- 絶対上限は **5,000 行**
- **R3 Institute は「数百行で実用にはならない」と実測に基づき警告**

### 標準機能の制約
- サブテーブル内フィールドは **`SUM` 関数でのみ参照可**
- 他アプリからのルックアップ key や関連レコードの**表示列として使えない**
- **Zapier 等の一般的連携サービスはサブテーブルを直接扱えない**
- **REST API では関連レコードの値を操作不可**

### 判断フロー
```
サブテーブルを使いたい
  ↓
① 想定行数 > 100 ?
  YES → 別アプリ化を検討
  NO  → ②へ
  ↓
② 他アプリから参照する要件あり?
  YES → 別アプリ必須（サブテーブルだと参照不可）
  NO  → ③へ
  ↓
③ 集計・グラフ・CSV 出力の要件あり?
  YES → 別アプリ必須
  NO  → ④へ
  ↓
④ Zapier 等の外部連携で直接扱う必要?
  YES → 別アプリ必須
  NO  → ✅ サブテーブルで OK
```

### 判断例
- **1案件の関係者 10-30 人**: サブテーブル OK（集計要件弱い前提）
- **1案件のサービスライン 5-7 件**: サブテーブル OK
- **1顧客の購入履歴**: 別アプリ必須（件数増加・集計要件強）

---

## Check 2: ルックアップ vs 関連レコード

### 公式比較表（cybozu developer network）

| 要件 | ルックアップ | 関連レコード |
|------|-----------|------------|
| 集計・グラフ化 | ✅ 可 | ❌ 不可 |
| 一覧画面への表示 | ✅ 可 | ❌ 不可 |
| CSV 出力 | ✅ 可 | ❌ 不可 |
| マスタ変更の自動反映 | ❌ 不可（手動再取得） | ✅ 可 |
| 複数件を一覧表示 | ❌ 不可 | ✅ 可 |

### 判断フロー
```
マスタを参照したい
  ↓
① 単一参照 (1件を参照)?
  YES → ② 集計・検索が必要?
         YES → ルックアップ
         NO  → ルックアップ（通常）
  NO  → ③
  ↓
③ 複数件を表示 + マスタ変更追随が必要?
  YES → ④ 集計が必要?
         YES → 別アプリ（Materialized View）化を検討
         NO  → 関連レコード
  NO  → 要件を再確認
```

### Snapshot 参照の注意
ルックアップは「**参照時点の値をコピー**」する。マスタを後で変更しても自動更新されない。
- **これを望むケース**: 過去の単価が現在の単価に引きずられない（契約時点の価格を保持）
- **これを望まないケース**: マスタ変更を即反映したい（住所変更がすぐ反映されてほしい）

→ ビジネス上の意図を意識的に選ぶ。

---

## Check 3: 採番ルール

### 公式警告
> "**レコード番号を一意キーとして使ってはならない**。データ移行時に非連番になり整合性が壊れる"
> — cybozu developer network "kintoneにおけるデータ設計の基本"

### 採番方式比較

| 方式 | 工数 | 堅牢性 | ベンダーロック |
|------|-----|-------|-------------|
| A. プラグイン (joyzo 等) | 低 | 高 | あり |
| B. JS + REST API | 中 | 中（要リトライ） | なし |
| C. レコード番号をゼロパディング | 最低 | 低（欠番あり・公式警告） | なし |

### B方式の JS 実装サンプル

```typescript
// common/auto-numbering.ts
import { KintoneRestAPIClient } from '@kintone/rest-api-client';

export async function generateNextId(params: {
  prefix: string;
  idField: string;
  padLength: number;
  maxRetry?: number;
}): Promise<string> {
  const { prefix, idField, padLength, maxRetry = 3 } = params;
  const app = kintone.app.getId();

  for (let attempt = 0; attempt < maxRetry; attempt++) {
    const resp = await kintone.api('/k/v1/records', 'GET', {
      app,
      query: `${idField} like "${prefix}-" order by $id desc limit 1`,
      fields: [idField],
    });
    const lastValue = resp.records[0]?.[idField]?.value;
    const lastNum = lastValue ? parseInt(lastValue.split('-')[1], 10) : 0;
    const nextValue = `${prefix}-${String(lastNum + 1).padStart(padLength, '0')}`;

    // 重複確認
    const dup = await kintone.api('/k/v1/records', 'GET', {
      app,
      query: `${idField} = "${nextValue}"`,
    });
    if (dup.records.length === 0) return nextValue;
  }
  throw new Error('採番リトライ上限到達');
}

// apps/company/main.ts
kintone.events.on('app.record.create.submit', async (event) => {
  if (!event.record.企業ID.value) {
    event.record.企業ID.value = await generateNextId({
      prefix: 'C',
      idField: '企業ID',
      padLength: 5,
    });
  }
  return event;
});
```

### プレフィックス設計例

| アプリ | プレフィックス | 桁数 | 例 |
|-------|-----------|:---:|----|
| 企業マスタ | `C-` | 5 | `C-00001` |
| 担当者マスタ | `P-` | 5 | `P-00001` |
| スタッフマスタ | `S-` | 3 | `S-001` |
| 案件管理 | `DD-YYYY-` | 4 | `DD-2026-0001` |
| 活動履歴 | `A-` | 6 | `A-000001` |

---

## Check 4: 粗利・集計ロジックの配置

### 根本問題
kintone の**関連レコードは集計・グラフ・CSV 出力が一切できない**。Case アプリに外注費合計や工数原価を集計フィールドで持とうとすると、プラグイン必須になる。

### 3 つの実装方式

#### 方式 A: Case アプリ側で関連レコード集計 + プラグイン ❌
- アディエム社の関連レコード集計プラグインなどを使う
- 制約: 1 アプリ 5 関連レコード・10 フィールド・**500 件上限**
- 500 件超の案件（大規模プロジェクト）に耐えない
- プラグインの SLA 依存

#### 方式 B: 別アプリ（Materialized View） + Webhook ⚪
- CostInvoice / WorkLog のレコード作成・更新・削除 Webhook
- 受け口は Azure Functions / GAS
- リアルタイム性あり

**実装サンプル（Azure Functions TypeScript）**:
```typescript
// functions/profit-webhook/index.ts
import { KintoneRestAPIClient } from '@kintone/rest-api-client';

export default async function (req: any) {
  const event = req.body;
  const caseId = event.record.関連案件.value;

  const client = new KintoneRestAPIClient({
    baseUrl: process.env.KINTONE_URL!,
    auth: { apiToken: process.env.KINTONE_API_TOKEN! },
  });

  const [costs, works] = await Promise.all([
    client.record.getAllRecords({
      app: APP_ID.COST_INVOICE,
      condition: `関連案件 = "${caseId}"`,
    }),
    client.record.getAllRecords({
      app: APP_ID.WORK_LOG,
      condition: `関連案件 = "${caseId}"`,
    }),
  ]);

  const costSum = costs.reduce((s, r) => s + Number(r['金額(税抜)'].value || 0), 0);
  const workSum = works.reduce((s, r) => s + Number(r.原価.value || 0), 0);

  await upsertFinanceRecord(client, caseId, {
    外注費合計: costSum,
    工数原価合計: workSum,
  });
}
```

#### 方式 C: 別アプリ + 日次バッチ ✅（推奨・Phase 1）
- 毎日 02:00 cron で全案件を走査
- 集計して案件収支レコードを upsert
- 実装最小・API 呼出抑制・失敗リトライ簡単

**方式 B vs C の選定**:
- **リアルタイム性が必要** → B
- **日次の経営指標として使う** → C（推奨）
- **Phase 1 は C、Phase 2 で B に移行** も可能

---

## Check 5: プラグイン vs カスタマイズ JS

### 判断基準

```
要件確定
  ↓
① 長期運用（3年+）?
  NO → プラグインで OK
  YES → ②
  ↓
② プラグイン稟議・月額コストを通せる?
  YES → プラグイン（保守低コスト・ベンダーロックあり）
  NO  → ③
  ↓
③ TS/JS エンジニアを継続アサイン可能?
  YES → カスタマイズ JS（ロックなし・月額ゼロ）
  NO  → スコープ縮小を検討
```

### 代替可能性マップ

| プラグイン | JS 代替 | 代替工数 | デメリット |
|----------|--------|---------|----------|
| joyzo 自動採番 | ✅ JS + REST API | +1-2人日 | 競合リスク（リトライで軽減） |
| tam-tam 重複チェック | ✅ JS + 類似度計算 | +3-5人日 | 正規化ロジックの自社メンテ |
| アディエム 関連レコード集計 | ✅ Webhook + Functions | 設計初期に組込 | 外部サーバー運用 |
| uSonar（法人マスタ 820万件） | ❌ | — | 代替不可（自社でマスタは持てない） |

---

## 性能設計（参考）

SIGNPOST「性能上の考慮点と改善策」準拠:

| 指標 | 基準 |
|------|------|
| データ量 | 100 万件/アプリまで実用可 |
| データ量 | 10 万件超で性能考慮必須 |
| フィールド数 | 100 超で一覧/詳細画面に遅延 |
| 同時接続 | 100/ドメイン |
| API 呼出 | 10,000/日/アプリ |

### 先手対策
- 長期運用で膨らみそうなアプリ（活動履歴・工数管理）は**年度別アーカイブ**を計画
- 一覧フィールドは 8 個以下に絞る
- バッチは**差分更新**（最終更新日時で絞込）で API 呼出抑制

---

## 出典

- kintone ヘルプ "制限値一覧" https://cn.kintone.help/k/en/admin/limitation/limit
- cybozu developer network "kintoneにおけるデータ設計の基本" https://cybozu.dev/ja/kintone/tips/best-practices/colum/basic-data-design-in-kintone/
- cybozu developer network "関連レコードの項目を条件付きで集計" https://cybozu.dev/ja/kintone/tips/development/customize/related-records/conditional-aggregation-related-records/
- Cybozu "kintone SIGNPOST 性能上の考慮点と改善策" https://kintone.cybozu.co.jp/kintone-signpost/guide/performance.html
- R3 Institute "kintoneのフィールドタイプ別解説「テーブル」" https://www.r3it.com/column/kintone-fieldtype-table
- アディエム "関連レコード集計プラグイン" https://kintone-sol.cybozu.co.jp/integrate/adiem027.html
