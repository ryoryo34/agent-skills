---
name: kintone-app-deploy
description: kintone アプリのフィールド追加・変更・削除・デプロイを、kintone REST API / MCP ツール経由で安全に進めるための実務プレイブック。クロスアプリ参照、LOOKUP 撤去、REFERENCE_TABLE 依存、破壊的変更の 2 段階デプロイ、`unique` silent drop、`GAIA_LO03` / `GAIA_RE07` 切り分けを扱う。"kintone デプロイ"、"kintone フィールド削除"、"LOOKUP 設定"、"REFERENCE_TABLE"、"kintone MCP"、"kintone-update-form-fields"、"kintone-deploy-app"、"kintone 2段階デプロイ"、"kintone アプリ構築" などで使う。
allowed-tools: Read, Glob, Grep, Edit, Write, Bash, AskUserQuestion
---

# kintone-app-deploy — kintone 実装・デプロイ実務プレイブック

## なぜこのスキルが必要か

kintone の「アプリ設定 → デプロイ」は単純な CRUD ではない。以下の**暗黙の依存関係**と**ツール側の既知バグ**が実務者をハマらせる:

1. **クロスアプリ参照の依存グラフ**: LOOKUP / REFERENCE_TABLE は相手アプリのフィールドを参照するため、削除・変更の順序を誤るとデプロイが FAIL する。
2. **preview / live の 2 階層**: フィールド変更は preview に溜まり、`deploy` で live に反映。設計ミスがあると FAIL して live とずれたまま固まる。
3. **型変更の禁止**: 一度作ったフィールドの `lookup` を後から外す等の**構造変更**は update では通らない。**delete → deploy → re-add → deploy** の 2 段階操作が必須。
4. **MCP ツール（`kintone-add-form-fields` / `update-form-fields`）の既知バグ**: `unique: true` / `defaultValue` / `minValue` / `maxValue` / `displayScale` が **silent に落ちる**。API 呼び出しは成功（revision が進む）するが、実際の設定は反映されない。**UI で手動設定**が必要なケースあり。
5. **deploy FAIL 時の情報不足**: ステータスが `FAIL` / `CANCEL` としか返らず、原因が分からない。依存関係を推測して切り分ける必要がある。

このスキルは、これらの罠を体系化し、**毎回同じ手順で事故なく進める**プレイブックを提供する。

---

## 最初に叩き込む 5 つの原則

### 原則1: 「削除は被参照側から、追加は被参照元から」

クロスアプリ参照（LOOKUP / REFERENCE_TABLE）の依存関係は一方向。

```
[1 側: Knowledge]                    [N 側: Case]
   id (unique) ────────────────── knowledge_id (LOOKUP)
   cases (REFERENCE_TABLE) ────── knowledge_id (filter key)
```

- **削除**: REFERENCE_TABLE → LOOKUP → 参照先フィールドの順で、**外側から剥がす**
- **追加**: 参照先フィールド → LOOKUP → REFERENCE_TABLE の順で、**内側から積む**

依存を逆順で操作すると必ず `GAIA_RE07`（削除不可：参照されている）で止まる。

### 原則2: preview と live を同時に脳内モデル化する

`kintone-add-form-fields` / `update-form-fields` / `delete-form-fields` は **preview のみ**を変更する。`kintone-deploy-app` を叩くまで live は変わらない。

- **preview**: 設定の編集バッファ
- **live**: 実際の運用データを保持する本番
- **`kintone-get-form-fields`** はデフォルトで live を返す。preview を見たいときは `preview: true`。

デプロイ FAIL が起きたら、**preview と live の差分**を想像することで原因の 9 割が当たる。

### 原則3: **構造変更は delete + re-add**

以下は update では通らない。delete → deploy → re-add → deploy の 2 段階を使う:

| 変更内容 | update 可否 | 対処 |
|---|---|---|
| ラベル変更、required 変更 | ✅ | update で OK |
| `unique: true` 追加 | ⚠️ MCP でバグ | UI 手動 or 後述の回避策 |
| LOOKUP 設定を後から剥がす | ❌ | delete → re-add |
| SINGLE_LINE_TEXT → MULTI_LINE_TEXT の型変更 | ❌ | delete → re-add |
| フィールドコード変更 | ❌ | 実質不可（新規フィールド + データ移行） |

### 原則4: **MCP ツールは silent drop を起こす**

`kintone-add-form-fields` / `update-form-fields` で以下のプロパティが落ちることが確認されている:

| プロパティ | 落ちる条件 | 回避策 |
|---|---|---|
| `unique: true` (SINGLE_LINE_TEXT) | add / update 両方 | **UI 手動で「値の重複を禁止する」チェック** |
| `defaultValue` (NUMBER) | update | add 時に設定 or UI |
| `minValue` / `maxValue` (NUMBER) | update | add 時に設定 or UI |
| `displayScale` (NUMBER) | update | add 時に設定 or UI |

**検知方法**: 設定後に `get-form-fields` で再取得し、期待したプロパティが反映されているか確認する。silent drop は必ず運用で問題を起こす（LOOKUP の参照先 unique が立っていなければ `GAIA_LO03` でレコード追加が失敗する）。

### 原則5: **選択肢系フィールドは空で作れない**

DROP_DOWN / RADIO_BUTTON / CHECK_BOX / MULTI_SELECT は `options` が空だと API がエラーになる。「選択肢は後から追加」でも、作成時点で**プレースホルダ**（例: `未分類`, `TBD`, `default`）を 1 つ入れる。

```json
{
  "label": {
    "type": "DROP_DOWN", "code": "label", "label": "業務ラベル",
    "required": true,
    "options": {
      "未分類": { "label": "未分類", "index": "0" }
    }
  }
}
```

---

## 標準プレイブック（新規アプリ構築）

`kintone-architect` や `kintone-design` で設計が完了している前提で、以下の順で実装する:

### Step 1: アプリ作成（2 アプリ以上ある場合は **被参照側を先に**）

```
kintone-add-app で Knowledge(被参照側) → Case(参照側) の順に作成
```

`space` パラメータで作成先スペースを指定。戻り値の `app` ID を記録。

### Step 2: フィールド追加（各アプリごと）

**被参照側（Knowledge）**: 通常フィールドをすべて追加。`id` フィールドには `unique: true` を指定する（※ silent drop を後で検証）。

**参照側（Case）**: 通常フィールドに加えて LOOKUP / REFERENCE_TABLE を設定。LOOKUP 先のフィールドコード（例: `knowledge_id`）と、コピーされる側（例: `knowledge_name`）を**両方**作る。

### Step 3: LOOKUP 設定の実装パターン

```json
"knowledge_id": {
  "type": "SINGLE_LINE_TEXT",
  "code": "knowledge_id",
  "label": "ナレッジID",
  "lookup": {
    "relatedApp": { "app": "1671", "code": "" },
    "relatedKeyField": "id",
    "fieldMappings": [
      { "field": "knowledge_name", "relatedField": "name" }
    ],
    "lookupPickerFields": ["id", "name", "status"],
    "filterCond": "",
    "sort": ""
  }
}
```

**前提条件**: `relatedApp.app` のアプリは **deploy 済み**で、`relatedKeyField`（`id`）には **unique 制約が立っている**こと。

### Step 4: REFERENCE_TABLE 設定の実装パターン

```json
"cases": {
  "type": "REFERENCE_TABLE",
  "code": "cases",
  "label": "ケース履歴",
  "referenceTable": {
    "relatedApp": { "app": "1672", "code": "" },
    "condition": {
      "field": "id",              // このアプリ（Knowledge）の field
      "relatedField": "knowledge_id"  // 相手アプリ（Case）の field
    },
    "filterCond": "",
    "displayFields": ["id", "problem", "decision", "issue_type"],
    "sort": "レコード番号 desc",
    "size": "20"
  }
}
```

**前提条件**: `relatedApp.app` のアプリは **deploy 済み**で、`relatedField`（`knowledge_id`）が**存在**していること。

### Step 5: 検証（最重要）

deploy 前に `kintone-get-form-fields` で各フィールド設定を取得し、silent drop の有無を確認:

```bash
# 期待: unique: true
# 実際: unique: false ← silent drop 発生
```

silent drop が確認されたら:
- **このプレイブックでは MCP で修復しようとしない**（update でも silent drop する）
- ユーザーに「UI で手動設定」を依頼する
- 手動設定後の再デプロイで LOOKUP が機能するか再検証

### Step 6: デプロイ

**順序**: 被参照側 → 参照側。両方同時に `kintone-deploy-app` に渡しても内部で依存が解決される場合もあるが、失敗した場合は必ず順序を分ける。

```
# 安全な順序
kintone-deploy-app [{ "app": "1671" }]  # Knowledge を先
# SUCCESS 確認
kintone-deploy-app [{ "app": "1672" }]  # Case を後
```

各 deploy 後に `kintone-get-app-deploy-status` で `SUCCESS` を確認。`PROCESSING` なら待つ。`FAIL` / `CANCEL` なら「トラブルシュート」セクションへ。

---

## 標準プレイブック（既存アプリの構造変更）

### パターン A: フィールド追加のみ

1. `kintone-add-form-fields` で preview に追加
2. `kintone-deploy-app` で live に反映
3. `kintone-get-form-fields` で反映確認

### パターン B: フィールド設定変更（軽微）

1. `kintone-update-form-fields` で preview 更新
2. deploy
3. `get-form-fields` で **silent drop の有無を必ず確認**。反映されていなければ UI 手動修正へ。

### パターン C: LOOKUP 撤去 / 型変更（2 段階デプロイ）

**最重要パターン**。LOOKUP 設定を後から剥がしたい等、update で変更不可能な構造変更で使う。

```
Phase 1: 依存を先に剥がす
  1-a. [被参照側] REFERENCE_TABLE を delete
  1-b. [被参照側] deploy
  1-c. [参照側] 旧 LOOKUP フィールドを delete
  1-d. [参照側] deploy

Phase 2: 新しい形で積み直す
  2-a. [参照側] 新フィールド（LOOKUP なしの SINGLE_LINE_TEXT 等）を add
  2-b. [参照側] deploy
  2-c. [被参照側] REFERENCE_TABLE を add
  2-d. [被参照側] deploy
```

**Phase をまたいで deploy しないと FAIL する**。`delete` と `add` を preview 内で連続実行しても、deploy で内部整合性チェックが通らないケースがある。

### パターン D: クロスアプリ参照のあるフィールド削除

必ず REFERENCE_TABLE → LOOKUP → フィールド本体の順で消す。逆順だと `GAIA_RE07`。

---

## デプロイ FAIL 切り分けフロー

`kintone-get-app-deploy-status` が `FAIL` or `CANCEL` を返したときの切り分け:

```
1. preview 側の最終状態を get-form-fields(preview: true) で確認
    → 意図した構成になっているか?
2. live 側の現状を get-form-fields で確認
    → preview との差分は何か?
3. 差分の中に「構造変更」が含まれているか?
    - LOOKUP の付け外し? → パターン C の 2 段階に分ける
    - 型変更? → 同上
4. クロスアプリ依存の外側から処理しているか?
    - REFERENCE_TABLE 先に消しているか?
    - LOOKUP 先に消しているか?
5. silent drop で依存が立っていない?
    - LOOKUP 参照先が unique になっていない → GAIA_LO03 の種
```

### トラブルシュート具体例

#### 事例1: `GAIA_LO03` ルックアップの参照先から値をコピーできません

```
原因: LOOKUP の relatedKeyField で指定したフィールドに unique 制約がない
発生: MCP で unique: true を指定したが silent drop していた
対処:
  1. get-form-fields で unique: false であることを確認
  2. UI で「値の重複を禁止する」にチェック
  3. 該当アプリを deploy
  4. レコード追加を再試行
```

#### 事例2: `GAIA_RE07` フィールドを削除できません。関連レコード一覧フィールドから参照されています

```
原因: REFERENCE_TABLE が参照しているフィールドを先に消そうとした
対処:
  1. 相手アプリの REFERENCE_TABLE を先に delete
  2. 相手アプリを deploy
  3. 改めて当該フィールドを delete
  4. deploy
```

#### 事例3: deploy status が `FAIL` / `CANCEL` のまま止まる

```
原因: preview に構造変更（LOOKUP 付け外し / 型変更）が溜まっている
対処:
  1. 2 段階デプロイ（パターン C）に分解
  2. 依存を先に delete + deploy
  3. その後 add + deploy
```

#### 事例4: DROP_DOWN フィールドが追加できない

```
原因: options が空オブジェクト
対処:
  "options": { "未分類": { "label": "未分類", "index": "0" } }
  のようにプレースホルダを 1 件以上入れる
```

---

## チェックリスト（デプロイ前）

- [ ] 被参照側 → 参照側 の順で作成・デプロイする計画になっているか
- [ ] LOOKUP の relatedKeyField は unique が立っているか（get-form-fields で確認）
- [ ] LOOKUP の fieldMappings で指定したフィールドは**事前に作ってあるか**
- [ ] REFERENCE_TABLE の relatedApp の field は**deploy 済み**か
- [ ] DROP_DOWN / RADIO_BUTTON 等の options が空でないか
- [ ] 構造変更が含まれる場合、2 段階デプロイ（パターン C）に分解済みか
- [ ] preview / live の差分を脳内でモデル化したか
- [ ] 各 deploy 後に `kintone-get-app-deploy-status` を叩く計画か
- [ ] silent drop しうるプロパティ（unique / defaultValue / 数値制約）は deploy 後に**再検証**する計画か

---

## 出力フォーマット

実装プラン / 手順書を作成する際は、以下の構成を**必ず守る**。読み手（ユーザー or 次の実装者）が上から読むだけで事故なく実行できる順序で記述する。

```markdown
# 実装プラン: [アプリ名] or 解決手順: [課題名]

## 1. デプロイ計画（依存グラフ + 順序）
  - 関連アプリの依存関係（誰が誰を参照しているか）
  - 削除順序 / 追加順序 / 2 段階デプロイの要否判定
  - 各 deploy ステップの発火タイミング

## 2. 各アプリのフィールド設計
  - アプリ名 / app ID / フィールド一覧
  - 型・必須・unique 等の属性
  - DROP_DOWN 等には必ず options プレースホルダ付き JSON

## 3. LOOKUP / REFERENCE_TABLE 設定
  - 参照関係の具体 JSON（relatedApp / relatedKeyField / fieldMappings / lookupPickerFields）
  - REFERENCE_TABLE の condition.field / condition.relatedField

## 4. デプロイ実行順序（ステップ番号付き）
  - 1. ... → deploy → SUCCESS 確認
  - 2. ... → deploy → SUCCESS 確認
  - 単一アプリずつ実行する原則に従う

## 5. 検証チェックリスト
  - silent drop 検証（unique / defaultValue / min/max / displayScale）
  - LOOKUP 参照先の unique 確認
  - deploy status が SUCCESS になっているか
  - テストレコード投入で GAIA_LO03 等が出ないか

## 6. 将来の構造変更時の注意点（2 段階デプロイが必要なケース）
  - LOOKUP 撤去 / 型変更 / フィールドコード変更
  - delete → deploy → re-add → deploy の 2 段階手順
```

このテンプレを崩さない。各セクションが省略されていると事故のトリアージが困難になる。

---

## 参考: 詳細リファレンス

| ファイル | 内容 |
|---|---|
| `references/deploy-order-playbook.md` | 依存グラフに基づく削除 / 追加 / 変更の型、複数アプリ同時デプロイの罠 |
| `references/mcp-gotchas.md` | MCP ツール（`kintone-add-form-fields` 等）の silent drop / undocumented エラー集、回避策一覧 |
| `references/two-phase-migration.md` | 2 段階デプロイの実例（LOOKUP 撤去、型変更、フィールドコード変更） |

---

## Limits（このスキルの限界）

- **kintone REST API / MCP ツールの版数によって挙動が変わる**: silent drop の対象プロパティは将来修正される可能性がある。本スキルは 2026-04 時点の観測ベース。
- **UI 操作の自動化は含まない**: silent drop の最終回避策として「UI で手動設定」を指示するが、そのステップは人間が実行する前提。
- **プラグインが加わっている環境では追加の制約がある**: カスタマイズ JS / プラグインが発火するタイミングで deploy 挙動が変わるケースは本スキルの範囲外。

---

## 関連スキル・エージェント

- **設計フェーズ**: `kintone-design` / `kintone-architect`（要件 → ドメインモデル → アプリ構成）
- **レイアウト**: `kintone-app-layout`（LABEL / HR の幅指定、HTML 装飾、セクション設計）
- **実装オーケストレータ**: `kintone-engineer` エージェント（本スキル + `kintone-app-layout` を連動）
