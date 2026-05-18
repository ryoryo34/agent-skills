# 全出典リスト

kintone-design スキルの根拠となる情報源を Reliability Tier 別に整理。

---

## Tier S（一次定義・公式）

### DDD / CQRS / Event Sourcing

1. **★★★★★ Fowler, Martin. "CQRS"** (2011-07)
   https://martinfowler.com/bliki/CQRS.html
   CQRS の一次定義。「Many systems do fit a CRUD mental model, and so should be done in that style」と警告。

2. **★★★★★ Fowler, Martin. "Event Sourcing"** (2005-12)
   https://martinfowler.com/eaaDev/EventSourcing.html
   ES の必須 3 要件（全変更がイベント由来・状態再構築可能・Temporal Query）を定義。

3. **★★★★★ Evans, Eric. "Domain-Driven Design Reference"** (2015-03)
   https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf
   Aggregate / Entity / Value Object / Repository の一次定義。

4. **★★★★☆ Vernon, Vaughn. "Effective Aggregate Design"** (3-part series, 2011)
   https://www.dddcommunity.org/library/vernon_2011/
   Small Aggregates 原則。他集約は ID 参照＋結果整合性の原則。

5. **★★★☆☆ Özkan, Babur et al. "Domain-Driven Design in Software Development: A Systematic Literature Review"** (2023-10 / 2025-06)
   arXiv:2310.01905, Journal of Systems and Software
   36 論文の SLR。DDD 採用の主動機は Microservices identification と結論。

### kintone 公式

6. **★★★★★ Cybozu Developer Network. "kintoneにおけるデータ設計の基本"** (2024-11)
   https://cybozu.dev/ja/kintone/tips/best-practices/colum/basic-data-design-in-kintone/
   ルックアップ vs 関連レコードの比較表、採番の注意点を公式明記。

7. **★★★★★ Cybozu Developer Network. "関連レコードの項目を条件付きで集計"** (2025-08)
   https://cybozu.dev/ja/kintone/tips/development/customize/related-records/conditional-aggregation-related-records/
   関連レコード集計の標準機能不可性と REST API 実装を公式解説。

8. **★★★★★ Cybozu. "kintone SIGNPOST 性能上の考慮点と改善策"** (2022-10)
   https://kintone.cybozu.co.jp/kintone-signpost/guide/performance.html
   性能指標（100 万件上限、10 万件警戒、API 制限等）の公式ガイド。

9. **★★★★★ Cybozu. "SIGNPOST 3-26 担当別アプリ"**
   https://kintone.cybozu.co.jp/kintone-signpost/pattern/3-26.html
   担当者・業務プロセス単位でのアプリ分割を公式推奨。

10. **★★★★☆ Cybozu. "SIGNPOST 2-19 データの断捨離"**
    https://kintone.cybozu.co.jp/kintone-signpost/pattern/2-19.html
    マスタ/トランザクション/コメント分類を公式が使用。

11. **★★★★★ kintone ヘルプ. "制限値一覧"**
    https://cn.kintone.help/k/en/admin/limitation/limit
    サブテーブル 10 フィールド・100 行推奨の公式制限値。

12. **★★★★☆ Cybozu Developer Network. "自動採番プラグイン"**
    https://cybozu.dev/ja/kintone/tips/development/plugins/sample-plugin/autonum-plugin/
    公式サンプルプラグイン。

13. **★★★☆☆ Cybozu. "kintoneガバナンス方針策定のポイント"** (PDF)
    https://kintone.cybozu.co.jp/material/pdf/kintone_governance_guideline.pdf
    ノーコード地獄予防策、命名規則、オーナー指定等のガバナンスガイドライン。

### ローコード プラットフォーム × DDD

14. **★★★★☆ Salesforce Trailhead. "Apex Enterprise Patterns: Domain & Selector Layers"** (2024)
    https://trailhead.salesforce.com/content/learn/modules/apex_patterns_dsl
    ローコード/業務プラットフォームで最も体系化された DDD パターン。

### Microsoft 公式

15. **★★★☆☆ Microsoft Learn. "CQRS パターン"** (2023-07 最終更新)
    https://learn.microsoft.com/ja-jp/azure/architecture/patterns/cqrs
    CQRS の公式解説（読み書き分離の文脈）。

---

## Tier A（認定パートナー・著名実装）

16. **★★★★☆ R3 Institute. "データベースとしての kintone"** (2020-07, updated 2025-12)
    https://www.r3it.com/column/kintone-as-a-database
    「kintone アプリはマイクロサービス」論の原典的記事。

17. **★★★★☆ R3 Institute. "kintoneのフィールドタイプ別解説「テーブル」"** (2020-06, updated 2025-07)
    https://www.r3it.com/column/kintone-fieldtype-table
    サブテーブルの実測ベース限界（数百行で実用不可）を明示。

18. **★★★☆☆ R3 Institute. "kintoneをベースにどこまでのシステムが開発できる？"** (2021-05, updated 2026-01)
    https://www.r3it.com/column/limitation-of-kintone-system-development
    トランザクション処理の弱さ等、kintone の限界論。

19. **★★★★☆ Kurrent (Event Store). "Event Sourcing vs Audit Log"** (2023)
    https://www.kurrent.io/blog/event-sourcing-audit
    ES 開発元による ES と Audit Log の定義的区別。

20. **★★★★☆ Greg Young. "CQRS and Event Sourcing" (Code on the Beach 2014 transcript)**
    https://www.kurrent.io/blog/transcript-of-greg-youngs-talk-at-code-on-the-beach-2014-cqrs-and-event-sourcing
    Greg Young 自身による CQRS と ES の関係定義。

21. **★★★★☆ JBCC. "kintoneで顧客管理や案件管理を行うためのSFAアプリの構成や作り方"** (2024-06, updated 2025-07)
    https://www.jbcc.co.jp/blog/column/kintone_sfa.html
    認定パートナーによる SFA アプリ構成の解説。

22. **★★★★☆ Toyokumo. "マスタを使って kintone を整理整頓！"** (2024-02, updated 2025-09)
    https://toyokumo-blog.kintoneapp.com/kintone-master-data-management-m/
    ルックアップと関連レコードの実務ガイダンス。

23. **★★★★☆ Toyokumo. "kintone アプリはこう使え！（複数アプリでの管理がオススメ）"** (2015-07, updated 2025-08)
    https://toyokumo-blog.kintoneapp.com/separated_app/
    複数アプリ分割の実務パターン。

24. **★★★☆☆ Cybozu セキュリティ室. "kintoneユーザー必読！kintoneガバナンスガイドラインのポイント"** (2022)
    https://note.com/security_cybozu/n/n331bf9fec5e7
    ノーコード地獄の具体事例（71 個の未使用アプリ、商品マスタ 3 個）。

25. **★★★★☆ アディエム株式会社. "関連レコード集計プラグイン for kintone"**
    https://kintone-sol.cybozu.co.jp/integrate/adiem027.html
    関連レコード集計プラグインの具体制約（500 件上限等）。

26. **★★★★☆ サイボウズ プラグイン連携. "自動採番プラグイン (joyzo)"**
    https://kintone-sol.cybozu.co.jp/integrate/joyzo008.html
    joyzo 採番プラグインの公式掲載。

27. **★★★★☆ サイボウズ プラグイン連携. "ユーソナー (uSonar)"**
    https://kintone-sol.cybozu.co.jp/integrate/usonar001.html
    LBC 820 万件法人マスタ連携サービス。

28. **★★★★☆ キンコミ. "顧客管理アプリを作成する際の名寄せ"**
    https://kincom.cybozu.co.jp/chats/i569up4bvyezgrnt
    公式ユーザーコミュニティの実務者議論。

29. **★★☆☆☆ 株式会社ジョイゾー. "kintone定額カスタマイズ開発サービス System39"**
    https://www.joyzo.co.jp/service/system39/
    認定パートナーのサービス概要。

30. **★★☆☆☆ Wikipedia. "Object–relational impedance mismatch"** (2024 last edit)
    https://en.wikipedia.org/wiki/Object%E2%80%93relational_impedance_mismatch
    ORM と DDD のミスマッチの定番解説。

---

## Tier B（実務者ブログ・コミュニティ）

31. **★★★★☆ little-hands. "CQRS実践入門 [ドメイン駆動設計]"** (2019-12)
    https://little-hands.hatenablog.com/entry/2019/12/02/cqrs
    DDD 実践者による CQRS 実装入門。Read Model = DTO の使い分けを明示。

32. **★★★☆☆ pospome. "DDDにおいて、なぜ複数の集約にまたがってトランザクションをかけてはいけないのか"** (2016-10)
    https://www.pospome.work/entry/20161023/1477206615
    集約とトランザクション境界の関係を詳述。

33. **★★★☆☆ Oskar Dudycz. "Is the audit log a proper architecture driver for Event Sourcing?"** (2021)
    https://event-driven.io/en/audit_log_event_sourcing/
    ES を audit log 目的で採用するアンチパターンへの警告。

34. **★★★☆☆ CodeZine. "実践DDD本 第10章「集約」〜トランザクション整合性を保つ境界〜"** (2018-04)
    https://codezine.jp/article/detail/10776
    Aggregate = transaction 境界の原理。

35. **★★★☆☆ Mehdi Khalili. "ORM anti-patterns - Part 4: Persistence vs Domain Model"** (2012)
    https://www.mehdi-khalili.com/orm-anti-patterns-part-4-persistence-domain-model
    Persistence Model と Domain Model を分離する意義。

36. **★★★☆☆ Jeff Atwood (Coding Horror). "Object-Relational Mapping is the Vietnam of Computer Science"** (2006-05)
    https://blog.codinghorror.com/object-relational-mapping-is-the-vietnam-of-computer-science/
    Ted Neward の著名な ORM 批判。

37. **★★★☆☆ Qiita @sy250f. "全ての SE に送りたい。kintone の基本設計で押さえておきたいポイント 5 選"** (2019-06, updated 2023-01)
    https://qiita.com/sy250f/items/06ca83bfb3d91a8c72a5
    実務者による kintone 設計原則。

38. **★★★☆☆ Qiita @rex0220. "kintone 制限値いろいろ"**
    https://qiita.com/rex0220/items/9e248db42621f3d9bf14
    実務者による制限値詳細まとめ。

39. **★★★☆☆ かりんこラボ. "プロセス管理履歴記録（テーブル版）"**
    https://caryncolabo.com/kintone_plugin/statusloggingpro/
    kintone プロセス管理履歴プラグインの実例。

---

## Reliability Summary

| Tier | 件数 | 概要 |
|------|:---:|------|
| S | 15 | 公式一次定義・Cybozu/Microsoft/Salesforce 公式ドキュメント・学術 SLR |
| A | 15 | 認定パートナー（R3, JBCC, Toyokumo）・著名実装者（Greg Young, Kurrent）・公式コミュニティ |
| B | 9 | 実務者ブログ（little-hands, pospome, Oskar Dudycz 等）・Qiita |

---

## 空白領域（調査で判明）

以下は**体系的な情報源が不在**と確認された領域:

1. **kintone × DDD の体系化**: 公式・認定パートナーに事例なし（論述空白）
2. **ローコード × CQRS/ES**: Salesforce 以外では体系化未成熟
3. **M&A DD / 会計事務所の kintone 導入**: 具体企業事例は公開範囲で特定できず

これらの空白を埋めるのが本スキルの価値。
