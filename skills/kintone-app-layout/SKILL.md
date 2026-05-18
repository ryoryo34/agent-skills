---
name: kintone-app-layout
description: kintone アプリのフォームレイアウトを読みやすく操作しやすく設計するためのプレイブック。LABEL / HR の幅指定、MULTI_LINE_TEXT の innerHeight、インライン HTML/CSS による LABEL 見出し、セクション設計、`kintone-update-form-layout` の layout JSON を扱う。"kintone レイアウト"、"kintone フォーム"、"kintone LABEL 幅"、"kintone update-form-layout"、"kintone セクション"、"kintone 折り返し"、"kintone HR" などで使う。
allowed-tools: Read, Glob, Grep, Edit, Write, AskUserQuestion
---

# kintone-app-layout — kintone フォームレイアウトの実践ガイド

## なぜこのスキルが必要か

kintone のフォームレイアウトは、`update-form-layout` API で JSON として操作する。単純に見えるが以下の**盲点**が実務者を困らせる:

1. **LABEL / HR はデフォルト幅 74px / 135px で、明示指定しないと折り返す**。長文の見出し「📑 識別情報」すら 2〜3 行に崩れる。
2. **LABEL はインライン HTML/CSS を解釈する**のに、この仕様がドキュメントで目立たないため、「セクション見出しを目立たせる」工夫がされないまま味気ないフォームが量産される。
3. **MULTI_LINE_TEXT の innerHeight デフォルトは 125px**で、長文の description / summary に足りない。innerHeight を明示しないと UX が劣化する。
4. **フィールド幅の「見た目の揃え」**（ID 200 + 名前 500 = 700 / 概要 700 等）を設計しないと、バラバラの幅になり可読性が落ちる。
5. **Agent からは JSON（REST API 結果）で取得するので、レイアウト自体は agent に無関係**と思われがちだが、**実際は人間のレビュー / 運用の効率に直結**する。Agent-native でもレイアウトは必要。

このスキルは、これらの盲点を体系化し、**読みやすく・保守しやすい**フォームを毎回作れるプレイブックを提供する。

---

## 最初に叩き込む 4 つの原則

### 原則1: **LABEL / HR は必ず `size.width` を明示する**

デフォルトの自動幅は `74px`（LABEL）/ `135px`（HR）。これは大抵の場合**本文フィールドより狭い**ため、LABEL の見出しが折り返し、HR は中途半端に切れる。

**解決**: LABEL / HR の width を、**本文フィールドの幅に揃える**。700px が多い本文なら LABEL も 700px、1000px なら 1000px。

```json
{
  "type": "ROW",
  "fields": [
    {
      "type": "LABEL",
      "label": "<span style=\"font-size:18px;color:#1976d2;font-weight:bold\">📑 識別情報</span>",
      "size": { "width": "700" }
    }
  ]
}
```

### 原則2: **セクション = LABEL（見出し）+ 本文フィールド群 + HR（区切り）**

人間が読みやすいフォームは、以下のリズムで構成される:

```
[LABEL] セクション見出し
[FIELD] [FIELD]          ← 本文フィールド群
[FIELD]
[HR]                      ← セクション区切り

[LABEL] 次のセクション見出し
...
```

最後のセクションは HR を省略してもよい。

### 原則3: **LABEL はインライン HTML/CSS で装飾できる**

プレーンテキストでは見出しが本文と同化して読みにくい。`<span>` とインライン style で視覚ヒエラルキーを作る。

```html
<span style="font-size:18px;color:#1976d2;font-weight:bold">📑 識別情報</span>
```

- **font-size**: 18〜20px（デフォルトは 14px）
- **color**: 青系推奨（`#1976d2` Material Blue）。赤はエラーと紛らわしい
- **font-weight**: bold
- **絵文字**: セクションの意味を即座に伝える。識別📑 / 本文📝 / 品質📊 / 関連🔗 / 決定✅ / 分析🔍 等

### 原則4: **MULTI_LINE_TEXT は用途に応じて innerHeight を指定**

デフォルト 125px は「一言メモ」用途には十分だが、**長文の description / summary / problem 分析**には足りない。

| 用途 | 推奨 innerHeight |
|---|---|
| 一言メモ / 短い備考 | 125（デフォルト） |
| 要約（200 字程度） | 150〜180 |
| 分析記述（400 字程度） | 180〜200 |
| 本文（800 字以上） | 250〜300 |

同時に `width` も 700〜900 に広げないと横折れする。

---

## 標準テンプレート

### テンプレ A: 識別 + 本文 + 関連 の 3 セクション構成

情報を分類する基本形。

```
[LABEL] 📑 識別情報
[id] [name]                         ← 1 行に短い項目を並べる
[repository] [label] [status]       ← 2〜3 項目で並べる
[HR]

[LABEL] 📝 本文
[summary (幅広・innerHeight 180)]
[description (全幅・innerHeight 300)]
[files]
[HR]

[LABEL] 🔗 関連情報
[related_id] [related_name]
```

### テンプレ B: 問題分析 → 決定 → 根拠 の意思決定構造

ケース管理 / 意思決定ログ向け。

```
[LABEL] 📑 識別情報
[id] [repository] [session_id]
[issue_type] [label]
[HR]

[LABEL] 🔍 問題分析（What・Why・Constraints）
[problem (幅広)]
[context (幅広)]
[restriction (幅広)]
[HR]

[LABEL] ✅ 決定（What & Why）
[decision (幅広)]
[rationale (幅広)]
[HR]

[LABEL] 🔗 紐付け情報
[knowledge_id] [knowledge_name]
```

### テンプレ C: 品質指標 + メタ情報 の運用ダッシュボード構造

confidence / score / priority / status 等のメトリクスを目立たせる。

```
[LABEL] 🎯 運用状況
[status] [confidence] [priority]
[HR]

[LABEL] 📝 内容
...
```

---

## フィールド型別の推奨サイズ

| フィールド型 | 用途 | 推奨 width (px) | innerHeight (px) |
|---|---|---|---|
| SINGLE_LINE_TEXT | ID / コード | 150〜200 | - |
| SINGLE_LINE_TEXT | 名前 / タイトル | 400〜500 | - |
| SINGLE_LINE_TEXT | URL / パス | 500〜700 | - |
| MULTI_LINE_TEXT | 要約 | 700 | 180 |
| MULTI_LINE_TEXT | 本文 | 700〜900 | 250〜300 |
| MULTI_LINE_TEXT | 備考 | 500 | 125 |
| NUMBER | 金額 / 数値 | 150〜200 | - |
| NUMBER | 確度 / スコア（小数） | 150 | - |
| DROP_DOWN | カテゴリ | 200 | - |
| RADIO_BUTTON | 二〜三択 | 250〜300 | - |
| DATE / DATETIME | 日付 | 200 | - |
| USER_SELECT | 担当者 | 300 | - |
| FILE | 添付 | 400 | - |
| REFERENCE_TABLE | 関連レコード | 幅指定不要（親行幅に従う） | - |
| LABEL | 見出し | **本文フィールドの幅と揃える** | - |
| HR | 区切り | **本文フィールドの幅と揃える** | - |

---

## LABEL HTML 装飾のパターン集

### パターン 1: シンプル見出し（推奨・デフォルト）

```html
<span style="font-size:18px;color:#1976d2;font-weight:bold">📑 識別情報</span>
```

### パターン 2: 段階的な見出し（h1 / h2 風）

最上位見出しを大きく、サブ見出しを小さく:

```html
<!-- 大見出し -->
<span style="font-size:22px;color:#0d47a1;font-weight:bold">🏢 顧客情報</span>

<!-- 小見出し -->
<span style="font-size:16px;color:#1976d2;font-weight:bold">　├ 基本情報</span>
```

### パターン 3: 警告・注意書き

```html
<span style="font-size:14px;color:#d32f2f;font-weight:bold">⚠️ 入力時の注意</span>
```

### パターン 4: 説明テキスト

```html
<span style="font-size:13px;color:#666">📌 このセクションは自動入力されます</span>
```

### パターン 5: バッジ風見出し（背景色つき）

```html
<span style="display:inline-block;padding:4px 12px;background:#1976d2;color:#fff;font-weight:bold;border-radius:4px">📑 識別情報</span>
```

色の使い分け:

| 色 | 用途 | 推奨カラーコード |
|---|---|---|
| 青 | 通常見出し | `#1976d2` / `#0d47a1` |
| 緑 | 成功 / 完了系 | `#2e7d32` / `#388e3c` |
| 赤 | 警告 / エラー | `#d32f2f` / `#c62828` |
| 橙 | 注意 / ハイライト | `#f57c00` / `#ef6c00` |
| 灰 | 補足 / メタ | `#616161` / `#757575` |

---

## トラブルシュート

### 事例 1: LABEL が改行される

**症状**: `📑 識別情報` と書いたのに画面で `📑` / `識別` / `情報` のように 3 行に分かれて表示される。

**原因**: `size.width` を指定せず、自動値 74px が適用されている。`📑`（絵文字 32px）+ `識別情報`（日本語 4 文字 × 約 18px = 72px）で 100px 超、74px に収まらない。

**対処**: `size: { "width": "700" }` を明示する。本文フィールドの幅と揃える。

### 事例 2: HR が短い

**症状**: 罫線が画面中央で途切れる。

**原因**: HR もデフォルト 135px。LABEL と同じく自動幅が短い。

**対処**: HR の `size.width` も本文幅に揃える。

```json
{ "type": "ROW", "fields": [{ "type": "HR", "size": { "width": "700" } }] }
```

### 事例 3: MULTI_LINE_TEXT の入力欄が小さすぎて使いづらい

**症状**: 本文 800 字を入れる想定のフィールドが 3 行しか見えない。

**原因**: innerHeight デフォルト 125px は短文前提。

**対処**: `"size": { "width": "800", "innerHeight": "300" }` のように innerHeight を用途に合わせる。

### 事例 4: HTML タグが文字として表示される

**症状**: `<span style="...">📑 識別情報</span>` が画面にそのまま出る。

**原因**: LABEL ではなく別のフィールド型に同じ文字列を入れた。LABEL 以外は HTML をエスケープする。

**対処**: 見出しは必ず LABEL フィールド（type: "LABEL"）で作る。

### 事例 5: deploy 後にレイアウトが反映されない

**症状**: `update-form-layout` の revision は進んだが、画面のレイアウトが変わらない。

**原因**: `deploy-app` を叩いていない（preview に留まっている）。

**対処**: `kintone-deploy-app apps=[{"app": "<id>"}]` を実行し、status SUCCESS を確認。

---

## チェックリスト（レイアウト設計時）

- [ ] セクション分割を LABEL（見出し）+ HR（区切り）で明示しているか
- [ ] 全 LABEL / HR に `size.width` を明示しているか（自動値 74/135 に委ねていないか）
- [ ] LABEL / HR の width を本文フィールドの width に揃えているか
- [ ] LABEL に HTML/CSS 装飾（font-size / color / font-weight）を入れているか
- [ ] MULTI_LINE_TEXT の innerHeight を用途に応じて調整しているか（125 デフォルト以外が必要か判断）
- [ ] 複数フィールドを横並びにする行で幅の合計が収まっているか（大抵 900〜1000px 以内）
- [ ] 絵文字セクション見出しで情報の種類が一目で分かるか
- [ ] deploy 後にブラウザで実機確認したか

---

## 出力フォーマット

レイアウト提案を作成する際は、以下の構成を**必ず守る**。特に `## 3. 画面イメージ (ASCII)` は**必須**。人間がレイアウトを頭に描けないと採用判断できない。

```markdown
# レイアウト設計: [アプリ名]

## 1. 採用セクションパターン
  - 使うテンプレ番号（`references/layout-patterns.md` の 1〜10 のどれか）
  - なぜそのテンプレを選んだかの理由（情報の論理構造・一覧性要件・ユースケース）

## 2. 幅・高さポリシー
  - 本文フィールド幅（例: 700px で統一）
  - LABEL / HR の width（本文幅と同じ）
  - MULTI_LINE_TEXT の innerHeight 用途別
  - SINGLE_LINE_TEXT / DROP_DOWN 等の短項目幅

## 3. 画面イメージ（ASCII）★必須
  - 実際のブラウザ表示を ASCII で縦展開
  - LABEL（見出し）の強調、HR（区切り）、各フィールドの width 目安を表現
  - 横並びは `[f1(200)] [f2(500)]` のように幅付きで
  - MULTI_LINE_TEXT は複数行のボックスで高さを表現
  - セクションヘッダは絵文字 + 装飾を見せる

## 4. update-form-layout に渡す完全 JSON
  - そのままコピペで MCP に投げられる形式
  - ROW / fields / size / 各属性を明示

## 5. スタイル装飾の根拠
  - LABEL の font-size / color / font-weight の選定理由
  - 絵文字の意味的選定（📑 識別, 🔍 分析, ✅ 決定, 🔗 関連, 📊 メトリクス）
  - 色のセマンティクス（青 = 通常、赤 = 警告、緑 = 完了、橙 = ハイライト）

## 6. 実機ブラウザ確認チェックリスト
  - [ ] LABEL が折り返していないか
  - [ ] HR が中途半端に切れていないか
  - [ ] MULTI_LINE_TEXT の高さが用途に足りているか
  - [ ] 横並びフィールドが合計 900px 以内か
  - [ ] deploy 後の live 画面で実機確認したか
```

### 画面イメージ（ASCII）の書き方

```
┌─────────────────────────────────────────────────────────┐
│ 📑 識別情報                        ← LABEL (18px/#1976d2/bold)
│ [id: 200         ] [name: 500                          ]
│ [repository: 300 ] [label: 200] [status: 200           ]
│ ──────────────────────────────────────────────── ← HR (width=700)
│ 📝 ナレッジ本体                    ← LABEL
│ [summary: 700 × 180                                     ]
│ │                                                        │
│ │                                                        │
│ [condition: 700                                         ]
│ [description: 700 × 300                                 ]
│ │                                                        │
│ │                                                        │
│ │                                                        │
│ [files: 400      ]
│ ────────────────────────────────────────────────
│ 📊 品質管理                        ← LABEL
│ [confidence: 200]
│ ────────────────────────────────────────────────
│ 🔗 紐付けケース履歴               ← LABEL
│ [cases REFERENCE_TABLE（Case app を逆引き表示、20件）   ]
└─────────────────────────────────────────────────────────┘
```

- `[name: 500]` の形式で **フィールドコード名 + width(px)** を示す
- `│ │` の縦棒で MULTI_LINE_TEXT の**高さ**を 3〜5 行で表現
- 絵文字付き LABEL は装飾情報（`(18px/#1976d2/bold)`）を右端に注記
- HR は `────` の水平線 + `← HR (width=700)` の注記
- REFERENCE_TABLE は参照先と表示件数を 1 行で
- 全体を `┌┐└┘│` でフォームの境界を示す

この ASCII を見るだけで、レビュアーが**採用すべきかどうか一発で判断**できることがゴール。

---

## 参考: 詳細リファレンス

| ファイル | 内容 |
|---|---|
| `references/layout-patterns.md` | 10 種類のレイアウトテンプレ完全版（識別×本文×関連、ダッシュボード、カード型、ウィザード型 等） |
| `references/label-styling-cookbook.md` | LABEL 装飾 HTML/CSS 集、20+ パターン、ブランドカラー対応 |
| `references/field-sizing-reference.md` | 全フィールド型 × 全用途での推奨 width / innerHeight 早見表 |

---

## Limits（このスキルの限界）

- **kintone 側の CSS オーバーライドで変わる可能性**: 組織で `customize.css` を適用している場合、LABEL の HTML/CSS 挙動が変わる。本スキルはデフォルトのスタイル前提。
- **モバイル画面の考慮は限定的**: 横並びフィールドが多いレイアウトはスマホで縦積みになる。モバイル重視なら縦積み中心に設計する。
- **アクセシビリティ**: LABEL の色依存は色覚多様性の観点で弱い。業務要件でアクセシビリティが重要なら、絵文字 + 濃色 + 明瞭な文字列で冗長化する。

---

## 関連スキル・エージェント

- **設計フェーズ**: `kintone-design` / `kintone-architect`（どのフィールドをどのアプリに配置するか）
- **デプロイ**: `kintone-app-deploy`（レイアウト変更後の deploy 手順、deploy FAIL 切り分け）
- **実装オーケストレータ**: `kintone-engineer` エージェント（本スキル + `kintone-app-deploy` を連動）
