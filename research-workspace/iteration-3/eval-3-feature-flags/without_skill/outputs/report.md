# 大規模サービスにおけるFeature Flagの運用事例

## 1. はじめに

Feature Flag（フィーチャーフラグ / フィーチャートグル）は、コードのデプロイと機能のリリースを分離するための手法である。大規模サービスでは、数千規模の実験を同時に実行し、段階的なロールアウトやA/Bテストを通じてプロダクトを改善するために不可欠な仕組みとなっている。

本レポートでは、Facebook、Netflix、Uber、サイバーエージェント、LINEなど、国内外の大規模サービスにおけるFeature Flagの運用事例と、運用上のベストプラクティス、技術的負債への対策、そして失敗事例から得られる教訓をまとめる。

---

## 2. 主要企業の運用事例

### 2.1 Facebook（Meta） - Gatekeeper

Facebookは「Gatekeeper」と呼ばれる内製のFeature Flag管理システムを構築している。

- **アーキテクチャ**: フラグの制御ロジックはコンフィグとして管理され、コードの再デプロイなしにWeb UIからリアルタイムに変更可能
- **Web UIによる操作**: グラフィカルなインターフェースで、if-then-else文の追加・削除、確率閾値の調整、制約パラメータの更新が可能
- **ターゲティング**: Facebook社員のみ、特定モバイルデバイスの1%のユーザーなど、きめ細かいロールアウト制御を実現
- **スケール**: ユーザーがfacebook.comにアクセスするたびにリアルタイムでGatekeeperプロジェクトがチェックされる。毎秒数十億回のチェックが発生し、フロントエンドクラスタ（数十万台のサーバー）の総CPU使用量のかなりの割合を消費している
- **開発文化**: エンジニアリングの変更はFeature Flagでラップされた状態で本番環境にプッシュされ、機能は「ライブだがオフ」の状態でデプロイされた後、Gatekeeperを通じて段階的に有効化される

**出典**: [Secret to Facebook's Hacker Engineering Culture | LaunchDarkly](https://launchdarkly.com/blog/secret-to-facebooks-hacker-engineering-culture/), [Rapid release at massive scale - Engineering at Meta](https://engineering.fb.com/2017/08/31/web/rapid-release-at-massive-scale/), [Holistic Configuration Management at Facebook (SOSP 2015)](https://sigops.org/s/conferences/sosp/2015/current/2015-Monterey/printable/008-tang.pdf)

### 2.2 Netflix - Experimentation Platform

Netflixは、UIの最適化からアルゴリズムの改善、インフラのパフォーマンスまで、あらゆる要素をA/Bテストする実験文化を持つ。

- **実験プラットフォーム**: 「ABlaze」と呼ばれるフロントエンドを持つExperimentation Platformを運用。実験の開始に必要な手順の自動化、分析レポートの自動生成、各フェーズの可視化を実現
- **実験の規模**: 年間数千の実験を同時実行。各ユーザーは常に複数のA/Bテストに参加しており、互いに矛盾しないよう管理される
- **セル設計**: 各メンバーは特定の実験内で1つのセルに排他的に属し、常に1つが「デフォルトセル」（コントロールグループ）として指定される
- **高度な分析**: 標準的なA/Bテストに加えて、contextual banditsやcounterfactualのログ記録を用いたオフライン実験など、より細粒度の因果推論フレームワークを開発
- **パーソナライゼーション**: ユーザーに表示されるアートワークは最大5つの異なるバリアントに対してテストされている

**出典**: [It's All A/Bout Testing: The Netflix Experimentation Platform | Netflix TechBlog](https://netflixtechblog.com/its-all-a-bout-testing-the-netflix-experimentation-platform-4e1ca458c15), [Experimentation is a major focus of Data Science across Netflix | Netflix TechBlog](https://netflixtechblog.com/experimentation-is-a-major-focus-of-data-science-across-netflix-f67923f8e985), [A/B Testing and Beyond | Netflix TechBlog](https://netflixtechblog.com/a-b-testing-and-beyond-improving-the-netflix-streaming-experience-with-experimentation-and-data-5b0ae9295bdf)

### 2.3 Uber - Piranha（自動フラグクリーンアップ）

Uberは大量のFeature Flagを運用する中で、古くなったフラグの技術的負債に対処するため「Piranha」を開発した。

- **課題**: 機能が100%ロールアウトされた後や実験が不成功に終わった後、コード内のFeature Flagは不要になるが放置されがちで、技術的負債となる
- **Piranhaの仕組み**: フラグ名、期待される動作、フラグ作成者の名前を入力として受け取り、プログラムのAST（抽象構文木）を分析して適切なリファクタリングを自動生成
- **自動パイプライン**: 毎週、フラグ管理システムに問い合わせて古くなったフラグのリストを取得し、各フラグに対してPiranhaを実行して差分（diff）を自動生成
- **成果**: 1381個のフラグ（総フラグの17%）に対してクリーンアップ用のdiffを生成。65%のdiffは変更なしでそのまま適用され、85%以上がコンパイル・テストに成功。開発者は生成されたdiffの88%以上を処理した。合計で約2000個の古いFeature Flagとその関連コードを削除
- **対応言語**: Objective-C、Java、Swift
- **学術発表**: ICSE 2020 (Software Engineering in Practice) で発表

**出典**: [Introducing Piranha: An Open Source Tool to Automatically Delete Stale Code | Uber Blog](https://www.uber.com/blog/piranha/), [GitHub - uber/piranha](https://github.com/uber/piranha), [Piranha: Reducing Feature Flag Debt at Uber (ICSE 2020)](https://conf.researchr.org/details/icse-2020/icse-2020-Software-Engineering-in-Practice/16/Piranha-Reducing-Feature-Flag-Debt-at-Uber)

### 2.4 サイバーエージェント - 内製Feature Flagsシステム / Bucketeer

サイバーエージェントでは、複数の事業・プロダクトを共通のコード資産で同時開発・運用するため、Feature Flagシステムを内製している。

- **マルチリージョン対応**: 汎用データ配信サーバーとしての設計思想でFeature Flagsシステムを開発
- **Bucketeer**: Feature FlagsとA/Bテストツールとして、OSSで開発されているプロダクト

**出典**: [マルチリージョンで稼働する内製Feature Flagsの実装 | CyberAgent Developers Blog](https://developers.cyberagent.co.jp/blog/archives/47225/)

### 2.5 LINEヤフー - OpenFeatureベースの新システム

LINE STOREチームでは、OpenFeatureのアーキテクチャ仕様に従ったFeature Flagシステムを新たに構築している。

- **OpenFeature準拠**: Flag Management System、Provider、Evaluation APIの3種類を実装
- **Central Dogma活用**: フラグの管理にCentral Dogmaを利用し、RxJavaを用いて非同期でフラグ設定ファイルを読み込み、常に最新の設定を取得

**出典**: [LINE STOREにおけるOpenFeatureを用いた新しいフィーチャーフラグシステムの開発 | LY Corporation Tech Blog](https://techblog.lycorp.co.jp/ja/20251203a)

---

## 3. Feature Flagの分類と用途

Feature Flagは一般的に以下の5種類に分類される。

| 種類 | 目的 | ライフサイクル |
|------|------|---------------|
| **Release Flag** | 未完成の機能を隠しながらトランクベース開発を実現 | 一時的（リリース完了後に削除） |
| **Experiment Flag** | A/Bテストによるデータ駆動の意思決定 | 一時的（実験終了後に削除） |
| **Ops Flag** | 運用上のシステム動作の制御 | 半永続的 |
| **Permission Flag** | 特定ユーザー・グループへの機能アクセス制御 | 永続的 |
| **Kill Switch** | 障害時の即座な機能無効化 | 永続的 |

**出典**: [11 principles for building and scaling feature flag systems | Unleash](https://docs.getunleash.io/guides/feature-flag-best-practices)

---

## 4. Kill Switch（キルスイッチ）とインシデント対応

Kill Switchは、Feature Flagの中でも特に重要な運用パターンである。

- **定義**: 通常のFeature Flagの逆で、「オンにすると機能を無効化」するフラグ。デフォルトでは機能は正常に動作し、問題発生時にトリガーされると機能がユーザー体験から除外される
- **要件**: リモート呼び出しなしで即時評価できること、安全な状態（機能オフ）にデフォルトすること、コード変更なしでオンコールエンジニアがアクセスできること
- **モニタリング連携**: アラートシステムと統合し、エラー率が上昇した際に関連するKill Switchへの直接リンクを含むアラートを自動送信
- **効果**: Feature Flagを用いたプログレッシブデリバリーにより、本番インシデントを70-90%削減できるとされている

**出典**: [Feature Flags as Kill Switches: Fast Incident Mitigation](https://upstat.io/blog/feature-flags-kill-switches), [What is a kill switch in software development? | Unleash](https://www.getunleash.io/blog/kill-switches-best-practice), [Using Feature Flags for Effective Incident Management | Harness](https://www.harness.io/blog/using-feature-flags-for-effective-incident-management)

---

## 5. 技術的負債とクリーンアップ戦略

大規模サービスでFeature Flagを運用すると、古くなったフラグが技術的負債として蓄積する問題が必ず発生する。

### 5.1 古いフラグがもたらすリスク

- コードの複雑化と保守性の低下
- セキュリティ脆弱性（意図しない機能やデータの露出）
- 予期しないアプリケーション動作とダウンタイムリスクの増大
- アプリの肥大化とパフォーマンス低下

### 5.2 クリーンアップのベストプラクティス

1. **作成時に有効期限を設定**: 「いつか」ではなく、具体的なカレンダー日付を設定する
2. **一時的/永続的のタグ付け**: フラグ作成時に分類し、一時的フラグには有効期限とクリーンアップ計画を設定
3. **Definition of Doneへの組み込み**: フラグの削除を完了の定義に含める
4. **自動検出とクリーンアップ**: Uberの Piranha のようなツールでCI/CDパイプラインに統合
5. **定期的な監査**: 四半期ごとの監査の実施。X日以上古いフラグのビルド失敗を自動化する手法も
6. **チケット管理ツールとの連携**: 30日以上状態が変更されていないフラグをクエリで検出
7. **定期的なフラグ削除デー**: チームで定期的にフラグレビューの日を設ける

### 5.3 運用規模の目安

健全なSaaSコードベースでは、**サービスごとのアクティブフラグ数を20-30個以下**に維持することが推奨されている。

**出典**: [The Complete Guide to Managing Feature Flag Technical Debt | FlagShark](https://flagshark.com/blog/feature-flag-technical-debt-guide/), [Managing Tech Debt by Cleaning Up Unused Flags | DevCycle](https://docs.devcycle.com/best-practices/tech-debt/), [Reducing technical debt from feature flags | LaunchDarkly](https://launchdarkly.com/docs/guides/flags/technical-debt), [Managing Feature Flag Technical Debt | Unleash](https://docs.getunleash.io/concepts/technical-debt)

---

## 6. 失敗事例: Knight Capital Group（2012年）

Feature Flagの不適切な運用が壊滅的な結果を招いた事例として、Knight Capital Groupの事件がある。

### 事件の概要

2012年8月1日、米国の大手取引会社であるKnight Capital Group（当時、米国株式取引の約10%を担当）が、ソフトウェア障害により**45分間で4億6000万ドル（約460億円）の損失**を被った。

### 原因

1. **Feature Flagの再利用**: 新しいRLPコードが、廃止された「Power Peg」機能に使われていた古いフラグを再利用した
2. **デプロイミス**: 8台のSMARSサーバーのうち1台に新しいコードがコピーされなかった
3. **死んだコードの放置**: 不要になったPower Pegのコードが何年も本番環境に残存していた
4. **自動化の欠如**: デプロイ手順の文書化やピアレビューの義務付けがなく、自動デプロイツールも不在
5. **インシデント対応の不備**: インシデント対応の文書化された手順がなく、フラグをオフにするという対応に思い至らなかった。結果、ロールバック時に全サーバーでレガシーコードが実行され、損失が拡大

### 教訓

- Feature Flagを再利用してはならない
- 不要になったFeature Flagと関連コードは速やかに削除する
- デプロイは自動化し、ピアレビューを義務付ける
- インシデント対応手順を文書化し、Kill Switchの利用を含めた訓練を行う

**出典**: [When Feature Flags Go Wrong - InfoQ](https://www.infoq.com/articles/feature-flags-gone-wrong/), [The Knight Capital Disaster | Speculative Branches](https://specbranch.com/posts/knight-capital/), [Knightmare: A DevOps Cautionary Tale - Doug Seven](https://dougseven.com/2014/04/17/knightmare-a-devops-cautionary-tale/)

---

## 7. 標準化の動向: OpenFeature

Feature Flagのエコシステムが拡大する中、ベンダーロックインを避けるための標準化が進んでいる。

- **OpenFeature**: ベンダー非依存でコミュニティ主導のFeature Flagging APIの仕様
- **CNCFステータス**: 2022年6月にCNCFに採択、2023年11月にIncubatingレベルに昇格
- **SDK対応**: .NET、Java、PHP、Python、JavaScript、Go、Rubyなど多数の言語に対応
- **新標準の策定**: リモートフラグ評価のためのワイヤプロトコル「OFREP (OpenFeature Remote Evaluation Protocol)」や、標準フラグ定義フォーマットの策定も進行中

**出典**: [OpenFeature](https://openfeature.dev/), [OpenFeature | CNCF](https://www.cncf.io/projects/openfeature/), [OpenFeature becomes a CNCF incubating project](https://www.cncf.io/blog/2023/12/19/openfeature-becomes-a-cncf-incubating-project/)

---

## 8. 2025-2026年のトレンド

- **AI駆動のフラグ管理**: 古いフラグの自動検出、クリーンアップコードの自動生成、フラグの影響分析のAI化
- **サーバーサイドフラグの重視**: クライアントサイドよりも制御性が高く、セキュリティリスクが低いサーバーサイド評価への移行
- **CI/CDパイプラインとの深い統合**: デプロイパイプラインにフラグのライフサイクル管理を組み込む
- **よりきめ細かいターゲティング**: ユーザー行動やデモグラフィクスに基づく精密なセグメンテーション
- **動的管理**: フラグのリアルタイム調整とモニタリングの統合

**出典**: [Feature Flags Best Practices: Complete Guide (2026) | DesignRevision](https://designrevision.com/blog/feature-flags-best-practices), [Understanding Feature Flags in 2025 | NudgeNow](https://www.nudgenow.com/blogs/feature-flag-benefits-best-practices), [Tired of Cleaning Up Stale Feature Flags? Let AI Do the Work! | Unleash](https://www.getunleash.io/blog/ai-flag-cleanup)

---

## 9. まとめ

| 観点 | ポイント |
|------|---------|
| **スケール** | Facebook、Netflix、Uber等は数千規模のフラグを運用。毎秒数十億回のフラグ評価が発生するケースも |
| **組織文化** | トランクベース開発と実験文化がFeature Flag運用の前提。Google、Facebookが実践 |
| **技術的負債** | 最大の課題。有効期限の設定、自動クリーンアップ（Piranha等）、定期監査が必須 |
| **インシデント対応** | Kill Switchは永続的なフラグとして維持し、即座に機能無効化できる体制を構築 |
| **標準化** | OpenFeatureによるベンダー非依存の標準APIが普及しつつある |
| **失敗からの教訓** | Knight Capital事件に見られるように、フラグの再利用禁止・死んだコードの除去・デプロイ自動化が重要 |

大規模サービスにおけるFeature Flagの運用は、単なる技術的な仕組みではなく、開発文化・組織プロセス・自動化・ガバナンスを含む包括的な取り組みである。適切に運用すればリリースの安全性と速度を大幅に向上させるが、管理を怠ると技術的負債や重大インシデントのリスクとなる。
