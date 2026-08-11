---
name: cloudflare-os-ops
description: >-
  デプロイ済み Cloudflare OS インスタンス(erebor.ryoryo.org)の運用プレイブック。
  gatekeeper の後付けデプロイ(GitHub/Google/Slack/MCP 等)、service binding の追加、
  AI モデルプロバイダーの追加(CF_AI_GATEWAY_PROVIDERS)、Worker の secrets 設定、
  接続トラブルの診断手順を含む。「erebor に〜を追加」「gatekeeper を繋ぐ」「Cloudflare OS の
  モデル/プロバイダーが出ない」「Not Configured と表示される」「binding 設定」など、
  Cloudflare OS インスタンスの構成変更・運用・デバッグに関わるタスクでは必ずこのスキルを
  参照すること。公式ドキュメントに本番運用手順が存在しないため(2026-08 時点)、
  ここが唯一の検証済み手順書。
---

# Cloudflare OS 運用プレイブック(erebor)

このスキルは 2026-08 に実機で検証した手順の記録。upstream(cloudflare/cloudflare-os)は
early access で、**gatekeeper の本番デプロイ手順は公式ドキュメントに存在しない**。
ここに書かれた規約はすべて「公式ワンクリックデプロイが生成した実機構成」と
「リポジトリのソース」から逆算・実証したもの。

## インスタンス固有値

| 項目 | 値 |
|---|---|
| ホスト | `https://erebor.ryoryo.org`(Cloudflare Access 保護、メール OTP) |
| Account ID | `4423db4df8672564465e66062a9630de` |
| Worker 群 | `erebor`(router) / `erebor-backend` / `erebor-gk-<name>`(gatekeeper 群) |
| ローカル clone | `/Users/ryosei/scraps/cloudflare-os` |
| AI Gateway | `erebor-ai`(BYOK 方式: プロバイダーキーは gateway 側に保管) |

## アーキテクチャ規約(すべてソース・実機で確認済みの事実)

1. **router(`erebor`)は `GATEKEEPER_*` binding を走査**して `/gatekeeper/<name>/*` を
   その Worker に転送する(`packages/router/src/index.ts:29-31`)。OAuth コールバックは
   gatekeeper Worker 自身に着地する(同 :43-44)
2. **backend(`erebor-backend`)も独立に `GATEKEEPER_*` を走査**して Connections UI 用の
   vendor map を作る(`packages/workshop-backend/src/auth/auth-vendors.ts:23-34`)
3. **backend への binding は entrypoint `GatekeeperVendor` の指定が必須**。router への
   binding は default エントリポイント。この非対称を忘れると動かない
4. 命名規約: Worker 名 `erebor-gk-<name>`、`BASE_URL=https://erebor.ryoryo.org/gatekeeper/<name>`
5. 公式デプロイ産の Worker は **workers.dev サブドメインを全て無効化**している。
   手動デプロイした Worker も必ず揃える(Access を迂回する裏口になるため)
6. OAuth 系 gatekeeper(GitHub/Google 等)の必要 env は `CLIENT_ID` / `CLIENT_SECRET` /
   `BASE_URL` の3つ(各 gatekeeper の src で `env.*` を数えて確認する)

## Gatekeeper 後付けデプロイ(検証済み: github, google)

### Step 0: プロバイダー側で OAuth アプリ作成【ユーザー作業】

- callback URL は必ず `https://erebor.ryoryo.org/gatekeeper/<name>/oauth`(末尾スラッシュなし)
- GitHub は「OAuth Apps」で作る(「GitHub Apps」は scope 制御が効かず不可。
  `packages/gatekeeper-github/README.md` 参照)
- Google は同意画面が Testing のままだと refresh token が7日で失効する。常用するなら公開する

### Step 1: Worker デプロイ【ユーザーが `!` で実行(クラウド書き込みのため)】

```
! cd /Users/ryosei/scraps/cloudflare-os/packages/gatekeeper-<name> && export PATH="$HOME/.nvm/versions/node/v22.22.0/bin:$PATH" && pnpm exec wrangler deploy --name erebor-gk-<name> --var "BASE_URL:https://erebor.ryoryo.org/gatekeeper/<name>"
```

pnpm はリポジトリ指定バージョンとの切替バグがあるため nvm の corepack shim を PATH 先頭に置く。

### Step 2: workers.dev 無効化【Claude が API で実行】

```sh
scripts/verify-gatekeeper.sh <name> --close-subdomain
```

または手動: `POST /accounts/{account}/workers/scripts/erebor-gk-<name>/subdomain` に
`{"enabled":false,"previews_enabled":false}`。

### Step 3: 認証情報【ユーザーがダッシュボードで設定。チャット経由禁止】

`erebor-gk-<name>` → Settings → Variables and Secrets:
- `CLIENT_ID` = Text で可(公開情報)
- `CLIENT_SECRET` = **必ずタイプ「Secret」を選ぶ**。Text(plain_text)で保存すると
  API から値が読め、確認作業で値がセッションに露出する事故が実際に起きた。
  もし Text で保存してしまったら: プロバイダー側でシークレット再生成 → 旧変数を削除 →
  Secret タイプで再登録

### Step 4: service binding ×2【ユーザーがダッシュボードで設定】

| Worker | binding 名 | Service | Entrypoint |
|---|---|---|---|
| `erebor` | `GATEKEEPER_<NAME>`(大文字) | `erebor-gk-<name>` | (default のまま) |
| `erebor-backend` | `GATEKEEPER_<NAME>` | `erebor-gk-<name>` | **`GatekeeperVendor`** |

### Step 5: 検証【Claude が実行】

```sh
scripts/verify-gatekeeper.sh <name>
```

このスクリプトは secret の値を一切表示しない(存在とタイプのみ)。手書きで API 確認する
場合も、**変数値は全てマスクする**こと(plain_text の secret が混ざっている前提で書く)。

最後にユーザーがブラウザで: Gatekeepers ページ → Available から接続 → OAuth 認可。
「CONNECTED に載る + AVAILABLE にも残る」は OAuth 型の正常動作(複数アカウント接続可の
ため。ambient 型だけが Available から消える。`routes/gatekeepers.tsx:692` 付近)。

## AI モデルプロバイダー追加(検証済み: openai)

モデルピッカーに出るプロバイダーは backend の env `CF_AI_GATEWAY_PROVIDERS`
(カンマ区切り)で決まる。追加は2点セット:

1. `erebor-backend` の `CF_AI_GATEWAY_PROVIDERS` に追記(例: `anthropic,cloudflare,openai,google`)
2. プロバイダーの API キーを **AI Gateway(erebor-ai)側に登録**(BYOK)。
   erebor の UI にはキー入力欄は出ない(gateway モードでは `AddModelModal.tsx` が
   `apiToken: gatewayMode ? '' : ...` とする実装)。キーの置き場所は erebor の外 =
   デプロイ管理ページ or ダッシュボードの AI Gateway 設定

## トラブルシュート早見表

| 症状 | 原因 | 対処 |
|---|---|---|
| `<Name> Gatekeeper Not Configured` ページ | CLIENT_ID か CLIENT_SECRET が未設定(誤値ではなく欠落判定。`google.ts:594-596` 相当) | Step 3 を実施/再確認 |
| Gatekeepers ページに新 vendor が出ない | backend への binding 欠落 or entrypoint 未指定 | Step 4 の backend 行を確認 |
| `/gatekeeper/<name>/` が 404/素通り | router への binding 欠落 | Step 4 の router 行を確認 |
| Add AI model にプロバイダーが出ない | `CF_AI_GATEWAY_PROVIDERS` に含まれていない | 上記2点セット |
| 接続後も AVAILABLE に残る | 仕様(OAuth 型は複数アカウント可) | 対処不要 |
| wrangler が非対話でトークン切れ | OAuth refresh 失敗 | ユーザーに `! wrangler login` を依頼 |

## 将来の統合方針(このスキルの賞味期限)

- upstream README は「gatekeeper を OS インスタンスから独立してデプロイ・保守できるようにする」
  構想を予告している。**公式手順が出たらそちらに移行し、このスキルは差分だけ残して縮退させる**
- 中期計画は「cloudflare-os-starter ベースのリポジトリ + GitHub Actions の Issue/PR 駆動デプロイ」
  (2026-08-11 のサブエージェントレビューで決定)。移行時の必須3点:
  1. CI secrets 加固(deploy は push-to-main 限定 / GitHub Environments required reviewer /
     `.github/workflows/**` と deploy script に CODEOWNERS)
  2. starter の `generateConfigs()` を拡張して既存 gatekeeper(github/google/scheduler)の
     binding を再現(そのままだと無言で機能退行)
  3. **Worker 名を厳密に引き継ぐ**(Durable Object は Worker 名に紐づく。名前が変わると
     ユーザーデータ・OAuth トークンが新規扱い=消失)
- ローカル MCP ブリッジ(tunnel 経由)は ops 用途では不採用(gatekeeper-mcp の認証が
  フル OAuth か無認証の二択で、無認証は承認キューを迂回した直叩きが可能なため)。
  読み取り専用ツール + 認証付きの構成でのみ再検討する
