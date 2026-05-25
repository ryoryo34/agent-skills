# Google Sheets 直接書き込み

オプション機能。ユーザーが Sheets への直接書き出しを希望した場合のみ実行する。CSV を経由せず、環境に用意された Google Sheets 操作ツールや API クライアントに 2 次元配列を渡す。

## 既存スプレッドシートに書き込む

シート名・範囲・値の 2 次元配列を渡す。転置型なので、`values` の各サブ配列が 1 行 = 1 項目（最初の要素は項目名、以降がサービスごとの値）。

```json
{
  "spreadsheetId": "<SHEET_ID>",
  "range": "<シート名>!A1",
  "valueInputOption": "USER_ENTERED",
  "majorDimension": "ROWS",
  "values": [
    ["比較項目", "サービスA", "サービスB", "サービスC"],
    ["提供会社名", "...", "...", "..."],
    ["公式URL", "...", "...", "..."],
    ["費用", "月額 ...\n初期費用 ...\n最小ユーザー数 ...\n契約方法 ...", "...", "..."],
    ["スマホ対応", "◯", "◯", "◯"],
    ["API連携", "◯", "◯", "△（プラグインあり）"]
  ]
}
```

`valueInputOption: "USER_ENTERED"` にすると Sheets 側でフォーマット（URL のハイパーリンク化など）が自動で効く。

## 新規スプレッドシートを作る

```json
{
  "properties": {"title": "<比較表タイトル>"},
  "sheets": [{"properties": {"title": "比較表"}}]
}
```

返却された `spreadsheetId` を使って `values update` で書き込む。

## 既存スプレッドシートの内容を確認

書き込み前に既存内容を読み取って衝突を避けたい場合は、対象範囲（例：`<シート名>!A1:Z100`）を読み取る。

```json
{
  "spreadsheetId": "<SHEET_ID>",
  "range": "<シート名>!A1:Z100"
}
```

## CSV を Sheets に取り込む 3 パターン

| パターン | 手順 | 適している場面 |
|---------|------|--------------|
| A. ユーザーが手動取り込み | CSV を渡す → ユーザーが Sheets で「ファイル > インポート」 | 一度きりの利用、ファイル管理したい |
| B. 直接 API 書き込み | Google Sheets API の `values.update` 相当で 2 次元配列を直接渡す | 既存シートを更新したい、繰り返し利用 |
| C. CSV を JSON 配列に変換して API へ | CSV を読み込んで 2 次元配列にしてから B | CSV をマスタとして残しつつ Sheets にも反映 |

C パターンの変換は Python だと一瞬：

```python
import csv, json
with open("comparison.csv", encoding="utf-8-sig") as f:
    rows = list(csv.reader(f))
payload = {"range": "比較表!A1", "majorDimension": "ROWS", "values": rows}
# あとは利用環境の Google Sheets 操作ツールに渡す
```

## ハマりどころ

- CLI ツールが stderr に認証・keyring 系メッセージを出す場合は、JSON パース時に混ざらないように注意する
- シート名に日本語が含まれる場合、CLI シェルでのクォート崩れに注意する
- `values.append` だと末尾追記、`values.update` だと指定範囲を上書き。比較表更新は `update` を使う
- セル内改行は `\n`（JSON 文字列内のリテラル改行）で OK。CSV ファイル本体ではダブルクォート内の実改行（CRLF）にする
