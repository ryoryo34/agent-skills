# agent-skills

This repository is a skills inventory for AI agents. It aggregates multiple [Agent Skills](https://agentskills.io/specification) in a single marketplace.

## Skills

| Skill | Description |
|-------|-------------|
| [dig](./skills/dig/) | Clarify ambiguities in plans with structured questions |
| [eval-plan](./skills/eval-plan/) | Self-evaluate plans for completeness, consistency, and feasibility (100-point scoring) |
| [code-review](./skills/code-review/) | 9-criteria + context-adaptive NFR checklist-driven code review |
| [research](./skills/research/) | Source-quality-guaranteed research with reliability tiers and verification |
| [claude-github-setup](./skills/claude-github-setup/) | Claude Code Action を使った GitHub 自動化セットアップ |
| [domain-model](./skills/domain-model/) | DDD ベースの対話的ドメインモデル作成（言語ゲーム理論 + データ破壊駆動） |
| [ai-estimate](./skills/ai-estimate/) | AI駆動開発の工数見積もり（ハイブリッドアジャイル + エピック分解 + Sprint計画 + 損益分析） |
| [kintone-design](./skills/kintone-design/) | kintone アプリ設計を DDD 視点で支援（概念マッピング + CQRS/ES 用語警告 + 物理設計チェックリスト + アンチパターン集）。iteration-2 (3 走行/設定) で **100% (57/57) vs without_skill 66.7% (38/57)**、標準偏差 0.00。詳細は [BENCHMARK.md](./skills/kintone-design/BENCHMARK.md) |

## Agents

| Agent | Description |
|-------|-------------|
| [kintone-architect](./agents/kintone-architect.md) | 要件・ユースケース → ドメインモデル → kintone アプリ構成までをオーケストレートするアーキテクト・エージェント。`domain-model` と `kintone-design` スキルを内部で併用し、5 フェーズ（要件取得 / モデリング / 翻訳 / 物理チェック / 成果物生成）で kintone 固有のアプリ構成を設計する |

## Structure

```
agent-skills/
├── .claude-plugin/
│   └── marketplace.json       # Marketplace config (skills + agents)
├── README.md
├── agents/
│   └── kintone-architect.md   # Orchestrator: requirements → kintone apps
└── skills/
    ├── dig/                   # Plan ambiguity clarifier
    ├── eval-plan/             # Plan self-evaluation (100-point scoring)
    ├── code-review/           # 9-criteria code review
    ├── research/              # Source-quality-guaranteed research
    ├── claude-github-setup/   # GitHub Actions automation
    ├── domain-model/          # DDD domain modeling
    ├── ai-estimate/           # AI-driven effort estimation
    └── kintone-design/        # kintone DDD mapping + physical checklist
        ├── SKILL.md
        ├── BENCHMARK.md       # Eval results (with_skill 100% vs without 63.2%)
        ├── evals/evals.json
        └── references/
```

## Installation

### 1. Marketplaceを追加

```bash
claude plugin marketplace add https://github.com/ryoryo34/agent-skills/
```

### 2. Pluginをインストール

```bash
claude plugin install agent-skills@ryoryo-marketplace
```

スコープを指定することもできるよ：

```bash
# ユーザースコープ（デフォルト）- 全プロジェクトで利用可能
claude plugin install agent-skills@ryoryo-marketplace --scope user

# プロジェクトスコープ - チームで共有（.claude/settings.json に記録）
claude plugin install agent-skills@ryoryo-marketplace --scope project
```

### 3. インストール確認

Claude Code内で `/plugin` を実行すると、**Installed** タブからインストール済みpluginを確認できる。

### アンインストール

```bash
claude plugin uninstall agent-skills@ryoryo-marketplace
```

## Adding a New Skill

1. Create a new directory under `skills/`
2. Add a `SKILL.md` with frontmatter (`name`, `description`)
3. Add `references/` or `scripts/` as needed
4. Register the skill in `.claude-plugin/marketplace.json`

## Adding a New Agent

1. Add a new `.md` file under `agents/`
2. Include frontmatter (`name`, `description` with triggers, `model`, `color`)
3. Write the agent's system prompt in the body
4. Register the agent in `.claude-plugin/marketplace.json` under `plugins[].agents`

Agents differ from skills: agents are full orchestrators invoked via the Task tool and can internally reference multiple skills (e.g., `kintone-architect` uses `domain-model` + `kintone-design` together).

## Reference

- [Agent Skills Specification](https://agentskills.io/specification)
- [Anthropic's Skills Repository](https://github.com/anthropics/skills)
- [OpenAI's Skills Repository](https://github.com/openai/skills)
- [fumiya-kume/claude-code - dig command](https://github.com/fumiya-kume/claude-code/blob/master/dig/commands/dig.md) — dig スキルの参考元
