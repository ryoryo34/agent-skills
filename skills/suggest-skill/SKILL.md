---
name: suggest-skill
description: Analyze conversations and suggest improvement candidates -- CLAUDE.md rules, Agents, or Skills (evaluation-driven development). Use when asked to suggest skills, analyze conversation for improvements, find repeating patterns, or identify automation opportunities.
allowed-tools: Read, Glob, Grep
---

# Improvement Suggestion (Evaluation-Driven Development)

Analyze conversations to identify **root causes (Why) of Claude's failures** and propose **CLAUDE.md rules, Agents, or Skills** as improvements.

## Analysis Perspective: Why, Not What

Focus on the underlying causes (Why) rather than surface phenomena (What).

| What (Phenomenon) | Why (Root Cause) |
|------------------|------------------|
| Repeatedly wrote the same code | Didn't know project-specific patterns |
| Repeatedly fixed errors | Didn't understand project's type definitions or conventions |
| Repeatedly explained the same thing | Lacked domain knowledge or business rules |
| Repeatedly discussed decisions | Didn't know the background of architectural decisions |
| Made workflow mistakes | Didn't know project-specific procedures |
| Repeatedly gave the same sequence of instructions | Claude lacked a defined process for this task |
| Had to redo work after skipping steps | Didn't know prerequisites or quality gates |
| Coordinated multi-step task incorrectly | Didn't know dependencies between steps |

## Analysis Process

### Step 1: Identify "Stumbling Points" in the Conversation

Look for the following signals:

- Places where the user requested corrections or fixes
- Places where the user provided additional explanations
- Places that required multiple exchanges
- Places where Claude made incorrect assumptions

Workflow-specific signals (process failures, not just knowledge gaps):

- User repeatedly dictated the same sequence of steps across tasks
- Claude skipped steps, did steps out of order, or missed prerequisites
- Claude didn't perform expected validation, testing, or review steps
- User had to explain dependencies between actions or tools

### Step 2: Analyze Root Causes (Why)

For each stumbling point, ask:

1. **Why didn't Claude know this?**
   - Because it's project-specific knowledge
   - Because it's domain-specific rules
   - Because implicit conventions exist
   - Because a defined process or procedure is missing

2. **Could we have done it correctly from the start if we had this knowledge?**
   - Yes → Worth capturing
   - No → A different approach is needed

3. **Is this a process/workflow problem rather than a knowledge problem?**
   - Did the failure come from missing steps, wrong order, or skipped gates? → Workflow issue
   - Did the failure come from not knowing a fact, convention, or rule? → Knowledge issue
   - Hint: If the fix is "define a procedure" → workflow. If the fix is "provide a fact" → knowledge
   - Workflow issues point toward **Skills** (defined procedures) or **Agents** (autonomous executors)

4. **What is the nature of this knowledge?** (Type Discrimination)

   Key question: **Does Claude need this knowledge in every session?**
   - YES + concise → **CLAUDE.md**
   - YES + large volume → **Skill** (reference content, Progressive Disclosure)
   - NO + user triggers → **Skill** (task content)
   - NO + autonomous → **Agent**

   See `references/patterns.md` > "Output Type Discrimination" for the full decision tree and signals table.

5. **Can existing CLAUDE.md/agents/skills handle this?**
   - Yes → Propose updating existing artifacts
   - No → Propose creating a new artifact

6. **Would this knowledge be useful in other contexts?**
   - Yes → Valuable as a general-purpose artifact
   - No → A one-time fix is sufficient

### Step 3: Determine Output Type

Apply the decision tree from `references/patterns.md` > "Output Type Discrimination":

1. **Does Claude need this in EVERY session?**
   - YES + concise (< ~50 lines) → **CLAUDE.md** (or `.claude/rules/*.md`)
   - YES + large volume → **Skill** (`user-invocable: false`, reference content)
2. **Is it triggered by a specific user action?**
   - YES → **Skill** (task content, user invokes with `/name`)
3. **Does it need autonomous execution in isolated context?**
   - YES → **Agent** (own context window, tool restrictions)
4. **Otherwise** → **Skill** (`user-invocable: false`, Claude auto-loads)
5. **Could multiple types complement each other?** → **Layered proposal**

**Simplicity principle**: When in doubt, prefer CLAUDE.md > Skill > Agent.
**Context cost awareness**: CLAUDE.md always consumes context. For large knowledge, prefer Skill's Progressive Disclosure.

### Step 4: Generate Proposals

For each root cause, generate the appropriate proposal type:

#### CLAUDE.md Rule Proposal

```markdown
## CLAUDE.md Rule: [Rule Name]
**Stumbling Point**: [...]
**Root Cause (Why)**: [...]
**Why CLAUDE.md** (not Skill/Agent):
[This knowledge is needed in every session / concise enough for always-on context]
**Proposed Rule**:
> [The exact text to add to CLAUDE.md or .claude/rules/]
**Placement**: [CLAUDE.md section / .claude/rules/[filename].md]
**Priority**: [High/Medium/Low]
```

#### Agent Proposal

```markdown
## Agent: [Agent Name]
**Stumbling Point**: [...]
**Root Cause (Why)**: [...]
**Why Agent** (not CLAUDE.md/Skill):
[Needs isolated context / tool restrictions / autonomous execution]
**Proposal**:
- name: [agent-name]
- description: [role and purpose -- include "proactively" if auto-delegation desired]
- tools: [allowed tools]
- disallowedTools: [denied tools, if any]
- model: [sonnet/haiku/inherit]
- Responsibilities: [...]
- Trigger: [when Claude should delegate to this agent]
**Priority**: [High/Medium/Low]
```

#### Skill Proposal

```markdown
## Skill: [Name]
**Stumbling Point**: [...]
**Root Cause (Why)**: [...]
**Why Skill** (not CLAUDE.md/Agent):
[On-demand knowledge / user-triggered workflow / Progressive Disclosure needed]
**Skill subtype**: [reference content / task content]
**Proposal**:
- name: [skill-name]
- description: [description]
- user-invocable: [true/false -- false for background reference]
- disable-model-invocation: [true/false -- true for side-effect workflows]
- context: [inline/fork]
- Knowledge to include:
  - [ ] [Specific knowledge, conventions, patterns]
**Priority**: [High/Medium/Low]
```

#### Existing Artifact Update

```markdown
## Update: [Artifact Name] ([CLAUDE.md/Agent/Skill])
**Target**: [Path to existing artifact]
**Stumbling Point**: [...]
**Root Cause (Why)**: [...]
**Update Content**: Knowledge to add / Sections to fix
**Priority**: [High/Medium/Low]
```

#### Layered Proposal

```markdown
## Layered Proposal: [Name]
**Stumbling Point**: [...]
**Root Cause (Why)**: [Why multiple types needed]
**Primary**: [type] -- [description]
**Companion**: [type] -- [description]
[Include templates for each component]
```

## Output Format

```markdown
# Improvement Proposal Report

## Analysis Summary
- Identified stumbling points: [number]
- Root cause categories: [list]
- Proposals by type:
  - CLAUDE.md rules: [n] (new: [n], updates: [n])
  - Agents: [n] (new: [n], updates: [n])
  - Skills: [n] (new: [n], updates: [n])

## Root Cause Analysis
### Stumbling Point 1: [Problem]
- **What**: [surface]
- **Why**: [root cause]
- **Recommended type**: [CLAUDE.md / Agent / Skill]
- **Type rationale**: [one-sentence reason based on context loading model]

## CLAUDE.md Rule Proposals
## Agent Proposals
## Skill Proposals
## Layered Proposals

## Next Actions
- [ ] Confirm root cause validity with user
- [ ] Review type assignments (context loading appropriateness)
- [ ] For CLAUDE.md rules: Add to CLAUDE.md or .claude/rules/*.md
- [ ] For Agents: Create .claude/agents/[name].md
- [ ] For Skills: Create skills/[name]/SKILL.md or edit existing
```

## Notes

- Don't propose improvements based solely on surface patterns (What)
- Always ask "Why didn't Claude know this?"
- Don't capture one-time problems
- **Prioritize updating existing artifacts over creating new ones when existing artifacts can solve the problem**
- In existing artifact update proposals, clearly specify sections to add or fix
- **Default to the simplest type**: CLAUDE.md > Skill > Agent
- **Context cost awareness**: CLAUDE.md always consumes context. For large knowledge, use Skill's Progressive Disclosure
- Every proposal must include a "Why [type]" rationale based on context loading model
- When unsure between types, explain the trade-off and let the user decide
- Skill proposals should specify subtype (reference content vs task content) and invocation settings
