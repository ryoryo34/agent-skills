# マイクロサービスのAPI設計におけるベストプラクティス

## 1. API ファースト設計

マイクロサービスにおけるAPI設計の最も重要な原則は「APIファースト」のアプローチである。コードを書き始める前にAPIコントラクト（契約）を定義し、ステークホルダーと合意を形成することで、長期的に安定したAPIを構築できる。

**主なポイント:**
- OpenAPI/Swagger仕様でAPIを定義し、各エンドポイント、パラメータ、リクエスト/レスポンススキーマ、認証方法を明文化する
- フロントエンド、モバイル、他のバックエンドサービスが安定したコントラクトに対して並行開発できる
- 実装の詳細ではなく、消費者のニーズにフォーカスする

## 2. ドメイン駆動設計（DDD）との連携

APIはサービス内部の実装ではなく、ドメインをモデル化する必要がある。ドメイン駆動設計（DDD）により、各マイクロサービスが特定のビジネス機能に整合し、サービス間の重複や不要な依存関係を防止できる。

**実践事項:**
- Bounded Context（境界づけられたコンテキスト）に基づいてサービスを分割する
- 各サービスのAPIはそのドメインの言葉（ユビキタス言語）で表現する
- サービス間の結合度を最小化し、凝集度を最大化する

## 3. 通信プロトコルの選択：REST vs gRPC

### REST API
- パブリック向けAPI、ブラウザとの対話に最適
- シンプルな実装、可読性、柔軟性が特徴
- 標準的なHTTPメソッド（GET, POST, PUT, DELETE）によるCRUD操作に適する
- JSON形式で人間にも読みやすい

### gRPC
- 内部サービス間通信でRESTの最大7倍のパフォーマンスを発揮する場合がある
- Protocol Buffersによるバイナリエンコーディングで効率的なシリアライズ/デシリアライズ
- HTTP/2ベースで双方向ストリーミングをサポート
- 金融取引プラットフォームなど低レイテンシが求められる場面に適する

### ハイブリッドアプローチ
多くの組織では、パブリック向けAPIにはRESTを、内部通信にはgRPCを採用するハイブリッドな構成を取っている。

**参考:**
- [gRPC vs REST - Difference Between Application Designs - AWS](https://aws.amazon.com/compare/the-difference-between-grpc-and-rest/)
- [gRPC vs. REST: Understanding gRPC, OpenAPI and REST | Google Cloud Blog](https://cloud.google.com/blog/products/api-management/understanding-grpc-openapi-and-rest-and-when-to-use-them)

## 4. APIゲートウェイパターン

APIゲートウェイは、すべてのクライアントリクエストに対する単一のエントリーポイントを提供する。オブジェクト指向設計のFacadeパターンに類似しているが、分散システムの一部として機能する。

**APIゲートウェイが担う役割:**
- 認証・認可
- レート制限
- ロギング・モニタリング
- レスポンスキャッシュ
- SSL終端
- リクエストルーティング

**APIゲートウェイ vs サービスメッシュ:**
- APIゲートウェイ: 外部トラフィック（North/South通信）を管理
- サービスメッシュ: 内部サービス間通信（East/West通信）を管理
- 両者は補完的であり、併用が推奨される

**参考:**
- [The API gateway pattern versus the direct client-to-microservice communication - Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/direct-client-to-microservice-communication-versus-the-api-gateway-pattern)
- [What Is API Gateway vs. Service Mesh? | Akamai](https://www.akamai.com/glossary/api-gateway-vs-service-mesh)

## 5. APIバージョニング戦略

バージョニング戦略は、最初のAPIを公開する前に決定すべきであり、最初の破壊的変更の後ではない。

### 主要なバージョニング方式

| 方式 | 例 | 特徴 |
|------|------|------|
| URLパスバージョニング | `/api/v1/products` | 最も一般的で直感的 |
| ヘッダーベース | `X-API-Version: 1` | URLとバージョンを分離 |
| クエリパラメータ | `/api/products?version=1` | シンプルだが慣習的ではない |

### バージョニングのベストプラクティス
- セマンティックバージョニングを採用し、変更の種類を明確に伝える
- 移行期間中は複数バージョンを同時に運用する
- 廃止予定のフィールドや機能をドキュメントで明示し、アップグレード方法を案内する
- 追加的で後方互換性のある変更を優先し、破壊的変更を最小化する
- すべてのマイクロサービスで一貫したバージョニング方式を適用する

**参考:**
- [Ultimate Guide to Microservices API Versioning](https://blog.dreamfactory.com/ultimate-guide-to-microservices-api-versioning)
- [The Ultimate Guide to Microservices Versioning Best Practices](https://www.opslevel.com/resources/the-ultimate-guide-to-microservices-versioning-best-practices)
- [Creating, evolving, and versioning microservice APIs - Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/maintain-microservice-apis)

## 6. エラーハンドリング

### RFC 7807 準拠のエラーレスポンス

マイクロサービスチェーンでリクエストが処理される場合、エラーの元のコンテキストを保持することが重要である。RFC 7807は、HTTPAPIにおけるマシンリーダブルなエラー詳細の標準フォーマットを提案している。

```json
{
  "type": "https://example.com/errors/insufficient-funds",
  "title": "Insufficient Funds",
  "status": 422,
  "detail": "Your account balance is $30.00, but the transaction requires $50.00.",
  "instance": "/accounts/12345/transactions/67890"
}
```

### エラーハンドリングの原則
- 適切なHTTPステータスコードを使用する（4xxはクライアントエラー、5xxはサーバーエラー）
- エラーメッセージは明確かつアクション可能な情報を提供する
- サービスチェーンにおけるエラー伝播では、元のコンテキストを保持する
- 内部実装の詳細はエラーレスポンスに漏洩させない

**参考:**
- [Microservices HTTP Error Propagation | Medium](https://medium.com/@jameszheng66/microservices-error-propagation-2a847feeb3f)
- [Error Report - Microservice API Patterns](https://microservice-api-patterns.org/patterns/structure/specialPurposeRepresentations/ErrorReport)

## 7. ページネーションとデータ取得

### 主要なページネーション方式

**オフセットベース:**
```
GET /api/v1/events?offset=20&limit=10
```
- シンプルで実装が容易
- 大規模データセットではパフォーマンスが低下する可能性がある

**カーソルベース:**
```
GET /api/v1/events?cursor=eyJpZCI6MTAwfQ&limit=10
```
- 大規模データセットでも一貫したパフォーマンス
- リアルタイムデータに適する

### 注意点
- DoS攻撃を防ぐため、返却アイテム数に上限を設ける
- ページネーション、検索、レート制限などの共通処理はすべてのAPIで一貫性を持たせる

**参考:**
- [Pagination - Microservice API Patterns](https://microservice-api-patterns.org/patterns/quality/dataTransferParsimony/Pagination)
- [Web API Design Best Practices - Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design)

## 8. レジリエンスパターン

### サーキットブレーカー
リモートサービスへの呼び出しをプロキシ経由で行い、連続失敗数が閾値を超えるとサーキットが「オープン」になり、即座に失敗を返す。一定時間後に「ハーフオープン」状態で回復を確認する。

### リトライパターン
- ジッターなしのバックオフはリトライストームを引き起こす
- 指数バックオフ + ジッター + リトライ予算の組み合わせが推奨される

### 冪等性（Idempotency）
- 正確に一度だけの配信は現実的ではない
- トランザクショナルアウトボックス + 重複排除が実用的な解決策
- リトライパターンが安全に機能するために冪等性は不可欠

### バルクヘッドパターン
サービスごとに独立したリソースプール（スレッド、コネクションなど）を使用し、一つのコンポーネントの障害が他に波及するのを防ぐ。

**参考:**
- [Circuit Breaker Pattern - microservices.io](https://microservices.io/patterns/reliability/circuit-breaker.html)
- [Microservices Resilience Patterns - GeeksforGeeks](https://www.geeksforgeeks.org/system-design/microservices-resilience-patterns/)
- [Resilient Microservices: A Systematic Review | arXiv](https://arxiv.org/html/2512.16959v1)

## 9. セキュリティ

### 認証と認可
- **認証（Authentication）:** ユーザーやサービスのIDを確認する（JWT, OAuth 2.0）
- **認可（Authorization）:** 認証済みユーザーが実行できるアクションを決定する（RBAC, ABAC）

### 多層防御（Defense in Depth）
1. **ゲートウェイレベル:** 粗い粒度でのアクセス制御
2. **マイクロサービスレベル:** 共有ライブラリによる細粒度の判定
3. **ビジネスコードレベル:** ビジネス固有のアクセス制御ルール

### セキュリティのベストプラクティス
- すべての通信にHTTPSを使用する
- ゼロトラストの原則と最小権限の原則を適用する
- トークンを定期的にローテーションする
- APIゲートウェイで認証・認可を集中管理する

**参考:**
- [Authentication and authorization in a microservice architecture - microservices.io](https://microservices.io/post/architecture/2025/04/25/microservices-authn-authz-part-1-introduction.html)
- [Microservices Security - OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/cheatsheets/Microservices_Security_Cheat_Sheet.html)
- [Secure Access Best Practices for Microservice APIs](https://www.descope.com/blog/post/secure-access-microservice-apis)

## 10. 非同期通信とイベント駆動設計

同期的なリクエスト-レスポンスパターンではなく、非同期通信を優先することがマイクロサービスアーキテクチャの重要なベストプラクティスの一つである。

**イベント駆動アーキテクチャの利点:**
- サービスはメッセージブローカー経由でイベントを発行・消費する
- 下流のコンシューマーを知らなくてもイベントを発行できる（疎結合）
- サービス間の時間的な結合を排除する
- スケーラビリティと耐障害性が向上する

**主要なパターン:**
- イベントソーシング
- CQRS（Command Query Responsibility Segregation）
- Sagaパターン（分散トランザクション管理）

## 11. 運用エンドポイント

RESTfulマイクロサービスは以下の運用エンドポイントを実装すべきである。

| エンドポイント | 用途 |
|--------------|------|
| `/health` | ヘルスチェック |
| `/version` | サービスバージョン情報 |
| `/metrics` | メトリクス収集 |

これらのエンドポイントは、オーケストレーションツール（Kubernetes等）やモニタリングシステムとの統合に不可欠である。

## まとめ

マイクロサービスのAPI設計においては、以下の点を総合的に考慮することが重要である。

1. **APIファースト設計** で安定したコントラクトを先に定義する
2. **ドメイン駆動設計** でサービス境界を適切に定める
3. **通信プロトコル** は用途に応じてREST/gRPCを使い分ける
4. **APIゲートウェイ** で横断的関心事を集約する
5. **バージョニング** は最初から戦略的に計画する
6. **エラーハンドリング** は標準フォーマット（RFC 7807）に準拠する
7. **レジリエンスパターン** で障害に強いシステムを構築する
8. **セキュリティ** は多層防御で実装する
9. **非同期通信** でサービス間の結合度を下げる
10. **運用エンドポイント** で可観測性を確保する

---

## Sources

- [API-First Design for Microservices: Best Practices and Patterns | Xcapit](https://www.xcapit.com/en/blog/api-first-design-microservices-best-practices)
- [API Design Best Practices in 2025 - MyAppAPI Blog](https://myappapi.com/blog/api-design-best-practices-2025)
- [Top 10 Microservices Architecture Best Practices for 2026 - TekRecruiter](https://www.tekrecruiter.com/post/top-10-microservices-architecture-best-practices-for-2026)
- [Mastering Microservices: Top Best Practices for 2026 - Imaginary Cloud](https://www.imaginarycloud.com/blog/microservices-best-practices)
- [API設計スキルを次のレベルに引き上げるベストプラクティス22選 - Qiita](https://qiita.com/baby-degu/items/6f516189445d98ddbb7d)
- [マイクロサービス アーキテクチャの設計 - Azure Architecture Center | Microsoft Learn](https://learn.microsoft.com/ja-jp/azure/architecture/microservices/design/)
- [API設計ガイドラインのベストプラクティス | Kong](https://jp.konghq.com/blog/engineering-best-practices-for-api-design-guidelines)
- [Microservice API Patterns](https://microservice-api-patterns.org/)
- [Web API Design Best Practices - Azure Architecture Center | Microsoft Learn](https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design)
- [Ultimate Guide to Microservices API Versioning - DreamFactory](https://blog.dreamfactory.com/ultimate-guide-to-microservices-api-versioning)
- [The Ultimate Guide to Microservices Versioning Best Practices - OpsLevel](https://www.opslevel.com/resources/the-ultimate-guide-to-microservices-versioning-best-practices)
- [Creating, evolving, and versioning microservice APIs - Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/maintain-microservice-apis)
- [gRPC vs REST - AWS](https://aws.amazon.com/compare/the-difference-between-grpc-and-rest/)
- [gRPC vs. REST | Google Cloud Blog](https://cloud.google.com/blog/products/api-management/understanding-grpc-openapi-and-rest-and-when-to-use-them)
- [The API gateway pattern - Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/direct-client-to-microservice-communication-versus-the-api-gateway-pattern)
- [What Is API Gateway vs. Service Mesh? | Akamai](https://www.akamai.com/glossary/api-gateway-vs-service-mesh)
- [Circuit Breaker Pattern - microservices.io](https://microservices.io/patterns/reliability/circuit-breaker.html)
- [Microservices Resilience Patterns - GeeksforGeeks](https://www.geeksforgeeks.org/system-design/microservices-resilience-patterns/)
- [Microservices HTTP Error Propagation | Medium](https://medium.com/@jameszheng66/microservices-error-propagation-2a847feeb3f)
- [Authentication and authorization in a microservice architecture - microservices.io](https://microservices.io/post/architecture/2025/04/25/microservices-authn-authz-part-1-introduction.html)
- [Microservices Security - OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/cheatsheets/Microservices_Security_Cheat_Sheet.html)
- [Secure Access Best Practices for Microservice APIs - Descope](https://www.descope.com/blog/post/secure-access-microservice-apis)
