# レイアウトテンプレ集

実案件で使いやすい 10 種類のテンプレート。`update-form-layout` の JSON として直接採用できる形。

## テンプレ 1: 識別 + 本文 + 関連（汎用 3 セクション）

```
📑 識別情報
────
📝 本文
────
🔗 関連情報
```

最も汎用的。マスタアプリ / Knowledge アプリ向け。

```json
[
  { "type": "ROW", "fields": [{"type": "LABEL", "label": "<span style=\"font-size:18px;color:#1976d2;font-weight:bold\">📑 識別情報</span>", "size": {"width": "700"}}] },
  { "type": "ROW", "fields": [{"type": "SINGLE_LINE_TEXT", "code": "id", "size": {"width": "200"}}, {"type": "SINGLE_LINE_TEXT", "code": "name", "size": {"width": "500"}}] },
  { "type": "ROW", "fields": [{"type": "SINGLE_LINE_TEXT", "code": "repository", "size": {"width": "300"}}, {"type": "DROP_DOWN", "code": "label", "size": {"width": "200"}}, {"type": "DROP_DOWN", "code": "status", "size": {"width": "200"}}] },
  { "type": "ROW", "fields": [{"type": "HR", "size": {"width": "700"}}] },
  { "type": "ROW", "fields": [{"type": "LABEL", "label": "<span style=\"font-size:18px;color:#1976d2;font-weight:bold\">📝 本文</span>", "size": {"width": "700"}}] },
  { "type": "ROW", "fields": [{"type": "MULTI_LINE_TEXT", "code": "summary", "size": {"width": "700", "innerHeight": "180"}}] },
  { "type": "ROW", "fields": [{"type": "MULTI_LINE_TEXT", "code": "description", "size": {"width": "700", "innerHeight": "300"}}] },
  { "type": "ROW", "fields": [{"type": "HR", "size": {"width": "700"}}] },
  { "type": "ROW", "fields": [{"type": "LABEL", "label": "<span style=\"font-size:18px;color:#1976d2;font-weight:bold\">🔗 関連情報</span>", "size": {"width": "700"}}] },
  { "type": "ROW", "fields": [{"type": "SINGLE_LINE_TEXT", "code": "related_id", "size": {"width": "200"}}, {"type": "SINGLE_LINE_TEXT", "code": "related_name", "size": {"width": "500"}}] }
]
```

---

## テンプレ 2: 問題分析 → 決定 → 紐付け（意思決定構造）

```
📑 識別情報
────
🔍 問題分析（What・Why・Constraints）
────
✅ 決定（What & Why）
────
🔗 紐付けナレッジ
```

ケース管理 / 意思決定ログ / 障害報告 等向け。

---

## テンプレ 3: 品質メトリクス + 内容（運用ダッシュボード）

```
🎯 運用状況
(status, confidence, priority, owner)
────
📝 内容
────
📊 履歴・計測
```

ナレッジ / SLI 管理 / KPI モニタリング向け。

---

## テンプレ 4: 時系列ステータス（案件管理）

```
📑 基本情報
────
📈 ステータス推移
(status, received_at, started_at, completed_at)
────
📝 内容
────
💰 金額・見積
────
🔗 関連
```

案件管理 / タスクトラッキング向け。

---

## テンプレ 5: カード型マスタ

```
📑 企業情報
(company_id, company_name, industry)
────
📍 所在地
(address, tel, website)
────
👥 担当者
(related records)
────
📝 備考
```

顧客 / 企業マスタ向け。関連レコードを差し込む型。

---

## テンプレ 6: ウィザード型（ステップ順）

```
① 初期情報
────
② 詳細入力
────
③ 確認
```

長いフォームを段階的に。各ステップの開始で LABEL の絵文字 + 番号で現在地を示す。

---

## テンプレ 7: メタ情報アップフロント

```
📑 サマリ
(title, status, assignee, priority) ← 最初に全景
────
📝 詳細
────
🔗 関連
```

「ぱっと見でわかる」を最優先するケース。管理職視点で一覧性を重視。

---

## テンプレ 8: 左右 2 列（詳細 vs 集計）

kintone のフォームは 1 列レイアウトだが、横並びを活用して疑似 2 列にできる。

```
[詳細 LABEL]            [集計 LABEL]
[detail_field1]         [summary_field1]
[detail_field2]         [summary_field2]
```

横並び 2 フィールドを同じ行に配置し、視覚的に対比させる。

---

## テンプレ 9: ログフィード型

```
📝 最新エントリ
(content, author, timestamp)
────
📜 過去のエントリ
(REFERENCE_TABLE)
```

活動履歴 / 投稿ログ向け。

---

## テンプレ 10: シンプル（セクションなし）

```
(field1)
(field2)
(field3)
```

フィールド 3〜5 個の軽量アプリ。セクション不要。

---

## 設計時の判断フロー

```
1. フィールド数は何個?
   3〜5 個 → テンプレ 10 (セクションなし)
   6 個以上 → セクション分割検討

2. 情報の論理グルーピングは?
   識別 / 本文 / 関連 → テンプレ 1
   問題 / 決定 → テンプレ 2
   メトリクス / 内容 / 履歴 → テンプレ 3
   時系列フロー → テンプレ 4
   マスタ性データ → テンプレ 5

3. ユースケースで一覧性は重要?
   Yes → テンプレ 7（サマリ上出し）
   No → 通常配置

4. 長さ・項目数が多い?
   Yes → テンプレ 6（ウィザード型）
```
