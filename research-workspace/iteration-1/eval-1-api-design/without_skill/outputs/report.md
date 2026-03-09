# マイクロサービスのAPI設計におけるベストプラクティス

## 1. APIファースト設計

マイクロサービスにおけるAPI設計では、**APIファースト（API-First）** のアプローチが強く推奨される。これは、実装コードを書く前にAPIのコントラクト（仕様）を定義・合意するアプローチである。

- **コントラクト駆動開発**: エンドポイント、リクエスト/レスポンスフォーマット、認証方式などを事前に定義する
- **並行開発の実現**: フロントエンド、モバイル、他のバックエンドサービスが安定した契約に基づいて並行して開発できる
- **OpenAPI/Swagger仕様の活用**: 各エンドポイント、パラメータ、リクエスト/レスポンスのスキーマ、認証方式を定義するOpenAPI仕様を作成する

## 2. RESTful API設計の原則

### リソース指向設計

- **リソースベースのURL設計**: URLには動詞を使わず、リソース（名詞）を使う
- **適切なHTTPメソッドの活用**: 操作の記述にはHTTPメソッド（GET, POST, PUT, DELETE, PATCH）を使う
- **一貫性のある命名規則**: コレクション名には複数形を使用し、ネストしたリソースには階層的なURLを使用する

### 共通処理の標準化

- ページネーション、検索、ソート、フィルタリングのパラメータ仕様を統一する
- レート制限の仕様をすべてのAPIで一貫させる
- エラーレスポンスのフォーマットを標準化する（RFC 7807 Problem Details等）

## 3. APIゲートウェイパターン

APIゲートウェイはクライアントとマイクロサービスの間に位置し、単一のエントリーポイントとして機能する。

### 主要な役割

- **ルーティング**: リクエストを適切な内部サービスにルーティングする
- **認証・認可の一元化**: セキュリティの共通処理をゲートウェイで担当する
- **レート制限とキャッシング**: パフォーマンスとセキュリティの向上
- **レスポンスの集約**: 複数サービスへのリクエストを1回のラウンドトリップで処理する
- **プロトコル変換**: 外部はREST、内部はgRPCといった変換を行う

### ベストプラクティス

- **ゲートウェイを軽量に保つ**: ビジネスロジックをゲートウェイに含めない
- **BFF（Backend for Frontend）パターン**: フロントエンドごとに専用のAPIゲートウェイを用意する（Web、iOS、Android等）
- **複数ゲートウェイの分割**: ビジネス境界に基づいてゲートウェイを分割する

## 4. サービス間通信

### 同期通信

| プロトコル | 特徴 | 適用場面 |
|-----------|------|---------|
| **REST** | HTTP/JSONベース、広く普及、シンプル | 公開API、外部連携、CRUD操作 |
| **gRPC** | HTTP/2ベース、バイナリ形式（Protocol Buffers）、高速、ストリーミング対応 | 内部サービス間通信、低レイテンシが必要な場面 |
| **GraphQL** | クライアント主導のクエリ、柔軟なデータ取得 | フロントエンド向けAPI、複雑なデータ要件 |

### 非同期通信

- **イベント駆動アーキテクチャ**: サービスがイベントを発行し、関心のあるサービスが消費する
- **メッセージブローカー**: Apache Kafka、RabbitMQ、AWS SQS等を活用
- **疎結合の実現**: サービス間の依存関係を減らし、スケーラビリティを向上させる
- **結果整合性（Eventual Consistency）**: 厳密な即座の一貫性ではなく、結果的に整合する設計

## 5. APIバージョニング

### 主要な戦略

1. **URLパスバージョニング**: `/v1/users` のようにURLにバージョンを埋め込む
   - 明示的で分かりやすい
   - 外部APIでの利用に適している
   - APIの成長に伴いURLが複雑になる可能性がある

2. **ヘッダーベースバージョニング**: `API-Version: 2.0` のようにHTTPヘッダーでバージョンを指定
   - URLがクリーンに保たれる
   - RESTful原則に準拠
   - 内部マイクロサービス間の通信に適している

3. **セマンティックバージョニング**: `MAJOR.MINOR.PATCH` 形式
   - MAJOR: 破壊的変更
   - MINOR: 後方互換性のある機能追加
   - PATCH: バグ修正

### 推奨事項

- 最初のAPIを公開する前にバージョニング戦略を決定する
- チーム間で一貫したバージョニング規約を維持する
- 外部APIにはURLパスバージョニング、内部APIにはヘッダーバージョニングの使い分けを検討する

## 6. セキュリティ

### 認証・認可

- **OAuth 2.0 / OAuth 2.1**: API認証の標準。クライアントクレデンシャルフローでサーバー間通信を保護
- **JWT（JSON Web Token）**: ステートレスな認証トークン。短い有効期限を設定し、リフレッシュトークンと組み合わせる
- **mTLS（相互TLS）**: クライアントとサーバーの両方を検証する最も強力な認証
- **PKCEを用いたAuthorization Code Flow**: Webおよびモバイルアプリ向け

### ゼロトラストセキュリティ

- すべてのリクエストに対して認可を検証する
- サービス間通信にも認証・認可を適用する（外部トラフィックだけでなく）
- 各サービスに独立したセキュリティ制御を実装する
- OAuth 2.0スコープによるオペレーションレベルの制御

### シークレット管理

- APIキー、証明書、トークンを安全に管理する
- 環境変数やシークレット管理サービス（HashiCorp Vault等）を活用する

## 7. 耐障害性・レジリエンスパターン

### サーキットブレーカーパターン

連続した障害がしきい値を超えた場合にサーキットブレーカーが作動し、一定期間すべてのリクエストを即座に失敗させる。その後、半開（half-open）状態で回復を確認する。

### リトライパターン

- バウンド付きリトライ（無制限にリトライしない）
- **ジッター付き指数バックオフ**: ジッターなしのバックオフはリトライストームを引き起こす
- 非冪等な操作にはリトライを避ける

### べき等性（Idempotency）

- 同じリクエストを繰り返しても同じ結果になることを保証する
- トランザクショナルアウトボックス + 重複排除が実用的な解決策
- べき等キー（Idempotency Key）の活用

### その他のパターン

- **バルクヘッドパターン**: リソースを分離し、一部の障害がシステム全体に波及しないようにする
- **タイムアウト設定**: 応答を待つ時間の上限を設定し、スローサービスによるシステム停止を防ぐ
- **フォールバック**: 障害時に代替レスポンスを返す

## 8. コントラクトテスト

### コンシューマ駆動コントラクトテスト

- **Pact**等のツールを活用し、コンシューマ側でコントラクトを定義する
- プロバイダがコンシューマの期待に対して検証する
- エンドツーエンドの統合テストへの依存を削減する
- 複雑なテスト環境のメンテナンスを減らす

### OpenAPIベースのテスト

- OpenAPI仕様からコンシューマおよびプロバイダのコントラクトテストを自動生成する
- APIモックをOpenAPI仕様から生成し、実際のAPIサーバーのリクエスト/レスポンスを模倣する

## 9. オブザーバビリティ（可観測性）

マイクロサービスの可観測性は、分散システムの内部状態を理解するために不可欠である。

### 三本柱

1. **ログ**: イベントの詳細な時刻付き記録。デバッグと事後分析に不可欠
2. **メトリクス**: システムパフォーマンスの定量的測定値。アラートの閾値設定やトレンド分析に活用
3. **トレース**: 分散システムの複数サービスを通過するリクエストのエンドツーエンド追跡

### 分散トレーシング

- すべてのリクエストに一意な識別子を付与し、各サービスに伝播させる
- スパン（Span）によってリクエストの各段階を追跡する
- Jaeger、Zipkin等のオープンソースツールを活用する
- 障害発生時にトランザクション全体を再現し、根本原因を特定できる

## 10. ドメイン駆動設計（DDD）との統合

- **境界づけられたコンテキスト（Bounded Context）**: サービスの境界をドメインに基づいて定義する
- **APIはドメインをモデル化する**: 内部実装ではなく、ビジネスドメインを反映したAPIを設計する
- **実装詳細の漏洩防止**: サービス内部の実装がAPIを通じて外部に露出しないようにする
- **Database per Service**: 各サービスが独自のデータストアを持ち、データの独立性を確保する

---

## Sources

- [API-First Design for Microservices: Best Practices and Patterns | Xcapit](https://www.xcapit.com/en/blog/api-first-design-microservices-best-practices)
- [API設計スキルを次のレベルに引き上げるベストプラクティス22選 - Qiita](https://qiita.com/baby-degu/items/6f516189445d98ddbb7d)
- [マイクロサービス アーキテクチャの設計 - Azure Architecture Center | Microsoft Learn](https://learn.microsoft.com/ja-jp/azure/architecture/microservices/design/)
- [マイクロサービス アーキテクチャ スタイル - Azure Architecture Center | Microsoft Learn](https://learn.microsoft.com/ja-jp/azure/architecture/guide/architecture-styles/microservices)
- [Top 10 Microservices Architecture Best Practices for 2026 | TekRecruiter](https://www.tekrecruiter.com/post/top-10-microservices-architecture-best-practices-for-2026)
- [Mastering Microservices: Top Best Practices for 2026 | Imaginary Cloud](https://www.imaginarycloud.com/blog/microservices-best-practices)
- [API Design Best Practices in 2025 | MyAppAPI](https://myappapi.com/blog/api-design-best-practices-2025)
- [Microservices Pattern: API Gateway / Backends for Frontends | microservices.io](https://microservices.io/patterns/apigateway.html)
- [API Gateway Pattern: 5 Design Options | Solo.io](https://www.solo.io/topics/api-gateway/api-gateway-pattern)
- [The API gateway pattern versus direct client-to-microservice communication | Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/direct-client-to-microservice-communication-versus-the-api-gateway-pattern)
- [Get to know 4 microservices versioning techniques | TechTarget](https://www.techtarget.com/searchapparchitecture/tip/Get-to-know-4-microservices-versioning-techniques)
- [Ultimate Guide to Microservices API Versioning | DreamFactory](https://blog.dreamfactory.com/ultimate-guide-to-microservices-api-versioning)
- [API Versioning in Microservices Architecture | DZone](https://dzone.com/articles/api-versioning-in-microservices-architecture)
- [API Security in Microservices Architecture | APIsec](https://www.apisec.ai/blog/api-security-in-microservices)
- [Authentication in Microservices | Frontegg](https://frontegg.com/blog/authentication-in-microservices)
- [Authentication and authorization in a microservice architecture | microservices.io](https://microservices.io/post/architecture/2025/05/28/microservices-authn-authz-part-2-authentication.html)
- [Microservices Communication Patterns: REST, gRPC, or Message Queues | DEV Community](https://dev.to/benyusouf/microservices-communication-patterns-when-to-use-rest-grpc-or-message-queues-2dl4)
- [Understanding Microservices Communication Patterns | OneUptime](https://oneuptime.com/blog/post/2026-02-20-microservices-communication-patterns/view)
- [Circuit Breaker Pattern in Microservices | GeeksforGeeks](https://www.geeksforgeeks.org/system-design/what-is-circuit-breaker-pattern-in-microservices/)
- [Microservices Resilience Patterns | GeeksforGeeks](https://www.geeksforgeeks.org/system-design/microservices-resilience-patterns/)
- [Microservices Pattern: Circuit Breaker | microservices.io](https://microservices.io/patterns/reliability/circuit-breaker.html)
- [Introduction | Pact Docs](https://docs.pact.io/)
- [API Contract Testing 101 | Redocly](https://redocly.com/learn/testing/contract-testing-101)
- [Scaling Microservices with Contract Testing and PactFlow | SmartBear](https://smartbear.com/blog/scaling-microservices-with-pactflow/)
- [Microservices Pattern: Distributed tracing | microservices.io](https://microservices.io/patterns/observability/distributed-tracing.html)
- [Microservices Observability: Logs, Metrics, and Traces | OpenObserve](https://openobserve.ai/blog/microservices-observability-logs-metrics-traces/)
- [API設計ガイドラインのベストプラクティス | Kong](https://jp.konghq.com/blog/engineering-best-practices-for-api-design-guidelines)
