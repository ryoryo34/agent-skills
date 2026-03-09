# RAG (Retrieval-Augmented Generation) 最新研究動向レポート

## 1. 概要

Retrieval-Augmented Generation (RAG) は、大規模言語モデル (LLM) の生成時に外部知識を検索・参照することで、事実性の向上やドメイン適応を実現するパラダイムである。2024年後半から2026年初頭にかけて、RAG研究は単純な「検索して生成する」パイプラインから、エージェント型・グラフ型・マルチモーダル型などの高度なアーキテクチャへと急速に進化している。

本レポートでは、最新の研究動向を以下の7つのテーマに分類して整理する。

---

## 2. RAG アーキテクチャの進化

### 2.1 Naive RAG から Modular RAG へ

RAG の発展は、大きく3世代に分類される。

- **Naive RAG**: 単純な検索 + 生成のパイプライン
- **Advanced RAG**: クエリ書き換え、リランキング、コンテキストフィルタリングなどの最適化を導入
- **Modular RAG**: 検索、メモリ、ルーティング、予測、タスクアダプタなど、柔軟に組み合わせ可能なモジュールで構成

Sharma (2025) による包括的サーベイでは、RAG アーキテクチャを「検索器中心型」「生成器中心型」「ハイブリッド型」「ロバスト性指向型」に分類する体系的な taxonomy が提示されている。

**参考文献:**
- [Retrieval-Augmented Generation: A Comprehensive Survey of Architectures, Enhancements, and Robustness Frontiers (arXiv:2506.00054)](https://arxiv.org/abs/2506.00054)

### 2.2 RAPTOR: 階層的要約ツリー

RAPTOR は、検索対象文書の階層的な要約ツリーを構築するアプローチで、GPT-4 を用いた QuALITY ベンチマークにおいて精度を20%向上させた実績がある。

---

## 3. Agentic RAG (エージェント型RAG)

### 3.1 概念と設計パターン

Agentic RAG は、従来の RAG パイプラインに自律的な AI エージェントを組み込むことで、動的な意思決定とワークフロー最適化を実現するパラダイムである。主要な設計パターンとして以下が挙げられる。

- **リフレクション (Reflection)**: 生成結果を自己評価し、必要に応じて再検索・再生成
- **プランニング (Planning)**: 複雑なクエリを分解し、段階的に検索・推論を実行
- **ツール使用 (Tool Use)**: 外部ツール（検索エンジン、データベース等）を動的に選択・利用
- **マルチエージェント協調**: 複数の専門エージェントが協調して情報を収集・統合

**参考文献:**
- [Agentic Retrieval-Augmented Generation: A Survey on Agentic RAG (arXiv:2501.09136)](https://arxiv.org/abs/2501.09136)

### 3.2 A-RAG: 階層的検索インターフェース

A-RAG (2026年2月) は、モデルに対して keyword_search、semantic_search、chunk_read の3種類の階層的検索ツールを直接公開し、エージェントが複数の粒度で適応的に検索できるフレームワークである。

**参考文献:**
- [A-RAG: Scaling Agentic Retrieval-Augmented Generation via Hierarchical Retrieval Interfaces (arXiv:2602.03442)](https://arxiv.org/html/2602.03442v1)

### 3.3 MA-RAG: マルチエージェント協調推論

MA-RAG は、複数の専門エージェントが協調的な Chain-of-Thought 推論を通じて、複雑な情報探索タスクにおける曖昧さや推論の課題に対処するフレームワークである。階層的エージェント RAG は、フラットまたは単一エージェントのベースラインと比較して、ドメイン QA やマルチモーダル QA タスクで一貫して5～13ポイントの改善を報告している。

**参考文献:**
- [MA-RAG: Multi-Agent Retrieval-Augmented Generation via Collaborative Chain-of-Thought Reasoning (arXiv:2505.20096)](https://arxiv.org/abs/2505.20096)

---

## 4. GraphRAG (グラフ型RAG)

### 4.1 Microsoft GraphRAG

Microsoft が提唱した GraphRAG は、テキストからエンティティ-リレーション知識グラフを自動構築し、コミュニティ検出と階層的要約を組み合わせることで、従来の RAG では困難だったグローバルな質問（データセット全体にまたがるテーマの要約等）に対応する。

主な特徴:
- LLM によるエンティティ知識グラフの自動抽出
- コミュニティ検出による意味的クラスタリング
- 階層的要約による多段階の回答生成
- マルチホップ QA でベースライン比6.4ポイントのリコール向上

**参考文献:**
- [From Local to Global: A Graph RAG Approach to Query-Focused Summarization (arXiv:2404.16130)](https://arxiv.org/abs/2404.16130)
- [Microsoft GraphRAG Project](https://www.microsoft.com/en-us/research/project/graphrag/)

### 4.2 GraphRAG vs 従来の RAG

比較研究では、GraphRAG はマルチホップ QA や複雑な要約タスクで従来の RAG を上回る一方、細粒度のファクトイド情報検索では従来の RAG が優位であることが示されている。

---

## 5. 自己修正型 RAG

### 5.1 Self-RAG

Self-RAG は、LLM にリフレクショントークンと呼ばれる特殊トークンを導入し、オンデマンドでの適応的な文書検索、生成結果の自己評価・自己批判を実現するフレームワークである。

**参考文献:**
- [Self-RAG: Learning to Retrieve, Generate, and Critique through Self-Reflection (arXiv:2310.11511)](https://arxiv.org/abs/2310.11511)

### 5.2 Corrective RAG (CRAG)

CRAG は、軽量な検索評価器を設計し、検索された文書の品質を信頼度スコアとして評価する。スコアに応じて以下のアクションを動的に切り替える:

- **高信頼度**: 検索結果をそのまま使用
- **低信頼度**: Web 検索による補完的な検索を実行
- **曖昧**: 分解・再構成アルゴリズムにより重要情報を選択的に抽出

**参考文献:**
- [Corrective Retrieval Augmented Generation (arXiv:2401.15884)](https://arxiv.org/abs/2401.15884)

---

## 6. 強化学習による RAG の最適化

2025年に入り、強化学習 (RL) を用いて RAG システムの検索・生成を最適化する研究が活発化している。

### 6.1 R3-RAG

R3-RAG は、RL を用いて LLM にステップバイステップの推論と検索を学習させ、包括的な外部知識の検索と事実に基づく回答生成を可能にする。

**参考文献:**
- [R3-RAG: Learning Step-by-Step Reasoning and Retrieval for LLMs via Reinforcement Learning](https://arxiv.org/html/2505.23794)

### 6.2 RAG-RL

RAG-RL は、カリキュラム学習と組み合わせた RL で回答生成モデルを訓練する。最初に関連コンテキストのみを含む簡易な例で訓練し、段階的に難易度を上げることで、引用スキルと推論能力をサンプル効率よく獲得させる。

**参考文献:**
- [RAG-RL: Advancing Retrieval-Augmented Generation via RL and Curriculum Learning (arXiv:2503.12759)](https://arxiv.org/abs/2503.12759)

### 6.3 RAG-Reward

RAG-Reward は、RAG における生成品質を評価する4つの主要指標を定義し、複数の LLM を活用した自動アノテーションパイプラインで報酬モデルを訓練、RLHF を適用してハルシネーション低減と包括的な回答生成を実現する。

**参考文献:**
- [RAG-Reward: Optimizing RAG with Reward Modeling and RLHF](https://arxiv.org/html/2501.13264v1)

---

## 7. マルチモーダル RAG

### 7.1 テキストを超えた検索拡張

マルチモーダル RAG は、テキストだけでなく画像、音声、動画、テーブルデータを統合的に検索・活用するアプローチである。2025-2026年にかけて急速に研究が進展している。

### 7.2 MMed-RAG: 医療分野への応用

MMed-RAG は、医療 Vision-Language モデルの事実性向上のために設計されたマルチモーダル RAG システムであり、5つの医療データセットで平均43.8%の事実性精度向上を達成した。ドメイン認識型検索メカニズム、適応的コンテキスト選択、RAG ベースの選好ファインチューニング戦略を組み合わせている。ICLR 2025 に採択された。

**参考文献:**
- [MMed-RAG: Versatile Multimodal RAG System for Medical Vision Language Models (arXiv:2410.13085)](https://arxiv.org/abs/2410.13085)
- [MMed-RAG (ICLR 2025)](https://proceedings.iclr.cc/paper_files/paper/2025/hash/a559a5a8aa5ae6682ced009ad97cdb16-Abstract-Conference.html)

### 7.3 マルチモーダル RAG サーベイ

マルチモーダル RAG のサーベイプロジェクトでは、データセット、ベンチマーク、評価指標、検索・融合・拡張・生成の方法論とイノベーションを体系的に分析している。

**参考文献:**
- [Multimodal-RAG-Survey (GitHub)](https://github.com/llm-lab-org/Multimodal-RAG-Survey)

---

## 8. ロングコンテキスト LLM vs RAG

### 8.1 論争の現状

Gemini のリリース以降、ロングコンテキスト LLM が RAG を不要にするかという議論が続いている。しかし、最新の研究では以下の知見が得られている:

- **ロングコンテキスト LLM** は、Wikipedia ベースの質問応答など特定のベンチマークで RAG を上回る
- **RAG** は、対話型クエリや一般的な質問で優位性を持つ
- **両者は相補的**: ロングコンテキストは RAG のコンテキストウィンドウを拡大し、設計の可能性を広げる
- **万能な解決策は存在しない**: 最適な選択はモデルサイズ、タスク種別、データの動的性等に依存する

### 8.2 RAG からコンテキストエンジンへ

2025年末のレビューでは、RAG は「Retrieval-Augmented Generation」という特定パターンから、「インテリジェント検索」を核とする「コンテキストエンジン」へと変容しつつあると指摘されている。

**参考文献:**
- [Long Context vs. RAG for LLMs: An Evaluation and Revisits (arXiv:2501.01880)](https://arxiv.org/abs/2501.01880)
- [From RAG to Context - A 2025 year-end review of RAG (RAGFlow)](https://ragflow.io/blog/rag-review-2025-from-rag-to-context)
- [Long Context RAG Performance of LLMs (Databricks Blog)](https://www.databricks.com/blog/long-context-rag-performance-llms)

---

## 9. RAG のセキュリティとロバスト性

### 9.1 データポイズニング攻撃

RAG システムの外部知識ソースに悪意ある情報を注入する攻撃が深刻な脅威として認識されている。

- **PoisonedRAG**: 数百万件のテキストを含む知識ベースに、ターゲット質問あたりわずか5件の悪意あるテキストを注入するだけで、NQ で97%、HotpotQA で99%、MS-MARCO で91%の攻撃成功率を達成
- **CorruptRAG** (2026年1月): たった1件の汚染テキスト注入で攻撃が成立する手法を提案し、実用性とステルス性を大幅に向上
- **PoisonedEye** (2025年中頃): Vision-Language RAG システムを標的とした初のナレッジポイズニング攻撃

### 9.2 防御戦略

効果的な防御には、モデルの再訓練や変更ではなく、エンベディング対応フィルタリングとクエリ-レスポンス分析が重要であるとされている。

**参考文献:**
- [PoisonedRAG (USENIX Security 2025)](https://www.usenix.org/system/files/usenixsecurity25-zou-poisonedrag.pdf)
- [RAG Security and Privacy: Formalizing the Threat Model and Attack Surface](https://arxiv.org/pdf/2509.20324)

---

## 10. RAG 評価の最前線

RAG システムの評価手法も進化しており、以下の領域で新しいアプローチが提案されている:

- **従来の評価指標**: 検索精度 (Precision, Recall, MRR) と生成品質 (BLEU, ROUGE, BERTScore)
- **新興評価手法**: 検索認識型評価、ロバスト性テスト、連合検索設定での評価
- **忠実性評価**: エージェント型 RAG パイプラインにおけるステートメントレベルのハルシネーション・冗長性の定量化

**参考文献:**
- [Retrieval Augmented Generation Evaluation in the Era of Large Language Models: A Comprehensive Survey (arXiv:2504.14891)](https://arxiv.org/abs/2504.14891)

---

## 11. 今後の研究課題

最新のサーベイ論文群から浮かび上がる主要な今後の研究課題:

1. **適応的検索アーキテクチャ**: クエリの複雑さに応じて検索戦略を動的に切り替える機構
2. **リアルタイム検索統合**: ストリーミングデータやリアルデータフィードとの連携
3. **マルチホップ推論の構造化**: 複数文書にまたがるエビデンスの構造的推論
4. **プライバシー保護型検索**: 連合学習や差分プライバシーを活用した安全な検索機構
5. **ロバスト性の向上**: 敵対的入力やノイズの多い検索結果に対する耐性
6. **検索精度と生成柔軟性のトレードオフ**: 両者のバランスを動的に最適化する仕組み
7. **クロスモーダル RAG の実用化**: テキスト以外のモダリティ（画像、音声、動画）を含む統合的な検索拡張

---

## 12. まとめ

RAG 研究は2024-2026年にかけて大きな転換期を迎えている。主要な潮流を整理すると:

| カテゴリ | 代表的手法 | 特徴 |
|---------|-----------|------|
| Agentic RAG | A-RAG, MA-RAG | 自律エージェントによる動的な検索・推論の制御 |
| GraphRAG | Microsoft GraphRAG | 知識グラフを活用したグローバルな文脈理解 |
| 自己修正型 | Self-RAG, CRAG | 検索結果の品質評価と動的な戦略切替 |
| RL 最適化 | R3-RAG, RAG-RL | 強化学習による検索・生成の端対端最適化 |
| マルチモーダル | MMed-RAG | テキスト以外のモダリティの統合的活用 |
| セキュリティ | PoisonedRAG, CorruptRAG | 攻撃手法の高度化と防御策の研究 |

従来の「検索して生成する」単純なパイプラインから、エージェント的な推論、グラフ構造の活用、強化学習による自己改善、マルチモーダル対応へと、RAG は LLM の基盤インフラストラクチャとしての地位を確立しつつある。

---

## 参考文献一覧

- [Retrieval-Augmented Generation: A Comprehensive Survey of Architectures, Enhancements, and Robustness Frontiers (arXiv:2506.00054)](https://arxiv.org/abs/2506.00054)
- [Agentic Retrieval-Augmented Generation: A Survey on Agentic RAG (arXiv:2501.09136)](https://arxiv.org/abs/2501.09136)
- [Retrieval Augmented Generation Evaluation in the Era of Large Language Models (arXiv:2504.14891)](https://arxiv.org/abs/2504.14891)
- [A-RAG: Scaling Agentic RAG via Hierarchical Retrieval Interfaces (arXiv:2602.03442)](https://arxiv.org/html/2602.03442v1)
- [MA-RAG: Multi-Agent RAG via Collaborative Chain-of-Thought Reasoning (arXiv:2505.20096)](https://arxiv.org/abs/2505.20096)
- [From Local to Global: A Graph RAG Approach to Query-Focused Summarization (arXiv:2404.16130)](https://arxiv.org/abs/2404.16130)
- [Microsoft GraphRAG Project](https://www.microsoft.com/en-us/research/project/graphrag/)
- [Self-RAG: Learning to Retrieve, Generate, and Critique through Self-Reflection (arXiv:2310.11511)](https://arxiv.org/abs/2310.11511)
- [Corrective Retrieval Augmented Generation (arXiv:2401.15884)](https://arxiv.org/abs/2401.15884)
- [R3-RAG: Learning Step-by-Step Reasoning and Retrieval via RL](https://arxiv.org/html/2505.23794)
- [RAG-RL: Advancing RAG via RL and Curriculum Learning (arXiv:2503.12759)](https://arxiv.org/abs/2503.12759)
- [RAG-Reward: Optimizing RAG with Reward Modeling and RLHF](https://arxiv.org/html/2501.13264v1)
- [MMed-RAG: Versatile Multimodal RAG System for Medical Vision Language Models (arXiv:2410.13085)](https://arxiv.org/abs/2410.13085)
- [Multimodal-RAG-Survey (GitHub)](https://github.com/llm-lab-org/Multimodal-RAG-Survey)
- [Long Context vs. RAG for LLMs: An Evaluation and Revisits (arXiv:2501.01880)](https://arxiv.org/abs/2501.01880)
- [From RAG to Context - A 2025 year-end review of RAG (RAGFlow)](https://ragflow.io/blog/rag-review-2025-from-rag-to-context)
- [Long Context RAG Performance of LLMs (Databricks Blog)](https://www.databricks.com/blog/long-context-rag-performance-llms)
- [PoisonedRAG (USENIX Security 2025)](https://www.usenix.org/system/files/usenixsecurity25-zou-poisonedrag.pdf)
- [RAG Security and Privacy: Formalizing the Threat Model and Attack Surface](https://arxiv.org/pdf/2509.20324)
- [Retrieval-Augmented Generation for AI-Generated Content: A Survey (Springer)](https://link.springer.com/article/10.1007/s41019-025-00335-5)
- [Retrieval-Augmented Generation (RAG) (Springer BISE)](https://link.springer.com/article/10.1007/s12599-025-00945-3)
- [Awesome-RAG-Reasoning (EMNLP 2025, GitHub)](https://github.com/DavidZWZ/Awesome-RAG-Reasoning)
