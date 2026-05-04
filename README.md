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
| [kintone-app-deploy](./skills/kintone-app-deploy/) | kintone アプリの実装・デプロイ実務プレイブック。被参照→参照のデプロイ順序、破壊的変更の 2 段階デプロイ（delete→deploy→re-add→deploy）、MCP ツール既知バグ（`unique` silent drop）回避策、`GAIA_LO03` / `GAIA_RE07` 切り分けフローを網羅 |
| [kintone-app-layout](./skills/kintone-app-layout/) | kintone フォームレイアウト実践ガイド。LABEL / HR の `size.width` 明示必須（デフォルト 74/135px で折返し）、インライン HTML/CSS で LABEL を見出し化、MULTI_LINE_TEXT の innerHeight 調整、10 種類のセクション設計テンプレ |

## Agents

| Agent | Description |
|-------|-------------|
| [kintone-architect](./agents/kintone-architect.md) | 要件・ユースケース → ドメインモデル → kintone アプリ構成までをオーケストレートするアーキテクト・エージェント。`domain-model` と `kintone-design` スキルを内部で併用し、5 フェーズ（要件取得 / モデリング / 翻訳 / 物理チェック / 成果物生成）で kintone 固有のアプリ構成を設計する |
| [kintone-engineer](./agents/kintone-engineer.md) | kintone 実装フェーズ担当エンジニア・エージェント。`kintone-architect` が**設計**したアプリ構成を受け取り、`kintone-app-deploy` + `kintone-app-layout` スキルを併用して**実機に物理化する**。6 フェーズ（入力確認 / デプロイ計画 / フィールド実装 / デプロイ実行 / レイアウト設計 / 検証引き渡し）で、依存順序・silent drop 検証・レイアウト仕上げを毎回安全に実行。architect(設計) と engineer(実装) の明確な役割分担で責務重複を回避 |

## Structure

```
agent-skills/
├── .claude-plugin/
│   └── marketplace.json       # Marketplace config (skills + agents)
├── README.md
├── agents/
│   ├── kintone-architect.md   # Designer: requirements → DDD → kintone app structure
│   └── kintone-engineer.md    # Implementer: structure → physical kintone (deploy + layout)
└── skills/
    ├── dig/                   # Plan ambiguity clarifier
    ├── eval-plan/             # Plan self-evaluation (100-point scoring)
    ├── code-review/           # 9-criteria code review
    ├── research/              # Source-quality-guaranteed research
    ├── claude-github-setup/   # GitHub Actions automation
    ├── domain-model/          # DDD domain modeling
    ├── ai-estimate/           # AI-driven effort estimation
    ├── kintone-design/        # kintone DDD mapping + physical checklist
    │   ├── SKILL.md
    │   ├── BENCHMARK.md       # Eval results (with_skill 100% vs without 63.2%)
    │   ├── evals/evals.json
    │   └── references/
    ├── kintone-app-deploy/    # Deploy order, two-phase migrations, MCP gotchas
    │   ├── SKILL.md
    │   └── references/        # deploy-order-playbook, mcp-gotchas, two-phase-migration
    └── kintone-app-layout/    # LABEL width, HTML styling, section design
        ├── SKILL.md
        └── references/        # layout-patterns, label-styling-cookbook, field-sizing-reference
```

## Installation

This repository supports three installation paths:

- **Claude Code Plugin**: install the whole Claude plugin marketplace, including Claude-only agents.
- **GitHub CLI `gh skill`**: install individual Agent Skills into Claude Code, Codex, or other supported agents.
- **`npx skills add`**: install skills locally or from GitHub without depending on the latest `gh` preview command.

The `skills/*/SKILL.md` directories are the shared source of truth. Claude plugin metadata in `.claude-plugin/` is kept for Claude Code plugin users, while `gh skill` and `npx skills add` discover the same skills directly.

### gh skill

Validate the repository before publishing:

```bash
cd ~/scraps/agent-skills
gh skill publish --dry-run
```

Install from GitHub:

```bash
# Claude Code, user scope
gh skill install ryoryo34/agent-skills kintone-design --agent claude-code --scope user

# Codex, user scope
gh skill install ryoryo34/agent-skills kintone-design --agent codex --scope user
```

Install from a local checkout while developing:

```bash
gh skill install . kintone-design --from-local --agent claude-code --scope user
gh skill install . kintone-design --from-local --agent codex --scope user
```

Publish a versioned release after validation passes:

```bash
gh skill publish --tag v1.0.0
```

### npx skills

List skills from the local checkout:

```bash
cd ~/scraps/agent-skills
npx skills add . --list
```

Install all shared skills into both Claude Code and Codex:

```bash
npx skills add . --skill '*' --agent claude-code --agent codex --global
```

Install selected skills from GitHub:

```bash
npx skills add ryoryo34/agent-skills \
  --skill kintone-design \
  --skill kintone-app-deploy \
  --agent claude-code \
  --agent codex \
  --global
```

Use `--copy` if you want independent copies instead of symlinks.

### Claude Code Plugin

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
