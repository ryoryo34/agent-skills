# 大規模サービスにおけるFeature Flagの運用事例

## 1. はじめに

Feature Flag（機能フラグ / フィーチャートグル）は、コードのデプロイとリリースを分離し、本番環境で機能の有効・無効を動的に切り替える手法である。大規模サービスでは、数千のフラグを同時に管理しながら安全なリリースと高速な開発を両立させる必要があり、その運用には独自の課題とベストプラクティスが存在する。

本レポートでは、グローバルテック企業および国内企業の具体的な運用事例を調査し、大規模運用における設計原則・課題・教訓をまとめる。

---

## 2. グローバルテック企業の事例

### 2.1 Meta（Facebook） - Gatekeeper

Metaは「Gatekeeper」と呼ばれる内製Feature Flagシステムを運用しており、数十億ユーザーへのリリースを制御している。

- **段階的ロールアウト**: コードがデプロイされると、まず社内ユーザーのみに有効化し、次に全体の2%のユーザーに展開。問題がなければ全ユーザーへロールアウトする
- **ターゲティング**: 国、年齢、データセンターなどのパラメータでフラグの対象を絞り込める
- **即時ロールバック**: 問題発生時はGatekeeperのスイッチをオフにするだけで、コードのリバートなしに機能を無効化できる
- **デプロイとリリースの分離**: モバイル・Webのコードリリースと機能公開を独立して管理し、リリースリスクを低減
- **リリース頻度**: 数時間ごとに数百の変更を本番投入する「Rapid Release」を実現

**出典:**
- [Rapid release at massive scale - Engineering at Meta](https://engineering.fb.com/2017/08/31/web/rapid-release-at-massive-scale/)
- [Secret to Facebook's Hacker Engineering Culture | LaunchDarkly](https://launchdarkly.com/blog/secret-to-facebooks-hacker-engineering-culture/)
- [Here's Facebook's Secret to Creating Software For Billions of Users | Fortune](https://fortune.com/2017/08/31/facebook-software-project-overhaul/)

### 2.2 Netflix - 実験プラットフォーム

Netflixは年間数千件のA/Bテストを実行しており、Feature Flagと実験プラットフォームを密接に統合して運用している。

- **ABlaze**: Netflixの実験基盤のフロントエンドとして機能するクロスプラットフォームA/Bテストソリューション
- **並行実験管理**: 各ユーザーは常に複数のA/Bテストに参加しており、同じUI領域を変更する競合テストが発生しないようスケジュール管理を行う
- **データドリブン意思決定**: 「最も声の大きい社員」ではなく、実際のユーザーデータに基づいて機能リリースを判断する文化
- **対象範囲**: アプリUI、エンコーディングアルゴリズム、CDN（Open Connect）上のコンテンツ配置など、あらゆる領域で実験を実施
- **数千デバイス対応**: 数千種類のデバイスにまたがるクロスプラットフォームでの一貫した実験管理

**出典:**
- [It's All A/Bout Testing: The Netflix Experimentation Platform | Netflix TechBlog](https://netflixtechblog.com/its-all-a-bout-testing-the-netflix-experimentation-platform-4e1ca458c15)
- [Experimentation is a major focus of Data Science across Netflix | Netflix TechBlog](https://netflixtechblog.com/experimentation-is-a-major-focus-of-data-science-across-netflix-f67923f8e985)
- [A/B Testing and Beyond | Netflix TechBlog](https://netflixtechblog.com/a-b-testing-and-beyond-improving-the-netflix-streaming-experience-with-experimentation-and-data-5b0ae9295bdf)

### 2.3 Google - Firebase Remote Config

Googleは社内でも大規模な実験基盤を運用しているが、外部向けにはFirebase Remote Configを提供している。

- **Android Feature Launch Flags**: Android OSの開発においてFeature Flagを活用し、最新リリースブランチの安定性を確保
- **Firebase Remote Config**: アプリの動作やUIをサーバーサイドから動的に制御し、段階的ロールアウト、A/Bテスト、パーソナライゼーションを実現
- **バージョン不要の機能制御**: 新しいアプリバージョンをリリースせずに機能の有効・無効を切り替え可能

**出典:**
- [Feature launch flag overview | Android Open Source Project](https://source.android.com/docs/setup/build/feature-flagging)
- [Firebase Remote Config](https://firebase.google.com/products/remote-config)

---

## 3. 国内企業の事例

### 3.1 サイバーエージェント（ABEMA / Bucketeer / wings）

サイバーエージェントはFeature Flagの活用において複数の取り組みを行っている。

#### ABEMA
- 300以上のフィーチャーフラグを運用
- リリース前はフラグをOFFにし、デバッグ・テスト時には自動的にONにする仕組み
- リリース直前にフラグをONにして動的な切り替えを実現
- フラグのライフサイクル管理（ロールアウト完了後の不要フラグ削除）を実施

#### Bucketeer
- 社内向けフィーチャーフラグ＆A/Bテストプラットフォームとして内製開発

#### wings（マルチリージョン対応Feature Flags）
- 海外展開時のレイテンシ問題（米国ユーザーに対し600msの遅延）を解決するために内製
- 汎用データ配信サーバーとしての設計思想
- クライアントコードの自動生成とTerraformによるIaC管理
- IDEでクライアントの呼び出し元を調べることで未使用フラグを発見可能

#### トランクベース開発との連携
- 1日15回の本番デプロイを実現
- OpenFeature仕様に準拠したFeature Flagツールを内製化

**出典:**
- [サイバーエージェントのフィーチャーフラグを活用した高速開発 | CyberAgent Developers Blog](https://developers.cyberagent.co.jp/blog/archives/35021/)
- [マルチリージョンで稼働する内製Feature Flagsの実装 | CyberAgent Developers Blog](https://developers.cyberagent.co.jp/blog/archives/47225/)
- [FeatureFlagツール内製化で実現するトランクベース開発 | CyberAgent Developers Blog](https://developers.cyberagent.co.jp/blog/archives/55358/)
- [1日に15回本番デプロイを実現するトランクベース開発のコツ | CyberAgent Developers Blog](https://developers.cyberagent.co.jp/blog/archives/31837/)

### 3.2 newmo - 独自Feature Flag基盤

newmoはモビリティサービスにおいて、独自のFeature Flag基盤を構築している。

- **OpenFeature準拠**: flagd（OpenFeature準拠ツール）のIn-Process Evaluation Modeを採用し、RPCと比較して低レイテンシを実現
- **Modular Monolithアーキテクチャ**: サービスアーキテクチャに合わせたFeature Flag基盤設計
- **宣言的定義**: カスタムToggle Configurationスキーマによる宣言的なフラグ定義
- **自動ライフサイクル管理**: 定期ジョブでフラグごとのToggle Point数を計測し、参照されなくなったフラグを自動検出・削除
- **コード生成**: OSS/FFaaSとアプリケーション双方のToggle Router設定を自動生成し、名前の不整合を防止

**出典:**
- [feature flag 入門と newmo の feature flag 基盤について - newmo 技術ブログ](https://tech.newmo.me/entry/newmo-feature-flag-system)
- [PFEM Online Feature Flag @ newmo - Speaker Deck](https://speakerdeck.com/shinyaishitobi/pfem-online-feature-flag-at-newmo)

---

## 4. Feature Flagの分類とライフサイクル

大規模運用では、フラグを目的と寿命で分類して管理することが重要とされている。

| フラグの種類 | 目的 | 想定寿命 |
|---|---|---|
| Release Toggle | 未完成機能の隠蔽・段階的ロールアウト | 数日〜数週間 |
| Experiment Toggle | A/Bテスト | 実験終了まで（数週間〜数ヶ月） |
| Ops Toggle | 運用制御（負荷軽減など） | 中長期 |
| Kill Switch | 緊急時の機能無効化 | 永続的（常時存在） |
| Permission Toggle | ユーザー権限による機能制御 | 永続的 |

**出典:**
- [Feature Flagがもたらす「技術的負債」と「ライフサイクルマネジメント」 | Think IT](https://thinkit.co.jp/article/38925)
- [Feature Flagという開発手法についてまとめる - 電通総研 テックブログ](https://tech.dentsusoken.com/entry/2025/05/26/Feature_Flag%E3%81%A8%E3%81%84%E3%81%86%E9%96%8B%E7%99%BA%E6%89%8B%E6%B3%95%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6%E3%81%BE%E3%81%A8%E3%82%81%E3%82%8B)

---

## 5. 障害事例と教訓

### 5.1 Knight Capital事件（2012年）

ウォール街最大級の高頻度取引業者であったKnight Capitalは、Feature Flagの不適切な運用により30分間で4億6,500万ドル（約465億円）を失い、事実上倒産した。

- **フラグの再利用**: 廃止された旧コードを制御していたフラグを、新機能の制御に再利用した
- **不完全なデプロイ**: 8台のサーバーのうち7台へのデプロイは成功したが、1台がサイレントに失敗し旧コードが残存
- **フラグの再有効化で旧コード起動**: フラグをONにした結果、1台のサーバーで廃止済みのトレーディングロジックが起動
- **パニックによる二次被害**: 修正デプロイが逆にフラグを全8台でONにし、損害が拡大

**教訓:**
- フラグ名の再利用は絶対に避ける
- 不要になったコードはフラグごと完全に削除する
- デプロイ成否の検証を自動化する
- ロールバック手順を事前に整備し、パニック時に正しく対処できるようにする

**出典:**
- [When Feature Flags Go Wrong - InfoQ](https://www.infoq.com/articles/feature-flags-gone-wrong/)
- [Knightmare: A DevOps Cautionary Tale - Doug Seven](https://dougseven.com/2014/04/17/knightmare-a-devops-cautionary-tale/)
- [The Knight Capital Disaster | Speculative Branches](https://specbranch.com/posts/knight-capital/)

---

## 6. 大規模運用のベストプラクティス

### 6.1 Unleashの11原則

オープンソースFeature Flag管理プラットフォームUnleashは、大規模Feature Flagシステム構築のための11の原則を定義している。主要な原則は以下の通り。

1. **ランタイム評価**: フラグは静的な設定ではなく、実行時に動的に評価されるべき。アプリケーション再起動なしにフラグを切り替えられなければならない
2. **読み取りと書き込みの分離**: スケーラブルなシステムには、読み取りAPIと書き込みAPIを分離したアーキテクチャが必要
3. **フラグの短命化**: フラグには明確なオーナーと終了日を設定し、ロールアウト完了後は速やかに削除する
4. **単一評価パターン**: リクエストの開始時に一度だけフラグを評価し、その結果をシステム全体で受け渡す

**出典:**
- [11 principles for building and scaling feature flag systems | Unleash Documentation](https://docs.getunleash.io/topics/feature-flags/feature-flag-best-practices)
- [Feature flag management at scale: best practices | Unleash Documentation](https://docs.getunleash.io/topics/feature-flags/best-practices-using-feature-flags-at-scale)

### 6.2 技術的負債の管理

Feature Flagの最大のリスクは技術的負債の蓄積である。

- **組み合わせ爆発**: アクティブなフラグがn個あると、理論上のシステム状態数は2^n通りになる
- **放置されたフラグ**: 本来短命であるべきRelease ToggleやExperiment Toggleが長期間放置されるケースが技術的負債の主因
- **対策**: 定期的なフラグの棚卸し、自動検出（Toggle Point計測による未使用フラグの検出）、フラグ削除のCI/CD組み込み

**出典:**
- [Feature Flagがもたらす「技術的負債」と「ライフサイクルマネジメント」 | Think IT](https://thinkit.co.jp/article/38925)

### 6.3 セキュリティとガバナンス

- **RBAC（ロールベースアクセス制御）**: フラグの変更権限と閲覧権限を分離
- **監査ログ**: すべてのトグル操作を署名付きWebhookで記録
- **承認フロー**: 本番環境のフラグ変更に承認プロセスを設ける

**出典:**
- [大規模サービスを止めない Feature Flag 駆動移行の実践ガイド | colabmix](https://colabmix.co.jp/note/%E3%82%A2%E3%82%B8%E3%83%A3%E3%82%A4%E3%83%AB%E6%99%82%E4%BB%A3%E3%81%AE%E3%80%8Cfeature-flag%E9%A7%86%E5%8B%95%E7%A7%BB%E8%A1%8C%E3%80%8D%E5%AE%9F%E8%B7%B5%E3%83%8E%E3%83%BC%E3%83%88%E2%80%95/)

---

## 7. Feature Flag管理ツールの比較

大規模運用でよく利用されるツール・プラットフォームの概要を以下に示す。

| ツール | 種別 | 特徴 |
|---|---|---|
| LaunchDarkly | SaaS | 1日6兆回のフラグ評価を処理。IBMは週2回から1日100回以上のデプロイを達成 |
| Unleash | OSS / SaaS | 11の設計原則に基づくスケーラブルなアーキテクチャ。自社ホスティング可能 |
| Flagsmith | OSS / SaaS | オープンソースのFeature Flag＆Remote Config管理 |
| Bucketeer | 内製（サイバーエージェント） | Feature Flag＆A/Bテストプラットフォーム |
| Firebase Remote Config | SaaS（Google） | モバイルアプリ向け。パーソナライゼーションとA/Bテスト機能を統合 |
| OpenFeature | 標準仕様 | ベンダーロックインを防ぐためのオープンなFeature Flag API仕様 |

**出典:**
- [LaunchDarkly + Fastly case study | Fastly](https://www.fastly.com/customers/launchdarkly)
- [フィーチャーフラグ（Feature Flag）を実現する主要サービスの5つの紹介と比較 | CodeZine](https://codezine.jp/article/detail/14662)

---

## 8. 効果の定量的指標

Feature Flagの大規模導入により報告されている効果:

- **デプロイ関連インシデント89%削減**: Kill Switchとしてのフラグ活用による障害時の即時復旧
- **MTTR（平均復旧時間）3倍高速化**: フラグのOFF操作だけで機能を無効化できるため、コードリバートが不要
- **夜間・週末リリース97%削減**: デプロイとリリースの分離により、営業時間内でのリリースが可能に
- **デプロイ頻度300%増加**: フラグによるリスク低減が、より頻繁なデプロイを可能にする

**出典:**
- [Feature Flags and the Pursuit of Reliability in Large-Scale Software Systems | Medium](https://medium.com/mr-dops/feature-flags-and-the-pursuit-of-reliability-in-large-scale-software-systems-fea9d47a821a)
- [A Deeper Look at LaunchDarkly Architecture | LaunchDarkly](https://launchdarkly.com/docs/tutorials/ld-arch-deep-dive)

---

## 9. まとめ

大規模サービスにおけるFeature Flagの運用から得られる主要な知見は以下の通りである。

1. **デプロイとリリースの分離は必須**: Meta、Netflix、サイバーエージェントなど、大規模サービスは例外なくこの原則を採用している
2. **フラグの分類と寿命管理が技術的負債を防ぐ**: フラグの種類（Release / Experiment / Ops / Kill Switch / Permission）ごとに寿命を定め、不要になったフラグは速やかに削除する
3. **自動化がスケーラビリティの鍵**: フラグの棚卸し、未使用フラグの検出、コード生成の自動化により、数百〜数千のフラグを安全に管理できる
4. **Knight Capital事件が示す教訓**: フラグ名の再利用禁止、不要コードの完全削除、デプロイ検証の自動化は、致命的障害を防ぐために不可欠
5. **内製 vs SaaS の判断**: ユーザー規模10万以上やマルチリージョン要件がある場合、内製（サイバーエージェントのwings、newmoの基盤）やOSS（Unleash）のセルフホスティングが有力な選択肢になる
6. **OpenFeature標準の台頭**: ベンダーロックインを避けるため、OpenFeature仕様に準拠した実装が増えている
