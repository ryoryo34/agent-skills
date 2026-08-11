#!/usr/bin/env bash
# Cloudflare OS インスタンスの gatekeeper 配線を検証する。secret の値は一切表示しない。
#
# 使い方:
#   verify-gatekeeper.sh <gatekeeper名> --instance <instance> [--close-subdomain]
#   verify-gatekeeper.sh <gatekeeper名> [--close-subdomain]   # 環境変数で指定する場合
#
# インスタンス設定の解決順:
#   1. --instance <name> → ~/.config/cloudflare-os-ops/instances/<name>.env を読み込む
#   2. 環境変数 CFOS_INSTANCE / CFOS_ACCOUNT_ID が設定済みならそれを使う
#
# .env の必須キー: CFOS_INSTANCE(Workerプレフィックス), CFOS_ACCOUNT_ID
set -euo pipefail

NAME="${1:?usage: verify-gatekeeper.sh <gatekeeper> [--instance <name>] [--close-subdomain]}"
shift
CLOSE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --instance)
      ENV_FILE="$HOME/.config/cloudflare-os-ops/instances/${2:?--instance requires a name}.env"
      [[ -f "$ENV_FILE" ]] || { echo "NG: $ENV_FILE がない(SKILL.md の『対象インスタンスの解決』参照)"; exit 1; }
      # shellcheck disable=SC1090
      source "$ENV_FILE"
      shift 2 ;;
    --close-subdomain) CLOSE=1; shift ;;
    *) echo "unknown arg: $1"; exit 1 ;;
  esac
done

: "${CFOS_INSTANCE:?CFOS_INSTANCE 未設定(--instance <name> か環境変数で指定)}"
: "${CFOS_ACCOUNT_ID:?CFOS_ACCOUNT_ID 未設定(--instance <name> か環境変数で指定)}"

WORKER="${CFOS_INSTANCE}-gk-${NAME}"
ROUTER="${CFOS_INSTANCE}"
BACKEND="${CFOS_INSTANCE}-backend"
UPPER="GATEKEEPER_$(echo "$NAME" | tr '[:lower:]-' '[:upper:]_')"
API="https://api.cloudflare.com/client/v4/accounts/${CFOS_ACCOUNT_ID}/workers/scripts"

# wrangler の OAuth トークンを環境変数経由で使う(値は表示しない)
TOKEN=$(grep -m1 'oauth_token' "$HOME/Library/Preferences/.wrangler/config/default.toml" \
  | sed 's/.*= *"\(.*\)"/\1/')
auth=(-H "Authorization: Bearer ${TOKEN}")

jqnode() { node -e "let d='';process.stdin.on('data',c=>d+=c).on('end',()=>{$1})"; }

# プリフライト: トークンが生きているか(wrangler の OAuth トークンは短命。
# 切れていると全チェックが偽 NG になるため、先に認証だけ検証する)
vst=$(curl -s -m 10 "https://api.cloudflare.com/client/v4/accounts/${CFOS_ACCOUNT_ID}" "${auth[@]}" \
  | jqnode 'const j=JSON.parse(d);console.log(j.success?"ok":"expired")')
if [[ "$vst" != "ok" ]]; then
  echo "NG: Cloudflare API 認証エラー。wrangler のトークン切れの可能性が高い。"
  echo "    対処: 'wrangler whoami' を一度実行(refresh token で自動更新)してから再実行"
  exit 2
fi

fail=0
note() { printf '%s %s\n' "$1" "$2"; }

if [[ "$CLOSE" == "1" ]]; then
  ok=$(curl -s -m 10 -X POST "${API}/${WORKER}/subdomain" "${auth[@]}" \
    -H "Content-Type: application/json" \
    -d '{"enabled":false,"previews_enabled":false}' | jqnode 'console.log(JSON.parse(d).success)')
  note "workers.dev 無効化:" "$ok"
fi

# 1. gatekeeper Worker の vars(値はタイプと存在のみ。plain_text の secret 露出を防ぐ)
echo "--- ${WORKER} の設定 ---"
curl -s -m 15 "${API}/${WORKER}/settings" "${auth[@]}" | jqnode '
  const j=JSON.parse(d);
  if(!j.result){console.log("NG: worker が存在しないか API エラー");process.exit(1);}
  const bs=j.result.bindings||[];
  for(const n of ["BASE_URL","CLIENT_ID","CLIENT_SECRET"]){
    const b=bs.find(x=>x.name===n);
    if(!b){console.log("NG:",n,"未設定");continue;}
    let v = b.type==="secret_text" ? "(secret)" : n==="BASE_URL" ? b.text : "(値は表示しない/type="+b.type+")";
    let warn = (n==="CLIENT_SECRET" && b.type!=="secret_text") ? "  ★警告: Secret タイプで再登録すべき" : "";
    console.log("OK:",n,"=",v,warn);
  }' || fail=1

# 2. workers.dev が閉じているか
sub=$(curl -s -m 10 "${API}/${WORKER}/subdomain" "${auth[@]}" | jqnode 'console.log(JSON.parse(d).result?.enabled)')
if [[ "$sub" == "false" ]]; then note "OK: workers.dev" "無効"; else note "NG: workers.dev" "有効のまま(--close-subdomain で閉じる)"; fail=1; fi

# 3. router / backend の binding(backend は entrypoint 必須)
for w in "$ROUTER" "$BACKEND"; do
  expect_ep=""; [[ "$w" == "$BACKEND" ]] && expect_ep="GatekeeperVendor"
  curl -s -m 15 "${API}/${w}/settings" "${auth[@]}" | jqnode "
    const j=JSON.parse(d);
    const b=(j.result?.bindings||[]).find(x=>x.type==='service'&&x.name==='${UPPER}');
    if(!b){console.log('NG: ${w} に ${UPPER} binding なし');process.exit(0);}
    if('${expect_ep}'&&b.entrypoint!=='${expect_ep}'){
      console.log('NG: ${w} の binding に entrypoint=${expect_ep} がない(現在:',b.entrypoint||'(default)',')');
    } else {
      console.log('OK: ${w} →',b.service,b.entrypoint?('(entrypoint: '+b.entrypoint+')'):'(default)');
    }" || fail=1
done

exit $fail
