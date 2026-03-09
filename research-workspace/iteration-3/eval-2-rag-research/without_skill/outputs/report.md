# RAG (Retrieval-Augmented Generation) 最新研究動向レポート

## 1. はじめに

Retrieval-Augmented Generation (RAG) は、大規模言語モデル (LLM) の生成能力と外部知識の検索を組み合わせることで、事実に基づいた正確な応答を実現する技術である。2020年にMeta AI (当時Facebook AI Research) によって提案されて以来、急速に発展を遂げており、2025-2026年にかけて多くの新しいアーキテクチャや手法が登場している。

本レポートでは、RAGの最新研究動向を以下の観点から整理する。

---

## 2. RAGアーキテクチャの進化

### 2.1 Naive RAG から Advanced RAG、Modular RAG へ

RAGの発展は大きく3つの段階に分類される。

- **Naive RAG**: 単純な「検索 + 生成」のパイプライン。クエリに対してドキュメントを検索し、コンテキストとしてLLMに渡して回答を生成する基本的なアプローチ。
- **Advanced RAG**: 検索前処理（クエリ書き換え、拡張）や検索後処理（リランキング、フィルタリング）を導入し、検索品質を向上させたアプローチ。
- **Modular RAG**: 検索、メモリ、ルーティング、予測、タスクアダプターなどの新しいモジュールを導入し、ゼロショット/フューショットタスクに対応可能な柔軟なアーキテクチャ。

最新のサーベイ論文 "Retrieval-Augmented Generation: A Comprehensive Survey of Architectures, Enhancements, and Robustness Frontiers" (2025) では、これらのアーキテクチャの体系的な分類と、堅牢性のフロンティアについて包括的にまとめられている。

### 2.2 主要な最新手法

| 手法 | 概要 | 特徴 |
|------|------|------|
| **Self-RAG** | 「リフレクショントークン」を用いた自己評価型RAG | フラグメントレベルのビームサーチでスコアを動的に更新。オープンドメインQAや推論タスクで従来手法を上回る性能 |
| **CRAG (Corrective RAG)** | 検索結果の品質を評価し、適応的に修正するフレームワーク | 検索結果を「正確」「不正確」「曖昧」に分類し、必要に応じてWebサーチにフォールバック |
| **RAPTOR** | 階層的要約ツリーを構築する手法 | GPT-4でQuALITYベンチマーク精度が20%向上 |
| **LongRAG** | 長いコンテキストチャンクの圧縮検索 | ロングコンテキストLLMの能力を最大限に活用 |
| **RQ-RAG** | マルチホップクエリの潜在的サブ質問への分解 | 複雑なクエリの処理精度を向上 |

---

## 3. Agentic RAG

### 3.1 概要

Agentic RAG は、2025年以降の最も注目される研究トレンドの一つである。Singh, Ehtesham, Kumar, Khoei らによるサーベイ論文 "Agentic Retrieval-Augmented Generation: A Survey on Agentic RAG" (arXiv:2501.09136) が、この分野の包括的な整理を行っている。

Agentic RAG は、自律的なAIエージェントをRAGパイプラインに組み込むことで、従来のRAGの静的なワークフローの制約を超越する。エージェントは以下のデザインパターンを活用する。

- **Reflection（振り返り）**: 生成結果を自己評価し、改善する
- **Planning（計画）**: 複雑なタスクをサブタスクに分解して段階的に処理する
- **Tool Use（ツール利用）**: 外部ツール（Web検索、データベース、APIなど）を動的に選択・使用する
- **Multi-Agent Collaboration（マルチエージェント協調）**: 複数のエージェントが協調して検索・推論を行う

### 3.2 従来RAGとの違い

従来のRAGでは単一の検索ステップで処理が完結するのに対し、Agentic RAGではエージェントにツールとループを与えることで、マルチステップの推論タスクを実行できる。検索戦略を動的に管理し、文脈理解を反復的に洗練し、ワークフローを適応的に変更する能力を持つ。

### 3.3 応用分野

ヘルスケア、金融、教育などの産業分野での応用が進んでおり、特にe-Governanceアプリケーションにおける忠実性評価の研究も進んでいる。

---

## 4. GraphRAG

### 4.1 概要

GraphRAG は、Microsoft Research が提案した知識グラフベースのRAGアプローチである。入力コーパスからエンティティ間の関係グラフを構築し、コミュニティ階層の生成とそのサマリーを活用してクエリに回答する。

### 4.2 技術的特徴

- テキストからナレッジグラフを自動抽出
- コミュニティ階層の構築とサマリー生成
- グラフ機械学習の出力をプロンプト拡張に活用
- テーマレベルの質問に対して、トレーサビリティを持った回答が可能

### 4.3 性能と課題

標準的なRAGが複数の情報を横断的に結びつけることが苦手な「connect the dots」問題に対して、GraphRAGは大幅な改善を実現する。最新の研究では、LazyGraphRAG がベクトルRAG、RAPTOR、LightRAG、標準GraphRAGに対して100%の勝率（96比較中96勝）を達成している。

一方、インデキシングコストがベクトルRAGの100-1000倍と高コストである課題がある。LazyGraphRAGはこのコストを完全なGraphRAGの0.1%に削減する手法として注目されている。

元論文: "From Local to Global: A Graph RAG Approach to Query-Focused Summarization" (arXiv:2404.16130)

---

## 5. マルチモーダルRAG

### 5.1 概要

マルチモーダルRAG は、テキストだけでなく画像、音声、動画など複数のモダリティを統合してRAGを行うアプローチである。2025年には複数のサーベイ論文が発表されている。

- "Ask in Any Modality: A Comprehensive Survey on Multimodal Retrieval-Augmented Generation" (2025年2月)
- "A Survey of Multimodal Retrieval-Augmented Generation" (arXiv:2504.08748, 2025年3月)
- "Retrieval Augmented Generation and Understanding in Vision: A Survey and New Outlook" (arXiv:2503.18016)

### 5.2 主要な研究テーマ

- **データセットとベンチマーク**: マルチモーダルRAG評価のための標準的なベンチマーク整備
- **検索・融合・拡張・生成**: 各段階でのモダリティ統合手法
- **エージェント型インタラクション**: マルチモーダルRAGにおけるエージェント的な振る舞い
- **音声中心の検索**: 音声モダリティに特化した検索手法

### 5.3 実用的応用

Amazon Nova Multimodal Embeddings などを活用して、動画アーカイブ、音声トランスクリプト、技術図面などの「ダークデータ」を統一的な意味空間に統合する取り組みが進んでいる。

---

## 6. RAG vs ロングコンテキストLLM

### 6.1 論争の背景

LLMのコンテキストウィンドウが急速に拡大（100K-1Mトークン以上）する中で、「RAGは不要になるのか」という議論が活発化している。

### 6.2 研究知見

"Long Context vs. RAG for LLMs: An Evaluation and Revisits" (arXiv:2501.01880) などの研究により、以下の知見が得られている。

- **ロングコンテキスト (LC) が優位な場面**: Wikipedia系の質問応答ベンチマーク。静的で長いドキュメントの処理。
- **RAGが優位な場面**: 対話型クエリ、動的・多様なデータセット。コスト面ではRAGが1クエリあたり最大1250倍安価。
- **性能の飽和**: Llama-3.1-405bは32kトークン以降、GPT-4-0125-previewは64kトークン以降で性能が低下し始める。

### 6.3 結論

RAGは廃れておらず、コンテキストウィンドウの拡大にもかかわらず、特定のタスクにおいて不可欠な手法であり続けている。両者は相互排他的ではなく、ユースケースに応じた使い分けが推奨される。

---

## 7. Cache-Augmented Generation (CAG)

### 7.1 新しいパラダイム

Cache-Augmented Generation (CAG) は、リアルタイム検索をバイパスする新しいアプローチとして注目されている。ACM Web Conference 2025で発表された。

元論文: "Don't Do RAG: When Cache-Augmented Generation is All You Need for Knowledge Tasks" (arXiv:2412.15605)

### 7.2 仕組み

関連するすべてのリソースをLLMの拡張コンテキストに事前ロードし、ランタイムパラメータをキャッシュする。推論時は追加の検索ステップなしにキャッシュされたパラメータを参照して回答を生成する。

### 7.3 RAGとの比較

- **利点**: 検索レイテンシの排除、検索エラーの最小化。HotPotQA、SQuADでRAGと同等以上の精度を維持しつつ生成時間を短縮。
- **制限**: 知識ソース全体がコンテキストウィンドウに収まる必要がある。頻繁に更新されるコーパスには不向き。
- **使い分け**: 制約のある安定した知識ベースにはCAG、大規模・動的データにはRAGが適している。

---

## 8. チャンキング戦略の進化

### 8.1 最新のチャンキング手法

RAGの検索精度に大きく影響するチャンキング戦略も進化を続けている。

- **Fixed-size Chunking**: 固定長での分割（ベースライン）
- **Recursive Chunking**: 再帰的な分割（推奨される開始点）
- **Semantic Chunking**: 文の埋め込みの類似度に基づく意味的な分割。パーセンタイル、標準偏差、四分位範囲に基づく手法がある。
- **Late Chunking**: ヘッダー、代名詞、相互参照など、周囲のコンテキストなしでは曖昧になるチャンクに有効。効率性は高いが、関連性と完全性が犠牲になる傾向。
- **Contextual Retrieval**: 意味的な一貫性をより効果的に保持するが、計算リソースが大きい。

### 8.2 2025-2026年の推奨

実務的には、Recursive Chunkingから始め、構造認識型の分割を追加し、Semantic Chunkingで改善した上で、Contextual Retrieval、Late Chunking、Cross-granularity パターンの導入によりさらなる精度向上を図ることが推奨されている。

---

## 9. RAG評価手法

### 9.1 主要な評価フレームワーク

RAGシステムの評価手法も標準化が進んでいる。"Retrieval Augmented Generation Evaluation in the Era of Large Language Models: A Comprehensive Survey" (arXiv:2504.14891) では、従来および新興の評価アプローチが体系的にレビューされている。

#### RAGAS (Retrieval-Augmented Generation Assessment)

- リファレンスフリーの評価フレームワーク（人手による正解データが不要）
- 主要メトリクス: Context Precision, Context Recall, Faithfulness, Answer Relevancy
- LLMを評価者として活用し、人間の判断を近似

#### ARES (Automated RAG Evaluation System)

- RAGパイプラインの各コンポーネントに対してカスタマイズされたLLMジャッジを生成
- 評価スコア: Context Relevance, Answer Faithfulness, Answer Relevance
- Prediction-Powered Inferenceを活用した信頼区間の提供
- RAGASと比較して、Context Relevanceで平均59.3ポイント、Answer Relevanceで14.4ポイントの精度向上

### 9.2 2026年の評価ツール

2026年時点での主要なRAG評価プラットフォームとして、Maxim AI、LangSmith、Arize Phoenix、Ragas、DeepEvalが挙げられている。

---

## 10. 今後の研究課題と展望

### 10.1 未解決の課題

- **適応的検索アーキテクチャ**: タスクやクエリの性質に応じて検索戦略を動的に切り替える仕組み
- **リアルタイム検索統合**: ストリーミングデータソースとのリアルタイム統合
- **マルチホップ推論**: 構造化された推論を複数の証拠に対して行う手法の高度化
- **プライバシー保護型検索**: 個人情報を保護しながら検索を行うメカニズム
- **スケーラビリティ**: エンタープライズ規模での実用的なデプロイメント

### 10.2 将来の方向性

- **RAGからContext Engineへ**: RAGは「検索拡張生成」という特定のパターンから、「コンテキストエンジン」としてより広い概念へと変容しつつある
- **因果推論との統合**: RAGと因果推論モデルの組み合わせにより、関連データの検索だけでなく因果関係の分析も可能に
- **連合学習 (Federated Learning)**: 分散型RAGシステムの安全な運用のための技術
- **サステナビリティ**: エネルギー効率の良いアルゴリズムへの取り組み
- **強化学習による自己改善**: ユーザーインタラクションに基づいて検索戦略を洗練する自己改善型RAGシステム

---

## 11. まとめ

RAGは2025-2026年にかけて、単純な「検索+生成」のパイプラインから、エージェント型、グラフベース、マルチモーダルなど多様なアーキテクチャへと急速に進化している。ロングコンテキストLLMやCAGといった代替アプローチの登場にもかかわらず、RAGは動的で大規模なデータソースに対するコスト効率の高いアプローチとして引き続き重要な位置を占めている。今後は「コンテキストエンジン」としての役割がさらに拡大し、エンタープライズAIの中核技術としての地位を確立していくと考えられる。

---

## Sources

- [Retrieval-Augmented Generation: A Comprehensive Survey of Architectures, Enhancements, and Robustness Frontiers (arXiv:2506.00054)](https://arxiv.org/abs/2506.00054)
- [Agentic Retrieval-Augmented Generation: A Survey on Agentic RAG (arXiv:2501.09136)](https://arxiv.org/abs/2501.09136)
- [Retrieval Augmented Generation Evaluation in the Era of Large Language Models: A Comprehensive Survey (arXiv:2504.14891)](https://arxiv.org/abs/2504.14891)
- [From Local to Global: A Graph RAG Approach to Query-Focused Summarization (arXiv:2404.16130)](https://arxiv.org/abs/2404.16130)
- [Don't Do RAG: When Cache-Augmented Generation is All You Need for Knowledge Tasks (arXiv:2412.15605)](https://arxiv.org/abs/2412.15605)
- [Long Context vs. RAG for LLMs: An Evaluation and Revisits (arXiv:2501.01880)](https://arxiv.org/abs/2501.01880)
- [Corrective Retrieval Augmented Generation (arXiv:2401.15884)](https://arxiv.org/abs/2401.15884)
- [A Survey of Multimodal Retrieval-Augmented Generation (arXiv:2504.08748)](https://arxiv.org/abs/2504.08748)
- [Retrieval Augmented Generation and Understanding in Vision: A Survey and New Outlook (arXiv:2503.18016)](https://arxiv.org/abs/2503.18016)
- [A Systematic Review of Key Retrieval-Augmented Generation (RAG) Systems: Progress, Gaps, and Future Directions](https://arxiv.org/html/2507.18910v1)
- [Retrieval-Augmented Generation (RAG) - Business & Information Systems Engineering, Springer](https://link.springer.com/article/10.1007/s12599-025-00945-3)
- [Retrieval-Augmented Generation for AI-Generated Content: A Survey - Data Science and Engineering, Springer](https://link.springer.com/article/10.1007/s41019-025-00335-5)
- [RAG in 2026: Bridging Knowledge and Generative AI - Squirro](https://squirro.com/squirro-blog/state-of-rag-genai)
- [From RAG to Context - A 2025 year-end review of RAG - RAGFlow](https://ragflow.io/blog/rag-review-2025-from-rag-to-context)
- [The Ultimate RAG Blueprint: Everything you need to know about RAG in 2025/2026 - LangWatch](https://langwatch.ai/blog/the-ultimate-rag-blueprint-everything-you-need-to-know-about-rag-in-2025-2026)
- [GraphRAG - Microsoft](https://microsoft.github.io/graphrag/)
- [Project GraphRAG - Microsoft Research](https://www.microsoft.com/en-us/research/project/graphrag/)
- [Reconstructing Context: Evaluating Advanced Chunking Strategies for RAG (arXiv:2504.19754)](https://arxiv.org/abs/2504.19754)
- [RAG Evaluation: 2026 Metrics and Benchmarks for Enterprise AI Systems - Label Your Data](https://labelyourdata.com/articles/llm-fine-tuning/rag-evaluation)
- [The 5 Best RAG Evaluation Tools You Should Know in 2026 - Maxim AI](https://www.getmaxim.ai/articles/the-5-best-rag-evaluation-tools-you-should-know-in-2026/)
- [Multimodal RAG Survey - GitHub](https://github.com/llm-lab-org/Multimodal-RAG-Survey)
- [AgenticRAG-Survey - GitHub](https://github.com/asinghcsu/AgenticRAG-Survey)
