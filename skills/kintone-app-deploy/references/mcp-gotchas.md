# MCP ツール（kintone）既知の落とし穴集

本ドキュメントは、kintone REST API の MCP ラッパー（`kintone-add-form-fields` / `update-form-fields` / `deploy-app` 等）の**観測ベースでの既知バグ・挙動の癖**をまとめる。2026-04 時点の実機観測を基にしている。

## silent drop（最優先で警戒）

### 現象

API 呼び出しは成功し、`revision` も進むが、**一部のプロパティが設定されない**。エラーも警告も出ない。

### 確認されている silent drop 対象

| プロパティ | 対象フィールド型 | 発生する API | 回避策 |
|---|---|---|---|
| `unique: true` | SINGLE_LINE_TEXT, NUMBER, LINK, DATE, DATETIME | add / update 両方 | **UI で手動設定**（「値の重複を禁止する」にチェック） |
| `defaultValue` | NUMBER | update | add 時に設定するか UI |
| `minValue` | NUMBER | update | 同上 |
| `maxValue` | NUMBER | update | 同上 |
| `displayScale` | NUMBER | update | 同上 |

### 検知方法

設定直後に `kintone-get-form-fields` で該当フィールドの設定を取得する。期待値と実際の戻り値を比較。

```
# 期待:  "unique": true
# 実際:  "unique": false  ← silent drop 発生
```

`add-form-fields` は`{ "revision": "N" }` を返すだけで、fields の詳細を返さないため、必ず**再取得で検証**する習慣を持つ。

### なぜこれが致命的か

`unique: true` が立っていないと、そのフィールドを `relatedKeyField` にする LOOKUP を作ると**後続のレコード追加で `GAIA_LO03` エラー**が出る。LOOKUP のソースフィールドには unique 制約が必須（kintone 仕様）。

つまり、silent drop は**作成時には成功するが、運用で必ず詰む**という最悪のパターン。

---

## undocumented なエラーコード

### `GAIA_LO03`

```
ルックアップの参照先から値をコピーできません。
「コピー元のフィールド」に指定したフィールドの設定で「値の重複を禁止する」を選択しておく必要があります。
```

**原因**: LOOKUP の `relatedKeyField` に unique 制約がない。silent drop の副作用であることが多い。

**対処**: 該当フィールドの `unique` 設定を UI で修正。その後 deploy して再試行。

### `GAIA_RE07`

```
フィールドを削除できません。「XXX」アプリの関連レコード一覧フィールド「YYY」から参照されています。
```

**原因**: REFERENCE_TABLE が参照しているフィールドを先に消そうとした。削除順序違反。

**対処**: 参照元の REFERENCE_TABLE を先に delete + deploy し、その後当該フィールドを削除。

### deploy `FAIL` / `CANCEL`（原因メッセージなし）

**原因パターン**:
1. preview に構造変更（LOOKUP 付け外し / 型変更）が溜まっている
2. クロスアプリ参照の依存違反（相手側の状態と矛盾）
3. 複数アプリ同時デプロイ時の内部整合性チェック失敗

**対処**: 
- preview と live の差分を `get-form-fields` で洗う
- 2 段階デプロイに分解
- 単一アプリずつデプロイする

---

## deploy 挙動の癖

### 複数アプリ同時デプロイの落とし穴

`kintone-deploy-app [{"app": "A"}, {"app": "B"}]` は内部で依存解決を試みるが、以下のケースで失敗する:

- A と B が相互参照していて、両方同時に構造変更がある
- A の変更が B の live 状態に依存している（B を先に deploy する必要がある）

**推奨**: **片方ずつ deploy する**。成功を確認してから次へ。

### PROCESSING 中の再叩き

`PROCESSING` 中に同じアプリを `deploy-app` で再叩きすると、前回が中断される可能性あり。`SUCCESS` / `FAIL` / `CANCEL` のいずれかが返るまで待つ。

---

## フィールド作成時の制約

### options が空のまま選択肢系を作れない

DROP_DOWN / RADIO_BUTTON / CHECK_BOX / MULTI_SELECT は `options: {}` だと API が 400 を返す。

**回避**: プレースホルダを必ず 1 つ入れる。

```json
"options": {
  "未分類": { "label": "未分類", "index": "0" }
}
```

### fieldMappings のバリデーション

LOOKUP の `fieldMappings` で指定するコピー先フィールド（`field`）は、**同じ add-form-fields 呼び出しの中に含まれていれば OK**。別の呼び出しで先に作る必要はない。

ただし、`relatedField`（相手アプリ側のフィールド）は**相手アプリが deploy 済み**である必要がある。

---

## update-form-fields の特殊性

### 更新できないフィールド属性

update で変更できない項目（MCP の制限ではなく kintone REST API 仕様）:

- フィールドコード（`code`）の変更
- フィールド型（`type`）の変更
- LOOKUP の付け外し（`lookup` プロパティの削除・追加）

→ これらは **delete + re-add** の 2 段階で対応。

### 変更が deploy FAIL を引き起こすケース

update で LOOKUP を**維持したまま** relatedApp を別のアプリに変えようとすると、deploy が FAIL することがある。この場合も delete + re-add が無難。

---

## 観測ログ: 今回のセッションで発生した事象

2026-04-24 のセッション:

1. `kintone-add-form-fields` で Knowledge.id に `unique: true` を指定 → silent drop（`get-form-fields` で `unique: false`）
2. `kintone-update-form-fields` で再度 `unique: true` 指定 → silent drop（revision は進むが反映されず）
3. LOOKUP を作った Case.knowledge_id から add-records → `GAIA_LO03`
4. LOOKUP を撤去しようと `update-form-fields` で `lookup` プロパティを外した body → update は通るが deploy で FAIL
5. `delete-form-fields` で knowledge_id を削除しようとする → `GAIA_RE07`（Knowledge 側の REFERENCE_TABLE `cases` が参照中）
6. Knowledge 側の `cases`（REFERENCE_TABLE）を先に delete + deploy → 成功
7. Case 側の `knowledge_id` / `knowledge_name` を delete + deploy → 成功
8. Case 側に LOOKUP なしの通常 SINGLE_LINE_TEXT として re-add → 成功
9. Knowledge 側の REFERENCE_TABLE を re-add + deploy → 成功
10. Case にレコード追加 → 成功（LOOKUP がないので unique 制約不要）
11. ユーザーに UI で unique を手動設定してもらう → その後 LOOKUP を再構築可能

このフローが**2 段階デプロイ**の典型例。
