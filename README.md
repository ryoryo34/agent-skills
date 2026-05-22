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
| [kintone-design](./kintone-design/) | kintone アプリ設計を DDD 視点で支援（概念マッピング + CQRS/ES 用語警告 + 物理設計チェックリスト + アンチパターン集） |
| [kintone-app-deploy](./kintone-app-deploy/) | kintone アプリの実装・デプロイ実務プレイブック。被参照→参照のデプロイ順序、破壊的変更の 2 段階デプロイ（delete→deploy→re-add→deploy）、MCP ツール既知バグ（`unique` silent drop）回避策、`GAIA_LO03` / `GAIA_RE07` 切り分けフローを網羅 |
| [kintone-app-layout](./kintone-app-layout/) | kintone フォームレイアウト実践ガイド。LABEL / HR の `size.width` 明示必須（デフォルト 74/135px で折返し）、インライン HTML/CSS で LABEL を見出し化、MULTI_LINE_TEXT の innerHeight 調整、10 種類のセクション設計テンプレ |

## Agents

| Agent | Description |
|-------|-------------|
| [kintone-architect](./agents/kintone-architect.md) | 要件・ユースケース → ドメインモデル → kintone アプリ構成までをオーケストレートするアーキテクト・エージェント。`domain-model` と `kintone-design` スキルを内部で併用し、5 フェーズ（要件取得 / モデリング / 翻訳 / 物理チェック / 成果物生成）で kintone 固有のアプリ構成を設計する |
| [kintone-engineer](./agents/kintone-engineer.md) | kintone 実装フェーズ担当エンジニア・エージェント。`kintone-architect` が**設計**したアプリ構成を受け取り、`kintone-app-deploy` + `kintone-app-layout` スキルを併用して**実機に物理化する**。6 フェーズ（入力確認 / デプロイ計画 / フィールド実装 / デプロイ実行 / レイアウト設計 / 検証引き渡し）で、依存順序・silent drop 検証・レイアウト仕上げを毎回安全に実行。architect(設計) と engineer(実装) の明確な役割分担で責務重複を回避 |

## Structure

```
agent-skills/
├── .claude-plugin/
│   ├── marketplace.json       # Claude marketplace
│   └── plugin.json            # Claude plugin manifest
├── .agents/
│   └── plugins/marketplace.json # Codex marketplace
├── .codex-plugin/
│   └── plugin.json            # Codex plugin manifest
├── apm.yml                    # APM local development manifest
├── README.md
├── agents/
│   ├── kintone-architect.md
│   └── kintone-engineer.md
├── ai-estimate/
├── claude-github-setup/
├── code-review/       # 6-perspective code review
├── dig/
├── domain-model/
├── eval-plan/
├── generalize-and-apply/
├── kintone-app-deploy/
├── kintone-app-layout/
├── kintone-design/
└── research/
```

## Installation

This repository supports these installation paths:

- **APM (Agent Package Manager)**: install individual skills from GitHub, or install all local skills from `apm.yml` while developing.
- **Claude Code Plugin**: install the whole Claude plugin marketplace, including Claude-only agents.
- **Codex Plugin**: install the local Codex plugin marketplace backed by the root skill directories.
- **GitHub CLI `gh skill`**: install individual Agent Skills into Claude Code, Codex, or other supported agents.
- **`npx skills add`**: install skills locally or from GitHub without depending on the latest `gh` preview command.

The repository root is the plugin package. Each root-level skill directory is independently installable, which keeps the layout close to `mizchi/skills` and convenient for APM, Claude Code, Codex, `gh skill`, `npx skills`, documentation links, and humans browsing the repo.

### APM

This repository follows the APM-friendly layout used by [mizchi/skills](https://github.com/mizchi/skills): each root-level skill directory is a standalone Agent Skill with its own `SKILL.md`, optional `references/`, optional `scripts/`, optional `assets/`, and optional `evals/`.

Install an individual skill from GitHub:

```bash
# Global / user scope
apm install -g ryoryo34/agent-skills/kintone-design

# Pin to a tag
apm install -g ryoryo34/agent-skills/kintone-design#v1.0.0
```

Add selected skills to another project's `apm.yml`:

```yaml
targets:
  - claude
  - codex

dependencies:
  apm:
    - ryoryo34/agent-skills/kintone-design
    - ryoryo34/agent-skills/kintone-app-deploy
    - ryoryo34/agent-skills/kintone-app-layout
```

Install all local skills from this checkout while developing:

```bash
cd ~/scraps/agent-skills
apm install
apm run verify
```

`apm install` reads this repository's `apm.yml` and installs the local `./<skill-name>` packages for the declared targets. Commit `apm.lock.yaml` after running `apm install` when you want teammates or CI to resolve the same package versions.

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

Use `--copy` if you want independent copies instead of linked local installs.

### Codex Plugin

The Codex plugin marketplace is defined at:

```bash
.agents/plugins/marketplace.json
```

It registers this repository root as the plugin package. The Codex plugin manifest at `.codex-plugin/plugin.json` points at the repository root and exposes directories that contain `SKILL.md`.

#### CodexでPluginを追加

Codex はリポジトリルートの `.agents/plugins/marketplace.json` を marketplace として読み込む。ローカルでこのリポジトリを開くと、このリポジトリ自体が Codex plugin として表示される。

1. Codex でこのリポジトリを開く
2. Plugin / Marketplace 画面で **Ryoryo Agent Skills** を選ぶ
3. **Agent Skills** plugin を install / enable する
4. 新しいスレッドを開始するか、Codex を再読み込みして反映を確認する

Codex plugin として認識されるために必要なファイルは以下:

```bash
.agents/plugins/marketplace.json
.codex-plugin/plugin.json
<skill-name>/SKILL.md
```

`marketplace.json` には repository root への相対パスを登録する:

```json
{
  "name": "agent-skills",
  "source": {
    "source": "local",
    "path": "./"
  },
  "policy": {
    "installation": "AVAILABLE",
    "authentication": "ON_INSTALL"
  },
  "category": "Productivity"
}
```

`plugin.json` 側では、Codex に公開する探索ルートを指定する:

```json
{
  "name": "agent-skills",
  "skills": "./"
}
```

このリポジトリではルートディレクトリが Claude Code と Codex の共有 plugin package なので、スキルを追加するときはリポジトリ直下に `<skill-name>/SKILL.md` を追加すればよい。

### Claude Code Plugin

The Claude marketplace is defined at:

```bash
.claude-plugin/marketplace.json
```

It registers this repository root as the plugin package. The Claude plugin manifest lives at `.claude-plugin/plugin.json`; skills are kept as root-level directories to match the APM package paths, and Claude-only agents remain under `agents/`.

### 1. Marketplaceを追加

```bash
claude plugin marketplace add https://github.com/ryoryo34/agent-skills/
```

### 2. Pluginをインストール

```bash
claude plugin install agent-skills@ryoryo-agent-skills
```

スコープを指定することもできるよ：

```bash
# ユーザースコープ（デフォルト）- 全プロジェクトで利用可能
claude plugin install agent-skills@ryoryo-agent-skills --scope user

# プロジェクトスコープ - チームで共有（.claude/settings.json に記録）
claude plugin install agent-skills@ryoryo-agent-skills --scope project
```

### 3. インストール確認

Claude Code内で `/plugin` を実行すると、**Installed** タブからインストール済みpluginを確認できる。

### アンインストール

```bash
claude plugin uninstall agent-skills@ryoryo-agent-skills
```

## Adding a New Skill

1. Create a new skill directory at the repository root
2. Add a `SKILL.md` with frontmatter (`name`, `description`)
3. Add `references/` or `scripts/` as needed
4. Add the local path to `dependencies.apm` in `apm.yml` if the skill should be installed by the local APM bundle
5. Run the validation commands below; plugin consumers, APM, `gh skill`, and `npx skills` all discover root-level skill directories from the repository root

## Adding a New Agent

1. Add a new `.md` file under `agents/`
2. Include frontmatter (`name`, `description` with triggers, `model`, `color`)
3. Write the agent's system prompt in the body
4. Run the validation commands below; Claude plugin consumers discover `agents/` from the repository root

Agents differ from skills: agents are full orchestrators invoked via the Task tool and can internally reference multiple skills (e.g., `kintone-architect` uses `domain-model` + `kintone-design` together).

## Validation

```bash
apm install --dry-run
claude plugin validate .
npx skills add . --list
gh skill publish --dry-run
```

## Reference

- [Agent Skills Specification](https://agentskills.io/specification)
- [mizchi/skills](https://github.com/mizchi/skills) — APM-ready skill repository layout and install examples
- [APM (Agent Package Manager)](https://github.com/apm-sh/apm)
- [Anthropic's Skills Repository](https://github.com/anthropics/skills)
- [OpenAI's Skills Repository](https://github.com/openai/skills)
- [fumiya-kume/claude-code - dig command](https://github.com/fumiya-kume/claude-code/blob/master/dig/commands/dig.md) — dig スキルの参考元
