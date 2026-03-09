# マイクロサービスのAPI設計におけるベストプラクティス

## 1. API設計の基本原則

### 1.1 API-Firstアプローチ

マイクロサービスにおけるAPI設計では、**API-First**の考え方が基本となる。これはAPIの契約（コントラクト）を実装コードより先に定義・合意するアプローチであり、チーム間の結合度を下げ、APIの一貫性・利用しやすさ・ドキュメント品質を初期段階から担保できる。

具体的には、OpenAPI（Swagger）仕様でAPIスキーマを先に記述し、それをもとにクライアントライブラリやテストコードを自動生成する手法が推奨される。

### 1.2 RESTとRPCの使い分け

APIの通信スタイルは用途に応じて選択する必要がある。

| プロトコル | 特徴 | 適用場面 |
|-----------|------|----------|
| **REST over HTTP** | リソース指向、広い互換性、ブラウザ対応 | パブリックAPI、外部クライアント向け |
| **gRPC** | バイナリシリアライゼーション、高速、型安全 | 内部サービス間の高性能通信 |
| **GraphQL** | 柔軟なデータ取得、オーバーフェッチ防止 | 多様なクライアント要件がある場合 |

Microsoft Azure Architecture Centerのガイドラインでは、特別なパフォーマンス要件がない限り**REST over HTTP**を推奨している。REST over HTTPは特別なライブラリを必要とせず、最小限の結合度で通信できるためである。

### 1.3 ドメイン駆動設計（DDD）とRESTのマッピング

REST APIの設計はドメインモデルと対応させることが重要である。

- **集約（Aggregate）** → RESTのリソースにマッピング
- **エンティティの一意性** → URLによる一意な識別子
- **子エンティティ** → 親リソースの表現内のリンク（HATEOAS）
- **値オブジェクトの更新** → `PUT`または`PATCH`リクエスト
- **リポジトリ** → コレクションリソース（クエリ・追加・削除）

内部実装の詳細やデータベーススキーマをAPIに露出させてはならない。APIはドメインをモデル化し、サービス間の契約として機能するべきである。

## 2. 通信パターンとレジリエンス

### 2.1 同期 vs 非同期通信

マイクロサービスでは、**非同期通信を同期通信よりも優先する**ことが推奨される。イベント駆動アーキテクチャ（EDA）では、サービスがREST APIを直接呼び出す代わりに、メッセージブローカーを介してイベントを生成・消費する。

同期通信が必要な場合でも、HTTP 202（Accepted）を返して処理を非同期で実行する**非同期リクエスト-リプライパターン**が有効である。

### 2.2 冪等性（Idempotency）

副作用を伴う操作は**冪等**にすることが推奨される。冪等な操作は複数回呼び出しても最初の呼び出し以降に追加の副作用を生まないため、安全なリトライを可能にし、レジリエンスを向上させる。

HTTP仕様では`GET`、`PUT`、`DELETE`は冪等であるべきとされている。`POST`メソッドは冪等性が保証されない。新しいエンティティを作成する場合、`PUT`メソッドを使用してURIでエンティティを識別することで冪等性を確保できる。

### 2.3 サーキットブレーカーパターン

サーキットブレーカーは障害を適切に管理するためのパターンで、3つの状態を持つ。

1. **Closed（閉）**: 正常動作。リクエストが通常通り流れる
2. **Open（開）**: 連続した失敗がしきい値を超えた状態。リクエストは即座に失敗する
3. **Half-Open（半開）**: 回復を確認するためにテストリクエストを流す

このパターンにより、あるサービスの障害が他のサービスに連鎖する「カスケード障害」を防止できる。リトライパターンやフォールバックメカニズムと組み合わせて使用することが推奨される。実装ライブラリとしてはResilience4jが推奨されている（Hystrixはメンテナンスモードに移行済み）。

## 3. APIゲートウェイ

### 3.1 ゲートウェイの役割

APIゲートウェイはクライアントとバックエンドサービスの間に位置し、以下の責務を担う。

- **ルーティング**: リクエストを適切なマイクロサービスに振り分け
- **認証・認可**: リクエストの認証トークン検証と粗粒度のアクセス制御
- **レート制限/スロットリング**: 単一クライアントからの過剰リクエストやDoS攻撃からの保護
- **キャッシュ**: レスポンスのキャッシングによるパフォーマンス向上
- **プロトコル変換**: 外部REST APIと内部gRPCなどのプロトコル間変換

### 3.2 Backend for Frontend（BFF）パターン

モバイルアプリやデスクトップブラウザなど、異なるクライアントに対して、それぞれに最適化された専用バックエンドを作成するパターン。各クライアントに適したペイロードサイズやインタラクションパターンを提供できる。

### 3.3 レート制限の設計

分散システムにおけるレート制限は特に難しい課題である。リクエストが複数のサービスを横断する場合、サービスごとのレート制限に加えて、サービス境界をまたぐエンドツーエンドの制限も考慮する必要がある。APIゲートウェイに集約することで、保護対象のすべてのサービスに対して統一的なレート制限を確保できる。

## 4. APIバージョニング

### 4.1 バージョニング戦略

主なバージョニング手法は以下の通り。

| 手法 | 例 | 特徴 |
|------|-----|------|
| **URIパスバージョニング** | `/v1/users` | 最も明示的で広く理解されている。推奨 |
| **ヘッダーベース** | `Accept: application/vnd.example.v1+json` | URLがクリーンに保たれる |
| **クエリパラメータ** | `/resource?version=1` | 簡便だが発見しにくい |

多くのマイクロサービスのコンテキストでは、その明示性から**URIパスバージョニング**が推奨される。

### 4.2 バージョニングの原則

- **後方互換性を最優先**: モデルからフィールドを削除するなどの破壊的変更は避ける。フィールドの追加は互換性を壊さない
- **セマンティックバージョニング**: MAJOR.MINOR.PATCH形式を使用。クライアントにはメジャーバージョンのみで選択させる
- **変更の最小化**: バージョニング戦略を持つことは重要だが、バージョン変更の必要性を減らすことがさらに重要
- **非推奨ポリシーの公開**: タイムラインとサンセット日を明確にし、非推奨フィールドや機能を文書化する
- **全サービスで一貫した戦略**: 選択したバージョニング戦略をすべてのマイクロサービスで統一的に適用する

## 5. セキュリティ

### 5.1 認証

- **OAuth 2.0**: 分散システムにおけるユーザー認可の業界標準プロトコル
- **JWT（JSON Web Token）**: ユーザーのIDと権限に関するクレームを含む署名付きJSONドキュメント
- **OpenID Connect（OIDC）**: OAuthを拡張してフェデレーテッドIDを追加

サービス間通信にはOAuth 2.0のクライアントクレデンシャルフローが推奨される。

### 5.2 認可の多層防御

認可は以下の複数レイヤーで実施する「多層防御（Defense in Depth）」が推奨される。

1. **ゲートウェイ/プロキシレベル**: 粗粒度の認可（トークン検証、基本的なアクセス制御）
2. **マイクロサービスレベル**: 共有認可ライブラリ/コンポーネントによる認可
3. **ビジネスロジックレベル**: ビジネス固有のアクセス制御ルール

### 5.3 ゼロトラストモデル

マイクロサービスが複数の環境に分散する場合、**ゼロトラストセキュリティモデル**が標準になりつつある。すべてのリクエストに対して厳格な認証と認可を強制する。

### 5.4 シークレット管理

APIキー、クライアントシークレット、認証情報などは**ソースコード管理システムにチェックインしてはならない**。専用のシークレット管理サービスを使用する。

## 6. 可観測性

マイクロサービスでは複数のサービスが独立して動作するため、**集約された可観測性ツール**の導入が不可欠である。

- **ログ集約**: すべてのサービスのログを一元管理
- **メトリクス**: パフォーマンス指標の収集と監視
- **分散トレーシング**: 各リクエストに一意のIDを割り当て、どのサービスが呼び出されたか、どの操作が実行されたかを記録

## 7. ドキュメンテーション

APIのドキュメンテーションは必須とされる。OpenAPI/Swagger仕様を記述することで以下のメリットが得られる。

- コンシューマーがAPIを容易に利用できる
- クライアントライブラリやテストコードの自動生成が可能
- IDL（インターフェース定義言語）としてAPIテストツールが利用できる

---

## Sources

- [API Design - Azure Architecture Center | Microsoft Learn](https://learn.microsoft.com/en-us/azure/architecture/microservices/design/api-design)
- [Web API Design Best Practices - Azure Architecture Center | Microsoft Learn](https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design)
- [API-First Design for Microservices: Best Practices and Patterns | Xcapit](https://www.xcapit.com/en/blog/api-first-design-microservices-best-practices)
- [API Design Best Practices in 2025: Trends and Techniques - MyAppAPI Blog](https://myappapi.com/blog/api-design-best-practices-2025)
- [Top 10 Microservices Architecture Best Practices for 2026 - TekRecruiter](https://www.tekrecruiter.com/post/top-10-microservices-architecture-best-practices-for-2026)
- [Mastering Microservices: Top Best Practices for 2026 - Imaginary Cloud](https://www.imaginarycloud.com/blog/microservices-best-practices)
- [8 Best Practices for Microservices to Master in 2025 - GoReplay](https://goreplay.org/blog/best-practices-for-microservices-20250808133113/)
- [Microservice API Patterns](https://microservice-api-patterns.org/)
- [Ultimate Guide to Microservices API Versioning - DreamFactory](https://blog.dreamfactory.com/ultimate-guide-to-microservices-api-versioning)
- [The Ultimate Guide to Microservices Versioning Best Practices - OpsLevel](https://www.opslevel.com/resources/the-ultimate-guide-to-microservices-versioning-best-practices)
- [Creating, evolving, and versioning microservice APIs and contracts - Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/maintain-microservice-apis)
- [Microservices Pattern: Circuit Breaker](https://microservices.io/patterns/reliability/circuit-breaker.html)
- [Circuit Breaker Pattern in Microservices - GeeksforGeeks](https://www.geeksforgeeks.org/system-design/what-is-circuit-breaker-pattern-in-microservices/)
- [Microservices Security - OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/cheatsheets/Microservices_Security_Cheat_Sheet.html)
- [Authentication and authorization in a microservice architecture - microservices.io](https://microservices.io/post/architecture/2025/04/25/microservices-authn-authz-part-1-introduction.html)
- [Best Practices for Authorization in Microservices - Oso](https://www.osohq.com/post/microservices-authorization-patterns)
- [Microservices Authentication and Authorization Using API Gateway - Permify](https://permify.co/post/microservices-authentication-authorization-using-api-gateway/)
- [API Gateway Pattern: 5 Design Options - Solo.io](https://www.solo.io/topics/api-gateway/api-gateway-pattern)
- [API Rate Limiting at Scale: Patterns, Failures, and Control Strategies - Gravitee](https://www.gravitee.io/blog/rate-limiting-apis-scale-patterns-strategies)
- [Pattern: Rate Limit - Microservice API Patterns](https://microservice-api-patterns.org/patterns/quality/qualityManagementAndGovernance/RateLimit)
- [Refonte Learning: API Developer Engineering in 2026](https://www.refontelearning.com/blog/api-developer-engineering-in-2026-trends-skills-best-practices)
