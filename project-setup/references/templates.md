# Templates

`{{...}}` はプロジェクトの検出結果・対話結果で置換する。不要なセクションは削る。

テンプレートを埋めるとき・ルールを追記するときは SKILL.md の設計原則 5 に従う: 肯定形 + 理由 / 強制語は不変条件のみ / 判断場面は decision rule（条件 → 行動）/ 手順よりゴール + 完了条件。

## AGENTS.md（正本）

```markdown
# {{project-name}}

{{1〜3行のプロジェクト説明}}

## Commands

- `{{test-command}}` — テスト実行
- `{{build-command}}` — ビルド / 型チェック
- `{{dev-command}}` — 開発サーバー

## Task → Must-Read Routing

着手前に、タスク種別に応じて対応ドキュメントを読むこと。ドキュメントを追加したらこの表に行を足す。

| タスク | 必読 |
| --- | --- |
| バグ調査 | `.claude/rules/investigation.md` |
| {{タスク種別}} | {{ドキュメントパス}} |

## Verification Before Reporting

- 完了条件（Done when）: `{{build-command}}` と `{{test-command}}` がパスし、変更が実際に動くことを確認できた状態。ここまで自走してから完了を報告する
- 失敗・スキップした項目は隠さず、出力とともにそのまま報告する
- {{UI があるプロジェクトの場合: スクリーンショット等の実行時確認も完了条件に含める}}

## Rules

`.claude/rules/` 配下のルールは常時適用される。{{個別ルールへの1行紹介}}
```

## CLAUDE.md（import 形式）

```markdown
@AGENTS.md
```

Claude Code 固有の指示が必要になったらこの下に追記する。例:

```markdown
@AGENTS.md

## Claude Code 固有

- {{サブエージェント運用・スキル指定など}}
```

## .claude/rules/verification-before-report.md

```markdown
# 報告前検証ルール

「実装した」と報告する前に、その主張を自分で検証する。テストが通ることと機能が動くことは別物。

- `{{build-command}}` と `{{test-command}}` を実行し、結果を確認してから報告する
- 失敗・スキップした項目は隠さず、出力とともにそのまま報告する
- 実行時にしか確認できない変更（UI、外部連携、CLI 挙動）は、実際に動かして観察してから完了とする
- 自動検証で捕捉できない項目（実機操作・アニメーション等）は、その一覧を明示してユーザーに検証を依頼する
```

## .claude/rules/branch.md

```markdown
# ブランチ運用ルール

## 常設ブランチ

| ブランチ | 用途 |
| --- | --- |
| `main` | {{用途}} |

## 作業ブランチ

- 命名: `feat/*`, `fix/*`, `chore/*`, `refactor/*`, `docs/*`, `test/*`
- base は `{{default-branch}}`。マージ後は削除してよい

## 緊急修正の扱い（decision rule）

- 本番影響が顕在化しているバグ → `hotfix/{{概要}}` ブランチで作業する
- 開発中機能のバグ・軽微な修正 → 通常の `fix/*` で作業する
- どちらか判断できない → 着手前にユーザーに確認する
```

## .claude/rules/investigation.md

```markdown
# バグ調査の初動ルール

1. **症状把握が先**: エラー出力・再現手順・影響範囲を確認してからコードを探す。stack trace があればそこが最強の起点
2. **空間探索は内→外へ**: File → Class/Function → Line の順で階層的に絞る。各層で仮説が立てば次に進まない
3. **時系列軸を並走**: `git log` / `git blame` / `git bisect` を随時使う。障害の多くは「最近の変更」に起因する
4. **仮説駆動**: 観測 → 仮説 → 反証を回す。仮説が 3 件立ったらユーザーにどれから深掘るか確認する
5. **10 分進展がなければ切替**: アドホック探索をやめ、時系列（bisect）または外部情報（公式 docs / issues）へ
```

## .gitignore 追記分

```gitignore
# AI agent local files
.claude/settings.local.json
CLAUDE.local.md
```

## Codex 連携 symlink

```bash
# .claude/rules を正本として Codex 側から共有する
ln -s ../.claude/rules {{codex-dir}}/rules
# skills を使う場合
ln -s ../.claude/skills {{codex-dir}}/skills
# 検証（壊れ symlink になっていないこと）
ls -L {{codex-dir}}/rules
```
