# Research Report: 大規模サービスでの Feature Flag の運用事例

## Executive Summary

Feature Flag（Feature Toggle）は、Netflix、Google、Meta、Uber、Amazon といった大規模サービスにおいて、安全なデプロイ・段階的ロールアウト・A/B テストの基盤技術として広く採用されている。運用上の最大の課題は「フラグの技術的負債（stale flag の蓄積）」であり、Uber の Piranha のような自動クリーンアップツールや、組織的なライフサイクル管理が不可欠である。Knight Capital の4.6億ドル損失事件が示すように、フラグの誤運用は壊滅的な障害を引き起こしうる。

## Findings

### 1. Feature Toggle の4分類フレームワーク（Fowler/Hodgson モデル）

Pete Hodgson が Martin Fowler のサイトで体系化した Feature Toggle の分類は、大規模運用の基盤となる考え方である。トグルを「寿命の長さ」と「切り替えの動的さ」の2軸で4種類に分類する：

- **Release Toggles**: 未完成の機能を本番にデプロイしつつ無効化しておく（短寿命）
- **Experiment Toggles**: A/B テスト用。ユーザーセグメントごとに異なる体験を提供（中寿命）
- **Ops Toggles**: 運用チームがシステム挙動を制御するためのスイッチ（長寿命の場合あり）
- **Permission Toggles**: 特定ユーザー群への機能アクセス制御（長寿命）

この分類に基づき、トグルの管理戦略（保存場所、変更頻度、テスト方針）を決定すべきとされる。また、トグルポイントはエントリーポイントに限定し、ビジネスロジック全体にフラグ分岐を入れないことが推奨される。

**Sources:**
- [B] Pete Hodgson (martinfowler.com), "Feature Toggles (aka Feature Flags)", https://martinfowler.com/articles/feature-toggles.html, 2017-10
- [B] Martin Fowler, "bliki: Feature Flag", https://martinfowler.com/bliki/FeatureFlag.html, 2017

### 2. Netflix の大規模実験プラットフォーム

Netflix は Feature Flag を実験基盤（Experimentation Platform）と密接に統合して運用している。同社の A/B テストプラットフォーム「ABlaze」では、各ユーザーが同時に複数の A/B テストに参加し、UI デザイン、パーソナライズされたレコメンデーション、コンテンツプロモーション、アートワーク選定など、サービスのあらゆる側面が実験対象となる。

テスト間の競合（同一 UI 領域を異なるテストが変更する場合）を検出するスケジュールビューを提供し、大規模な並行実験を安全に運用している。Netflix の実験文化は「あらゆるプロダクト変更は A/B テストを経てからデフォルト体験になる」というポリシーに基づいている。

**Sources:**
- [S] Netflix Technology Blog, "It's All A/Bout Testing: The Netflix Experimentation Platform", https://netflixtechblog.com/its-all-a-bout-testing-the-netflix-experimentation-platform-4e1ca458c15, 2016-04
- [S] Netflix Technology Blog, "Experimentation is a major focus of Data Science across Netflix", https://netflixtechblog.com/experimentation-is-a-major-focus-of-data-science-across-netflix-f67923f8e985, 2020-01

### 3. Google Chrome の Finch（Field Trials）による段階的ロールアウト

Google Chrome は「Finch」と呼ばれる Field Trials プラットフォームを通じて、Feature Flag をサーバーサイドで動的に制御している。Chrome は定期的にサーバーから設定ファイルを取得し、機能の有効/無効をランタイムで切り替える。

主な用途は2つ：**実験（Experimentation）** と **機能ロールアウト（Feature Rollout）** である。実験では実験群と対照群を作成し、テレメトリを比較する。ロールアウトでは新機能を少数のユーザーに段階的に有効化し、テレメトリやユーザーフィードバックを監視しながら、問題があれば即座に0%に戻すか、100%に拡大する。

互換性の問題を引き起こしうる機能でも、Finch を使えば迅速に無効化できるため、安全にリリースできる。ただし、開発者向けのプラットフォーム変更には段階的 Finch ロールアウトではなくウォーターフォール型ロールアウトが推奨されている。

**Sources:**
- [S] Chrome for Developers, "What is a Chrome Finch experiment?", https://developer.chrome.com/docs/web-platform/chrome-finch, 2024
- [S] Chromium Docs, "Chromium Flag Guarding Guidelines", https://chromium.googlesource.com/chromium/src/+/main/docs/flag_guarding_guidelines.md, Date unknown
- [S] Chrome for Developers, "What are Chrome flags?", https://developer.chrome.com/docs/web-platform/chrome-flags, 2024

### 4. Uber の Piranha：Feature Flag の技術的負債を自動解消

Uber は Feature Flag のクリーンアップ問題に対して、静的解析ベースの自動リファクタリングツール「Piranha」を開発・公開した。Piranha は以下の3ステップでコードを自動削除する：

1. Feature Flag API 呼び出し周辺のコード削除
2. 上記の結果到達不能になったコードの削除
3. 関連するテストコードの削除

Uber 社内では週次の自動パイプラインで stale flag を検出し、コードレビュー用の diff を自動生成する。フラグの元の作成者がデフォルトのレビュアーとなり、diff の承認・修正・却下を判断する。

**実績（2017年12月〜2019年5月）：** 全フラグの17%にあたる1,381フラグのクリーンアップ diff を生成。65%は変更なしでそのまま承認され、88%以上がコンパイル・テスト成功。この成果は ICSE 2020（ソフトウェア工学のトップ会議）で発表された。

**Sources:**
- [S] Uber Engineering Blog, "Introducing Piranha: An Open Source Tool to Automatically Delete Stale Code", https://www.uber.com/blog/piranha/, 2022-10
- [S] Ramanathan et al., "Piranha: Reducing Feature Flag Debt at Uber", ICSE-SEIP 2020, https://dl.acm.org/doi/10.1145/3377813.3381350, 2020-05
- [A] InfoQ, "How Uber Deals with Unreachable Code Associated to Feature Flags in its Mobile Apps", https://www.infoq.com/news/2020/04/uber-piranha-unreachable-code/, 2020-04

### 5. Amazon/AWS の Feature Flag 運用と AWS AppConfig

AWS re:Invent 2025 で Steve Rice（AWS AppConfig & Parameter Store GM）と Ben Shumpert（Senior SDE）が、Amazon 内部での Feature Flag 大規模運用事例を紹介した。

典型的なパターンとして：新機能のコードを事前にデプロイしておき、フラグで無効化。1% → 10% → 20%と段階的に有効化し、問題発生時は即座にロールバック。re:Invent の発表週では、新機能は数週間前にデプロイ済みだが Feature Flag で隠されており、経営幹部がキーノートで機能を発表するタイミングでエンジニアがフラグを切り替えて公開する。

AWS AppConfig はデプロイ戦略（段階的 or 即時）と CloudWatch アラーム連動による自動ロールバックを提供し、Lambda Layer・コンテナイメージ・RPM など複数のプラットフォームで動作する。

**Sources:**
- [S] AWS (dev.to), "DEV Track Spotlight: Advanced feature flags: Faster releases and rapid recovery (DEV320)", https://dev.to/aws/dev-track-spotlight-advanced-feature-flags-faster-releases-and-rapid-recovery-dev320-4k5i, 2025-12
- [S] AWS Cloud Operations Blog, "Using AWS AppConfig Feature Flags", https://aws.amazon.com/blogs/mt/using-aws-appconfig-feature-flags/, 2022

### 6. Meta/Facebook の実験インフラと Statsig への継承

Meta は社内で10,000以上のアクティブな Feature Flag を運用し、トランクベース開発を実践して1日に数千回のデプロイを行っている。新機能はまず少数のユーザーグループにリリースし、問題がないことを確認してから段階的に拡大する。

元 Facebook VP の Vijaye Raji は、社外の企業が Facebook の実験インフラ（Deltoid、Scuba 等）を再構築する困難さを見て、2021年に Statsig を創業。Facebook 内部の実験基盤を外部向けに再構築した。Statsig は1日1兆以上のイベントを処理し、99.99%のアップタイムとサブミリ秒のフラグ評価レイテンシを実現。2025年9月に OpenAI が約11億ドルで買収した。

**Sources:**
- [A] Statsig, "Implementing feature flags at scale", https://www.statsig.com/perspectives/implementing-feature-flags-at-scale, 2024
- [A] OpenAI, "Vijaye Raji to become CTO of Applications with acquisition of Statsig", https://openai.com/index/vijaye-raji-to-become-cto-of-applications-with-acquisition-of-statsig/, 2025-09

### 7. Knight Capital 事件：Feature Flag 誤運用による4.6億ドル損失

2012年、Knight Capital が Feature Flag の誤運用により30分間で約4.6億ドルの損失を出した事件は、Feature Flag 運用のアンチパターンの象徴として知られる。

問題の連鎖：
1. **フラグの再利用**: 新しいプロジェクトに既存のフラグ名を再利用した
2. **デッドコードの放置**: 旧機能のコードが削除されずに残っていた
3. **ロールバック困難**: フラグのオフにデプロイが必要で、即座に切り替えできなかった

結果として、フラグ切り替え時に8台中1台のサーバーで旧コードが意図せず実行され、パニック状態でのデプロイが全8台に問題を拡大させた。この事例は、フラグの再利用禁止・stale code の削除・デプロイ非依存のフラグ切り替え機構の重要性を示している。

**Sources:**
- [A] InfoQ, "When Feature Flags Go Wrong", https://www.infoq.com/articles/feature-flags-gone-wrong/, 2019
- [B] Henrico Dolfing, "Case Study 4: The $440 Million Software Error at Knight Capital", https://www.henricodolfing.com/2019/06/project-failure-case-study-knight-capital.html, 2019-06
- [A] Statsig Blog, "How to lose half a billion dollars with bad feature flags", https://blog.statsig.com/how-to-lose-half-a-billion-dollars-with-bad-feature-flags-ccebb26adeec, 2023

### 8. 大規模運用における共通のベストプラクティス

複数の事例から浮かび上がる共通のベストプラクティス：

- **オーナーシップと有効期限の設定**: フラグ作成時にオーナーと有効期限を明示的に設定する
- **命名規約の統一**: `OLD_SWITCH_ULNG` のような不明瞭な名前を避け、チーム横断で理解可能な名前にする
- **中央管理 UI の導入**: 設定ファイルではなく専用 UI でフラグを管理し、デプロイなしで切り替え可能にする
- **定期的なクリーンアップ**: スプリントごとに1ストーリー、または四半期ごとに1スプリントをフラグ削除に充てる
- **フラグの分離**: Feature Flag システムを汎用的な設定管理（API タイムアウト、レートリミット等）に流用しない
- **段階的ロールアウト**: 1% → 10% → 50% → 100% のようなリング型デプロイで監視しながら拡大する

**Sources:**
- [B] Pete Hodgson (martinfowler.com), "Feature Toggles (aka Feature Flags)", https://martinfowler.com/articles/feature-toggles.html, 2017-10
- [A] InfoQ, "When Feature Flags Go Wrong", https://www.infoq.com/articles/feature-flags-gone-wrong/, 2019
- [A] Harness, "5 Common Challenges When Using Feature Flags", https://www.harness.io/blog/feature-flags-challenges, 2023
- [A] Flagsmith, "Build vs. Buy for Feature Flags: My Experience as a CTO", https://www.flagsmith.com/blog/build-vs-buy-feature-flags-experience-as-a-cto, 2024

## Source Reliability Summary

| Tier | Count | Notes |
|------|-------|-------|
| S    | 8     | 公式エンジニアリングブログ（Netflix, Uber, AWS, Google Chrome）、トップ学会論文（ICSE 2020） |
| A    | 6     | 大手テックメディア（InfoQ）、主要 SaaS 企業ブログ（Statsig, Harness, Flagsmith）、OpenAI 公式発表 |
| B    | 3     | 著名プラクティショナー（Martin Fowler サイト、Henrico Dolfing） |

## Source List

1. [S] Netflix Technology Blog, "It's All A/Bout Testing: The Netflix Experimentation Platform", https://netflixtechblog.com/its-all-a-bout-testing-the-netflix-experimentation-platform-4e1ca458c15, 2016-04
2. [S] Netflix Technology Blog, "Experimentation is a major focus of Data Science across Netflix", https://netflixtechblog.com/experimentation-is-a-major-focus-of-data-science-across-netflix-f67923f8e985, 2020-01
3. [S] Chrome for Developers, "What is a Chrome Finch experiment?", https://developer.chrome.com/docs/web-platform/chrome-finch, 2024
4. [S] Chromium Docs, "Chromium Flag Guarding Guidelines", https://chromium.googlesource.com/chromium/src/+/main/docs/flag_guarding_guidelines.md, Date unknown
5. [S] Chrome for Developers, "What are Chrome flags?", https://developer.chrome.com/docs/web-platform/chrome-flags, 2024
6. [S] Uber Engineering Blog, "Introducing Piranha: An Open Source Tool to Automatically Delete Stale Code", https://www.uber.com/blog/piranha/, 2022-10
7. [S] Ramanathan et al., "Piranha: Reducing Feature Flag Debt at Uber", ICSE-SEIP 2020, https://dl.acm.org/doi/10.1145/3377813.3381350, 2020-05
8. [S] AWS (dev.to), "DEV Track Spotlight: Advanced feature flags: Faster releases and rapid recovery (DEV320)", https://dev.to/aws/dev-track-spotlight-advanced-feature-flags-faster-releases-and-rapid-recovery-dev320-4k5i, 2025-12
9. [A] InfoQ, "When Feature Flags Go Wrong", https://www.infoq.com/articles/feature-flags-gone-wrong/, 2019
10. [A] InfoQ, "How Uber Deals with Unreachable Code Associated to Feature Flags in its Mobile Apps", https://www.infoq.com/news/2020/04/uber-piranha-unreachable-code/, 2020-04
11. [A] Statsig, "Implementing feature flags at scale", https://www.statsig.com/perspectives/implementing-feature-flags-at-scale, 2024
12. [A] OpenAI, "Vijaye Raji to become CTO of Applications with acquisition of Statsig", https://openai.com/index/vijaye-raji-to-become-cto-of-applications-with-acquisition-of-statsig/, 2025-09
13. [A] Harness, "5 Common Challenges When Using Feature Flags", https://www.harness.io/blog/feature-flags-challenges, 2023
14. [A] Flagsmith, "Build vs. Buy for Feature Flags: My Experience as a CTO", https://www.flagsmith.com/blog/build-vs-buy-feature-flags-experience-as-a-cto, 2024
15. [A] AWS Cloud Operations Blog, "Using AWS AppConfig Feature Flags", https://aws.amazon.com/blogs/mt/using-aws-appconfig-feature-flags/, 2022
16. [B] Pete Hodgson (martinfowler.com), "Feature Toggles (aka Feature Flags)", https://martinfowler.com/articles/feature-toggles.html, 2017-10
17. [B] Martin Fowler, "bliki: Feature Flag", https://martinfowler.com/bliki/FeatureFlag.html, 2017
18. [B] Henrico Dolfing, "Case Study 4: The $440 Million Software Error at Knight Capital", https://www.henricodolfing.com/2019/06/project-failure-case-study-knight-capital.html, 2019-06
19. [A] Statsig Blog, "How to lose half a billion dollars with bad feature flags", https://blog.statsig.com/how-to-lose-half-a-billion-dollars-with-bad-feature-flags-ccebb26adeec, 2023

## Caveats

- WebFetch がブロックされたため、各ソースの記事本文を直接取得して詳細を確認することができなかった。情報は WebSearch の検索結果サマリーに基づいている
- Meta/Facebook の Feature Flag 運用の内部詳細（具体的なアーキテクチャ、フラグ管理ツール名等）は公開情報が限られており、Statsig 創業の文脈での間接的な情報に依存している
- Netflix の具体的な並行実験数や Feature Flag 数の公式数値は確認できなかった
- Chromium Flag Guarding Guidelines の正確な公開日・更新日は特定できなかった
- Knight Capital 事件（2012年）は10年以上前の事例だが、Feature Flag 運用の教訓として現在も広く引用されている基礎的事例であるため含めた
