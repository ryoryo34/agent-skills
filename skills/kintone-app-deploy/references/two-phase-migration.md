# 2 段階デプロイ実例集

LOOKUP 撤去や型変更など、update で変更できない構造変更を **delete → deploy → re-add → deploy** の 2 段階で処理する具体例。

## 実例 1: LOOKUP を通常 SINGLE_LINE_TEXT に戻す

### 初期状態

- Knowledge (id=1671): `id` (SINGLE_LINE_TEXT, unique=false), `cases` (REFERENCE_TABLE→Case.knowledge_id)
- Case (id=1672): `knowledge_id` (SINGLE_LINE_TEXT with LOOKUP→Knowledge.id), `knowledge_name` (LOOKUP copy)

### 問題

`Knowledge.id` の unique が立っていないため LOOKUP が正しく機能せず、レコード追加で `GAIA_LO03` が発生する。
MCP tool では unique 設定が silent drop するため、LOOKUP 撤去を検討。

### 手順

```
# Phase 1: 依存の剥がし

1. [Knowledge] cases (REFERENCE_TABLE) を delete
   kintone-delete-form-fields app=1671 fields=["cases"]
2. [Knowledge] deploy
   kintone-deploy-app apps=[{"app": "1671"}]
   → SUCCESS 確認
3. [Case] knowledge_id, knowledge_name を delete
   kintone-delete-form-fields app=1672 fields=["knowledge_id", "knowledge_name"]
4. [Case] deploy
   kintone-deploy-app apps=[{"app": "1672"}]
   → SUCCESS 確認

# Phase 2: 再構築

5. [Case] knowledge_id, knowledge_name を LOOKUP なしの SINGLE_LINE_TEXT として add
   kintone-add-form-fields app=1672 properties={
     "knowledge_id": { "type": "SINGLE_LINE_TEXT", "code": "knowledge_id", ... },
     "knowledge_name": { "type": "SINGLE_LINE_TEXT", "code": "knowledge_name", ... }
   }
6. [Case] deploy
   → SUCCESS
7. [Knowledge] cases (REFERENCE_TABLE) を add
   kintone-add-form-fields app=1671 properties={
     "cases": { "type": "REFERENCE_TABLE", ..., "referenceTable": {
       "relatedApp": {"app": "1672", "code": ""},
       "condition": {"field": "id", "relatedField": "knowledge_id"}, ...
     }}
   }
8. [Knowledge] deploy
   → SUCCESS
```

### 失敗するパターンと回避策

- **Phase 1 の 2 をスキップして 3 を実行**
  → `GAIA_RE07`（Knowledge の REFERENCE_TABLE が Case.knowledge_id を参照中）
  → 対処: Step 2 を必ず入れる

- **Phase 2 の 6 をスキップして 7 を実行**
  → deploy FAIL（Knowledge の REFERENCE_TABLE が参照する Case.knowledge_id が live に存在しない）
  → 対処: Case の deploy を先に完了させる

---

## 実例 2: フィールド型変更（SINGLE_LINE_TEXT → MULTI_LINE_TEXT）

### 前提

`problem` フィールドを SINGLE_LINE_TEXT で作ったが、後から MULTI_LINE_TEXT に変えたい。既存レコードにデータが入っている。

### 手順

```
# Phase 0: データバックアップ
1. kintone-get-records app=1672 query="" fields=["id", "problem"]
   → JSON で手元に保存

# Phase 1: 旧フィールド削除
2. kintone-delete-form-fields app=1672 fields=["problem"]
3. kintone-deploy-app apps=[{"app": "1672"}]

# Phase 2: 新フィールド追加
4. kintone-add-form-fields app=1672 properties={
     "problem": { "type": "MULTI_LINE_TEXT", "code": "problem", ... }
   }
5. kintone-deploy-app apps=[{"app": "1672"}]

# Phase 3: データ復元
6. バックアップした JSON を loop で kintone-update-record で書き戻す
   各レコードの problem に旧データを投入
```

### 注意

- delete した時点で live の既存レコードの `problem` 値は**失われる**
- Phase 0 のバックアップは必須
- フィールドコードは同じ `problem` を使うので、他のカスタマイズ JS や自動化は Phase 3 完了後に壊れない

---

## 実例 3: アプリ間で Aggregate 境界を移動

### 前提

`decision` フィールドを Case アプリから Knowledge アプリに移動したい（設計見直しの結果）。

### 手順

```
# Phase 1: Knowledge 側に新フィールド作成
1. kintone-add-form-fields app=1671 properties={
     "decision": { "type": "MULTI_LINE_TEXT", ... }
   }
2. kintone-deploy-app apps=[{"app": "1671"}]

# Phase 2: データ移行（必要なら）
3. Case の全レコードから decision を抽出
4. Knowledge の該当レコードに投入（knowledge_id で紐づけて）

# Phase 3: Case 側の旧フィールド削除
5. kintone-delete-form-fields app=1672 fields=["decision"]
6. kintone-deploy-app apps=[{"app": "1672"}]
```

### 判断ポイント

- **Aggregate 境界の変更**は設計レベルの決定。`kintone-design` の原則・Check を再確認してから実行する
- `kintone-architect` で再設計を走らせてから物理変更に入るのが安全

---

## 共通のベストプラクティス

### 毎 deploy 後に status を確認する

```
kintone-get-app-deploy-status apps=["<id>"]
→ SUCCESS を待ってから次のステップへ
→ FAIL / CANCEL なら即座に原因切り分け（plays 戻り or UI 確認）
```

### バックアップは API ベースで取る

UI からのエクスポートに頼らず、`kintone-get-records` で構造化データ（JSON）としてバックアップする。ロールバック時に再投入が容易。

### ユーザーに事前告知する

2 段階デプロイ中は、一時的にフィールドが消えたりレコード追加が失敗したりする。エンドユーザーが触る環境なら**メンテナンス時間を設けて**実行する。

### dry-run 感覚で preview 確認する

deploy 前に必ず `kintone-get-form-fields(preview: true)` で preview の最終状態を確認。期待と違えば deploy しない。
