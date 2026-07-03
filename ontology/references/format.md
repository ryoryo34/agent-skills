# .claude/ontology/ ファイル書式（正本）

生成するのは 4 ファイル。すべて git 管理される前提で、diff レビューしやすいように整形する。

```
.claude/ontology/
├── README.md       # 読み方・語彙・粒度ルール・last_synced_commit
├── entities.yaml   # クラス定義 + エンティティ一覧
├── relations.yaml  # 関係型の語彙 + 関係一覧
└── constraints.md  # アーキテクチャ制約（根拠付き）
```

## README.md

オントロジーを初めて読む人（人間・モデル両方）向けの案内。以下のテンプレートをプロジェクトに合わせて埋める。`last_synced_commit` は機械可読な行として必ず先頭ブロックに置く。

```markdown
# コードベース・オントロジー

このディレクトリはこのコードベースの知識グラフ（エンティティ・型付き関係・制約）。
アーキテクチャや依存関係の質問・変更では、コードを広く探索する前にまずここを読む。

last_synced_commit: <git SHA>

## ファイル構成
- entities.yaml — 主要コンポーネントの一覧（クラス + 属性 + 観察事項）
- relations.yaml — コンポーネント間の型付き関係（根拠付き）
- constraints.md — 守られているアーキテクチャ制約

## 更新ルール
- モジュール/サービスの追加・削除・改名、依存・呼び出し関係の変更、
  公開 API・イベント・スキーマの変更、制約の変更をしたら、同じ変更の中でここも更新する
- コードと食い違ったらコードが正。オントロジー側を直す
- 粒度: モジュール/サービス/ドメイン概念レベル。ファイル・関数単位のエンティティは追加しない
- 関係は relations.yaml の語彙表にある型だけを使い、evidence（コード位置）を必ず付ける
- 削除・改名されたものは消す/付け替える（deprecated として残さない。履歴は git が持つ）
```

## entities.yaml

```yaml
# 書式・更新ルールは README.md を参照

# クラス = エンティティの種類。プロジェクトに合わせて定義する（下記は例）
classes:
  service: 独立して動作するバックエンドサービス
  module: アプリケーション内の論理モジュール
  datastore: 永続化ストア（DB・キャッシュ・キュー）
  external: 外部システム・サードパーティ API
  concept: コードに直接対応しないドメイン概念

entities:
  - id: order-service          # kebab-case。relations.yaml から参照される
    class: service             # classes に定義したものだけ
    path: src/order-service/   # 対応するコード位置（concept 等で無い場合は省略可）
    summary: 注文の受付と状態遷移を管理する
    properties:                # 任意。判断に効く属性だけ
      language: TypeScript
      external-api: false
    observations:              # 任意。関係・属性に収まらない短い観察事項
      - 決済完了イベントを購読して注文を確定する

  - id: payment-service
    class: service
    path: src/payment-service/
    summary: 決済の実行と結果通知
    properties:
      external-api: true
```

- `id` / `class` / `summary` は必須。他は判断に効くものだけ書く
- `properties` は「知っていると設計判断が変わる」属性に絞る（言語、外部依存、同期/非同期など）
- `observations` は 1 行の短文。長い説明が要るならエンティティの粒度が細かすぎるサイン

## relations.yaml

```yaml
# 書式・更新ルールは README.md を参照

# 関係型の語彙。新しい型が必要なときは、まずここに定義を追加してから使う
types:
  is-a: 〜の一種である（分類）
  part-of: 〜の一部である（包含）
  calls: 〜を同期的に呼び出す（HTTP / RPC / 直接呼び出し）
  depends-on: 〜に依存する（import・ビルド・設定レベル）
  emits: 〜（イベント・メッセージ）を発行する
  consumes: 〜（イベント・メッセージ）を購読する
  reads-from: 〜（ストア）から読み取る
  writes-to: 〜（ストア）へ書き込む

relations:
  - from: order-service              # entities.yaml の id
    to: payment-service
    type: calls
    evidence: src/order-service/payment-client.ts:12
    note: POST /payments             # 任意。1 行まで

  - from: payment-service
    to: payment-events
    type: emits
    evidence: src/payment-service/publisher.ts:8
```

- `from` / `to` / `type` / `evidence` は必須
- `evidence` は関係の存在をコードで確認した位置（`path` または `path:line`）。確認できない関係は書かない
- `emits`/`consumes` の対象がイベントそのものの場合、イベントを `concept` クラスのエンティティとして定義してよい

## constraints.md

```markdown
# アーキテクチャ制約

守られている（守るべき）成立条件を、根拠と一緒に列挙する。根拠のない一般論は書かない。

- サービスは他サービスの DB を直接参照しない
  - 根拠: docs/adr/0003-database-per-service.md
- ドメイン層は infrastructure 層を import しない
  - 根拠: .eslintrc の import/no-restricted-paths 設定
```

## CLAUDE.md 注入テンプレート

プロジェクトルートの CLAUDE.md に以下をマーカーごと追記する（無ければ CLAUDE.md を新規作成）。既に `<!-- ontology:start -->` があれば、マーカー間をこの最新版で置き換える — 重複させない。

```markdown
<!-- ontology:start -->
## コードベース・オントロジー

`.claude/ontology/` にこのコードベースの知識グラフ（エンティティ・型付き関係・制約）がある。

- アーキテクチャ・モジュール構成・依存関係に関する質問や変更では、コードを広く探索する前にまず `.claude/ontology/` を読む
- 以下の構造変更を行ったら、**同じセッション内で** `.claude/ontology/` の該当ファイルも更新する:
  - モジュール / サービス / 主要コンポーネントの追加・削除・改名
  - コンポーネント間の依存・呼び出し関係の追加・削除
  - 公開 API・イベント・スキーマの変更
  - アーキテクチャ制約の追加・変更
- 更新時は `.claude/ontology/README.md` の書式・語彙・粒度ルールに従う（ファイル・関数単位のエンティティは追加しない）
- オントロジーとコードが食い違っていたらコードを正としてオントロジーを直す
- 大きくドリフトしていると感じたら `ontology` スキルで再同期する
<!-- ontology:end -->
```

このセクションが毎セッション自動ロードされることで、スキルを再発火させなくてもオントロジーが更新され続ける。Bootstrap でここを省略するとグラフは一度きりのスナップショットになってしまうので、必ず注入すること。
