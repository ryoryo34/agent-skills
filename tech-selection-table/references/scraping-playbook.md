# スクレイピング・プレイブック（devtool MCP）

比較表用の情報を公式サイトから取得する具体手順。WebFetch は本文要約しか返さないので、料金表・スペック表の細部までは必ず devtool MCP（Chrome DevTools MCP）でブラウザ越しに取る。

## 収集の 3 段フロー

```
Step 1. WebSearch で対象 URL を発見
   ↓
Step 2. devtool MCP で公式サイトを実際に開いて全文取得
   ↓
Step 3. 取得したスナップショット／DOM から必要項目を抽出
```

| ステップ | 主に使うツール | 目的 |
|---------|--------------|------|
| Step 1 | `WebSearch` | 「{サービス名} 料金」「{サービス名} API」などのクエリで公式 URL を見つける |
| Step 2 | `mcp__chrome-devtools__navigate_page` → `mcp__chrome-devtools__take_snapshot` | レンダリング後の全文・構造を取得 |
| Step 2 軽量代替 | `WebFetch` | 静的な HTML のみのページ・短い説明ページに限り使用 |
| Step 3 | `mcp__chrome-devtools__evaluate_script` / `take_snapshot` の解析 | 料金表・FAQ の特定セクションを抜く |

**MCP ツール名は fully-qualified 形式で記述する**（`mcp__<server-name>__<tool-name>`）。複数 MCP サーバーが共存する環境では `navigate_page` 単独だと別サーバーと衝突する可能性があるため、必ず prefix 付きで呼ぶ。

## WebFetch 使い分け

| 使ってよい | 使ってはダメ |
|-----------|-------------|
| 単一の説明文ページ（プロダクト概要程度） | 料金表（タブ／アコーディオン切替） |
| PDF・Markdown など静的ドキュメント | SPA で構築された SaaS ヘルプセンター |
| | JS で動的に料金を出すページ |
| | 長文の比較解説ページ |

## devtool MCP でのスクレイピング手順

各サービスにつき最低 2-3 ページ（トップ・料金・API/連携）を巡回する。

```
1. mcp__chrome-devtools__navigate_page(url="https://例.com/")
2. mcp__chrome-devtools__take_snapshot()
   （アクセシビリティツリー＋テキストを取得）
3. 必要なら mcp__chrome-devtools__evaluate_script で特定セクションを抽出
   例: document.querySelector('.pricing-table')?.innerText
4. 別ページへ：mcp__chrome-devtools__navigate_page("https://例.com/pricing")
5. mcp__chrome-devtools__take_snapshot()
```

### JS 必須サイトの落とし穴対策

- `navigate_page` 直後はネットワーク待ちが必要なことがある → 動的コンテンツが出てこなかったら `mcp__chrome-devtools__wait_for` で要素が現れるまで待ってから snapshot
- Cookie バナー・ダイアログが料金表を隠していることがある → `mcp__chrome-devtools__click` でまず閉じる
- ログイン必須ページ（管理画面の機能紹介）→ 素直に「公開情報からは確認不可、不明」とする。無理にログインしない
- 料金ページが iframe で外部サイトを埋め込んでいる場合 → iframe の URL に直接 `navigate_page`

## 並列スクレイピング（subagent パターン）

3-6 社を順番に巡回すると時間がかかるので、サービス 1 社につき 1 つの subagent を `Agent` ツールで立ち上げて並列実行する。

```
description: "Scrape {サービス名} for comparison table"
prompt: |
  以下のサービスについて、公式サイトをスクレイピングして
  比較表用の項目を埋めてください。

  サービス名: {サービス名}
  探す URL の起点: WebSearch で「{サービス名} 公式」「{サービス名} 料金」を実行
  ツール: devtool MCP の fully-qualified 名で呼ぶこと
         （mcp__chrome-devtools__navigate_page → mcp__chrome-devtools__take_snapshot）。
         WebFetch は使わない（部分要約しか返らないため）。

  巡回するページ（最低3ページ）:
    1. 製品トップ → 提供会社名・サービス概要
    2. 料金ページ → 月額・初期費用・最小ユーザー数・契約方法
    3. API / 連携ページ → API 連携可否、スマホアプリ有無

  抽出する項目（必須6つ）:
    - サービス名
    - 提供会社名
    - 公式URL
    - 費用（月額・初期費用・最小ユーザー数・契約方法を改行内訳）
    - スマホ対応 (◯ / △ / × / 不明)
    - API連携 (◯ / △（プラグインあり） / × / 不明)

  追加項目: {ユーザーがヒアリングで選んだ追加項目をここに列挙}

  確証が取れない値は ◯ にせず「不明」と書くこと。
  個別見積もり制のサービスは費用欄に「個別見積もり」と書くこと。
  出力は JSON で {項目名: 値} の形にすること。
```

各 subagent の戻り値（JSON）を集約して CSV にする。

## 埋められないセルの扱い

- 確証が取れないものは推測で `◯` と書かない。`不明` または `不明（おそらく可能）` とする
- 費用が公開されていない B2B SaaS は素直に `個別見積もり` と書く
- スクレイピング失敗時は理由（「Cookie バナーで pricing が隠れる」など）をログに残し、当該セルは `不明` 扱い
