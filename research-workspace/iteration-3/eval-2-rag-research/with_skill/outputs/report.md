# Research Report: RAG (Retrieval-Augmented Generation) の最新研究動向

## Executive Summary

RAG（Retrieval-Augmented Generation）は2024-2026年にかけて急速に進化しており、従来の「検索+生成」パイプラインから、エージェント的自律制御（Agentic RAG）、グラフ構造の活用（GraphRAG）、マルチモーダル対応（Multimodal RAG）、そして「コンテキストエンジン」への変貌という複数の方向に発展している。特にAgentic RAGは自己修正・計画・ツール使用を組み込むことで従来RAGの限界を超え、GraphRAGはエンティティ間の関係性を活用してマルチホップ推論を実現し、チャンキング戦略やリトリーバル品質の改善が実運用精度を大きく左右することが明らかになっている。

## Findings

### 1. Agentic RAG: エージェントによる自律的検索・生成制御

従来のRAGが固定パイプライン（検索 -> 生成）であったのに対し、Agentic RAGはAIエージェントをRAGパイプラインに組み込み、検索戦略の動的管理を行う。主要な設計パターンとして、リフレクション（自己省察）、プランニング（計画立案）、ツール使用、マルチエージェント協調がある。

具体的には以下のサブ手法が注目されている:

- **Corrective RAG (CRAG)**: 検索結果の品質を軽量な評価器で判定し、品質が低い場合はクエリ書き換えやWeb検索による補完を自動的に行う。検索文書を分解・再構成するアルゴリズムにより、関連情報のみを選択的に抽出する。
- **Self-RAG**: モデル自体が「検索が必要か」を動的に判断し、取得情報の関連性を評価し、自身の出力を批判的に検証する自己省察メカニズムを持つ。
- **Plan-then-Retrieve**: 複雑なクエリを分解してから段階的に検索を行うアプローチ。

医療分野では臨床判断支援にエージェント的Graph RAGが適用され、金融分野では規制コンプライアンス分析に活用されている。

**Sources:**
- [S] Singh, A., Ehtesham, A., Kumar, S., Khoei, T.T., "Agentic Retrieval-Augmented Generation: A Survey on Agentic RAG", https://arxiv.org/abs/2501.09136, 2025-01 — Relevance: ★★★★★ (Agentic RAGの包括的サーベイ、分類体系・応用・実装戦略を網羅)
- [B] Yan, S.-Q. et al., "Corrective Retrieval Augmented Generation", https://arxiv.org/abs/2401.15884, 2024-01 — Relevance: ★★★★☆ (自己修正型RAGの先駆的研究、CRAGの手法詳細)

### 2. GraphRAG: 知識グラフによる構造的検索

MicrosoftのGraphRAGに代表されるように、テキストからエンティティと関係性を抽出してナレッジグラフを構築し、コミュニティ検出・要約を通じて検索を行うアプローチが主流化しつつある。従来のベクトル類似度検索が苦手とするマルチホップ推論や、散在する情報の統合に強みを持つ。

- **Microsoft GraphRAG**: 文書からエンティティナレッジグラフを抽出し、コミュニティ階層を構築、コミュニティ要約を事前生成する。2024年に公開され、Dynamic Community Selectionによるグローバル検索の改善が2025年に導入された。
- **LightRAG**: EMNLP 2025 Findingsに採択。エンティティと関係性に基づくデュアルレベル検索（詳細レベルと抽象レベル）を実現し、グラフ構造とベクトル表現を統合。インクリメンタル更新アルゴリズムにより動的データ環境にも対応する。

**Sources:**
- [S] Edge, D. et al., "From Local to Global: A Graph RAG Approach to Query-Focused Summarization", https://arxiv.org/abs/2404.16130, 2024-04 — Relevance: ★★★★★ (GraphRAGの原論文、手法の全体像を定義)
- [A] Microsoft Research, "Project GraphRAG", https://www.microsoft.com/en-us/research/project/graphrag/, 2024 — Relevance: ★★★★☆ (GraphRAGの公式プロジェクトページ、最新の動向を含む)
- [S] Guo, Z., Xia, L., Yu, Y., Ao, T., Huang, C., "LightRAG: Simple and Fast Retrieval-Augmented Generation", https://aclanthology.org/2025.findings-emnlp.568/, 2025 — Relevance: ★★★★★ (EMNLP2025採択、軽量かつ高速なグラフベースRAG)

### 3. マルチモーダルRAG: テキストを超えた検索・生成

テキストのみに依存していたRAGが、画像・動画・音声などのマルチモーダルデータを統合する方向に進化している。

- **Multimodal RAG (MRAG)**: テキスト・画像・動画をリトリーバルと生成の両プロセスに統合する枠組み。データセット・評価手法・限界についてのサーベイが2025年に発表された。
- **MegaRAG**: マルチモーダルナレッジグラフベースのRAGで、視覚的手がかりをナレッジグラフの構築・検索・回答生成の各段階に組み込み、クロスモーダル推論を実現する。
- **MAHA (Modality-Aware Hybrid Architecture)**: モダリティ認識型ナレッジグラフを用いて、密ベクトル検索と構造化グラフ走査を統合するアーキテクチャ。

**Sources:**
- [B] Mei, L., Mo, S., Yang, Z., Chen, C., "A Survey of Multimodal Retrieval-Augmented Generation", https://arxiv.org/abs/2504.08748, 2025-04 — Relevance: ★★★★★ (マルチモーダルRAGの包括的サーベイ)
- [B] "MegaRAG: Multimodal Knowledge Graph-Based Retrieval Augmented Generation", https://arxiv.org/abs/2512.20626, 2025-12 — Relevance: ★★★★☆ (マルチモーダルKGとRAGの統合手法)
- [B] "Multimodal RAG for Unstructured Data: Leveraging Modality-Aware Knowledge Graphs with Hybrid Retrieval", https://arxiv.org/abs/2510.14592, 2025-10 — Relevance: ★★★★☆ (モダリティ認識型ハイブリッド検索)

### 4. チャンキング戦略の進化

チャンキング品質が埋め込みモデル選択以上に検索精度を制約することが明らかになり、高度なチャンキング手法の研究が活発化している。

- **Late Chunking**: 文書全体をトークンレベルで埋め込んだ後にチャンクに分割する手法。照応参照を含む文書で検索精度が10-12%向上する。
- **Contextual Retrieval**: 基本チャンキング後にLLMで文書レベルのコンテキストを各チャンクに付与してから埋め込む手法。意味的一貫性の保持に優れるが計算コストが高い（2-18%の改善）。
- **Semantic Chunking**: セクション・見出し構造を保持した意味的チャンキング。忠実性スコアがナイーブな固定サイズチャンキング（0.47-0.51）に対して0.79-0.82を達成。
- **Adaptive Chunking**: 論理的トピック境界に合わせた適応的チャンキングが臨床判断支援において87%の精度を達成（固定サイズの13%に対して）。

**Sources:**
- [B] "Reconstructing Context: Evaluating Advanced Chunking Strategies for Retrieval-Augmented Generation", https://arxiv.org/abs/2504.19754, 2025-04 — Relevance: ★★★★★ (チャンキング戦略の体系的評価)
- [A] "Comparative Evaluation of Advanced Chunking for Retrieval-Augmented Generation in Large Language Models for Clinical Decision Support", https://pmc.ncbi.nlm.nih.gov/articles/PMC12649634/, 2025 — Relevance: ★★★★☆ (査読済み臨床研究でのチャンキング比較)

### 5. RAG評価手法の体系化

RAG固有の評価フレームワークが整備されつつある。不適切な評価により、正しい情報にアクセスしているにもかかわらず応答の最大40%がハルシネーションを含む問題が指摘されている。

- 従来の評価指標（BLEU、ROUGE等）に加え、検索認識型評価（retrieval-aware evaluation）が登場。
- ロバスト性テスト、フェデレーテッドリトリーバル設定での評価が新たな評価軸として注目。
- RAGのシステム性能、事実正確性、安全性、計算効率を体系的にレビューするサーベイが2025年4月に発表された。

**Sources:**
- [B] "Retrieval Augmented Generation Evaluation in the Era of Large Language Models: A Comprehensive Survey", https://arxiv.org/abs/2504.14891, 2025-04 — Relevance: ★★★★★ (RAG評価手法の包括的サーベイ)

### 6. RAGの「コンテキストエンジン」への進化

2025年末の振り返りとして、RAGは「Retrieval-Augmented Generation」という特定パターンから、「コンテキストエンジン」（知的検索を核とする基盤）へと変貌しつつあるという見方が示されている。

主要な技術的変化:
- **Search/Retrieve の分離**: 検索（小さく意味的に純粋な単位でのハイリコール）と取得（LLM向けに大きく完全なコンテキスト断片の動的集約）を異なるテキスト粒度で分離。
- **TreeRAG**: LLMを用いて文書の階層的ツリー構造のディレクトリ要約を自動構築する技術。
- **エンタープライズの現実**: 企業は「RAGなしでは生きられないが満足もしていない」状態。安定した結果を得るには広範な最適化が依然として必要。

**Sources:**
- [A] InfiniFlow/RAGFlow, "From RAG to Context — A 2025 year-end review of RAG", https://ragflow.io/blog/rag-review-2025-from-rag-to-context, 2025-12 — Relevance: ★★★★★ (2025年のRAG全体の振り返りと方向性)

### 7. 包括的サーベイ論文の動向

2024-2025年にかけて多数の包括的RAGサーベイが発表されており、分野の急速な発展を反映している。

- Sharma (2025-05) のサーベイは、RAGアーキテクチャをretriever-centric、generator-centric、hybrid、robustness-orientedの4カテゴリに分類する体系的な分類法を提示。
- Cheng et al. (2025-03) のKnowledge-Oriented RAGサーベイは、検索メカニズム、生成プロセス、両者の統合を体系的にレビュー。
- Gupta et al. (2024-10) のサーベイは、RAGの進化を基礎概念から現在の最先端まで追跡。

**Sources:**
- [B] Sharma, C., "Retrieval-Augmented Generation: A Comprehensive Survey of Architectures, Enhancements, and Robustness Frontiers", https://arxiv.org/abs/2506.00054, 2025-05 — Relevance: ★★★★★ (アーキテクチャ分類の体系的サーベイ)
- [B] Cheng, M. et al., "A Survey on Knowledge-Oriented Retrieval-Augmented Generation", https://arxiv.org/abs/2503.10677, 2025-03 — Relevance: ★★★★☆ (知識指向RAGの包括的レビュー)
- [B] Gupta, S., Ranjan, R., Singh, S.N., "A Comprehensive Survey of Retrieval-Augmented Generation (RAG): Evolution, Current Landscape and Future Directions", https://arxiv.org/abs/2410.12837, 2024-10 — Relevance: ★★★★☆ (RAGの進化を基礎から追跡)

## Source Reliability Summary

| Tier | Count | Notes |
|------|-------|-------|
| S    | 3     | トップカンファレンス採択論文（EMNLP 2025）、原著論文 |
| A    | 3     | 主要テック企業の公式プロジェクト、査読済み研究、著名OSSプロジェクトブログ |
| B    | 9     | arXivプレプリント（著名研究グループ所属、高引用数のもの） |

## Source List

1. [S] Singh, A., Ehtesham, A., Kumar, S., Khoei, T.T., "Agentic Retrieval-Augmented Generation: A Survey on Agentic RAG", https://arxiv.org/abs/2501.09136, 2025-01 — Relevance: ★★★★★ (Agentic RAGの包括的サーベイ、分類体系・応用を網羅)
2. [S] Edge, D. et al., "From Local to Global: A Graph RAG Approach to Query-Focused Summarization", https://arxiv.org/abs/2404.16130, 2024-04 — Relevance: ★★★★★ (GraphRAGの原論文)
3. [S] Guo, Z., Xia, L., Yu, Y., Ao, T., Huang, C., "LightRAG: Simple and Fast Retrieval-Augmented Generation", https://aclanthology.org/2025.findings-emnlp.568/, 2025 — Relevance: ★★★★★ (EMNLP2025採択、グラフベース軽量RAG)
4. [A] Microsoft Research, "Project GraphRAG", https://www.microsoft.com/en-us/research/project/graphrag/, 2024 — Relevance: ★★★★☆ (GraphRAG公式プロジェクト)
5. [A] "Comparative Evaluation of Advanced Chunking for RAG in LLMs for Clinical Decision Support", https://pmc.ncbi.nlm.nih.gov/articles/PMC12649634/, 2025 — Relevance: ★★★★☆ (査読済み臨床研究)
6. [A] InfiniFlow/RAGFlow, "From RAG to Context — A 2025 year-end review of RAG", https://ragflow.io/blog/rag-review-2025-from-rag-to-context, 2025-12 — Relevance: ★★★★★ (2025年の総括)
7. [B] Yan, S.-Q. et al., "Corrective Retrieval Augmented Generation", https://arxiv.org/abs/2401.15884, 2024-01 — Relevance: ★★★★☆ (CRAG手法の詳細)
8. [B] Mei, L., Mo, S., Yang, Z., Chen, C., "A Survey of Multimodal Retrieval-Augmented Generation", https://arxiv.org/abs/2504.08748, 2025-04 — Relevance: ★★★★★ (マルチモーダルRAGサーベイ)
9. [B] "MegaRAG: Multimodal Knowledge Graph-Based Retrieval Augmented Generation", https://arxiv.org/abs/2512.20626, 2025-12 — Relevance: ★★★★☆ (マルチモーダルKG+RAG)
10. [B] "Multimodal RAG for Unstructured Data", https://arxiv.org/abs/2510.14592, 2025-10 — Relevance: ★★★★☆ (モダリティ認識型検索)
11. [B] "Reconstructing Context: Evaluating Advanced Chunking Strategies for RAG", https://arxiv.org/abs/2504.19754, 2025-04 — Relevance: ★★★★★ (チャンキング戦略評価)
12. [B] "Retrieval Augmented Generation Evaluation in the Era of LLMs: A Comprehensive Survey", https://arxiv.org/abs/2504.14891, 2025-04 — Relevance: ★★★★★ (RAG評価手法サーベイ)
13. [B] Sharma, C., "RAG: A Comprehensive Survey of Architectures, Enhancements, and Robustness Frontiers", https://arxiv.org/abs/2506.00054, 2025-05 — Relevance: ★★★★★ (アーキテクチャ分類サーベイ)
14. [B] Cheng, M. et al., "A Survey on Knowledge-Oriented Retrieval-Augmented Generation", https://arxiv.org/abs/2503.10677, 2025-03 — Relevance: ★★★★☆ (知識指向RAGサーベイ)
15. [B] Gupta, S. et al., "A Comprehensive Survey of RAG: Evolution, Current Landscape and Future Directions", https://arxiv.org/abs/2410.12837, 2024-10 — Relevance: ★★★★☆ (RAG進化の追跡)

## Caveats

- **WebFetchが利用不可だったため、各論文の詳細な内容はWeb検索結果のスニペットに基づいている。** 論文の具体的な実験結果や数値データは、原論文を直接確認することを推奨する。
- **Tier Bソースが多い**: RAG分野は急速に発展しているため、多くの重要な研究がarXivプレプリントとして公開されており、査読を経ていない段階のものが多い。ただし、いずれも著名な研究グループや機関に所属する著者によるものであり、コミュニティでの議論実績がある。
- **Self-RAGの原論文（Asai et al., 2023）は2023年の発表であり、3年以上前の研究である。** ただし、Agentic RAGやCRAGの基盤となる概念として現在も広く参照されている基礎的著作である。
- **マルチモーダルRAGのサーベイ論文はTier Bに分類**: 2025年4月のプレプリントであり、トップカンファレンスへの採択はまだ確認できていない。ただし、この分野では最も包括的なサーベイの一つである。
- **企業の実運用事例**: 大規模な実運用事例の詳細（アーキテクチャ、精度、コスト）は公開情報が限られている。RAGFlowの2025年レビューが最も包括的な業界視点を提供している。
- **日本語圏の研究動向**: 本調査は主に英語圏の研究を対象としており、日本語圏固有のRAG研究動向（例: 日本語特化のチャンキングや検索手法）はカバーしていない。
