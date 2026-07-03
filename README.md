# agent-skills

This repository is a skills inventory for AI agents. It publishes one plugin package rooted at the repository root, backed by [Agent Skills](https://agentskills.io/specification).

## Skills

| Skill | Description |
|-------|-------------|
| [dig](./dig/) | Clarify ambiguities in plans with structured questions |
| [eval-plan](./eval-plan/) | Self-evaluate plans for completeness, consistency, and feasibility (100-point scoring) |
| [code-review](./code-review/) | 6-perspective multi-agent code review with confidence scoring and context-adaptive NFR checks |
| [research](./research/) | Source-quality-guaranteed research with reliability tiers and verification |
| [generalize-and-apply](./generalize-and-apply/) | 具体例・調査結果・競合パターンから共通原則を抽象化し、プロダクト/設計/意思決定へ再具体化する |
| [claude-github-setup](./claude-github-setup/) | Claude Code Action を使った GitHub 自動化セットアップ |
| [domain-model](./domain-model/) | DDD ベースの対話的ドメインモデル作成（言語ゲーム理論 + データ破壊駆動） |
| [ai-estimate](./ai-estimate/) | AI駆動開発の工数見積もり（ハイブリッドアジャイル + エピック分解 + Sprint計画 + 損益分析） |
| [tech-selection-table](./tech-selection-table/) | 技術選定・サービス比較のための転置型 CSV 比較表を作成（公式サイト調査 + 費用/API/スマホ対応 + 追加観点） |
| [ontology](./ontology/) | コードベースの知識グラフ（エンティティ + 型付き関係 + 制約）を `.claude/ontology/` に構築し、CLAUDE.md 注入で以降のセッションでも自動維持 |

## Agents

No agents are currently published.

## Structure

```text
agent-skills/
├── .agents/plugins/marketplace.json
├── .claude-plugin/
├── .codex-plugin/
├── apm.yml
├── README.md
├── ai-estimate/
├── claude-github-setup/
├── code-review/
├── dig/
├── domain-model/
├── eval-plan/
├── generalize-and-apply/
├── ontology/
├── research/
└── tech-selection-table/
```

## Installation

The repository root is the package. Each root-level skill directory is independently installable by APM, Claude Code, Codex, `gh skills`, and `npx skills`.

### Recommended: gh skills

```bash
gh skills publish --dry-run
gh skills install ryoryo34/agent-skills research --agent claude-code --scope user
gh skills install ryoryo34/agent-skills research --agent codex --scope user
```

`gh skill` is the canonical command group; `gh skills` is its alias.

### Alternative: npx skills

```bash
npx skills add . --list
npx skills add . --all --global
npx skills add ryoryo34/agent-skills --skill research --agent claude-code codex --global --yes
```

### APM

```bash
apm install -g ryoryo34/agent-skills/research
apm install
apm run verify
```

### Plugins

Codex and Claude plugin manifests are included for installing the whole repository as a plugin:

```text
.agents/plugins/marketplace.json
.codex-plugin/plugin.json
.claude-plugin/marketplace.json
.claude-plugin/plugin.json
```

Codex marketplace policy marks this plugin as `RECOMMENDED`.

## Adding a New Skill

1. Create a new directory at the repository root
2. Add a `SKILL.md` with frontmatter (`name`, `description`)
3. Add `references/`, `scripts/`, `assets/`, or `evals/` as needed
4. **Bump the version** in `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, and `apm.yml` — installed copies only pick up changes via `claude plugin update` when the version increases (see `CLAUDE.md` for the semver rule)
5. Run the validation commands below

## Validation

```bash
claude plugin validate .
npx skills add . --list
gh skills publish --dry-run
```

## Reference

- [Agent Skills Specification](https://agentskills.io/specification)
- [Anthropic's Skills Repository](https://github.com/anthropics/skills)
- [OpenAI's Skills Repository](https://github.com/openai/skills)
- [fumiya-kume/claude-code - dig command](https://github.com/fumiya-kume/claude-code/blob/master/dig/commands/dig.md) — dig スキルの参考元
