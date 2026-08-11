---
name: cloudflare-os-ops
description: >-
  デプロイ済み Cloudflare OS インスタンスの運用プレイブック。
  gatekeeper の後付けデプロイ(GitHub/Google/Slack/MCP 等)、service binding の追加、
  AI モデルプロバイダーの追加(CF_AI_GATEWAY_PROVIDERS)、Worker の secrets 設定、
  接続トラブルの診断手順を含む。「(インスタンス名)に〜を追加」「gatekeeper を繋ぐ」
  「Cloudflare OS のモデル/プロバイダーが出ない」「Not Configured と表示される」
  「binding 設定」など、Cloudflare OS インスタンスの構成変更・運用・デバッグに関わる
  タスクでは必ずこのスキルを参照すること。公式ドキュメントに本番運用手順が存在しないため
  (2026-08 時点)、ここが唯一の検証済み手順書。
---

# Cloudflare OS 運用プレイブック

このスキルは 2026-08 に実機(公式ワンクリックデプロイ産のインスタンス)で検証した手順の記録。
upstream(cloudflare/cloudflare-os)は early access で、**gatekeeper の本番デプロイ手順は
公式ドキュメントに存在しない**。ここに書かれた規約はすべて「公式デプロイフローが生成した
実機構成」と「リポジトリのソース」から逆算・実証したもの。

## 対象インスタンスの解決(最初に必ずやる)

このスキルは複数の Cloudflare OS インスタンスを扱える。作業前に対象を確定させる:

1. ユーザーがインスタンス名を指定していればそれを使う
2. `~/.config/cloudflare-os-ops/instances/*.env` を列挙する。1つならそれ、複数なら
   ユーザーにどれか確認する
3. 設定ファイルがなければユーザーに値を聞き、次回のために `.env` を作成する
   (このファイルはローカル専用。リポジトリにコミットしない)

`.env` のスキーマ(値はすべて例):

```sh
# ~/.config/cloudflare-os-ops/instances/<instance>.env
CFOS_INSTANCE="myos"                        # Worker 名プレフィックス(router Worker 名と同じ)
CFOS_HOST="https://os.example.com"          # 公開ホスト(Access 保護推奨)
CFOS_ACCOUNT_ID="0123456789abcdef..."       # Cloudflare Account ID
CFOS_CLONE="$HOME/src/cloudflare-os"        # cloudflare-os リポジトリのローカル clone
```

以降のコマンドはこの env を読み込んだ前提(`source <path>.env`)。
Worker 群の命名は公式デプロイフローの規約に従う:
router = `$CFOS_INSTANCE` / backend = `$CFOS_INSTANCE-backend` /
gatekeeper = `$CFOS_INSTANCE-gk-<name>`。

## アーキテクチャ規約(すべてソース・実機で確認済みの事実)

1. **router は `GATEKEEPER_*` binding を走査**して `/gatekeeper/<name>/*` をその Worker に
   転送する(`packages/router/src/index.ts:29-31`)。OAuth コールバックは gatekeeper Worker
   自身に着地する(同 :43-44)
2. **backend も独立に `GATEKEEPER_*` を走査**して Connections UI 用の vendor map を作る
   (`packages/workshop-backend/src/auth/auth-vendors.ts:23-34`)
3. **backend への binding は entrypoint `GatekeeperVendor` の指定が必須**。router への
   binding は default エントリポイント。この非対称を忘れると動かない
4. 命名規約: Worker 名 `$CFOS_INSTANCE-gk-<name>`、
   `BASE_URL=$CFOS_HOST/gatekeeper/<name>`
5. 公式デプロイ産の Worker は **workers.dev サブドメインを全て無効化**している。
   手動デプロイした Worker も必ず揃える(Access を迂回する裏口になるため)
6. OAuth 系 gatekeeper(GitHub/Google 等)の必要 env は `CLIENT_ID` / `CLIENT_SECRET` /
   `BASE_URL` の3つ(各 gatekeeper の src で `env.*` を数えて確認する)

## Gatekeeper 後付けデプロイ(検証済み: github, google)

### Step 0: プロバイダー側で OAuth アプリ作成【ユーザー作業】

- callback URL は必ず `$CFOS_HOST/gatekeeper/<name>/oauth`(末尾スラッシュなし)
- GitHub は「OAuth Apps」で作る(「GitHub Apps」は scope 制御が効かず不可。
  `packages/gatekeeper-github/README.md` 参照)
- Google は同意画面が Testing のままだと refresh token が7日で失効する。常用するなら公開する。
  加えて GCP プロジェクトで使う API の有効化が必要(Gmail / Drive / Docs / Sheets /
  Calendar / BigQuery — `packages/gatekeeper-google/README.md` Step 2)

### Step 1: Worker デプロイ【ユーザーが `!` で実行(クラウド書き込みのため)】

```
! cd $CFOS_CLONE/packages/gatekeeper-<name> && pnpm exec wrangler deploy --name $CFOS_INSTANCE-gk-<name> --var "BASE_URL:$CFOS_HOST/gatekeeper/<name>"
```

pnpm がリポジトリ指定バージョンと食い違う環境では、corepack shim(nvm 配下等)を
PATH 先頭に置くと安定する。

### Step 2: workers.dev 無効化【Claude が API で実行】

```sh
scripts/verify-gatekeeper.sh <name> --instance <instance> --close-subdomain
```

または手動: `POST /accounts/$CFOS_ACCOUNT_ID/workers/scripts/$CFOS_INSTANCE-gk-<name>/subdomain`
に `{"enabled":false,"previews_enabled":false}`。

### Step 3: 認証情報【ユーザーがダッシュボードで設定。チャット経由禁止】

`$CFOS_INSTANCE-gk-<name>` → Settings → Variables and Secrets:
- `CLIENT_ID` = Text で可(公開情報)
- `CLIENT_SECRET` = **必ずタイプ「Secret」を選ぶ**。Text(plain_text)で保存すると
  API から値が読め、確認作業で値がセッションに露出する事故が実際に起きた。
  もし Text で保存してしまったら: プロバイダー側でシークレット再生成 → 旧変数を削除 →
  Secret タイプで再登録

### Step 4: service binding ×2【ユーザーがダッシュボードで設定】

| Worker | binding 名 | Service | Entrypoint |
|---|---|---|---|
| `$CFOS_INSTANCE`(router) | `GATEKEEPER_<NAME>`(大文字) | `$CFOS_INSTANCE-gk-<name>` | (default のまま) |
| `$CFOS_INSTANCE-backend` | `GATEKEEPER_<NAME>` | `$CFOS_INSTANCE-gk-<name>` | **`GatekeeperVendor`** |

### Step 5: 検証【Claude が実行】

```sh
scripts/verify-gatekeeper.sh <name> --instance <instance>
```

このスクリプトは secret の値を一切表示しない(存在とタイプのみ)。手書きで API 確認する
場合も、**変数値は全てマスクする**こと(plain_text の secret が混ざっている前提で書く)。

最後にユーザーがブラウザで: Gatekeepers ページ → Available から接続 → OAuth 認可。
「CONNECTED に載る + AVAILABLE にも残る」は OAuth 型の正常動作(複数アカウント接続可の
ため。ambient 型だけが Available から消える。`routes/gatekeepers.tsx:692` 付近)。

## AI モデルプロバイダー追加(検証済み: openai)

モデルピッカーに出るプロバイダーは backend の env `CF_AI_GATEWAY_PROVIDERS`
(カンマ区切り)で決まる。追加は2点セット:

1. `$CFOS_INSTANCE-backend` の `CF_AI_GATEWAY_PROVIDERS` に追記
   (例: `anthropic,cloudflare,openai,google`)
2. プロバイダーの API キーを **AI Gateway 側に登録**(BYOK)。gateway モードでは
   erebor 側 UI にキー入力欄は出ない(`AddModelModal.tsx` が
   `apiToken: gatewayMode ? '' : ...` とする実装)。キーの置き場所はインスタンスの外 =
   デプロイ管理ページ or ダッシュボードの AI Gateway 設定

## トラブルシュート早見表

| 症状 | 原因 | 対処 |
|---|---|---|
| `<Name> Gatekeeper Not Configured` ページ | CLIENT_ID か CLIENT_SECRET が未設定(誤値ではなく欠落判定。`google.ts:594-596` 相当) | Step 3 を実施/再確認 |
| Gatekeepers ページに新 vendor が出ない | backend への binding 欠落 or entrypoint 未指定 | Step 4 の backend 行を確認 |
| `/gatekeeper/<name>/` が 404/素通り | router への binding 欠落 | Step 4 の router 行を確認 |
| Add AI model にプロバイダーが出ない | `CF_AI_GATEWAY_PROVIDERS` に含まれていない | 上記2点セット |
| 接続後も AVAILABLE に残る | 仕様(OAuth 型は複数アカウント可) | 対処不要 |
| Google 連携が API エラー | GCP プロジェクトで対象 API 未有効化 | Step 0 の API 有効化リストを確認 |
| wrangler が非対話でトークン切れ | OAuth refresh 失敗 | ユーザーに `! wrangler login` を依頼 |

## 将来の統合方針(このスキルの賞味期限)

- upstream README は「gatekeeper を OS インスタンスから独立してデプロイ・保守できるようにする」
  構想を予告している。**公式手順が出たらそちらに移行し、このスキルは差分だけ残して縮退させる**
- 中期計画は「cloudflare-os-starter ベースのリポジトリ + GitHub Actions の Issue/PR 駆動デプロイ」。
  移行時の必須3点:
  1. CI secrets 加固(deploy は push-to-main 限定 / GitHub Environments required reviewer /
     `.github/workflows/**` と deploy script に CODEOWNERS)
  2. starter の `generateConfigs()` を拡張して既存 gatekeeper の binding を再現
     (そのままだと無言で機能退行)
  3. **Worker 名を厳密に引き継ぐ**(Durable Object は Worker 名に紐づく。名前が変わると
     ユーザーデータ・OAuth トークンが新規扱い=消失)
- ローカル MCP ブリッジ(tunnel 経由)は ops 用途では不採用(gatekeeper-mcp の認証が
  フル OAuth か無認証の二択で、無認証は承認キューを迂回した直叩きが可能なため)。
  読み取り専用ツール + 認証付きの構成でのみ再検討する
