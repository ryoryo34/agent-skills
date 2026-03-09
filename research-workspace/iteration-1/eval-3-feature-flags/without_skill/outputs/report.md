# 大規模サービスにおけるFeature Flagの運用事例

## 1. Feature Flagとは

Feature Flag（Feature Toggle）は、コードのデプロイとリリースを分離し、特定の機能の有効/無効をランタイムで制御する手法である。大規模サービスでは、安全なリリース、A/Bテスト、段階的ロールアウト、障害時の即時切り戻しなど、多様な目的で活用されている。

## 2. Feature Flagの分類（Martin Fowlerモデル）

Pete Hodgsonが[Martin Fowlerのサイト](https://martinfowler.com/articles/feature-toggles.html)で体系化した分類は、大規模運用における設計指針として広く参照されている。

| 種類 | 目的 | 寿命 | 動的切替 |
|------|------|------|----------|
| **Release Toggle** | 未完成機能の隠蔽、トランクベース開発の実現 | 短期（数日〜数週間） | デプロイ時 |
| **Experiment Toggle** | A/Bテスト、多変量テスト | 中期（数週間〜数ヶ月） | リクエスト単位 |
| **Ops Toggle** | 運用制御、負荷対策、Kill Switch | 長期（恒久的な場合も） | リアルタイム |
| **Permission Toggle** | ユーザー属性に基づく機能制御（ベータユーザー等） | 長期 | リクエスト単位 |

この分類に基づいてフラグを管理することで、ライフサイクルの管理方針や削除タイミングを明確にできる。

## 3. 海外大手企業の運用事例

### 3.1 Netflix：大規模A/Bテスト基盤

Netflixは年間数千件のA/Bテストを実施しており、Feature Flagはその中核インフラとなっている。

- **Experimentation Platform**という専門チームがA/Bテスト基盤を構築・運用し、各開発チームが自律的に実験を実行できる環境を提供している
- ユーザーは常に複数のA/Bテストに同時参加しており、テスト間の競合を防ぐ仕組みが実装されている
- ストリーミング関連の実験は短期間で大量に実施されるため、ワークフローの自動化に投資している
- UIの表示内容、読み込み速度、コンテンツ推薦アルゴリズムなど、あらゆる要素をフラグで制御しA/Bテストを実施

出典: [It's All A/Bout Testing: The Netflix Experimentation Platform - Netflix TechBlog](https://netflixtechblog.com/its-all-a-bout-testing-the-netflix-experimentation-platform-4e1ca458c15)

### 3.2 Facebook（Meta）：トランクベース開発の実現

Facebookは毎日本番環境にコードをデプロイしており、Feature Flagによってデプロイとリリースを完全に分離している。

- 数千のFeature Flagを同時に運用
- コードは常にmainブランチにマージされ、Feature Flagで機能の可視性を制御
- 1日に数千回のデプロイを行いながらシステムの安定性を維持

出典: [Adopt the 10,000 Experiment Rule Like Netflix and Facebook - DevCycle](https://devcycle.com/blog/adopt-the-10-000-experiment-rule-like-netflix-and-facebook)

### 3.3 Uber：Piranhaによる自動クリーンアップ

Uberは、Feature Flagの技術的負債を自動的に解消するオープンソースツール「Piranha」を開発・公開している。

- **課題**: 大量のFeature Flagが使用後も放置され、コードベースに不要な分岐が蓄積
- **解決策**: Piranhaが静的解析により以下を自動実行:
  1. Feature Flag APIの呼び出しコードを削除
  2. 不要になった到達不能コードを削除
  3. 関連するテストコードを削除
- **運用フロー**: 週次でPiranhaが差分を自動生成し、フラグの作成者にPull Requestをアサイン。リマインダーBot「PiranhaTidy」が未対応タスクを定期通知
- **成果**: Android/iOSコードベースから約2,000件の古いFeature Flagと関連コードを削除
- Java、Swift、Objective-Cに対応

出典: [Introducing Piranha: An Open Source Tool to Automatically Delete Stale Code - Uber Blog](https://www.uber.com/blog/piranha/)、[GitHub - uber/piranha](https://github.com/uber/piranha)

### 3.4 LaunchDarkly：Feature Flag管理SaaSの大規模運用

Feature Flag管理プラットフォームのLaunchDarklyは、そのインフラ規模自体が大規模Feature Flag運用の参考になる。

- 1日あたり最大25兆回のFeature Flag評価を処理
- 1,400万のモバイルデバイス・ブラウザ、400万のサーバーにフラグを配信
- Fastlyのエッジクラウドを活用し、フラグ変更時にミリ秒単位でキャッシュをパージ
- 顧客は夜間・週末リリースを97%削減しつつ、本番デプロイ頻度を300%向上（2020〜2023年）

出典: [LaunchDarkly + Fastly case study - Fastly](https://www.fastly.com/customers/launchdarkly)

## 4. 日本企業の運用事例

### 4.1 サイバーエージェント：マルチリージョン対応の内製Feature Flags「wings」

サイバーエージェントは、海外展開するプロダクトにおけるFeature Flags運用の課題を解決するため、内製システム「wings」を構築した。

- **課題**: 既存SaaS（Bucketeerなど）ではマルチリージョンのレプリケーションに対応できず、アメリカのユーザーに対して600msの遅延が発生
- **設計思想**: 単なるON/OFF切替ではなく、柔軟な条件記述が可能な「汎用データ配信サーバー」として設計
- **成果**: マルチリージョンでのパフォーマンスと条件判定の柔軟性を両立し、1年以上の本番運用実績

さらに、別のプロダクトでもFeature Flagツールを内製化し、トランクベース開発を実現している。

出典: [マルチリージョンで稼働する内製Feature Flagsの実装 - CyberAgent Developers Blog](https://developers.cyberagent.co.jp/blog/archives/47225/)、[FeatureFlagツール内製化で実現するトランクベース開発 - CyberAgent Developers Blog](https://developers.cyberagent.co.jp/blog/archives/55358/)

## 5. 障害事例：Knight Capital Group（4億6,000万ドルの損失）

Feature Flagの不適切な管理がもたらす最悪のケースとして、2012年のKnight Capital Groupの事例が広く知られている。

- **背景**: 古い「Power Peg」というコードが無効化された状態で長年残存。新機能の実装時にそのFeature Flagを再利用
- **原因**: 8台のSMARSサーバーのうち1台に新しいコードがデプロイされず、古いフラグが意図せず有効化された
- **結果**: 45分間で4億6,000万ドルの損失が発生し、NYSE取引量の17%を扱っていた企業が事実上破綻
- **教訓**:
  - 古いFeature Flagは必ず削除する
  - フラグ名の再利用は禁止する
  - デプロイの一貫性を保証する仕組みが必要

出典: [The $460 Million Feature Flag: Why Every Stale Flag Is a Ticking Time Bomb - FlagShark](https://flagshark.com/blog/460-million-dollar-feature-flag-knight-capital/)、[Knightmare: A DevOps Cautionary Tale - Doug Seven](https://dougseven.com/2014/04/17/knightmare-a-devops-cautionary-tale/)

## 6. 大規模運用のベストプラクティス

### 6.1 ライフサイクル管理

- フラグ作成時に**有効期限**を設定する（「いつか」ではなく具体的な日付）
- 機能リリース完了時のフラグ削除作業を、開発スケジュールに組み込む
- 月次または四半期ごとの「Flag Cleanup Day」を設定し、チーム全体で棚卸しを実施

出典: [Feature flag management at scale: best practices - Unleash](https://docs.getunleash.io/topics/feature-flags/best-practices-using-feature-flags-at-scale)

### 6.2 コード品質の維持

- Feature Flagはリクエストごとに1回だけ評価し、結果を下流に渡す（重複評価を避ける）
- ネストしたフラグ構造を避ける（親フラグ配下に子フラグを置く構造は、誤設定のリスクを増大させる）
- フラグに**人間が読める名前**を付与し、管理を容易にする

出典: [11 principles for building and scaling feature flag systems - Unleash](https://docs.getunleash.io/guides/feature-flag-best-practices)

### 6.3 セキュリティとアクセス制御

- Feature FlagのスイッチはIAM/RBACで権限を分離する
- クライアントサイドのフラグはユーザーに可視化されるリスクがあるため、機密性の高いロジックはサーバーサイドで制御する
- 変更ログをWORMストレージに保存し、改ざんを防止する

出典: [大規模サービスを止めないFeature Flag駆動移行の実践ガイド - colabmix](https://colabmix.co.jp/note/%E3%82%A2%E3%82%B8%E3%83%A3%E3%82%A4%E3%83%AB%E6%99%82%E4%BB%A3%E3%81%AE%E3%80%8Cfeature-flag%E9%A7%86%E5%8B%95%E7%A7%BB%E8%A1%8C%E3%80%8D%E5%AE%9F%E8%B7%B5%E3%83%8E%E3%83%BC%E3%83%88%E2%80%95/)

### 6.4 障害対応と運用効率

- Kill Switchとして活用し、問題発生時に即座にフラグをOFFにして影響を限定する
- Feature Flag導入組織はデプロイ起因のインシデントを89%削減、平均復旧時間（MTTR）を3倍高速化したという報告がある

出典: [Feature Flags Best Practices - Harness](https://www.harness.io/blog/feature-flags-best-practices)

### 6.5 ツール選定の指針

| 観点 | SaaS（LaunchDarkly等） | 自社ホスティング（Unleash等） |
|------|----------------------|---------------------------|
| 月額コスト | 20〜50万円程度 | 3〜5万円程度 |
| ユーザー数5万未満 | 有利 | - |
| ユーザー数10万以上 | - | IaC自動化と組み合わせて有利 |
| 運用負荷 | 低い | 高い（インフラ管理が必要） |

出典: [大規模サービスを止めないFeature Flag駆動移行の実践ガイド - colabmix](https://colabmix.co.jp/note/%E3%82%A2%E3%82%B8%E3%83%A3%E3%82%A4%E3%83%AB%E6%99%82%E4%BB%A3%E3%81%AE%E3%80%8Cfeature-flag%E9%A7%86%E5%8B%95%E7%A7%BB%E8%A1%8C%E3%80%8D%E5%AE%9F%E8%B7%B5%E3%83%8E%E3%83%BC%E3%83%88%E2%80%95/)

## 7. まとめ

大規模サービスにおけるFeature Flag運用の要点は以下の通りである。

1. **分類と方針の明確化**: フラグを種類別に分類し、それぞれにライフサイクル管理方針を定める
2. **デプロイとリリースの分離**: Netflix、Facebook、サイバーエージェントなどが実践するトランクベース開発の基盤として活用
3. **技術的負債の自動管理**: Uberの Piranhaのように、古いフラグの検出・削除を自動化する仕組みを構築
4. **障害からの学習**: Knight Capital事例のように、フラグの放置が壊滅的な結果を招きうることを認識し、厳格な運用ルールを設定
5. **スケールに応じたツール選定**: ユーザー規模や要件に応じて、SaaSと自社ホスティングを使い分ける

---

## Sources

- [Feature Toggles (aka Feature Flags) - Martin Fowler](https://martinfowler.com/articles/feature-toggles.html)
- [It's All A/Bout Testing: The Netflix Experimentation Platform - Netflix TechBlog](https://netflixtechblog.com/its-all-a-bout-testing-the-netflix-experimentation-platform-4e1ca458c15)
- [Adopt the 10,000 Experiment Rule Like Netflix and Facebook - DevCycle](https://devcycle.com/blog/adopt-the-10-000-experiment-rule-like-netflix-and-facebook)
- [Introducing Piranha: An Open Source Tool to Automatically Delete Stale Code - Uber Blog](https://www.uber.com/blog/piranha/)
- [GitHub - uber/piranha](https://github.com/uber/piranha)
- [LaunchDarkly + Fastly case study - Fastly](https://www.fastly.com/customers/launchdarkly)
- [マルチリージョンで稼働する内製Feature Flagsの実装 - CyberAgent Developers Blog](https://developers.cyberagent.co.jp/blog/archives/47225/)
- [FeatureFlagツール内製化で実現するトランクベース開発 - CyberAgent Developers Blog](https://developers.cyberagent.co.jp/blog/archives/55358/)
- [The $460 Million Feature Flag: Why Every Stale Flag Is a Ticking Time Bomb - FlagShark](https://flagshark.com/blog/460-million-dollar-feature-flag-knight-capital/)
- [Knightmare: A DevOps Cautionary Tale - Doug Seven](https://dougseven.com/2014/04/17/knightmare-a-devops-cautionary-tale/)
- [Feature flag management at scale: best practices - Unleash](https://docs.getunleash.io/topics/feature-flags/best-practices-using-feature-flags-at-scale)
- [11 principles for building and scaling feature flag systems - Unleash](https://docs.getunleash.io/guides/feature-flag-best-practices)
- [Feature Flags Best Practices - Harness](https://www.harness.io/blog/feature-flags-best-practices)
- [大規模サービスを止めないFeature Flag駆動移行の実践ガイド - colabmix](https://colabmix.co.jp/note/%E3%82%A2%E3%82%B8%E3%83%A3%E3%82%A4%E3%83%AB%E6%99%82%E4%BB%A3%E3%81%AE%E3%80%8Cfeature-flag%E9%A7%86%E5%8B%95%E7%A7%BB%E8%A1%8C%E3%80%8D%E5%AE%9F%E8%B7%B5%E3%83%8E%E3%83%BC%E3%83%88%E2%80%95/)
- [Feature Flagという開発手法についてまとめる - 電通総研テックブログ](https://tech.dentsusoken.com/entry/2025/05/26/Feature_Flag%E3%81%A8%E3%81%84%E3%81%86%E9%96%8B%E7%99%BA%E6%89%8B%E6%B3%95%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6%E3%81%BE%E3%81%A8%E3%82%81%E3%82%8B)
