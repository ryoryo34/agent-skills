# Root Cause (Why) Patterns

A catalog of root cause patterns for detecting improvement candidates from conversations.

## Root Cause Categories

### 1. Lack of Project-Specific Knowledge

**Typical Stumbling Points**:
- User explains "This project uses XX"
- Proposed wrong libraries or patterns
- Wrote code that violates project conventions

**Why**: Claude doesn't know project-specific tool choices, conventions, or patterns

**Output Type Guidance**:
- **CLAUDE.md** (most common): Static conventions, library choices, tech stack decisions
  - Example: "Always use pnpm, not npm" / "Use Tailwind CSS for styling"
  - → 常に知っているべき知識。セッション開始時に読み込まれる
- **Skill**: Complex setup procedures (e.g., "set up a new module following our conventions")
  - → ユーザーが呼び出す手順。呼び出し時にのみ読み込まれる
- **Agent**: Rarely. Only for autonomous convention enforcement

### 2. Lack of Domain Knowledge / Business Rules

**Typical Stumbling Points**:
- User repeatedly explains business terminology
- Made incorrect assumptions about business logic
- Misunderstood relationships between domain entities

**Why**: Claude doesn't know the project's domain model or business rules

**Output Type Guidance**:
- **CLAUDE.md**: Stable glossary, core domain invariants, key business rules
  - Example: "An Order must always have at least one LineItem"
  - → 常に知っているべきドメイン知識
- **Skill** (`user-invocable: false`): Large domain knowledge base. Claude auto-loads when relevant
  - → 量が多い場合は Skill の Progressive Disclosure で効率的に提供
- **Agent**: Domain-specific reviewer (autonomous compliance checking)

### 3. Insufficient Understanding of Type Definitions / Schemas

**Typical Stumbling Points**:
- Repeatedly fixed type errors
- Misunderstood API response structure
- Misunderstood database schema

**Why**: Claude doesn't know the project's type definitions, schemas, or data structures

**Output Type Guidance**:
- **CLAUDE.md**: Key type conventions, schema naming patterns
  - Example: "All API responses follow the { data, error, meta } envelope"
- **Skill** (`user-invocable: false`): Detailed type definitions as reference content
  - → 型情報が多い場合は Skill reference files でオンデマンド読み込み
- **Agent**: Type-checking or schema-validation agent

### 4. Insufficient Understanding of Workflows / Procedures

**Typical Stumbling Points**:
- Skipped steps in the process
- Proceeded without meeting prerequisites
- Didn't know project-specific workflows

**Why**: Claude doesn't know project-specific procedures or dependencies

**Output Type Guidance**:
- **CLAUDE.md**: Simple procedural reminders ("always run tests before committing")
- **Skill** (most common): Multi-step workflows with user interaction
  - Example: deployment workflow, PR review procedure, release process
  - → Task content。ユーザーが /deploy 等で呼び出す
- **Agent**: Autonomous workflow executor (e.g., CI pipeline agent)
  - → 独立コンテキストで自律実行。ユーザー介入不要な場合

### 5. Lack of Architectural Decision Context

**Typical Stumbling Points**:
- Couldn't answer "Why is it like this?"
- Proposed alternatives that were already considered
- Proposed changes that contradict design intent

**Why**: Claude doesn't know the rationale or trade-offs behind architectural decisions

**Output Type Guidance**:
- **CLAUDE.md** (most common): Architectural constraints, design principles
  - Example: "We chose SSR over SPA because of SEO requirements"
- **Skill** (`user-invocable: false`): Detailed ADRs as reference content
  - → ADR が多い場合は Skill reference でオンデマンド提供
- **Agent**: Architecture review agent

### 6. Lack of Implicit Conventions / Practices

**Typical Stumbling Points**:
- Code review feedback: "We do it this way here"
- Didn't know team's implicit understandings
- Violated undocumented rules

**Why**: Claude doesn't know unwritten conventions or team practices

**Output Type Guidance**:
- **CLAUDE.md** (most common): Do's and don'ts, naming rules, formatting
  - Example: "Commit messages in Japanese" / "Use kebab-case for file names"
  - → .claude/rules/*.md でモジュラーに管理も可能
- **Skill**: Complex convention-following workflows
- **Agent**: Convention enforcement agent (read-only tools)

## Capture Criteria

### When to Capture

| Root Cause | Criteria |
|-----------|----------|
| Project-specific | This knowledge isn't useful in other projects |
| Recurring | Same stumbling point occurred 2+ times |
| Solvable with knowledge | Problem wouldn't have occurred if known beforehand |
| Stable knowledge | Knowledge that doesn't change frequently |

### When Not to Capture

| Situation | Reason |
|-----------|--------|
| One-time problem | Not worth capturing if it won't recur |
| Frequently changing information | High maintenance cost |
| Claude's general knowledge | Something Claude already knows |
| Context-dependent judgment | Requires different judgment each time |

## Output Type Discrimination

### Context Loading Model (判別の核心)

| タイプ | 起動時 | 呼び出し時 | コンテキスト分離 |
|-------|--------|-----------|--------------|
| CLAUDE.md | 全文読み込み | N/A (常に存在) | なし (メイン会話と同居) |
| Skill | description のみ | SKILL.md 本文読み込み | なし (inline) or あり (context: fork) |
| Agent | description のみ | 独立コンテキスト生成 | あり (常に独立) |

### Decision Tree

```
Root cause identified
├─ Does Claude need this knowledge in EVERY session?
│  ├─ YES: Is it concise enough for always-on context? (< ~50 lines)
│  │  ├─ YES → **CLAUDE.md** (.claude/rules/*.md for modularity)
│  │  └─ NO → **Skill** (reference content, `user-invocable: false`)
│  │     → 大量の知識は Progressive Disclosure で提供
│  └─ NO: Is it triggered by a specific user action?
│     ├─ YES → **Skill** (task content, user invokes with /name)
│     └─ NO: Does it need autonomous execution in isolated context?
│        ├─ YES → **Agent** (own context window, tool restrictions)
│        └─ NO → **Skill** (`user-invocable: false`, Claude auto-loads)
└─ Could multiple types work together?
   └─ YES → **Layered proposal** (primary + companion)
```

### Type Comparison Matrix

| Characteristic | CLAUDE.md | Skill | Agent |
|---------------|-----------|-------|-------|
| Context loading | Session start (full) | On-demand (description at startup) | On-demand (own context) |
| Context cost | Always consumes tokens | Description only until invoked | Description only until delegated |
| Invocation | Automatic | User (/name) or Claude (auto) | Claude delegates via Task tool |
| Context isolation | None (shared) | None (inline) or forked | Always isolated |
| Interaction | Passive | Interactive (AskUserQuestion) | Minimal (autonomous) |
| Progressive Disclosure | No (full text always) | Yes (SKILL.md → references/) | No (system prompt is fixed) |
| Location | CLAUDE.md, .claude/rules/*.md | skills/*/SKILL.md | .claude/agents/*.md |

### Discrimination Signals

| Signal | Points to | Context rationale |
|--------|-----------|------------------|
| "Always do X" / "Never do Y" | CLAUDE.md | 常に知っているべき |
| Naming, formatting, style preferences | CLAUDE.md | 毎回の作業で必要 |
| Library/framework selection rationale | CLAUDE.md | 常に正しい選択をするために必要 |
| Large reference documentation | Skill (reference) | オンデマンドでコンテキスト効率化 |
| Step-by-step process users trigger | Skill (task) | ユーザーが明示的に呼び出す |
| Background knowledge Claude auto-loads | Skill (`user-invocable: false`) | 関連時にのみ読み込み |
| Autonomous review/checking/enforcement | Agent | 独立コンテキストで自律実行 |
| Tasks needing restricted tool access | Agent | ツール制限で安全性確保 |
| Complex orchestration without user involvement | Agent | 独立した長時間タスク |
| Convention + enforcement workflow together | Layered | 知識(CLAUDE.md) + 手順(Skill/Agent) |

## Analysis Checklist

Checklist for analyzing conversations:

- [ ] Where did the user request corrections or fixes?
- [ ] Why didn't Claude know that?
- [ ] Could we have done it correctly from the start with this knowledge?
- [ ] Is this problem likely to occur again?
- [ ] Can't we handle this by improving existing CLAUDE.md/agents/skills?
- [ ] Does Claude need this knowledge in every session? (→ CLAUDE.md)
- [ ] Is the knowledge volume appropriate for always-on context? (large → Skill)
- [ ] What type of artifact best captures this knowledge? (Apply decision tree)
- [ ] Is the type assignment correct? (Apply simplicity principle)
- [ ] Does this need a layered proposal (multiple types)?
