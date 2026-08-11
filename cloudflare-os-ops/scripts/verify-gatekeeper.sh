#!/usr/bin/env bash
# erebor の gatekeeper 配線を検証する。secret の値は一切表示しない。
# 使い方:
#   verify-gatekeeper.sh <name>                    # 検証のみ (例: github)
#   verify-gatekeeper.sh <name> --close-subdomain  # workers.dev を無効化してから検証
set -euo pipefail

NAME="${1:?usage: verify-gatekeeper.sh <name> [--close-subdomain]}"
ACCOUNT="4423db4df8672564465e66062a9630de"
WORKER="erebor-gk-${NAME}"
UPPER="GATEKEEPER_$(echo "$NAME" | tr '[:lower:]-' '[:upper:]_')"
API="https://api.cloudflare.com/client/v4/accounts/${ACCOUNT}/workers/scripts"

# wrangler の OAuth トークンを環境変数経由で使う(値は表示しない)
TOKEN=$(grep -m1 'oauth_token' "$HOME/Library/Preferences/.wrangler/config/default.toml" \
  | sed 's/.*= *"\(.*\)"/\1/')
auth=(-H "Authorization: Bearer ${TOKEN}")

jqnode() { node -e "let d='';process.stdin.on('data',c=>d+=c).on('end',()=>{$1})"; }

fail=0
note() { printf '%s %s\n' "$1" "$2"; }

if [[ "${2:-}" == "--close-subdomain" ]]; then
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
for w in erebor erebor-backend; do
  curl -s -m 15 "${API}/${w}/settings" "${auth[@]}" | jqnode "
    const j=JSON.parse(d);
    const b=(j.result?.bindings||[]).find(x=>x.type==='service'&&x.name==='${UPPER}');
    if(!b){console.log('NG: ${w} に ${UPPER} binding なし');process.exit(0);}
    if('${w}'==='erebor-backend'&&b.entrypoint!=='GatekeeperVendor'){
      console.log('NG: ${w} の binding に entrypoint=GatekeeperVendor がない(現在:',b.entrypoint||'(default)',')');
    } else {
      console.log('OK: ${w} →',b.service,b.entrypoint?('(entrypoint: '+b.entrypoint+')'):'(default)');
    }" || fail=1
done

exit $fail
