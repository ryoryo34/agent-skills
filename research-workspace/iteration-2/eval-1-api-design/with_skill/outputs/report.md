# Research Report: マイクロサービスのAPI設計におけるベストプラクティス

## Executive Summary

マイクロサービスのAPI設計では、API-First（コントラクト先行）設計、RESTとgRPCの適切な使い分け、一貫したバージョニング戦略、API Gatewayパターンの活用、冪等性の確保が主要なベストプラクティスとして確立されている。Microsoft、Google、AWS、Netflixなどの大手テック企業の公式ガイドラインと実践知見を横断的に調査した結果、これらの原則は業界全体で広く合意されており、2024-2025年においても基本的な方向性は変わっていない。

## Findings

### 1. API-First（コントラクト先行）設計の採用

実装コードを書く前にAPIコントラクト（OpenAPI仕様など）を定義するアプローチが、マイクロサービス開発における標準的な手法として確立されている。APIコントラクトをYAMLまたはJSONで記述し、エンドポイント、パラメータ、リクエストボディ、レスポンススキーマ、認証方法、エラーコードを機械可読な形式で定義する。

主な利点:
- チーム間の並行開発が可能になり、統合時の手戻りが大幅に削減される
- OpenAPI仕様がドキュメント、モックサーバー、バリデーションの単一の情報源として機能する
- SpectralやRedoclyなどのツールによる仕様の自動検証が可能
- 2025年時点で企業の25%がAPI-Firstインフラストラクチャに完全移行済み（2024年比12%増）

**Sources:**
- [S] Microsoft Azure Architecture Center, "API Design for Microservices", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10
- [A] Nordic APIs, "The Top 8 API Specifications to Know in 2025", https://nordicapis.com/the-top-8-api-specifications-to-know-in-2025/, 2025
- [A] Nordic APIs, "A Software Architect's Guide to API-First Strategy", https://nordicapis.com/a-software-architects-guide-to-api-first-strategy/, 2025

### 2. リソース指向のRESTful API設計

RESTful APIは名詞ベースのリソースURIを設計の基本とし、HTTPメソッド（GET, POST, PUT, PATCH, DELETE）で操作を表現する。Googleは2014年以来このリソース指向設計を社内標準として採用しており、Microsoftも同様のガイドラインを公開している。

主要な設計原則:
- **リソースURIには名詞を使用**: `/orders` であって `/create-order` ではない
- **コレクションには複数形の名詞**: `/customers`（コレクション）、`/customers/5`（個別リソース）
- **URIの階層は浅く保つ**: `collection/item/collection` より深い階層は避ける
- **内部データベース構造を露出しない**: APIはビジネスエンティティのモデル化であり、データベーステーブルの直接公開ではない
- **チャットI/Oを避ける**: 小さなリソースを多数公開するのではなく、関連情報を統合した適切な粒度のリソースを設計する
- **DDD（ドメイン駆動設計）との対応**: 集約はリソースに、エンティティのIDはURLに、値オブジェクトの更新はPUT/PATCHにマッピングする

Googleのリソース指向設計では、標準メソッド（Get, List, Create, Update, Delete）を基本とし、標準メソッドで対応できない場合にのみカスタムメソッドを使用する。

**Sources:**
- [S] Microsoft Azure Architecture Center, "Web API Design Best Practices", https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design, 2025-03
- [S] Google Cloud, "API Design Guide", https://docs.cloud.google.com/apis/design, 2025
- [S] Google, "AIP-121: Resource-oriented design", https://google.aip.dev/121, 2025

### 3. RESTとgRPCの使い分け

マイクロサービスアーキテクチャでは、パブリックAPIとサービス間通信で異なるプロトコルを採用するのが一般的なベストプラクティスとなっている。

**REST over HTTP の適用場面:**
- パブリックAPI（ブラウザやモバイルクライアント向け）
- シンプルなCRUD操作
- 広範なクライアント互換性が必要な場合
- 特別なライブラリが不要で結合度が低い

**gRPC の適用場面:**
- サービス間の内部通信（高パフォーマンスが求められる場合）
- リアルタイムストリーミングが必要な場合
- 大量のデータ転送
- HTTP/2ベースで、データ受信時にRESTの約7倍、送信時に約10倍の速度

**使い分けの指針（Microsoft推奨）:**
- デフォルトではREST over HTTPを採用する（特別なライブラリが不要で結合度が低い）
- バイナリプロトコルの性能メリットが必要な場合にのみgRPC等を検討する
- gRPCを採用する場合、パブリックAPIとの間にプロトコル変換レイヤー（Gateway）が必要になる場合がある
- 開発プロセスの早期段階でパフォーマンス・負荷テストを実施し、RESTで十分かどうかを検証する

**Sources:**
- [S] Microsoft Azure Architecture Center, "API Design for Microservices", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10
- [S] AWS, "gRPC vs REST - Difference Between Application Designs", https://aws.amazon.com/compare/the-difference-between-grpc-and-rest/, 2025
- [S] Google Cloud Blog, "Understanding gRPC, OpenAPI and REST", https://cloud.google.com/blog/products/api-management/understanding-grpc-openapi-and-rest-and-when-to-use-them, 2024

### 4. APIバージョニング戦略

APIはサービスとクライアント間の「契約」であり、変更管理を体系的に行う必要がある。

**バージョニング手法の比較:**

| 手法 | 例 | 利点 | 欠点 |
|------|-----|------|------|
| URLパス | `/v1/users` | 明示的、キャッシュ可能、ルーティングが容易 | URLの増殖 |
| クエリパラメータ | `?version=1` | URLがクリーン | キャッシュしにくい |
| ヘッダー | `Accept: application/vnd.example.v1+json` | URLとバージョンが分離 | ツール対応が限定的 |

**推奨プラクティス:**
- URLパスバージョニングが最も実用的で広く推奨されている
- セマンティックバージョニング（MAJOR.MINOR.PATCH）を採用し、クライアントはメジャーバージョンのみで選択する
- 後方互換性を最優先: フィールドの削除は避け、追加のみとする。クライアントは認識しないフィールドを無視すべき
- 非推奨化ポリシーを事前に策定: 外部APIは6-12ヶ月の移行期間、内部APIはより短い期間
- 2つのバージョンの実装方法: 同一サービス内で両バージョンを公開する方法と、サイドバイサイドデプロイの方法がある
- HATEOAS（Hypermedia as the Engine of Application State）はバージョニングと進化可能なAPIの実現に最適なソリューション

**Sources:**
- [S] Microsoft Azure Architecture Center, "API Design for Microservices", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10
- [S] Microsoft Learn, "Creating, evolving, and versioning microservice APIs and contracts", https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/maintain-microservice-apis, 2021-01
- [A] TechTarget, "Get to know 4 microservices versioning techniques", https://www.techtarget.com/searchapparchitecture/tip/Get-to-know-4-microservices-versioning-techniques, 2024

### 5. API Gatewayパターンの活用

API Gatewayは外部クライアントとマイクロサービス群の間に位置する単一のエントリポイントとして機能し、横断的関心事を集約する。

**API Gatewayの主要な責務:**
- リクエストルーティング
- 認証・認可
- レート制限（`X-RateLimit-Limit`, `X-RateLimit-Remaining` ヘッダーの公開）
- TLS終端
- レスポンス変換・集約
- ログ・モニタリング
- サーキットブレーカーによるカスケード障害の防止

**関連パターン:**
- **Backend for Frontend (BFF)**: 単一の汎用ゲートウェイではなく、クライアントタイプごとに専用のゲートウェイレイヤーを設ける。モバイル、Web、サードパーティそれぞれに最適化されたAPIを提供する
- **リクエスト集約**: 複数の内部マイクロサービスへのリクエストを1つのクライアントリクエストにまとめ、レスポンスを統合して返す
- **サイドカーゲートウェイ / サービスメッシュ**: 各サービスにサイドカーゲートウェイをデプロイし、インバウンドリクエストのプロキシとして機能させる

**設計上の注意点:**
- ゲートウェイは薄く保つ: ビジネスロジックを含めず、ルーティング・セキュリティ・軽量な変換に限定する
- ゲートウェイが「新しいモノリス」になることを避ける（Netflix Zuulの教訓）

**Sources:**
- [S] AWS Prescriptive Guidance, "API gateway pattern", https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-integrating-microservices/api-gateway-pattern.html, 2025
- [B] Chris Richardson / microservices.io, "Pattern: API Gateway / Backends for Frontends", https://microservices.io/patterns/apigateway.html, 2024
- [S] Microsoft Learn, "The API gateway pattern versus the direct client-to-microservice communication", https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/direct-client-to-microservice-communication-versus-the-api-gateway-pattern, 2024

### 6. 冪等性（Idempotency）の確保

分散システムにおけるリトライの安全性を確保するため、API操作の冪等性を設計段階から考慮する必要がある。

**HTTPメソッドの冪等性:**
- `GET`, `PUT`, `DELETE` はHTTP仕様上、冪等であるべき（RFC 7231）
- `POST` は冪等性が保証されない。新しいリソースを作成する場合、同じリクエストを複数回送信すると重複リソースが生成される可能性がある

**冪等性を実現するパターン:**
- **Idempotent Consumer パターン**: 処理済みメッセージのIDを記録し、重複を検出・破棄する。IDはPROCESSED_MESSAGESテーブルまたはビジネスエンティティに保存する
- **Idempotent Receiver パターン**（Martin Fowler）: クライアントからのリクエストを一意に識別し、リトライ時の重複リクエストを無視する
- **PUTとPOSTの使い分け**: PUTはURIが特定のエンティティを指し、存在すれば更新・存在しなければ作成する（冪等）。POSTはコレクションに対して新規リソースを作成し、サーバーがURIを割り当てる（非冪等）
- 非同期操作にはHTTP 202（Accepted）を返し、処理完了を別途通知する

**Sources:**
- [S] Microsoft Azure Architecture Center, "API Design for Microservices", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10
- [B] Chris Richardson / microservices.io, "Pattern: Idempotent Consumer", https://microservices.io/patterns/communication-style/idempotent-consumer.html, 2020-10
- [B] Martin Fowler, "Idempotent Receiver", https://martinfowler.com/articles/patterns-of-distributed-systems/idempotent-receiver.html, 2023

### 7. サービス独立性とデータ所有権

マイクロサービスの独立性を維持するために、APIの背後にあるデータの所有と管理を適切に設計する必要がある。

**主要原則:**
- 各サービスは自身のデータストアを管理し、サービス間でデータベースを共有しない
- サービスの内部実装の詳細をAPIに露出させない
- APIはドメインモデルを表現し、データベーススキーマの反映ではない
- サービス間通信はAPIを介してのみ行い、直接的なデータアクセスは許可しない

**Netflixの実践:**
- 1,000以上のマイクロサービスが協調動作
- 各マイクロサービスは2-8人の小規模チームが全ライフサイクルを担当
- モノリシックAPIからFederated GraphQLアーキテクチャへ移行
- サーキットブレーカーパターン（Hystrix）によるカスケード障害の防止

**Sources:**
- [S] Microsoft Azure Architecture Center, "API Design for Microservices", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10
- [A] F5/NGINX, "Adopting Microservices at Netflix: Lessons for Architectural Design", https://www.f5.com/company/blog/nginx/microservices-at-netflix-architectural-best-practices, 2024

### 8. エラーハンドリングとHTTPステータスコードの適切な使用

APIのエラーレスポンスは一貫性があり、クライアントが適切に処理できる情報を提供すべきである。

**HTTPステータスコードの適切な使用:**
- `200 OK`: 正常完了
- `201 Created`: リソース作成成功（Locationヘッダーに新リソースURIを含める）
- `202 Accepted`: 非同期処理の受付
- `204 No Content`: 成功したがレスポンスボディなし
- `400 Bad Request`: クライアントリクエストの不備
- `404 Not Found`: リソースが見つからない
- `409 Conflict`: リソースの競合

**ベストプラクティス:**
- エラーレスポンスは統一されたフォーマットで返す
- エラーメッセージには問題の内容と対処方法を含める
- レート制限ヘッダー（`X-RateLimit-Limit`, `X-RateLimit-Remaining`）を公開し、クライアントが適切にバックオフできるようにする
- 例外は集中管理された例外追跡サービスに報告する

**Sources:**
- [S] Microsoft Azure Architecture Center, "Web API Design Best Practices", https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design, 2025-03
- [A] TechTarget, "16 REST API design best practices and guidelines", https://www.techtarget.com/searchapparchitecture/tip/16-REST-API-design-best-practices-and-guidelines, 2024
- [B] Chris Richardson / microservices.io, "Pattern: Exception tracking", https://microservices.io/patterns/observability/exception-tracking.html, 2024

## Source Reliability Summary

| Tier | Count | Notes |
|------|-------|-------|
| S    | 9     | Microsoft Azure Architecture Center、AWS公式ドキュメント、Google Cloud API Design Guide、RFC |
| A    | 4     | Nordic APIs、TechTarget、F5/NGINX（Netflix事例） |
| B    | 4     | microservices.io（Chris Richardson）、Martin Fowler |

## Source List

1. [S] Microsoft Azure Architecture Center, "API Design for Microservices", https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design, 2025-10
2. [S] Microsoft Azure Architecture Center, "Web API Design Best Practices", https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design, 2025-03
3. [S] Microsoft Learn, "Creating, evolving, and versioning microservice APIs and contracts", https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/maintain-microservice-apis, 2021-01
4. [S] Microsoft Learn, "The API gateway pattern versus the direct client-to-microservice communication", https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/direct-client-to-microservice-communication-versus-the-api-gateway-pattern, 2024
5. [S] AWS, "gRPC vs REST - Difference Between Application Designs", https://aws.amazon.com/compare/the-difference-between-grpc-and-rest/, 2025
6. [S] AWS Prescriptive Guidance, "API gateway pattern", https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-integrating-microservices/api-gateway-pattern.html, 2025
7. [S] Google Cloud, "API Design Guide", https://docs.cloud.google.com/apis/design, 2025
8. [S] Google, "AIP-121: Resource-oriented design", https://google.aip.dev/121, 2025
9. [S] Google Cloud Blog, "Understanding gRPC, OpenAPI and REST", https://cloud.google.com/blog/products/api-management/understanding-grpc-openapi-and-rest-and-when-to-use-them, 2024
10. [A] Nordic APIs, "The Top 8 API Specifications to Know in 2025", https://nordicapis.com/the-top-8-api-specifications-to-know-in-2025/, 2025
11. [A] Nordic APIs, "A Software Architect's Guide to API-First Strategy", https://nordicapis.com/a-software-architects-guide-to-api-first-strategy/, 2025
12. [A] TechTarget, "16 REST API design best practices and guidelines", https://www.techtarget.com/searchapparchitecture/tip/16-REST-API-design-best-practices-and-guidelines, 2024
13. [A] F5/NGINX, "Adopting Microservices at Netflix: Lessons for Architectural Design", https://www.f5.com/company/blog/nginx/microservices-at-netflix-architectural-best-practices, 2024
14. [B] Chris Richardson / microservices.io, "Pattern: API Gateway / Backends for Frontends", https://microservices.io/patterns/apigateway.html, 2024
15. [B] Chris Richardson / microservices.io, "Pattern: Idempotent Consumer", https://microservices.io/patterns/communication-style/idempotent-consumer.html, 2020-10
16. [B] Chris Richardson / microservices.io, "Pattern: Exception tracking", https://microservices.io/patterns/observability/exception-tracking.html, 2024
17. [B] Martin Fowler, "Idempotent Receiver", https://martinfowler.com/articles/patterns-of-distributed-systems/idempotent-receiver.html, 2023

## Caveats

- WebFetchのアクセス制限により、AWS、Google Cloud Blog、GitHub（Microsoft API Guidelines）の詳細ページを直接取得できなかった。これらのソースからの情報は検索結果のスニペットに基づいている
- microservices.io（Chris Richardson）は業界で広く参照される権威あるリソースだが、個人サイトの性質上Tier Bに分類した。ただし、Chris Richardson氏は「Microservices Patterns」（Manning出版）の著者であり、信頼性は高い
- GraphQLについてはNetflixのFederated GraphQL移行に触れたが、GraphQL固有のAPI設計ベストプラクティスの深掘りは行っていない。必要であれば追加調査が可能
- セキュリティ（OAuth 2.0、JWT、mTLS等）に関する詳細な調査は今回のスコープ外とした
- AsyncAPI（イベント駆動API）に関しては2025年の新しい仕様として言及されているが、詳細は調査していない
