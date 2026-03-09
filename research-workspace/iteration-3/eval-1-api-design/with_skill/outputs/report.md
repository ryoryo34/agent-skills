# Research Report: マイクロサービスのAPI設計におけるベストプラクティス

## Executive Summary

マイクロサービスにおけるAPI設計は、サービス間の全データ交換がAPIコールまたはメッセージングを通じて行われるため、アーキテクチャの成功を左右する最重要要素である。主要なベストプラクティスとして、API-Firstアプローチによる契約駆動設計、REST/gRPCの適材適所な使い分け、APIゲートウェイパターンの活用、セマンティックバージョニングによる後方互換性の維持、そしてコントラクトテストによる品質保証が、Google、Microsoft、Netflixなどの大規模プラットフォームで実践され、業界標準として確立されている。

## Findings

### 1. API-Firstアプローチと契約駆動設計

マイクロサービスでは、実装前にAPIの契約（コントラクト）を定義する「API-First」アプローチが推奨される。OpenAPI（Swagger）仕様を用いてリソース、オペレーション、リクエスト/レスポンススキーマ、エラーコードを事前に定義することで、フロントエンドとバックエンドのチームが並行開発でき、曖昧さを排除できる。

Google Cloud API Design Guideでは、リソース指向設計（Resource-Oriented Design）を基本原則としている。APIの基本構成要素は個別に名前付けされたリソース（名詞）とそれらの関係性であり、標準メソッド（Get, List, Create, Update, Delete）とカスタムメソッドの小さなセットでセマンティクスを提供する。重要な注意点として、APIをデータベーススキーマと同一にすることはアンチパターンである。

Microsoftのガイダンスでは、パブリックAPIとバックエンドAPI（サービス間通信）を明確に区別することを推奨している。パブリックAPIはクライアントアプリケーションとの互換性が必要であり、バックエンドAPIはネットワークパフォーマンス（シリアライゼーション速度、ペイロードサイズ）を重視する必要がある。

**Sources:**
- [S] Microsoft, "API Design - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10 — Relevance: ★★★★★ (マイクロサービスAPI設計の包括的ガイドライン)
- [S] Google Cloud, "API design guide", https://docs.cloud.google.com/apis/design, Date unknown — Relevance: ★★★★★ (Googleのリソース指向API設計原則を定義)
- [S] Google Cloud, "Resource-oriented design", https://cloud.google.com/apis/design/resources, Date unknown — Relevance: ★★★★☆ (リソース指向設計の詳細な原則)
- [A] NGINX/F5, "The Benefits of an API-First Approach to Building Microservices", https://www.f5.com/company/blog/nginx/benefits-of-api-first-approach-to-building-microservices, Date unknown — Relevance: ★★★★☆ (API-Firstアプローチの利点を解説)

### 2. REST vs gRPC の使い分け

RESTとgRPCはマイクロサービスで最も広く使われる2つのプロトコルであり、用途に応じた使い分けが重要である。

**RESTが適するケース:**
- パブリックAPI（ブラウザからの直接利用が可能）
- シンプルなCRUD操作（HTTPメソッドとリソース指向設計が直感的にマッピング）
- 広範な相互運用性が必要な場合（ほぼ全ての言語・フレームワークがHTTPをサポート）
- 特別なクライアントライブラリが不要で、結合度が低い

**gRPCが適するケース:**
- 内部のサービス間通信（パフォーマンスが重要）
- リアルタイムストリーミング（双方向ストリーミングをネイティブサポート）
- 低レイテンシが要求されるシステム（金融取引、リアルタイムビディングなど）
- gRPCはProtocol BuffersによるバイナリシリアライゼーションとHTTP/2により、小さなペイロードでRESTの7-10倍高速

**ハイブリッドアプローチ:** 多くの成功している組織では、パブリックAPIにREST、内部通信にgRPCを採用するハイブリッド構成を採用している。APIゲートウェイでプロトコル変換を行うことで、両方の利点を活かせる。

**Sources:**
- [S] AWS, "gRPC vs REST - Difference Between Application Designs", https://aws.amazon.com/compare/the-difference-between-grpc-and-rest/, Date unknown — Relevance: ★★★★★ (gRPCとRESTの包括的比較)
- [A] Google Cloud Blog, "gRPC vs REST: Understanding gRPC, OpenAPI and REST", https://cloud.google.com/blog/products/api-management/understanding-grpc-openapi-and-rest-and-when-to-use-them, Date unknown — Relevance: ★★★★★ (Googleによるプロトコル選択ガイド)
- [S] Microsoft, "API Design - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10 — Relevance: ★★★★☆ (RESTとRPCのトレードオフを解説)

### 3. APIゲートウェイパターン

APIゲートウェイは、クライアントとマイクロサービス群の間に配置され、リクエストのルーティング、認証、レート制限、レスポンスの集約などを一元管理する。クライアントが個々のマイクロサービスと直接通信する構成は、多数のリクエスト発生、プロトコルの不一致、セキュリティの複雑化などの問題を引き起こすため、ゲートウェイの活用が推奨される。

**主要なパターン:**
- **Backend for Frontends (BFF):** クライアントの種類（モバイル、Web、デスクトップ）ごとに専用のゲートウェイを用意し、各フロントエンドに最適化されたAPIを提供する
- **API集約:** 複数のマイクロサービスへのリクエストをゲートウェイが取りまとめ、クライアントは1回のコールで必要なデータを取得できる
- **マイクロゲートウェイ:** 各マイクロサービスが専用の小さなゲートウェイを持ち、より細かいトラフィック制御を実現する

**ベストプラクティス:** ゲートウェイはルーティングとリクエスト管理に集中させ、ビジネスロジックを含めないこと。ゲートウェイはビジネス境界に基づいて分割すべきであり、単一の巨大なゲートウェイは避ける。

Netflixは1,000以上のマイクロサービスを運用し、1日あたり20億以上のリクエストをAPIゲートウェイ（Zuul）で処理している。現在はFederated GraphQLアーキテクチャに進化し、GraphQL Gatewayがドメイングラフサービスへのリクエストをオーケストレーションしている。

**Sources:**
- [S] Chris Richardson, "Pattern: API Gateway / Backends for Frontends", https://microservices.io/patterns/apigateway.html, Date unknown — Relevance: ★★★★★ (APIゲートウェイパターンの定義と詳細)
- [S] Microsoft, "The API gateway pattern versus direct client-to-microservice communication", https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/direct-client-to-microservice-communication-versus-the-api-gateway-pattern, Date unknown — Relevance: ★★★★★ (ゲートウェイ vs 直接通信の比較)
- [S] AWS, "API gateway pattern - AWS Prescriptive Guidance", https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-integrating-microservices/api-gateway-pattern.html, Date unknown — Relevance: ★★★★☆ (AWSにおけるゲートウェイパターンの実装ガイド)
- [A] NGINX/F5, "Adopting Microservices at Netflix: Lessons for Architectural Design", https://www.f5.com/company/blog/nginx/microservices-at-netflix-architectural-best-practices, Date unknown — Relevance: ★★★★☆ (Netflixの実践事例)

### 4. APIバージョニング戦略

APIは変更が避けられないため、バージョニング戦略の確立が重要である。

**主要なバージョニング方式:**
1. **URLパスバージョニング** (`/v1/users`, `/v2/users`): 最も明示的で広く理解されている。ルーティングが簡単で、ドキュメント整理も容易。ほとんどのマイクロサービスコンテキストで推奨される
2. **ヘッダーバージョニング**: URIがクリーンに保たれ、柔軟性が高い
3. **クエリパラメータバージョニング**: 一時的・実験的なバージョンに有用

**コアプラクティス:**
- **後方互換性の維持:** フィールドの削除はクライアントを壊すため避ける。フィールドの追加は互換性を破壊しない（クライアントは未知のフィールドを無視すべき）
- **セマンティックバージョニング（SemVer）の採用:** MAJOR.MINOR.PATCH形式。ただし、クライアントはMAJORバージョンのみで選択すべき（細かすぎる粒度はサポートコストを増大させる）
- **非推奨（Deprecation）ポリシー:** 外部APIは6-12ヶ月の猶予期間、内部サービスはそれより短い期間を設定
- **全マイクロサービスで一貫した戦略を適用する**

**Sources:**
- [S] Microsoft, "Creating, evolving, and versioning microservice APIs and contracts", https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/maintain-microservice-apis, Date unknown — Relevance: ★★★★★ (マイクロサービスAPIバージョニングの公式ガイド)
- [S] Microsoft, "API Design - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10 — Relevance: ★★★★☆ (バージョニングセクションを含む包括的ガイド)
- [S] Semantic Versioning, "Semantic Versioning 2.0.0", https://semver.org/, Date unknown — Relevance: ★★★☆☆ (SemVer仕様の定義)

### 5. べき等性とエラーハンドリング

マイクロサービス間の通信はネットワーク障害のリスクを伴うため、べき等（idempotent）な操作の設計が重要である。

**べき等性:**
- HTTP仕様上、GET, PUT, DELETEはべき等でなければならない。POSTはべき等性が保証されない
- 副作用を伴う操作はPUTメソッドとして実装し、べき等性を確保することで安全なリトライが可能になる
- 非同期処理の場合はHTTP 202（Accepted）を返し、処理が受理されたがまだ完了していないことを示す

**エラーハンドリング:**
- 正しいHTTPステータスコードを返す（201 Created, 202 Accepted, 404 Not Found, 409 Conflict 等）
- Correlation-ID, X-Request-ID, X-Trace-IDなどのヘッダーでトレースコンテキストを伝播し、リクエストのエンドツーエンド追跡を可能にする
- POSTは201（Created）を返し、Locationヘッダーに新リソースのURIを含める

**ページネーション:**
- limit/offsetパラメータを使用し、デフォルト値（例: limit=25, offset=0）を設定
- DoS攻撃防止のため、返却アイテム数に上限を設ける

**Sources:**
- [S] Microsoft, "API Design - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10 — Relevance: ★★★★★ (べき等性の設計パターンとコード例を含む)
- [S] Microsoft, "Web API Design Best Practices", https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design, Date unknown — Relevance: ★★★★☆ (ページネーション・エラーハンドリングのベストプラクティス)
- [S] Google Cloud, "Common design patterns", https://cloud.google.com/apis/design/design_patterns, Date unknown — Relevance: ★★★★☆ (APIデザインパターンの共通事項)

### 6. コントラクトテスト

マイクロサービスでは異なるチームが異なるサービスを担当するため、APIコントラクトテストが特に重要である。

**Consumer-Driven Contract Testing（消費者駆動コントラクトテスト）:**
- API消費者がコントラクト（期待するリクエスト/レスポンス形式、データ構造）を定義する
- 消費者-プロバイダーのペアごとに個別のコントラクトを持ち、実際の使用に焦点を当てる
- 消費者のユースケースに重要なフィールドとレスポンスのみに集中し、タイムスタンプや自動生成IDなどの内部メタデータをロックインしない

**CI/CDとの統合:**
1. 消費者がローカルで期待値を定義
2. コントラクトをエクスポート・公開（例: Pact Broker）
3. プロバイダーのCIパイプラインが関連コントラクトを取得
4. プロバイダーが検証テストを実行
5. 検証失敗時はプロバイダーのビルドをブロックし、破壊的変更のデプロイを防止

**主要ツール:** Pact（多言語対応）、Spring Cloud Contract（Spring Bootエコシステム向け）

**Sources:**
- [S] Pact, "Introduction | Pact Docs", https://docs.pact.io/, Date unknown — Relevance: ★★★★★ (コントラクトテストの標準ツールの公式ドキュメント)
- [A] OpenLiberty, "Implement consumer-driven contract testing for Java microservices using the Pact framework", https://openliberty.io/guides/contract-testing.html, Date unknown — Relevance: ★★★★☆ (実装ガイド付きの実践的チュートリアル)

### 7. APIセキュリティ

マイクロサービス環境では、複数のサービスエンドポイントが存在するため、セキュリティ設計がモノリスよりも複雑になる。

**認証:**
- OAuth 2.0 + OpenID Connectがフェデレーテッドログインの標準
- JWTによるステートレス認証: APIゲートウェイがJWTを発行し、各サービスが署名、有効期限、発行者、オーディエンス、アルゴリズムを検証
- トークンの有効期限は5-15分に設定

**認可:**
- OAuth 2.0スコープによるオペレーションレベル制御
- RBAC（Role-Based Access Control）またはABAC（Attribute-Based Access Control）
- ゼロトラストセキュリティ: 全リクエストに対して認可を検証

**サービス間通信:**
- Mutual TLS（mTLS）による相互認証: サービスメッシュ（Istio, Linkerd, Consul）が証明書管理を自動化
- シークレットはVaultやクラウドシークレットマネージャーで管理し、ハードコーディングは厳禁

**防御の多層化（Defense in Depth）:** ゲートウェイ層、サービス層、ネットワーク層、データ層の各レイヤーでセキュリティを適用する。

**Sources:**
- [S] Chris Richardson / microservices.io, "Authentication and authorization in a microservice architecture: Part 2 - Authentication", https://microservices.io/post/architecture/2025/05/28/microservices-authn-authz-part-2-authentication.html, 2025-05 — Relevance: ★★★★★ (マイクロサービス認証の権威的ガイド)
- [S] Microsoft, "Securing .NET Microservices and Web Applications", https://learn.microsoft.com/en-us/dotnet/architecture/microservices/secure-net-microservices-web-applications/, Date unknown — Relevance: ★★★★☆ (Microsoftによるセキュリティ実装ガイド)
- [A] APIsec, "API Security in Microservices Architecture: Best Practices", https://www.apisec.ai/blog/api-security-in-microservices, Date unknown — Relevance: ★★★★☆ (APIセキュリティ専門企業のベストプラクティス)

### 8. ドメイン駆動設計（DDD）とRESTのマッピング

マイクロサービスのAPI設計において、ドメイン駆動設計（DDD）のパターンをRESTに適切にマッピングすることが重要である。

| DDDコンセプト | REST対応 | 例 |
|---|---|---|
| 集約（Aggregate） | リソース | `{ "id": 1234, "status": "pending" }` |
| エンティティID | URL | `https://delivery-service/deliveries/1` |
| 子エンティティ | リンク（HATEOAS） | `{ "href": "/deliveries/1/confirmation" }` |
| 値オブジェクト更新 | PUT / PATCH | `PUT /deliveries/1/dropoff` |
| リポジトリ | コレクション | `/deliveries?status=pending` |

APIは内部実装の詳細やデータベーススキーマを直接公開すべきではなく、ドメインモデルを表現する契約として設計すべきである。Martin Fowlerの「分散オブジェクトの第一法則: オブジェクトを分散するな」を踏まえ、分散はAPIをよりコース粒度（coarse-grained）にする必要があり、障害処理、一貫性、可用性を考慮した設計が求められる。

**Sources:**
- [S] Microsoft, "API Design - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10 — Relevance: ★★★★★ (DDDとRESTマッピングの詳細な解説とコード例)
- [B] Martin Fowler, "Microservices", https://martinfowler.com/articles/microservices.html, 2014-03 — Relevance: ★★★★☆ (マイクロサービスの原典的論考。3年以上前だが基礎的著作)
- [B] Martin Fowler, "Microservices and the First Law of Distributed Objects", https://martinfowler.com/articles/distributed-objects-microservices.html, Date unknown — Relevance: ★★★☆☆ (分散設計の注意点)

## Source Reliability Summary

| Tier | Count | Notes |
|------|-------|-------|
| S    | 13    | Microsoft Learn公式ドキュメント、Google Cloud API Design Guide、AWS公式ドキュメント、Pact公式ドキュメント、microservices.io（Chris Richardson）、セマンティックバージョニング仕様 |
| A    | 5     | NGINX/F5エンジニアリングブログ、Google Cloud Blog、APIsec、OpenLiberty |
| B    | 2     | Martin Fowler（基礎的著作として引用） |

## Source List

1. [S] Microsoft, "API Design - Azure Architecture Center", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10 — Relevance: ★★★★★ (マイクロサービスAPI設計の包括的ガイドライン。REST/RPC比較、DDD-RESTマッピング、バージョニング、べき等性を網羅)
2. [S] Google Cloud, "API design guide", https://docs.cloud.google.com/apis/design, Date unknown — Relevance: ★★★★★ (Googleのリソース指向API設計原則。標準メソッド、カスタムメソッドの定義)
3. [S] Google Cloud, "Resource-oriented design", https://cloud.google.com/apis/design/resources, Date unknown — Relevance: ★★★★☆ (リソース指向設計の詳細な原則)
4. [S] AWS, "gRPC vs REST - Difference Between Application Designs", https://aws.amazon.com/compare/the-difference-between-grpc-and-rest/, Date unknown — Relevance: ★★★★★ (gRPCとRESTの包括的比較、ユースケース別推奨)
5. [S] Microsoft, "Creating, evolving, and versioning microservice APIs and contracts", https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/maintain-microservice-apis, Date unknown — Relevance: ★★★★★ (APIバージョニングと契約管理の公式ガイド)
6. [S] Microsoft, "The API gateway pattern versus direct client-to-microservice communication", https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/direct-client-to-microservice-communication-versus-the-api-gateway-pattern, Date unknown — Relevance: ★★★★★ (ゲートウェイパターン vs 直接通信の比較と推奨)
7. [S] Chris Richardson / microservices.io, "Pattern: API Gateway / Backends for Frontends", https://microservices.io/patterns/apigateway.html, Date unknown — Relevance: ★★★★★ (APIゲートウェイパターンの定義と詳細)
8. [S] AWS, "API gateway pattern - AWS Prescriptive Guidance", https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-integrating-microservices/api-gateway-pattern.html, Date unknown — Relevance: ★★★★☆ (AWSにおけるゲートウェイパターンの実装ガイド)
9. [S] Microsoft, "Web API Design Best Practices", https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design, Date unknown — Relevance: ★★★★☆ (ページネーション、エラーハンドリング等の汎用ベストプラクティス)
10. [S] Google Cloud, "Common design patterns", https://cloud.google.com/apis/design/design_patterns, Date unknown — Relevance: ★★★★☆ (APIデザインパターンの共通事項)
11. [S] Pact, "Introduction | Pact Docs", https://docs.pact.io/, Date unknown — Relevance: ★★★★★ (コントラクトテストの標準ツール公式ドキュメント)
12. [S] Chris Richardson / microservices.io, "Authentication and authorization in a microservice architecture: Part 2", https://microservices.io/post/architecture/2025/05/28/microservices-authn-authz-part-2-authentication.html, 2025-05 — Relevance: ★★★★★ (マイクロサービス認証の権威的ガイド)
13. [S] Semantic Versioning, "Semantic Versioning 2.0.0", https://semver.org/, Date unknown — Relevance: ★★★☆☆ (SemVer仕様の定義)
14. [A] Google Cloud Blog, "gRPC vs REST: Understanding gRPC, OpenAPI and REST", https://cloud.google.com/blog/products/api-management/understanding-grpc-openapi-and-rest-and-when-to-use-them, Date unknown — Relevance: ★★★★★ (Googleによるプロトコル選択の実践ガイド)
15. [A] NGINX/F5, "Adopting Microservices at Netflix: Lessons for Architectural Design", https://www.f5.com/company/blog/nginx/microservices-at-netflix-architectural-best-practices, Date unknown — Relevance: ★★★★☆ (Netflixの実践事例に基づくアーキテクチャガイド)
16. [A] NGINX/F5, "The Benefits of an API-First Approach to Building Microservices", https://www.f5.com/company/blog/nginx/benefits-of-api-first-approach-to-building-microservices, Date unknown — Relevance: ★★★★☆ (API-Firstアプローチの利点解説)
17. [A] OpenLiberty, "Implement consumer-driven contract testing for Java microservices", https://openliberty.io/guides/contract-testing.html, Date unknown — Relevance: ★★★★☆ (Pactを使ったコントラクトテストの実装ガイド)
18. [A] APIsec, "API Security in Microservices Architecture: Best Practices", https://www.apisec.ai/blog/api-security-in-microservices, Date unknown — Relevance: ★★★★☆ (APIセキュリティ専門企業のベストプラクティス)
19. [S] Microsoft, "Securing .NET Microservices and Web Applications", https://learn.microsoft.com/en-us/dotnet/architecture/microservices/secure-net-microservices-web-applications/, Date unknown — Relevance: ★★★★☆ (マイクロサービスセキュリティの公式実装ガイド)
20. [B] Martin Fowler, "Microservices", https://martinfowler.com/articles/microservices.html, 2014-03 — Relevance: ★★★★☆ (マイクロサービスの原典的論考。3年以上前だが基礎的著作として引用)
21. [B] Martin Fowler, "Microservices and the First Law of Distributed Objects", https://martinfowler.com/articles/distributed-objects-microservices.html, Date unknown — Relevance: ★★★☆☆ (分散設計における注意点の基礎的考察)

## Caveats

- **公開日の特定困難:** Google Cloud、AWSの公式ドキュメントの多くは具体的な公開日が明示されておらず、「Date unknown」と記載した。ただし、これらは継続的に更新される公式ドキュメントであるため、情報の鮮度は概ね信頼できる
- **Martin Fowlerの著作の古さ:** マイクロサービスの原典（2014年）は3年以上前の著作だが、基礎的・概念的な内容であり現在も広く参照されているため、Tier Bとして引用した
- **GraphQL関連のカバレッジ不足:** マイクロサービスにおけるGraphQL（特にFederated GraphQL）の利用は近年増加しているが、本レポートではREST/gRPCに焦点を当てたため、GraphQLの詳細な設計パターンはカバーしていない
- **イベント駆動APIの限定的カバレッジ:** AsyncAPI仕様を用いたイベント駆動マイクロサービスのAPI設計は重要な領域だが、本調査では同期API（REST/gRPC）を中心に調査した
- **WebFetchの制限:** 一部のソースでWebFetchが制限されたため、Microsoft Learnの1ソースから詳細なコンテンツを取得し、他のソースについてはWebSearchの結果サマリに基づいて情報を整理した
