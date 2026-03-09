# Research Report: マイクロサービスのAPI設計におけるベストプラクティス

## Executive Summary

マイクロサービスアーキテクチャにおけるAPI設計は、サービス間通信の基盤であり、システム全体の品質を左右する。本レポートでは、公開APIと内部API の使い分け、リソース指向設計、API-Firstアプローチ、バージョニング戦略、API Gatewayパターン、通信プロトコル選択（REST vs gRPC）、冪等性・エラーハンドリングなど、主要なベストプラクティスを実際のソースに基づいて整理した。Google、Microsoft、Zalando、AWS などの公式ドキュメントおよびエンジニアリングブログを中心に、信頼性の高いソースから知見を収集している。

## Findings

### 1. 公開APIと内部APIの明確な区別

マイクロサービスでは、クライアントアプリケーションが呼び出す**公開API**と、サービス間通信のための**内部（バックエンド）API**を明確に区別すべきである。公開APIはブラウザやモバイルアプリとの互換性が求められるため、REST over HTTPが適している。一方、内部APIではネットワークパフォーマンスが重要であり、シリアライゼーション速度やペイロードサイズを考慮して gRPC、Apache Avro、Apache Thrift などのバイナリプロトコルが有効な選択肢となる。

**Sources:**
- [S] Microsoft, "API Design - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10-16

### 2. リソース指向設計とRESTful原則

APIはリソース（名詞）を中心に設計し、標準的なHTTPメソッド（GET, POST, PUT, DELETE）で操作を表現する。Googleの API Design Guide では、リソース指向設計（Resource-Oriented Design）を基本とし、個々に名前を持つリソースとその階層関係を定義した上で、標準メソッド（Create, Get, List, Update, Delete）でCRUD操作をマッピングすることを推奨している。

命名規則については以下が重要である:
- リソース名は名詞を使用し、動詞は避ける
- コレクションは複数形を使用（例: `/api/deliveries`）
- 一貫した命名規約（camelCase / snake_case）をAPI全体で統一する
- 内部実装の詳細やデータベーススキーマを直接公開しない

**Sources:**
- [S] Google, "API design guide | Cloud API Design Guide", https://docs.cloud.google.com/apis/design
- [S] Google, "AIP-121: Resource-oriented design", https://google.aip.dev/121
- [S] Google, "Naming conventions | Cloud API Design Guide", https://cloud.google.com/apis/design/naming_convention
- [S] Microsoft, "API Design - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10-16

### 3. API-Firstアプローチとコントラクト駆動開発

APIの実装前にOpenAPI Specification（旧Swagger）でAPI定義を作成する「API-First」アプローチが広く推奨されている。Zalandoはこれをエンジニアリング原則の一つとして採用しており、コード外でAPI定義を行い、十分なピアレビューを経て高品質なAPIを実現している。

API-Firstの主要な利点:
- フロントエンドとバックエンドの並行開発が可能になる
- OpenAPI仕様が「単一の真実の情報源（Single Source of Truth）」として機能し、ドキュメントと実装の乖離を防ぐ
- コントラクトテスト（Pact等のツール）により、統合テストの工数を大幅に削減できる
- モックサーバーの自動生成により、依存サービスなしでの開発・テストが可能になる

**Sources:**
- [A] Zalando, "Zalando RESTful API and Event Guidelines", https://opensource.zalando.com/restful-api-guidelines/
- [A] Zalando Engineering, "Developing Zalando APIs", https://engineering.zalando.com/posts/2019/04/developing-zalando-apis.html
- [B] SmartBear, "API Contract Testing For A Design-First World", https://smartbear.com/blog/api-contract-testing-for-a-design-first-world/

### 4. APIバージョニング戦略

APIの進化に伴う破壊的変更を管理するために、適切なバージョニング戦略が不可欠である。主要なアプローチは以下の通り:

| 戦略 | 例 | 特徴 |
|------|-----|------|
| URIパスバージョニング | `/v1/products` | 最も明示的で広く理解されている。ルーティングが簡単 |
| ヘッダーバージョニング | `Accept: application/vnd.api+json;version=2` | URLがクリーンに保たれ、柔軟性が高い |
| クエリパラメータ | `/products?version=1` | 実装が簡単だが、あまり推奨されない |

**セマンティックバージョニング（MAJOR.MINOR.PATCH）** の採用が推奨されるが、クライアントが選択するのはメジャーバージョン（または重要なマイナーバージョン）のみに留めるべきである。細かすぎるバージョン指定はサポートコストを増大させる。

核心的なプラクティス:
- 可能な限り**後方互換性**を維持する（フィールドの追加はOK、削除はNG）
- 新旧バージョンの**同時稼働**を可能にし、クライアントが自身のペースで移行できるようにする
- 外部APIの廃止には**6-12ヶ月の事前通知**が推奨される
- 複数バージョンの維持は開発・テスト・運用コストを増大させるため、古いバージョンは速やかに廃止する

**Sources:**
- [S] Microsoft, "API Design - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10-16
- [S] Microsoft, "Creating, evolving, and versioning microservice APIs and contracts", https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/maintain-microservice-apis
- [A] Semver.org, "Semantic Versioning 2.0.0", https://semver.org/

### 5. API Gatewayパターン

API Gatewayはクライアントとマイクロサービス群の間に位置し、単一のエントリーポイントとして機能するアーキテクチャパターンである。Chris Richardsonのmicroservices.ioで定義されている通り、リクエストルーティング、レスポンス集約、認証・認可、レート制限、SSL終端、キャッシュなどの横断的関心事を一元管理する。

主な利点:
- クライアントが個々のマイクロサービスのアドレスを知る必要がない
- 複数サービスへのリクエストを集約し、1回のAPI呼び出しで返却できる
- 認証、ロギング、レート制限などの横断的処理を一元化できる
- 入力バリデーションによりバックエンドを不正なリクエストから保護する

**Backend for Frontend（BFF）パターン**は、API Gatewayの発展形として Sam Newman が提唱したもので、クライアントタイプ（Web、モバイル等）ごとに専用のバックエンドを用意する。Netflixなどが採用しており、各クライアントに最適化されたAPIを提供できる。

**Sources:**
- [S] Chris Richardson, "Pattern: API Gateway / Backends for Frontends", https://microservices.io/patterns/apigateway.html
- [S] AWS, "API gateway pattern - AWS Prescriptive Guidance", https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-integrating-microservices/api-gateway-pattern.html
- [S] Microsoft, "Backends for Frontends Pattern - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/patterns/backends-for-frontends
- [B] Sam Newman, "Backends For Frontends", https://samnewman.io/patterns/architectural/bff/

### 6. 通信プロトコルの選択: REST vs gRPC

REST over HTTPとgRPCは、マイクロサービスにおける2大通信プロトコルである。AWSの公式比較によれば、以下のように使い分けるべきである:

| 観点 | REST | gRPC |
|------|------|------|
| プロトコル | HTTP/1.1 | HTTP/2 |
| データ形式 | JSON/XML（テキスト） | Protocol Buffers（バイナリ） |
| 通信パターン | リクエスト-レスポンス | 単方向/双方向ストリーミング対応 |
| パフォーマンス | 標準的 | 小さいペイロードで7-10倍高速 |
| ブラウザサポート | ネイティブ対応 | 追加のプロキシ層が必要 |
| 適用場面 | 公開API、Webクライアント向け | 内部サービス間通信、リアルタイム処理 |

推奨アプローチ: バイナリプロトコルのパフォーマンスメリットが必要でない限り、REST over HTTPを使用する。RESTを選択する場合は、開発プロセスの早期段階でパフォーマンス・負荷テストを実施し、要件を満たすか確認する。gRPCとRESTは同一プロジェクト内で共存可能であり、ハイブリッドアプローチも有効である。

**Sources:**
- [S] AWS, "gRPC vs REST - Difference Between Application Designs", https://aws.amazon.com/compare/the-difference-between-grpc-and-rest/
- [S] Microsoft, "API Design - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10-16

### 7. 冪等性の設計

分散システムにおけるリトライの安全性を確保するため、副作用のある操作は冪等に設計すべきである。HTTPの仕様上、GET、PUT、DELETEは冪等であるべきとされている（RFC 7231）。POSTは冪等性が保証されない。

実装のポイント:
- PUTメソッドを活用し、安全なリトライを実現する
- POSTで新規リソースを作成する場合は、冪等性キー（Idempotency Key）をリクエストヘッダーに含め、重複リクエストを検出する
- ビジネスデータとアウトボックスエントリを同一トランザクションで処理し、「DBは更新されたがイベントが送信されない」問題を回避する

Martin Fowlerの「Idempotent Receiver」パターンでは、クライアントからのリクエストを一意に識別し、下流サービスが重複呼び出しを無視できる仕組みが解説されている。

**Sources:**
- [S] Microsoft, "API Design - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10-16
- [S] IETF, "RFC 7231 - Hypertext Transfer Protocol (HTTP/1.1): Semantics and Content", https://tools.ietf.org/html/rfc7231#section-4
- [B] Martin Fowler, "Idempotent Receiver", https://martinfowler.com/articles/patterns-of-distributed-systems/idempotent-receiver.html

### 8. DDDとREST APIのマッピング

ドメイン駆動設計（DDD）の概念はREST APIに自然にマッピングできる。Microsoftのガイドでは以下の対応関係を示している:

| DDDの概念 | RESTの対応 | 例 |
|-----------|-----------|-----|
| Aggregate | Resource | `{ "id": 1234, "status": "pending" }` |
| Entity Identity | URL | `https://delivery-service/deliveries/1` |
| Child Entity | Links (HATEOAS) | `{ "href": "/deliveries/1/confirmation" }` |
| Value Object更新 | PUT / PATCH | `PUT /deliveries/1/dropoff` |
| Repository | Collection | `/deliveries?status=pending` |

APIは内部実装ではなくドメインモデルを表現すべきであり、データだけでなくビジネスオペレーションとデータの制約も考慮して設計する。

**Sources:**
- [S] Microsoft, "API Design - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10-16

### 9. エラーハンドリングの標準化

APIのエラーレスポンスは一貫性があり、クライアントが適切に対処できる情報を含むべきである。主要なプラクティス:

- すべての例外に対してHTTP 500を返すのではなく、適切なステータスコードを使い分ける（制約違反は409 Conflict、不正なリクエストは400 Bad Request）
- エラーレスポンスにはエラーの意味のある説明を含める
- 非同期操作の場合はHTTP 202（Accepted）を返し、処理が受付済みだがまだ完了していないことを示す
- RFC 7807（Problem Details for HTTP APIs）に準拠した標準的なエラー形式の採用を検討する

**Sources:**
- [S] Microsoft, "Web API Implementation - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-implementation
- [S] Microsoft, "API Design - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10-16

### 10. 非同期通信とイベント駆動設計

サービス間の疎結合を実現するため、同期的なAPI呼び出しだけでなく、非同期のイベント駆動通信も検討すべきである。Zalandoは、リモート依存の障害の影響を軽減するため、イベントブローカーを介した非同期通信を積極的に採用している。AsyncAPI 3.0（2024年リリース）がイベント駆動APIの標準仕様として確立されつつある。

**Sources:**
- [A] Zalando, "Zalando RESTful API and Event Guidelines", https://opensource.zalando.com/restful-api-guidelines/
- [A] Zalando, GitHub - restful-api-guidelines, https://github.com/zalando/restful-api-guidelines

## Source Reliability Summary

| Tier | Count | Notes |
|------|-------|-------|
| S    | 11    | Microsoft Azure Architecture Center、Google Cloud API Design Guide、AWS公式ドキュメント、IETF RFC、microservices.io |
| A    | 4     | Zalando Engineering Blog & API Guidelines、Semver.org |
| B    | 3     | Martin Fowler (Idempotent Receiver)、Sam Newman (BFF Pattern)、SmartBear |

## Source List

1. [S] Microsoft, "API Design - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10-16
2. [S] Google, "API design guide | Cloud API Design Guide", https://docs.cloud.google.com/apis/design
3. [S] Google, "AIP-121: Resource-oriented design", https://google.aip.dev/121
4. [S] Google, "Naming conventions | Cloud API Design Guide", https://cloud.google.com/apis/design/naming_convention
5. [S] AWS, "gRPC vs REST - Difference Between Application Designs", https://aws.amazon.com/compare/the-difference-between-grpc-and-rest/
6. [S] AWS, "API gateway pattern - AWS Prescriptive Guidance", https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-integrating-microservices/api-gateway-pattern.html
7. [S] Chris Richardson, "Pattern: API Gateway / Backends for Frontends", https://microservices.io/patterns/apigateway.html
8. [S] Microsoft, "Backends for Frontends Pattern - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/patterns/backends-for-frontends
9. [S] Microsoft, "Creating, evolving, and versioning microservice APIs and contracts", https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/maintain-microservice-apis
10. [S] Microsoft, "Web API Implementation - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-implementation
11. [S] IETF, "RFC 7231 - Hypertext Transfer Protocol (HTTP/1.1): Semantics and Content", https://tools.ietf.org/html/rfc7231#section-4
12. [A] Zalando, "Zalando RESTful API and Event Guidelines", https://opensource.zalando.com/restful-api-guidelines/
13. [A] Zalando Engineering, "Developing Zalando APIs", https://engineering.zalando.com/posts/2019/04/developing-zalando-apis.html
14. [A] Zalando, GitHub - restful-api-guidelines, https://github.com/zalando/restful-api-guidelines
15. [A] Semver.org, "Semantic Versioning 2.0.0", https://semver.org/
16. [B] Martin Fowler, "Idempotent Receiver", https://martinfowler.com/articles/patterns-of-distributed-systems/idempotent-receiver.html
17. [B] Sam Newman, "Backends For Frontends", https://samnewman.io/patterns/architectural/bff/
18. [B] SmartBear, "API Contract Testing For A Design-First World", https://smartbear.com/blog/api-contract-testing-for-a-design-first-world/

## Caveats

- WebFetchのアクセス制限により、Google Cloud API Design Guide、AWS、Zalando Guidelines の詳細ページの本文を直接取得できなかった。これらのソースについては検索結果のスニペットとメタ情報に基づいて記述している。
- GraphQLについてはMicrosoftのガイドで言及されているが、本レポートではREST/gRPCを中心に扱い、GraphQLの深掘りは行っていない。
- パフォーマンス比較（gRPCがRESTの7-10倍高速）の数値は特定の条件下での測定結果であり、ペイロードサイズやネットワーク環境によって異なる。
- Zalando Engineering Blogの記事（2019年）は3年以上前のものだが、Zalandoの API Guidelines 自体は継続的に更新されている基盤的なドキュメントである。
- Martin FowlerとSam NewmanはTier Bに分類したが、いずれもマイクロサービス分野において広く認知された実務家であり、情報の信頼性は高い。
