# デプロイ順序プレイブック

kintone アプリ間のクロス参照（LOOKUP / REFERENCE_TABLE）がある場合の、**削除 / 追加 / 変更の型**を整理する。

## 依存グラフ（N:1 の典型例）

```
┌─────────────────────┐                   ┌─────────────────────┐
│ Knowledge (被参照側) │                   │ Case (参照側)       │
│                     │                   │                     │
│ id (unique) ◀───────┼─── relatedKeyField│ knowledge_id (LOOKUP)│
│ name                │                   │ knowledge_name (cp) │
│                     │                   │                     │
│ cases (REF_TABLE) ──┼───condition.field →│                    │
└─────────────────────┘                   └─────────────────────┘
           ▲                                          │
           └──── condition.relatedField ──────────────┘
```

- 矢印 `→` は **「参照している」**方向。
- **被参照側**: 依存を受ける側（Knowledge）。LOOKUP の `relatedKeyField` や REFERENCE_TABLE の `condition.relatedField` が指すフィールドを持つ。
- **参照側**: 依存している側（Case）。LOOKUP フィールド本体を持つ。
- **REFERENCE_TABLE は「被参照側に置かれる逆引きウィジェット」**。参照関係としては REFERENCE_TABLE 側が Case 側の field を参照する。

## 基本原則

| 操作 | 順序 |
|---|---|
| 削除 | 外側（参照している側）→ 内側（参照されている側） |
| 追加 | 内側（参照される側）→ 外側（参照する側） |
| 変更 | ケースバイケース（update で済むか、2 段階になるか） |

---

## 型 1: 新規構築フロー

```
Step 1: [Knowledge] アプリ作成 + 基本フィールド追加（id, name, ...）
Step 2: [Knowledge] deploy
  ↓ この時点で live に Knowledge の id フィールドが存在
Step 3: [Case] アプリ作成 + 基本フィールド + LOOKUP 追加
Step 4: [Case] deploy
  ↓ この時点で live に Case.knowledge_id (LOOKUP) が存在
Step 5: [Knowledge] REFERENCE_TABLE 追加（Case の knowledge_id を参照）
Step 6: [Knowledge] deploy
```

**NG パターン**: Step 1 から Step 6 まで preview を溜め込んで最後にまとめて deploy する → 依存整合性で FAIL する可能性大。

---

## 型 2: LOOKUP 撤去フロー（2 段階デプロイ）

既存の LOOKUP 設定を剥がして通常フィールドに戻す場合。

```
Phase 1: 依存の剥がし
  1-a. [Knowledge] REFERENCE_TABLE を delete
  1-b. [Knowledge] deploy ─── live から REFERENCE_TABLE 消滅
  1-c. [Case] LOOKUP フィールド（knowledge_id, knowledge_name）を delete
  1-d. [Case] deploy    ─── live から LOOKUP 消滅

Phase 2: 新しい構成で再構築
  2-a. [Case] LOOKUP なしの SINGLE_LINE_TEXT として knowledge_id / knowledge_name を add
  2-b. [Case] deploy    ─── live に通常フィールドとして存在
  2-c. [Knowledge] REFERENCE_TABLE を add（通常フィールドを参照）
  2-d. [Knowledge] deploy ─── REFERENCE_TABLE 復活
```

**なぜ Phase 1 / Phase 2 で deploy を分けるか**: 1-c で delete する時点で Knowledge 側の live は REFERENCE_TABLE を持っていない必要がある。1-a の delete が preview に溜まっていて deploy していないと、Case の delete が `GAIA_RE07` で止まる。

---

## 型 3: フィールド型変更

例: SINGLE_LINE_TEXT → MULTI_LINE_TEXT に変更したい。

```
Phase 1: [本アプリ] 旧フィールド delete + deploy
  ※ 既存レコードのデータは失われる
Phase 2: [本アプリ] 新フィールド（新しい型で同じ code）add + deploy
```

**注意**: データ保全が必要なら、先に `get-records` でバックアップを取り、delete + re-add 後に新フィールドへインポートする。

---

## 型 4: 単一アプリの軽微変更（1 段階でOK）

以下は 1 回の update + deploy で済む:

- ラベル変更（`label`）
- `required` の切替
- ヘルプテキスト追加
- DROP_DOWN の options 追加（既存の options を残して追加）
- REFERENCE_TABLE の displayFields 変更
- size（幅）の変更

---

## 順序違反で起きる典型エラー

| シナリオ | 発生エラー | 正しい順序 |
|---|---|---|
| LOOKUP 先の id フィールドを先に delete | `GAIA_RE07` | LOOKUP を先に delete → deploy → id delete |
| REFERENCE_TABLE が参照中の field を delete | `GAIA_RE07` | REFERENCE_TABLE を先に delete → deploy → field delete |
| Knowledge 作成前に Case で LOOKUP 作成 | 400 エラー | Knowledge deploy → Case LOOKUP 追加 |
| Case に knowledge_id フィールドがない状態で Knowledge に REFERENCE_TABLE 追加 | deploy FAIL | Case に field 作成 → deploy → REFERENCE_TABLE 追加 |

---

## 複数アプリ同時デプロイの判断

`kintone-deploy-app [{"app": "A"}, {"app": "B"}]` で同時に渡すか、片方ずつ渡すか。

| 状況 | 推奨 |
|---|---|
| 両方とも単純な追加のみ | 同時 OK |
| どちらかに構造変更（LOOKUP / 型変更） | **片方ずつ** |
| 相互参照の REFERENCE_TABLE / LOOKUP が絡む | **片方ずつ + 順序固定** |
| 前回 deploy で FAIL / CANCEL が出た | 必ず**片方ずつで再試行** |

困ったら片方ずつ。時間がかかっても確実。
