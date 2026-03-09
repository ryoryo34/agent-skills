# Research Report: RAG (Retrieval-Augmented Generation) の最新研究動向

## Executive Summary

RAG（Retrieval-Augmented Generation）は2024-2025年にかけて爆発的な研究成長を遂げ、arXiv上のRAG関連論文は2023年の100本未満から2024年には1,200本以上に急増した。主要な研究トレンドとして、(1) Agentic RAG（自律エージェントをRAGパイプラインに統合）、(2) GraphRAG（知識グラフによる構造的検索）、(3) マルチモーダルRAG（テキスト以外のモダリティへの拡張）、(4) Long-Context LLM vs RAGの比較研究が挙げられる。従来のNaive RAGからAdvanced RAG、さらにModular RAGへとパラダイムが進化し、2025-2026年にはエージェント型・グラフ型の次世代アーキテクチャが主流になりつつある。

## Findings

### 1. RAGパラダイムの進化：Naive RAG → Advanced RAG → Modular RAG

Gao et al. (2023) の包括的サーベイにより、RAGのパラダイムは3段階に分類された。Naive RAGは単純な「検索→生成」の2段階パイプライン、Advanced RAGはpre-retrieval（クエリ書き換え等）やpost-retrieval（リランキング等）の最適化を加えたもの、Modular RAGはこれらのコンポーネントを柔軟に組み合わせ可能にした設計である。2025年のサーベイ（arxiv 2506.00054）では、アーキテクチャをretriever-centric、generator-centric、hybrid、robustness-orientedの4カテゴリに体系的に分類している。

**Sources:**
- [S] Gao et al., "Retrieval-Augmented Generation for Large Language Models: A Survey", https://arxiv.org/abs/2312.10997, 2023-12
- [B] arxiv 2506.00054, "Retrieval-Augmented Generation: A Comprehensive Survey of Architectures, Enhancements, and Robustness Frontiers", https://arxiv.org/abs/2506.00054, 2025-06

### 2. Agentic RAG：自律エージェントによるRAGの高度化

Agentic RAGは、従来のRAGの静的ワークフローの限界を超え、自律AIエージェントをRAGパイプラインに組み込むアプローチである。reflection（自己反省）、planning（計画立案）、tool use（ツール活用）、multi-agent collaboration（マルチエージェント協調）といったエージェント設計パターンを活用し、検索戦略の動的管理、文脈理解の反復的改善、複雑なタスク要件へのワークフロー適応を実現する。Singh et al. (2025) のサーベイでは、ヘルスケア、金融、教育などの産業への応用も体系的にまとめられている。

**Sources:**
- [B] Singh, Ehtesham, Kumar, Khoei, "Agentic Retrieval-Augmented Generation: A Survey on Agentic RAG", https://arxiv.org/abs/2501.09136, 2025-01

### 3. Corrective RAG（CRAG）：検索品質の自己補正

CRAG（Corrective Retrieval Augmented Generation）は、検索された文書の品質を軽量な評価器で自動判定し、品質に応じて異なる知識検索アクションを起動する手法である。静的コーパスからの検索が不十分な場合、大規模Web検索で補完する。decompose-then-recomposeアルゴリズムにより、検索文書から重要な情報を選択的に抽出し、無関係な情報をフィルタリングする。既存のRAGベースアプローチにプラグアンドプレイで統合可能な点が実用上の大きな利点である。

**Sources:**
- [A] Yan, Gu, Zhu, Ling, "Corrective Retrieval Augmented Generation", https://arxiv.org/abs/2401.15884, 2024-01

### 4. GraphRAG：知識グラフによる構造的検索の強化

GraphRAGは、テキストから知識グラフを構築し、エンティティ間のリレーショナル構造を活用してより正確・包括的な検索を実現するアプローチである。Microsoftが2024年にオープンソースとして公開したGraphRAGツールは、文書をチャンクに分割してエンティティと関係を抽出し、コミュニティ検出によって階層的な要約を生成する。Local Search（特定エンティティに関する詳細クエリ）とGlobal Search（データセット全体にまたがるクエリ）の2モードを備え、さらにDRIFT Searchがコミュニティ情報をLocal Searchに統合する新手法として導入された。Han et al. (2025) のサーベイでは、query processor、retriever、organizer、generator、data sourceの5コンポーネントからなるフレームワークが定義されている。GraphRAG Benchmarkの研究はICLR 2026に採択された。

**Sources:**
- [S] Han et al., "Retrieval-Augmented Generation with Graphs (GraphRAG)", https://arxiv.org/abs/2501.00309, 2025-01
- [S] Microsoft Research, "GraphRAG: New tool for complex data discovery now on GitHub", https://www.microsoft.com/en-us/research/blog/graphrag-new-tool-for-complex-data-discovery-now-on-github/, 2024-07
- [S] Microsoft Research, "From Local to Global: A Graph RAG Approach to Query-Focused Summarization", https://arxiv.org/abs/2404.16130, 2024-04
- [S] Microsoft Research, "Introducing DRIFT Search", https://www.microsoft.com/en-us/research/blog/introducing-drift-search-combining-global-and-local-search-methods-to-improve-quality-and-efficiency/, 2024

### 5. マルチモーダルRAG：テキスト以外への拡張

RAG-Anything（Guo et al., 2025）は、テキスト・画像・表などあらゆるモダリティにわたる包括的な知識検索を実現する統一フレームワークである。マルチモーダルコンテンツを孤立したデータ型ではなく相互接続された知識エンティティとして再概念化し、dual-graph constructionにより、クロスモーダルな関係性とテキスト意味論の両方を統一的に表現する。長い文書において従来手法が失敗するケースで特に顕著な性能向上を示している。

**Sources:**
- [B] Guo, Ren, Xu, Zhang, Huang, "RAG-Anything: All-in-One RAG Framework", https://arxiv.org/abs/2510.12323, 2025-10

### 6. チャンキング戦略の再評価

NAACL 2025で発表されたQu et al.の研究は、セマンティックチャンキングの有効性を体系的に評価し、固定サイズチャンキング（200ワード）がセマンティックチャンキングと同等かそれ以上の性能を発揮する場合があることを示した。セマンティックチャンキングの計算コストが一貫した性能向上で正当化されないと結論づけ、従来の仮定に疑問を投げかけた。一方、別のベンチマーク（2026年2月）では再帰的512トークン分割が69%の精度で1位、セマンティックチャンキングは54%という結果も報告されている。実用的には、HIERARCHICALチャンキング + ハイブリッド検索 + リランキングが最も堅牢なデフォルト構成として推奨されている。

**Sources:**
- [S] Qu, Tu, Bao, "Is Semantic Chunking Worth the Computational Cost?", https://aclanthology.org/2025.findings-naacl.114/, 2025 (NAACL 2025 Findings)
- [A] Firecrawl, "Best Chunking Strategies for RAG (and LLMs) in 2026", https://www.firecrawl.dev/blog/best-chunking-strategies-rag, 2026

### 7. RAG評価の標準化：ベンチマークとフレームワーク

RAG評価の標準化が2024-2025年に大きく進展した。RAGBench（2024年7月）は100kサンプルの大規模ベンチマークデータセットで、TRACe評価フレームワーク（uTilization、Relevance、Adherence、Completeness）を導入した。TREC 2024 RAG Trackでは、Ragnarokフレームワークが再利用可能な評価基盤として提供され、GPT-4oやCohere Command R+などの産業ベースラインが設定された。AutoNuggetizerフレームワークによる自動評価と人間評価の間に強い相関が確認されている。

**Sources:**
- [A] Friel et al., "RAGBench: Explainable Benchmark for Retrieval-Augmented Generation Systems", https://arxiv.org/abs/2407.11005, 2024-07
- [S] Pradeep, Thakur et al., "Ragnarok: A Reusable RAG Framework and Baselines for TREC 2024 Retrieval-Augmented Generation Track", https://arxiv.org/abs/2406.16828, 2024-06
- [A] Lin et al., "Initial Nugget Evaluation Results for the TREC 2024 RAG Track with the AutoNuggetizer Framework", https://arxiv.org/abs/2411.09607, 2024-11

### 8. Long-Context LLM vs RAG：銀の弾丸は存在しない

コンテキストウィンドウの拡大（100K~1Mトークン）に伴い、RAGの必要性に関する議論が活発化している。LaRAベンチマーク（2,326テストケース）の研究では、Long-Context LLMはWikipediaベースのQAで優位だが、対話ベースや一般的なクエリではRAGが優位であることが示された。コスト面ではRAGがlong-contextアプローチの1/1250、速度面でもRAGが平均1秒に対しlong-contextは45秒と、実用面でRAGの優位性が大きい。2026年のベストプラクティスとしては、事実検索にはRAG、スタイルやポリシーにはファインチューニングを組み合わせるハイブリッドアプローチが推奨されている。

**Sources:**
- [B] "Long Context vs. RAG for LLMs: An Evaluation and Revisits", https://arxiv.org/abs/2501.01880, 2025-01
- [B] "LaRA: Benchmarking Retrieval-Augmented Generation and Long-Context LLMs", https://openreview.net/forum?id=CLF25dahgA, 2025
- [A] RAGFlow, "From RAG to Context - A 2025 year-end review of RAG", https://ragflow.io/blog/rag-review-2025-from-rag-to-context, 2025

## Source Reliability Summary

| Tier | Count | Notes |
|------|-------|-------|
| S    | 5     | トップカンファレンス論文（NAACL, TREC）、Microsoft Research公式ブログ |
| A    | 4     | arXiv査読付き論文、主要技術ブログ |
| B    | 5     | arXivプレプリント（新規・未査読だが著名グループ）、コミュニティリソース |

## Source List

1. [S] Gao, Xiong, Gao, Jia, Pan, Bi, Dai, Sun, Wang, Wang, "Retrieval-Augmented Generation for Large Language Models: A Survey", https://arxiv.org/abs/2312.10997, 2023-12
2. [S] Qu, Tu, Bao, "Is Semantic Chunking Worth the Computational Cost?", https://aclanthology.org/2025.findings-naacl.114/, 2025 (NAACL 2025 Findings)
3. [S] Pradeep, Thakur et al., "Ragnarok: A Reusable RAG Framework and Baselines for TREC 2024 RAG Track", https://arxiv.org/abs/2406.16828, 2024-06
4. [S] Microsoft Research, "From Local to Global: A Graph RAG Approach to Query-Focused Summarization", https://arxiv.org/abs/2404.16130, 2024-04
5. [S] Han et al., "Retrieval-Augmented Generation with Graphs (GraphRAG)", https://arxiv.org/abs/2501.00309, 2025-01
6. [A] Yan, Gu, Zhu, Ling, "Corrective Retrieval Augmented Generation", https://arxiv.org/abs/2401.15884, 2024-01
7. [A] Friel et al., "RAGBench: Explainable Benchmark for Retrieval-Augmented Generation Systems", https://arxiv.org/abs/2407.11005, 2024-07
8. [A] Lin et al., "Initial Nugget Evaluation Results for the TREC 2024 RAG Track", https://arxiv.org/abs/2411.09607, 2024-11
9. [A] RAGFlow, "From RAG to Context - A 2025 year-end review of RAG", https://ragflow.io/blog/rag-review-2025-from-rag-to-context, 2025
10. [B] Singh, Ehtesham, Kumar, Khoei, "Agentic Retrieval-Augmented Generation: A Survey on Agentic RAG", https://arxiv.org/abs/2501.09136, 2025-01
11. [B] "Retrieval-Augmented Generation: A Comprehensive Survey of Architectures, Enhancements, and Robustness Frontiers", https://arxiv.org/abs/2506.00054, 2025-06
12. [B] Guo, Ren, Xu, Zhang, Huang, "RAG-Anything: All-in-One RAG Framework", https://arxiv.org/abs/2510.12323, 2025-10
13. [B] "Long Context vs. RAG for LLMs: An Evaluation and Revisits", https://arxiv.org/abs/2501.01880, 2025-01
14. [B] "LaRA: Benchmarking Retrieval-Augmented Generation and Long-Context LLMs", https://openreview.net/forum?id=CLF25dahgA, 2025
15. [A] Firecrawl, "Best Chunking Strategies for RAG (and LLMs) in 2026", https://www.firecrawl.dev/blog/best-chunking-strategies-rag, 2026

## Caveats

- WebFetchが利用不可であったため、各論文の詳細な内容（実験結果の数値、具体的な手法の詳細）はWebSearchの結果サマリーに依存している。原論文を直接確認することで、より正確な数値やニュアンスが得られる可能性がある。
- Agentic RAGサーベイ（Singh et al.）は著者の所属機関の知名度が不明なため、Tier Bに分類した。引用数の増加に伴いTier Aに昇格する可能性がある。
- RAG-Anything（2025-10）やarxiv 2506.00054（2025-06）はプレプリント段階であり、査読を経ていない。
- Long-Context LLM vs RAGの比較研究は急速に進展中であり、新しいモデル（コンテキストウィンドウ拡張）のリリースに伴い結論が変わる可能性がある。
- 本レポートは英語圏の研究に偏っており、中国語圏の研究（特にRAGの実用化事例）のカバレッジが限定的である。
