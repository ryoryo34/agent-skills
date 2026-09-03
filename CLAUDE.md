# agent-skills リポジトリルール

## リリースルール（必須）

スキルの追加・変更・削除を含むコミットでは、**必ず version を bump すること**。
version が同じままだと、インストール済み環境の `claude plugin update` が
「already at the latest version」でスキップされ、変更が配布されない。

bump 対象は以下の4ファイル（すべて同じ値に揃える）:

1. `.claude-plugin/plugin.json` — `version`（Claude Code のプラグイン更新判定に使われる正本）
2. `.claude-plugin/marketplace.json` — `metadata.version`
3. `.codex-plugin/plugin.json` — `version`
4. `apm.yml` — `version`

bump の目安（semver）:

- **patch (x.y.Z)**: typo 修正、description の微調整、references の軽微な更新
- **minor (x.Y.0)**: スキルの追加、evals の追加、SKILL.md の内容変更
- **major (X.0.0)**: スキルの削除・リネーム、レイアウト変更（過去の破壊的変更例: kintone 系スキルの分離）

## レイアウトルール（必須）

スキルはリポジトリ直下 `<name>/SKILL.md` に置く（APM 互換）。Claude Code はデフォルトで
`skills/` しかスキャンしないため、`.claude-plugin/plugin.json` の `"skills": "./"` を
**絶対に消さないこと**。消すとプラグインは有効化されていてもスキルが 1 つも読み込まれない。

## 検証

コミット前に必ず実行:

```bash
claude plugin validate .
```

evals を追加・変更した場合は JSON 構文チェックも:

```bash
jq -e .skill_name <skill>/evals/evals.json
```
