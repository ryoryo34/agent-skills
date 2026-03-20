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

## Structure

```
agent-skills/
├── .claude-plugin/
│   └── marketplace.json       # Marketplace config listing all skills
├── README.md
└── skills/
    ├── dig/                   # Plan ambiguity clarifier
    │   └── SKILL.md
    └── eval-plan/             # Plan self-evaluation (100-point scoring)
        └── SKILL.md
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

## Reference

- [Agent Skills Specification](https://agentskills.io/specification)
- [Anthropic's Skills Repository](https://github.com/anthropics/skills)
- [OpenAI's Skills Repository](https://github.com/openai/skills)
- [fumiya-kume/claude-code - dig command](https://github.com/fumiya-kume/claude-code/blob/master/dig/commands/dig.md) — dig スキルの参考元
