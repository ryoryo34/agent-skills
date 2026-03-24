# 工数算出基準リファレンス

本ドキュメントは、AI駆動開発における工数見積もりの算出基準をまとめたものである。
各観点について「現在の基準値」「根拠」「最新情報を収集するための検索ワード」を記載する。
AI技術は急速に進化するため、**四半期に1回程度**、検索ワードで最新データを収集し基準値を更新することを推奨する。

最終更新: 2026-03

---

## 1. コード生成・実装フェーズ

### 観点: AIコーディングツールによる実装工数の削減率

| 項目 | 現在の基準値 | 根拠 |
|------|------------|------|
| 定型コード生成（CRUD・API） | 30-50%削減 | GitHub/MS研究(2023): 55.8%高速化、McKinsey(2023): 最大45%削減 |
| フロントエンド実装 | 25-45%削減 | v0/Cursor等によるUIコンポーネント生成の普及 |
| 熟練開発者への逆効果 | 19%遅延の可能性 | METR研究(2025): 熟練OSS開発者で19%遅延 |

**検索ワード（最新データ収集用）:**
- `GitHub Copilot developer productivity study [year]`
- `AI coding assistant productivity empirical research [year]`
- `Claude Code Cursor Copilot productivity benchmark [year]`
- `AI code generation enterprise productivity measurement [year]`
- `LLM code generation accuracy quality metrics [year]`
- `METR AI developer productivity study [year]`

### 観点: AIコーディングツールの進化と新機能

| 項目 | 現在の状況 | 注目ツール |
|------|----------|----------|
| マルチファイル編集 | Cursor/Claude Codeで実用レベル | Cursor, Claude Code, Windsurf |
| エージェント型開発 | Claude Code, GitHub Copilot Workspace | 自律的にタスク分解→実装→テスト |
| デザイン→コード変換 | v0, Bolt.new | UIモック→React/Next.jsコード |

**検索ワード:**
- `AI coding agent autonomous development [year]`
- `AI agentic software development SWE-bench [year]`
- `best AI coding tools comparison [year]`
- `AI IDE features multi-file editing agent mode [year]`
- `design to code AI tool v0 Bolt [year]`

---

## 2. テスト工程

### 観点: AIによるテスト自動化の削減率

| 項目 | 現在の基準値 | 根拠 |
|------|------------|------|
| テストコード生成 | 25-40%削減 | AIでユニットテスト・結合テストの雛形生成 |
| テストシナリオ生成 | 15-25%削減 | NTTデータ: AIエージェントでテスト項目表を自動生成 |
| E2Eテスト実行 | 10-20%削減 | テストスクリプト生成は効果的、判断は人間 |
| AIコードレビュー | 品質81%向上 | Qodo 2025レポート: AIレビューで品質改善 |

**検索ワード:**
- `AI test generation unit test integration test automation [year]`
- `AI software testing productivity reduction [year]`
- `AI code review quality improvement metrics [year]`
- `Autify testRigor AI E2E test automation [year]`
- `AI テスト自動化 工数削減 効果 [year]`
- `生成AI テストケース自動生成 精度 [year]`

### 観点: テスト設計へのAI活用

| 項目 | 現在の状況 |
|------|----------|
| 要件→テスト観点の自動抽出 | 実用初期段階。網羅性チェックに有効 |
| テストマトリクス生成 | AIでドラフト生成→人間がレビュー |
| 回帰テスト範囲の特定 | コード変更の影響分析でAI活用 |

**検索ワード:**
- `AI test design requirements traceability [year]`
- `AI test case generation from requirements specification [year]`
- `AI impact analysis regression test scope [year]`

---

## 3. 要件定義・設計フェーズ

### 観点: AIによる要件定義・設計の支援効果

| 項目 | 現在の基準値 | 根拠 |
|------|------------|------|
| 要件定義支援 | 10-20%削減 | RAGで既存仕様参照、ストーリー・受け入れ基準のドラフト生成 |
| アーキテクチャ設計 | 10-25%削減 | AI提案は参考レベル。判断は人間 |
| テスト設計 | 15-25%削減 | 網羅性チェックはAI得意 |
| ドキュメント作成 | 30-50%削減 | McKinsey: 約50%短縮 |

**検索ワード:**
- `AI requirements engineering natural language processing [year]`
- `AI software architecture design assistance [year]`
- `生成AI 要件定義 設計書 自動生成 精度 [year]`
- `AI documentation generation API specification [year]`
- `RAG requirements analysis specification generation [year]`

### 観点: AIエージェントによる上流工程の自動化

| 項目 | 現在の状況 |
|------|----------|
| 要件→設計→実装の一気通貫 | 富士通Takane: 全工程AIで3人月→4時間（100倍） ※特定条件下 |
| マルチエージェント協調 | MetaGPT: PM/アーキテクト/エンジニア役のAIが連携 |
| 仕様駆動開発 | GitHub Spec Kit: 仕様→実装→テストのエージェント制御 |

**検索ワード:**
- `AI agent software development lifecycle end-to-end [year]`
- `multi-agent software engineering MetaGPT [year]`
- `specification driven AI development [year]`
- `富士通 Takane AI駆動開発 全工程自動化 [year]`
- `AI agentic SDLC enterprise adoption [year]`

---

## 4. インフラ・DevOps

### 観点: AIによるインフラ構築の削減率

| 項目 | 現在の基準値 | 根拠 |
|------|------------|------|
| IaCコード生成 | 15-30%削減 | Terraform/Bicep/CDKのテンプレート生成 |
| CI/CDパイプライン設定 | 20-30%削減 | GitHub Actions等のYAML生成 |
| 監視設定 | 15-25%削減 | アラートルール・ダッシュボード定義生成 |

**検索ワード:**
- `AI infrastructure as code Terraform Bicep generation [year]`
- `AI DevOps CI/CD pipeline automation [year]`
- `AI cloud infrastructure provisioning automation [year]`
- `Amazon CodeWhisperer IaC generation [year]`
- `AI observability monitoring setup automation [year]`

---

## 5. セキュリティ

### 観点: AIによるセキュリティ対応の限界

| 項目 | 現在の基準値 | 根拠 |
|------|------------|------|
| セキュリティレビュー | 0-10%削減 | 文脈依存の判断が必要。AI単体では不十分 |
| 脆弱性スキャン | ツール自動化は進むが、判断は人間 | Snyk等のAI統合 |
| セキュアコーディング | AI生成コードにセキュリティリスクあり | AI生成コードの36%に脆弱性（2025報告） |

**検索ワード:**
- `AI generated code security vulnerability rate [year]`
- `AI security review OWASP automation [year]`
- `AI code security blind spot risk [year]`
- `Snyk AI security scanning accuracy [year]`
- `AI セキュアコーディング 脆弱性 生成コード [year]`

---

## 6. プロジェクトマネジメント・コミュニケーション

### 観点: AIで削減しにくい工程

| 項目 | 現在の基準値 | 理由 |
|------|------------|------|
| 要件ヒアリング・合意形成 | 0-10%削減 | 対人コミュニケーション主体 |
| UI/UXレビュー | 0-10%削減 | 主観的・感覚的判断 |
| クライアントMTG | 削減なし | 対面・オンライン会議は人間のみ |
| ステークホルダー調整 | 削減なし | 政治的・組織的判断 |

**検索ワード:**
- `AI project management automation limitations [year]`
- `AI communication stakeholder management [year]`
- `AI sprint planning velocity prediction accuracy [year]`
- `AI agile estimation tool Baseliner accuracy [year]`

### 観点: AIスプリントプランニングツール

| 項目 | 現在の状況 | 根拠 |
|------|----------|------|
| スプリント見積もりAI | 精度77-87%。計画バラツキ23%低減 | Baseliner.ai等 |
| ベロシティ予測 | オンタイムデリバリー率27%向上 | 予測分析採用チームの実測 |
| プランニング時間短縮 | 60分→10分以下の事例 | AI自動見積もり |

**検索ワード:**
- `AI sprint planning estimation tool accuracy [year]`
- `AI velocity prediction agile delivery [year]`
- `Baseliner AI sprint estimation review [year]`
- `AI agile project management tool comparison [year]`

---

## 7. SIer/受託開発特有の観点

### 観点: 受託開発でのAI見積もりの商慣習

| 項目 | 現在の状況 |
|------|----------|
| 人月見積もり文化 | 顧客は依然として「人日」「人月」での提示を求める |
| AI削減の説明 | 「AIで工数削減→値下げ」を求められるリスク |
| 契約形態 | Fixed-price per sprint（スプリント単位固定価格）が推奨 |
| スコープ管理 | 「Money for Nothing, Change for Free」モデル |

**検索ワード:**
- `SIer AI駆動開発 見積もり 人月 変化 [year]`
- `agile fixed price contract sprint estimation [year]`
- `AI開発 受託 工数削減 顧客説明 [year]`
- `生成AI SIer ビジネスモデル 変革 [year]`
- `AI development outsourcing estimation pricing model [year]`

### 観点: 日本のSIer業界のAI導入状況

| 項目 | 現在の状況 | 根拠 |
|------|----------|------|
| 大手SIerの目標 | 2029年までに生産性50%向上（TIS） | 日経xTECH |
| 欧米先行事例 | 人間の工数20-50%削減が一般化 | 芝陽一郎(i3DESIGN CEO) |
| 日本の現状 | 議事録・資料作成の補助にとどまる企業が多い | 2025年時点 |

**検索ワード:**
- `日本 SIer AI導入 生産性向上 実績 [year]`
- `大手SIer 生成AI 開発生産性 目標 [year]`
- `AI駆動開発 SIer 事例 成功 失敗 [year]`
- `Japan system integrator AI adoption rate [year]`

---

## 8. 工数算出の計算式

### 基本計算式

```
AI活用後の工数 = AI未活用時の工数 × (1 - 削減率)

削減率の決定:
- AI活用=「AI」 → 削減率ガイドラインの上限値
- AI活用=「AIと人間」 → 削減率ガイドラインの中央値
- AI活用=「人間」 → 0%（削減なし）
```

### スプリントベースの計算式

```
1スプリント工数 = チーム人数 × 10日 × 実効率(70-80%)
必要スプリント数 = Σ(各エピックの推定スプリント数)
本番工数 = Phase 0 + (スプリント数 × スプリント工数) + Final Phase
総額 = 本番工数 × 人日単価 + インフラ費用 + バッファ
```

### バッファの考え方

| 条件 | 推奨バッファ |
|------|------------|
| 標準的な案件 | 10-15% |
| AI技術の新規性が高い | 15-20% |
| セキュリティ要件が厳しい（半官企業等） | 20-25% |
| 既存システム連携が複雑 | 15-20% |
| チームのAI習熟度が低い | 20-30% |

**検索ワード:**
- `software project estimation buffer contingency best practice [year]`
- `AI project risk estimation uncertainty [year]`
- `agile estimation accuracy improvement over sprints [year]`

---

## 更新履歴

| 日付 | 更新内容 |
|------|---------|
| 2026-03 | 初版作成。GitHub/MS研究、McKinsey、METR研究、NTTデータ事例等を基に基準値を設定 |
