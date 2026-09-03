---
name: gh-create-visual-pr
description: >-
  ローカルで UI を起動・操作して視覚的な動作証跡を取得し、GitHub CLI の
  --attach で画像または動画を埋め込んだ Pull Request を作成・更新する。
  「スクショ付きで PR を作って」「UI 修正の Before/After を PR に載せて」
  「動作確認画像付きでプルリクを出して」「レビュー用の画面録画を添付して」など、
  PR 上で視覚的なレビューを完結させたい依頼に使用する。単にコードを変更するだけ、
  または画像を伴わない通常の PR 作成には使用しない。
license: MIT
---

# Visual PR を作成する

変更後の UI を実際に起動・操作し、レビューに必要な最小限の視覚証跡を添えて PR を作る。
画像をアップロードしただけで「確認済み」とせず、表示内容と操作結果を検証してから公開する。

## 完了条件

- 変更に応じたテスト、ビルド、UI 操作確認が完了している
- レビュアーが変更点を判断できる画像または動画が PR の該当箇所に表示される
- PR 本文にローカルファイルパスが残っていない
- 実行した確認、確認できなかった事項、リスクが本文に正確に記録されている

## 1. コンテキストを確定する

リポジトリの `AGENTS.md`、`CLAUDE.md`、PR テンプレートを先に確認する。現在のブランチ、
base branch、remote、差分、既存 PR の有無を調べ、対象外の未コミット変更を分離して扱う。

- default branch 上では PR を作成しない。作業ブランチがなければ依頼範囲に沿って作る
- 同じ head branch の PR が存在すれば新規作成せず、その PR を更新する
- PR 作成まで依頼されている場合は、対象変更の commit と push を実行してよい。ただし
  ユーザーや別タスクの変更を stage、commit、push しない
- 対象、base、含める変更が一意に決まらない場合だけ、外部変更の前にユーザーへ確認する

## 2. `gh --attach` の利用可否を確認する

外部変更の前に次を確認する。

```bash
gh version
gh pr create --help | rg -- --attach
gh auth status
gh repo view --json nameWithOwner,defaultBranchRef,viewerPermission
```

`--attach` には GitHub CLI v2.99.0 以上、GitHub.com、対象リポジトリへの push 権限が必要。
flag が見つからない、認証されていない、または権限が不足している場合は PR を作成しない。
必要な更新または認証手順を報告し、ブラウザのコメント欄をアップロード置き場にする旧方式へ
自動でフォールバックしない。

## 3. 視覚証跡を設計する

diff と依頼内容から、変更を最短で説明できる画面、状態、操作、viewport を選ぶ。
枚数を固定せず、通常は 2〜6 枚を目安に重複を避ける。

| 変更 | 推奨する証跡 |
|---|---|
| 既存 UI の見た目修正 | Before / After |
| 新規画面・新規コンポーネント | After |
| レスポンシブ修正 | 影響する Desktop / Mobile |
| モーダル・エラー・完了状態 | 重要な各状態 |
| アニメーション・連続操作 | MP4 / WebM などの短い動画 |
| UI に影響しない変更 | 視覚証跡を捏造せず、このスキルの対象外と報告 |

Before は、base branch を一時 worktree などで安全かつ同じ条件で起動できる場合だけ取得する。
現在の作業ツリーを切り替えたり、未コミット変更を退避・破棄したりしない。Before の準備が
大きな追加作業になる場合は After のみとし、PR に理由を書く。

## 4. アプリを起動して確認する

プロジェクト既定のコマンド、fixture、seed、テストアカウントを優先する。実運用データを
変更しない。既存のブラウザ操作手段または E2E 環境を使い、次を行う。

1. 変更に応じたテストとビルドを実行する
2. 開発サーバーを起動し、ready/health を確認する
3. 対象画面へ移動し、変更に関係する操作を実行する
4. 安定した最終状態で画像または動画を保存する
5. 保存した画像を目視し、対象 UI、viewport、状態が正しいことを確認する

ローディング中、空白、予期しないエラー、デバッグ UI を含む画像は採用しない。認証情報、
個人情報、顧客データ、内部 URL などが映る場合は安全な fixture で撮り直す。安全に除去できない
場合はアップロードせず、ユーザーへ報告する。

メディアは commit 対象外の一時ディレクトリに、空白や `#` を含まない説明的な名前で保存する。
同じファイルを複数回 `--attach` しない。標準は PNG。GitHub の上限に合わせ、画像/GIF は
10 MB 以下、動画はプラン上限が不明なら 10 MB 以下にする。

## 5. PR 本文を作る

既存の PR テンプレートがあれば、その見出し、チェック項目、Issue 記法を維持して埋める。
視覚証跡は変更内容の後、またはテスト結果の前へ追加する。テンプレートがない場合は
`assets/pr-body-template.md` を一時ファイルへコピーして編集する。

本文中の表示したい位置に、実在するローカルパスを通常の Markdown 画像として書く。

```markdown
![保存操作後に成功メッセージが表示された設定画面](/tmp/visual-pr/settings-after.png)
```

Before / After は同じ viewport とデータ条件で揃える。alt text は「画像」ではなく、画面名、
状態、確認できる変更を簡潔に表す。補助的な画像や動画が多い場合は `<details>` にまとめる。

テスト欄には実際に成功したコマンドだけをチェック済みにする。未実施・失敗・確認不能を
成功扱いせず、`リスク・未確認事項` に理由と影響を書く。

## 6. `gh` で作成または更新する

PR 本文と全メディアを 1 回のコマンドへ渡す。各 `--attach` のパスは本文中のパスと完全に
一致させると、GitHub CLI がその位置をアップロード済み URL に置換する。

```bash
gh pr create \
  --base BASE_BRANCH \
  --head HEAD_BRANCH \
  --title "PR_TITLE" \
  --body-file /tmp/visual-pr/pr-body.md \
  --attach /tmp/visual-pr/settings-before.png \
  --attach /tmp/visual-pr/settings-after.png
```

既存 PR を更新する場合は次を使う。

```bash
gh pr edit PR_NUMBER \
  --body-file /tmp/visual-pr/pr-body.md \
  --attach /tmp/visual-pr/settings-after.png
```

対話プロンプトへ依存しない。draft、reviewer、label、Issue の close はユーザーの指定または
リポジトリ規約に従う。指定がなければ、検証が完了した PR は通常 PR として作成する。

## 7. GitHub 上の結果を検証する

作成コマンドの終了だけで完了にしない。

```bash
gh pr view PR_NUMBER --json number,url,state,title,body,headRefName,baseRefName
```

次を確認する。

- PR の head/base と含まれる commit が意図どおり
- 本文に添付数と同数の `github.com/user-attachments/assets/` URL がある
- `/tmp/` などのローカルパスが本文に残っていない
- alt text、Before / After の順序、テスト結果が正しい
- 利用可能ならレンダリングされた PR を開き、画像が表示される

失敗後に再実行する前は、同じ branch の PR が作成済みか再確認して重複作成を防ぐ。添付だけが
失敗した場合は既存 PR に対して `gh pr edit --attach` を 1 回だけ試す。それでも解消しなければ、
PR URL、成功した処理、残った問題を報告して停止する。

## 報告

PR URL、添付した画面・状態、実行したテストと結果、Before を省略した理由、未確認事項を簡潔に
報告する。「画像付き」ではなく、レビュアーが各画像で何を確認できるかを示す。

## 参考

- GitHub Docs: https://docs.github.com/en/github-cli/github-cli/attaching-files-with-github-cli
- GitHub Changelog: https://github.blog/changelog/2026-09-01-github-cli-media-in-issues-pull-requests-and-comments/
