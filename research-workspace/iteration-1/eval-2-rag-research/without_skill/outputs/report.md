# RAG (Retrieval-Augmented Generation) 最新研究動向レポート

**調査日:** 2026-03-08

---

## 1. 概要

Retrieval-Augmented Generation (RAG) は、外部知識ソースから関連情報を検索し、大規模言語モデル (LLM) の生成に活用するアーキテクチャである。2024年後半から2026年にかけて、RAG は単純な「検索+生成」パイプラインから、自律的エージェント、グラフ構造、マルチモーダル対応を備えた高度なシステムへと急速に進化している。本レポートでは、最新の研究動向を体系的に整理する。

---

## 2. RAG アーキテクチャの進化

### 2.1 Naive RAG から Advanced/Modular RAG へ

RAG の発展は3段階に整理される:

- **Naive RAG**: 単一パスで検索・生成を行う最も基本的な構成
- **Advanced RAG**: クエリ最適化、リランキング、反復検索など高度な検索戦略を導入
- **Modular RAG**: タスクに応じて柔軟にコンポーネントを組み替え可能なアーキテクチャ

最新の研究では、Modular RAG をさらに発展させ、エージェントによる自律的な制御を組み込んだ **Agentic RAG** が主要な研究テーマとなっている。

### 2.2 RAG から「コンテキストエンジン」へ

2025年末のレビューでは、RAG は「Retrieval-Augmented Generation」という特定のパターンから、「インテリジェント検索」を核とした **コンテキストエンジン** へと変貌を遂げつつあると指摘されている。静的な文書インデックスから、動的なグラフ構造知識ベースへの移行が進んでいる。

**出典:**
- [From RAG to Context - A 2025 year-end review of RAG | RAGFlow](https://ragflow.io/blog/rag-review-2025-from-rag-to-context)

---

## 3. 主要な研究トレンド

### 3.1 Agentic RAG (エージェント型 RAG)

Agentic RAG は、RAG パイプラインに自律的な AI エージェントを組み込むアプローチである。従来の固定的な単一ホップ検索を超え、エージェントが以下の機能を自律的に実行する:

- **計画 (Planning)**: 複雑なクエリを分解し、複数の検索ステップを計画
- **ツール利用 (Tool Use)**: 検索エンジン、データベース、API など複数のツールを選択的に利用
- **反省 (Reflection)**: 中間回答を評価し、検索戦略を適応的に修正
- **マルチエージェント協調**: 複数のエージェントが役割分担しながら協調的に動作

Singh らによるサーベイ論文が、Agentic RAG の基盤原理と RAG パラダイムの進化を包括的に整理している。

**出典:**
- [Agentic Retrieval-Augmented Generation: A Survey on Agentic RAG](https://arxiv.org/abs/2501.09136)
- [GitHub - AgenticRAG-Survey](https://github.com/asinghcsu/AgenticRAG-Survey)

### 3.2 GraphRAG (グラフ型 RAG)

GraphRAG は、知識グラフを活用した検索手法であり、Microsoft の研究を起点に急速に発展している。

- **従来の RAG との違い**: ベクトル類似度検索ではなく、エンティティ間の意味的関係（オントロジー）を活用
- **強み**: マルチホップ QA や複雑な要約タスクで Vanilla RAG を上回る性能
- **ハイブリッド検索**: ベクトル類似度とグラフ走査を Reciprocal Rank Fusion (RRF) で融合する手法が提案されている
- **実用化の課題**: 効率的な知識グラフ構築パイプライン（依存関係解析の活用）が研究されている

**出典:**
- [Towards Practical GraphRAG: Efficient Knowledge Graph Construction and Hybrid Retrieval at Scale](https://arxiv.org/abs/2507.03226)
- [Awesome-GraphRAG (GitHub)](https://github.com/DEEP-PolyU/Awesome-GraphRAG)
- [GraphRAG & Knowledge Graphs: Making Your Data AI-Ready for 2026 - Fluree](https://flur.ee/fluree-blog/graphrag-knowledge-graphs-making-your-data-ai-ready-for-2026/)

### 3.3 Multimodal RAG (マルチモーダル RAG)

テキストだけでなく、画像、音声、動画を統合的に扱う RAG が研究されている。

- マルチモーダル埋め込みにより、異なるモダリティを統一的な意味空間 (Unified Semantic Space) に配置
- 動画アーカイブ、音声トランスクリプト、技術図面などの「ダークデータ」の活用が可能に
- テキスト・画像・動画を同時に理解・記憶するマルチモーダルメモリシステムがプロトタイプ段階にある

**出典:**
- [GitHub - Multimodal-RAG-Survey](https://github.com/llm-lab-org/Multimodal-RAG-Survey)
- [RAG 2.0 Guide: Multimodal Memory & GraphRAG Architectures](https://www.mytechmantra.com/sql-server/enterprise-rag-2-0-multimodal-memory-guide/)

### 3.4 自己改善型 RAG (Self-RAG, Corrective RAG, Speculative RAG)

RAG システム自体が自律的に品質を評価・改善するアプローチが複数提案されている:

| 手法 | 特徴 | 利点 |
|------|------|------|
| **Self-RAG** | 「リフレクショントークン」(retrieve, critic) を用いたフラグメントレベルのビームサーチ。スコアを動的に更新 | オープンドメイン QA・推論タスクで従来手法を上回る |
| **Corrective RAG (CRAG)** | 検索結果の正確性を評価し、不正確な場合は動的に Web 検索に切り替え | 信頼性・堅牢性の向上 |
| **Speculative RAG** | 小型の専門 LM が複数のドラフトを並列生成し、大型 LM が検証 | 精度最大 12.97% 向上、レイテンシ 50.83% 削減 (PubHealth) |

**出典:**
- [Speculative RAG: Enhancing Retrieval Augmented Generation through Drafting](https://arxiv.org/abs/2407.08223)
- [Corrective RAG (CRAG): Workflow, implementation, and more](https://www.meilisearch.com/blog/corrective-rag)
- [14 types of RAG](https://www.meilisearch.com/blog/rag-types)

---

## 4. 検索技術の高度化

### 4.1 チャンキング戦略の進化

文書をどのように分割するかは RAG の精度に直結する。2025年の研究では以下の手法が比較検討されている:

- **Late Chunking**: 文書全体をトークンレベルで埋め込んでから分割。照応関係を含む文書で検索精度 10-12% 向上
- **Contextual Retrieval**: ベースチャンキング後に LLM で文書レベルのコンテキストを各チャンクに付加。精度 2-18% 向上
- **Semantic Chunking**: 意味的なまとまりに基づいて分割
- **Agentic Chunking**: エージェントが文脈を理解して最適な分割を自律的に判断

Late Chunking はアーキテクチャ変更なしで性能向上できる利点があり、Contextual Retrieval は最大性能が必要な場合に適するが計算コストが高い。

**出典:**
- [Reconstructing Context: Evaluating Advanced Chunking Strategies for Retrieval-Augmented Generation](https://arxiv.org/abs/2504.19754)
- [Document Chunking for RAG: 9 Strategies Tested (70% Accuracy Boost 2025)](https://langcopilot.com/posts/2025-10-11-document-chunking-for-rag-practical-guide)

### 4.2 ハイブリッド検索

ベクトル検索 (Dense Retrieval) と BM25 (Sparse Retrieval) を組み合わせるハイブリッド検索が標準的なプラクティスとなりつつある:

- Dense 埋め込みによる意味理解と BM25 による正確なキーワードマッチングの組み合わせ
- エンタープライズ環境で精度 15-30% 向上の報告
- メタデータフィルタリング、ツリーベース・グラフベースのクエリとの統合

### 4.3 クエリ最適化

ユーザーのクエリを検索に最適化する技術も発展している:

- **Query Expansion**: Multi-Query、Sub-Query、Chain-of-Verification
- **Query Transformation**: HyDE (Hypothetical Document Embeddings)、Step-back Prompting
- **Adaptive Retrieval**: クエリの複雑さに応じて検索深度を動的に調整（単純な事実質問は単一ホップ、推論タスクは多段階検索）

---

## 5. RAG vs Long Context LLM

コンテキストウィンドウの急速な拡大（100万トークン以上）により、RAG の必要性が問い直されている。

### 研究結果のまとめ

- Long Context は Wikipedia ベースの QA ベンチマークで RAG を上回る傾向
- 一方、対話ベースや一般的な質問では RAG が優位
- データセットが動的・多様な場合は RAG が適する
- 実際のモデルは公称のコンテキストウィンドウよりもはるかに短い段階で精度劣化が見られる（100トークンで失敗するケースも報告）

### 実務的な判断基準

- 小規模で静的な文書セット → Long Context で十分（ベクトル DB は不要なオーバーヘッド）
- 大規模・動的・多様なデータセット → RAG が依然として必要
- エンタープライズでは RAG の基盤的役割が「コンセンサス」に

**出典:**
- [Long Context vs. RAG for LLMs: An Evaluation and Revisits](https://arxiv.org/abs/2501.01880)
- [Beyond RAG vs. Long-Context: Learning Distraction-Aware Retrieval for Efficient Knowledge Grounding (OpenReview)](https://openreview.net/forum?id=c8CZWLy4T4)
- [LaRA: Benchmarking Retrieval-Augmented Generation and Long-Context LLMs (OpenReview)](https://openreview.net/forum?id=CLF25dahgA)

---

## 6. RAG の評価手法

### 主要な評価フレームワーク

| フレームワーク | 特徴 |
|--------------|------|
| **RAGAS** | 参照不要 (reference-free) の評価。Context Precision, Context Recall, Faithfulness, Answer Relevancy の4指標 |
| **ARES** | 合成評価データセットの生成と LLM ジャッジの訓練に基づく評価。信頼度スコア付き |
| **RAGBench** | 100K サンプルの大規模ベンチマーク |

### 2026年の主要評価プラットフォーム

Maxim AI、LangSmith、Arize AI、RAGAS、Braintrust が主要プラットフォームとして挙げられている。

**出典:**
- [RAG Evaluation: 2026 Metrics and Benchmarks for Enterprise AI Systems](https://labelyourdata.com/articles/llm-fine-tuning/rag-evaluation)
- [Ragas: Automated Evaluation of Retrieval Augmented Generation](https://arxiv.org/abs/2309.15217)
- [RAGBench: Explainable Benchmark for Retrieval-Augmented Generation Systems](https://arxiv.org/abs/2407.11005)
- [The 5 Best RAG Evaluation Tools You Should Know in 2026](https://www.getmaxim.ai/articles/the-5-best-rag-evaluation-tools-you-should-know-in-2026/)

---

## 7. ドメイン特化 RAG

RAG の応用は汎用的な QA を超え、特定ドメインへの適用が進んでいる:

- **医療 (Healthcare)**: Naive、Advanced、Modular RAG の各アーキテクチャが検索深度・応答品質・計算効率の最適化に活用されている
- **教育 (Education)**: インタラクティブ学習システム、教育コンテンツの生成と評価、大規模教育エコシステムへの展開
- **電子政府 (e-Governance)**: Agentic RAG システムの忠実度評価に LLM ベースの判定フレームワークを適用
- **製造業**: Document GraphRAG による製造ドメインの文書 QA

**出典:**
- [RAG models for healthcare applications (Springer)](https://link.springer.com/article/10.1007/s00521-025-11666-9)
- [Retrieval-augmented generation for educational application (ScienceDirect)](https://www.sciencedirect.com/science/article/pii/S2666920X25000578)
- [Evaluating Faithfulness in Agentic RAG Systems for e-Governance](https://www.mdpi.com/2504-2289/9/12/309)

---

## 8. 今後の展望と課題

### 主要な研究方向

1. **エージェントと RAG の深い統合**: エージェントが検索・生成・評価のサイクルを自律的に制御するシステムの成熟
2. **知識グラフとベクトル検索のハイブリッド**: 構造化知識と非構造化知識の統合的な活用
3. **マルチモーダル対応の本格化**: テキスト以外のモダリティの実用的な統合
4. **因果推論との融合**: RAG と因果推論モデルの組み合わせによる因果関係分析（医療分野などでの応用）
5. **プライバシーと連合学習**: 分散型 RAG システムによるデータプライバシーの確保

### 残存する課題

- **精度と安定性のギャップ**: エンタープライズでは RAG なしでは成り立たないが、安定した高精度の実現には広範な最適化が必要
- **評価の標準化**: RAG システムの包括的・再現可能な評価手法はまだ発展途上
- **スケーラビリティ**: 知識グラフ構築やコンテキスト付きチャンキングの計算コスト
- **ハルシネーション制御**: 検索結果に基づかない生成の抑制は依然として重要課題

**出典:**
- [A Systematic Review of Key RAG Systems: Progress, Gaps, and Future Directions](https://arxiv.org/html/2507.18910v1)
- [Retrieval-Augmented Generation: A Comprehensive Survey of Architectures, Enhancements, and Robustness Frontiers](https://arxiv.org/abs/2506.00054)
- [The Next Frontier of RAG: How Enterprise Knowledge Systems Will Evolve (2026-2030)](https://nstarxinc.com/blog/the-next-frontier-of-rag-how-enterprise-knowledge-systems-will-evolve-2026-2030/)

---

## 9. 主要サーベイ論文一覧

| 論文 | リンク |
|------|--------|
| A Systematic Review of Key RAG Systems: Progress, Gaps, and Future Directions | [arxiv.org](https://arxiv.org/html/2507.18910v1) |
| Retrieval-Augmented Generation: A Comprehensive Survey of Architectures, Enhancements, and Robustness Frontiers | [arxiv.org](https://arxiv.org/abs/2506.00054) |
| Agentic Retrieval-Augmented Generation: A Survey on Agentic RAG | [arxiv.org](https://arxiv.org/abs/2501.09136) |
| Retrieval-Augmented Generation Evaluation in the Era of Large Language Models: A Comprehensive Survey | [arxiv.org](https://arxiv.org/abs/2504.14891) |
| Retrieval-Augmented Generation for AI-Generated Content: A Survey (Springer) | [springer.com](https://link.springer.com/article/10.1007/s41019-025-00335-5) |
| Retrieval-Augmented Generation (Springer BISE) | [springer.com](https://link.springer.com/article/10.1007/s12599-025-00945-3) |
| The Ultimate RAG Blueprint (LangWatch) | [langwatch.ai](https://langwatch.ai/blog/the-ultimate-rag-blueprint-everything-you-need-to-know-about-rag-in-2025-2026) |
