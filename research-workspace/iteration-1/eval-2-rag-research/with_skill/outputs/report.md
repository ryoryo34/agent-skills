# Research Report: RAG (Retrieval-Augmented Generation) の最新研究動向

## Executive Summary

RAG（Retrieval-Augmented Generation）は2024〜2026年にかけて急速に進化しており、従来の「検索して生成する」単純なパイプラインから、Agentic RAG、GraphRAG、マルチモーダルRAGといった高度なアーキテクチャへと発展している。また、RAGは「Context Engine（コンテキストエンジン）」へと概念的に進化し、検索品質・忠実性・評価手法の改善が主要な研究テーマとなっている。長コンテキストLLMの台頭にもかかわらず、RAGはコスト効率・動的データ対応・スケーラビリティの面で依然として重要な技術であり続けている。

## Findings

### 1. RAGアーキテクチャの体系的分類と進化

2025年5月に発表された包括的サーベイにおいて、RAGアーキテクチャは以下の4カテゴリに分類されている：(1) Retriever-centric（検索器中心）、(2) Generator-centric（生成器中心）、(3) Hybrid（ハイブリッド）、(4) Robustness-oriented（堅牢性指向）。RAGはLLMの静的な学習データに起因する事実の不整合やドメイン非柔軟性といった限界を克服する一方、検索品質、グラウンディング忠実性、パイプライン効率、ノイズや敵対的入力に対する堅牢性など新たな課題を生んでいる。

**Sources:**
- [B] Chaitanya Sharma, "Retrieval-Augmented Generation: A Comprehensive Survey of Architectures, Enhancements, and Robustness Frontiers", https://arxiv.org/abs/2506.00054, May 2025

### 2. Agentic RAG — エージェントによる自律的検索

Agentic RAGは、自律的なAIエージェントをRAGパイプラインに組み込み、reflection（振り返り）、planning（計画）、tool use（ツール利用）、multiagent collaboration（マルチエージェント協調）といったエージェント設計パターンを活用して、検索戦略を動的に管理するアプローチである。従来のRAGの静的なワークフローの限界を超え、多段階推論や複雑なタスク管理を可能にする。ヘルスケア、金融、教育など幅広い産業での応用が報告されている。

2026年2月には、A-RAGが提案され、キーワード検索・セマンティック検索・チャンクリードの3つの階層的検索インターフェースをモデルに直接公開することで、エージェントが複数粒度にわたる適応的な検索を行えるフレームワークが登場した。

**Sources:**
- [B] Aditi Singh, Abul Ehtesham, Saket Kumar, Tala Talaei Khoei, "Agentic Retrieval-Augmented Generation: A Survey on Agentic RAG", https://arxiv.org/abs/2501.09136, January 2025
- [B] Mingxuan Du et al., "A-RAG: Scaling Agentic Retrieval-Augmented Generation via Hierarchical Retrieval Interfaces", https://arxiv.org/abs/2602.03442, February 2026

### 3. GraphRAG — 知識グラフによるグローバル質問応答

MicrosoftのGraphRAGは、テキストコーパスからエンティティ知識グラフを構築し、関連性の高いエンティティ群のコミュニティサマリーを事前生成することで、「データセット全体のテーマは何か？」といったグローバルな質問に対応する。100万トークン規模のデータセットに対する実験で、従来のRAGベースラインと比較して回答の包括性と多様性の両方で大幅な改善を達成した。2025年にはGraphRAG auto-tuningが導入され、新しいドメインへの迅速な適応が可能となった。

**Sources:**
- [A] Darren Edge, Ha Trinh et al. (Microsoft), "From Local to Global: A Graph RAG Approach to Query-Focused Summarization", https://arxiv.org/abs/2404.16130, April 2024
- [S] Microsoft Research, "Project GraphRAG", https://www.microsoft.com/en-us/research/project/graphrag/, 2024-2025

### 4. マルチモーダルRAG — テキストを超えた検索と生成

RAG-Anything（2025年10月）は、テキスト・画像・表・数式など異種モダリティにわたる包括的な知識検索を可能にする統一フレームワークである。Dual-graph construction（二重グラフ構築）によりクロスモーダル関係とテキスト意味論を統一的に表現し、構造的知識ナビゲーションとセマンティックマッチングを組み合わせたクロスモーダルハイブリッド検索を実現する。特に長文ドキュメントで従来手法を大きく上回る性能を示した。

**Sources:**
- [B] Zirui Guo, Xubin Ren, Lingrui Xu, Jiahao Zhang, Chao Huang, "RAG-Anything: All-in-One RAG Framework", https://arxiv.org/abs/2510.12323, October 2025

### 5. RAG推論（RAG-Reasoning）の融合

EMNLP 2025 Findingsにおいて、RAGと推論（Reasoning）の融合に関するサーベイが発表され、Chain-of-Thought（CoT）をRAGに統合するアプローチが注目されている。CoT-RAGはチェーン・オブ・ソートと検索拡張生成を統合して推論能力を強化するフレームワークであり、MCTS-RAG（モンテカルロ木探索ベースのRAG）も提案されている。これらのフレームワークは、多段階質問応答、数学的問題解決、構造化情報の統合において改善を示している。

**Sources:**
- [S] "A Survey of RAG-Reasoning Systems in LLMs", EMNLP 2025 Findings, https://aclanthology.org/2025.findings-emnlp.648.pdf, 2025
- [S] Feiyang Li et al., "CoT-RAG: Integrating Chain of Thought and Retrieval-Augmented Generation", EMNLP 2025 Findings, https://aclanthology.org/2025.findings-emnlp.168.pdf, 2025

### 6. RAGの忠実性とハルシネーション検出

Sparse Autoencoders（SAE）を用いてLLMの内部活性化を解きほぐし、RAGハルシネーション時に特異的にトリガーされる特徴を特定する研究が発表された。提案されたRAGLensは、LLMの内部表現を使用してRAGの不忠実な出力を検出する軽量ハルシネーション検出器であり、既存手法を上回る検出精度を達成しつつ、解釈可能な根拠も提供する。

**Sources:**
- [B] Guangzhi Xiong et al., "Toward Faithful Retrieval-Augmented Generation with Sparse Autoencoders", https://arxiv.org/abs/2512.08892, December 2025

### 7. チャンキング戦略の進化

RAGの性能はチャンキング戦略に大きく依存する。2025〜2026年の研究で以下の知見が得られている：

- **Adaptive Chunking（適応的チャンキング）**: 論理的なトピック境界に合わせたチャンキングが、固定サイズベースライン（13%）に対して87%の精度を達成（臨床意思決定支援のピアレビュー研究）
- **Recursive Chunking（再帰的チャンキング）**: 512トークンの再帰分割が7戦略中最高の69%精度を記録
- **Semantic Chunking（意味的チャンキング）**: NAACL 2025 Findingsの論文で、計算コストに見合う一貫した改善は得られないとの結論。固定200単語チャンクが意味的チャンキングと同等以上の性能
- **Late Chunking / Contextual Retrieval**: 文脈保持の新手法として、late chunkingは効率性に優れるが関連性と完全性を犠牲にし、contextual retrievalは意味的一貫性の保持に優れるが計算リソースを多く要する

実用的な推奨デフォルト値は256〜512トークン、10〜20%のオーバーラップとされている。

**Sources:**
- [B] Carlo Merola, Jaspinder Singh, "Reconstructing Context: Evaluating Advanced Chunking Strategies for Retrieval-Augmented Generation", https://arxiv.org/abs/2504.19754, April 2025
- [A] PMC/NIH, "Comparative Evaluation of Advanced Chunking for Retrieval-Augmented Generation in Large Language Models for Clinical Decision Support", https://pmc.ncbi.nlm.nih.gov/articles/PMC12649634/, 2025

### 8. RAG評価フレームワークとベンチマーク

RAG評価の体系化も急速に進んでいる。RAGBenchは100kサンプルの大規模ベンチマークであり、TRACe評価フレームワークにより Utilization（活用度）、Relevance（関連性）、Adherence（忠実度）、Completeness（完全性）の4軸で評価を行う。KDD Cup 2024のCRAGチャレンジは複数ドメイン・質問タイプにわたるRAGシステムの包括的評価を導入した。2025年4月のサーベイでは、従来型と新興型の評価アプローチを体系的にレビューし、システム性能、事実正確性、安全性、計算効率を網羅している。

**Sources:**
- [B] Robert Friel, Masha Belyi, Atindriyo Sanyal, "RAGBench: Explainable Benchmark for Retrieval-Augmented Generation Systems", https://arxiv.org/abs/2407.11005, July 2024
- [S] KDD 2024, "A Survey on RAG Meeting LLMs: Towards Retrieval-Augmented Large Language Models", https://dl.acm.org/doi/10.1145/3637528.3671470, 2024
- [B] "Retrieval Augmented Generation Evaluation in the Era of Large Language Models: A Comprehensive Survey", https://arxiv.org/abs/2504.14891, April 2025

### 9. RAG vs. 長コンテキストLLM — 共存と進化

長コンテキストウィンドウを持つLLM（100K+トークン）の台頭により「RAGは不要になるのか」という議論が活発化している。研究結果は以下を示している：

- 長コンテキストはWikipediaベースの質問応答ベンチマークではRAGを上回ることが多いが、要約ベースの検索は長コンテキストと同等の性能を示す
- 長コンテキストは「Lost in the Middle」効果や情報氾濫によりモデルの注意が分散し、回答品質が低下する問題がある
- RAGは必要な情報のみを検索するため、処理トークン数を削減し、大規模クエリではコスト効率が高い
- LaRAベンチマーク（2025年）では、モデルサイズ・タスクタイプ・コンテキスト長・検索品質により最適解が異なり、万能な解決策はないと結論

RAGは「Context Engine（コンテキストエンジン）」へと進化し、長コンテキストLLMと相補的な関係を形成している。

**Sources:**
- [B] "Long Context vs. RAG for LLMs: An Evaluation and Revisits", https://arxiv.org/abs/2501.01880, January 2025
- [A] RAGFlow, "From RAG to Context — A 2025 year-end review of RAG", https://ragflow.io/blog/rag-review-2025-from-rag-to-context, December 2025
- [A] Databricks, "Long Context RAG Performance of LLMs", https://www.databricks.com/blog/long-context-rag-performance-llms, 2025

## Source Reliability Summary

| Tier | Count | Notes |
|------|-------|-------|
| S    | 4     | KDD 2024採択論文、EMNLP 2025 Findings採択論文、Microsoft Research公式ページ |
| A    | 4     | ピアレビュー済み研究、大手テック企業ブログ（Databricks, RAGFlow/InfiniFlow）、PMC/NIH掲載論文 |
| B    | 8     | arXivプレプリント（著名な研究グループ、コミュニティで広く議論されたもの） |

## Source List

1. [B] Chaitanya Sharma, "Retrieval-Augmented Generation: A Comprehensive Survey of Architectures, Enhancements, and Robustness Frontiers", https://arxiv.org/abs/2506.00054, May 2025
2. [B] Aditi Singh, Abul Ehtesham, Saket Kumar, Tala Talaei Khoei, "Agentic Retrieval-Augmented Generation: A Survey on Agentic RAG", https://arxiv.org/abs/2501.09136, January 2025
3. [A] Darren Edge, Ha Trinh et al. (Microsoft), "From Local to Global: A Graph RAG Approach to Query-Focused Summarization", https://arxiv.org/abs/2404.16130, April 2024
4. [S] Microsoft Research, "Project GraphRAG", https://www.microsoft.com/en-us/research/project/graphrag/, 2024-2025
5. [B] Zirui Guo, Xubin Ren, Lingrui Xu, Jiahao Zhang, Chao Huang, "RAG-Anything: All-in-One RAG Framework", https://arxiv.org/abs/2510.12323, October 2025
6. [S] "A Survey of RAG-Reasoning Systems in LLMs", EMNLP 2025 Findings, https://aclanthology.org/2025.findings-emnlp.648.pdf, 2025
7. [S] Feiyang Li et al., "CoT-RAG: Integrating Chain of Thought and Retrieval-Augmented Generation", EMNLP 2025 Findings, https://aclanthology.org/2025.findings-emnlp.168.pdf, 2025
8. [B] Guangzhi Xiong et al., "Toward Faithful Retrieval-Augmented Generation with Sparse Autoencoders", https://arxiv.org/abs/2512.08892, December 2025
9. [B] Carlo Merola, Jaspinder Singh, "Reconstructing Context: Evaluating Advanced Chunking Strategies for Retrieval-Augmented Generation", https://arxiv.org/abs/2504.19754, April 2025
10. [A] PMC/NIH, "Comparative Evaluation of Advanced Chunking for Retrieval-Augmented Generation in Large Language Models for Clinical Decision Support", https://pmc.ncbi.nlm.nih.gov/articles/PMC12649634/, 2025
11. [B] Robert Friel, Masha Belyi, Atindriyo Sanyal, "RAGBench: Explainable Benchmark for Retrieval-Augmented Generation Systems", https://arxiv.org/abs/2407.11005, July 2024
12. [S] KDD 2024, "A Survey on RAG Meeting LLMs: Towards Retrieval-Augmented Large Language Models", https://dl.acm.org/doi/10.1145/3637528.3671470, 2024
13. [B] "Retrieval Augmented Generation Evaluation in the Era of Large Language Models: A Comprehensive Survey", https://arxiv.org/abs/2504.14891, April 2025
14. [B] "Long Context vs. RAG for LLMs: An Evaluation and Revisits", https://arxiv.org/abs/2501.01880, January 2025
15. [A] RAGFlow/InfiniFlow, "From RAG to Context — A 2025 year-end review of RAG", https://ragflow.io/blog/rag-review-2025-from-rag-to-context, December 2025
16. [A] Databricks, "Long Context RAG Performance of LLMs", https://www.databricks.com/blog/long-context-rag-performance-llms, 2025
17. [B] Mingxuan Du et al., "A-RAG: Scaling Agentic Retrieval-Augmented Generation via Hierarchical Retrieval Interfaces", https://arxiv.org/abs/2602.03442, February 2026

## Caveats

- arXivプレプリントの多くはまだピアレビューを受けておらず、Tier Bに分類している。今後の査読結果により評価が変わる可能性がある
- GraphRAG論文（2404.16130）は2024年4月公開であるが、GraphRAGの基盤的論文として含めている。Microsoft Researchのプロジェクトページは2025年まで更新が確認されている
- マルチモーダルRAG（RAG-Anything）は発表から日が浅く、独立した再現実験の報告は限定的
- RAG評価の分野は急速に発展しており、本レポート作成時点で未カバーの新しいベンチマークが存在する可能性がある
- チャンキング戦略の比較結果はデータセットやタスクに依存するため、一般化には注意が必要
- 本調査はWebSearch経由で取得した情報に基づいており、WebFetchによる論文本文の詳細な確認はツール制約により一部実施できなかった
