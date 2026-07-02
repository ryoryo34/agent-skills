---
name: code-review
description: Multi-agent parallel code review with 6 specialist perspectives (Correctness, Security, Performance, Maintainability, Readability, Reliability) + confidence scoring. Each agent reviews independently, findings are filtered by confidence threshold to eliminate false positives, then synthesized into a single prioritized report. Use for DEEP, thorough reviews of large or risky changes — when the user asks for "multi-agent review", "deep review", "thorough review", "6-perspective review", "マルチエージェントレビュー", "精密レビュー", "徹底レビュー", "6視点レビュー", or explicitly names this skill ("agent-skills code-review"). Do NOT trigger on casual review requests like "レビューして" or "review this" — those should use the built-in /code-review, which is faster and cheaper for everyday diffs.
allowed-tools: Read, Glob, Grep, Bash, Agent, AskUserQuestion
context: fork
license: MIT
---

# Multi-Agent Code Review

Review code changes by dispatching 6 specialist agents in parallel, each focused on a distinct quality dimension. Findings are confidence-scored and filtered to eliminate false positives, then synthesized into a single prioritized report.

## Why multi-agent?

A single reviewer trying to catch everything — from logic bugs to SQL injection to N+1 queries — suffers from attention dilution. Research shows that specialized agents with non-overlapping detection patterns improve accuracy by ~40 percentage points over a single generalist (CodeX-Verify, 2025). By giving each agent a focused checklist and running them in parallel, we get deeper analysis without sacrificing speed.

## Phase 1: Scope & Context Detection

Identify the review target and detect project context to guide agent behavior.

1. Check for argument: if a branch name or commit range is provided, use `git diff <base>...<head>`
2. Otherwise, check `git diff --staged` first, then `git diff` for unstaged changes
3. If no diff is found, ask the user what to review via AskUserQuestion
4. Collect changed file list and line counts: `git diff --stat`
5. If total changed lines > 500, warn and suggest splitting the review
6. Read `references/context-rules.md` for context detection rules
7. Apply Stage 1 (file pattern matching) to categorize changed files
8. Apply Stage 2 (project exploration) using Read, Glob, Grep to detect:
   - Framework and libraries (package.json, go.mod, etc.)
   - Existing observability setup (logger imports)
   - i18n configuration (locales directory, i18n libraries)
   - API definitions (OpenAPI, protobuf, GraphQL schemas)
   - Health check implementations

### Stage 3: Repository-Internal Context Enrichment

For each changed function/method in the diff, collect surrounding context **from the repository内** that the agents will need to make accurate judgments. Research shows that providing callers/callees alongside the diff improves key bug inclusion by 2x over diff-only review.

Scope: **リポジトリ内のソースコードのみ**。外部仕様書・設計書・API ドキュメント等は対象外。

1. For each changed file, use Grep to find:
   - **Callers（呼び出し元）**: リポジトリ内で変更された関数/メソッドを呼び出している箇所
   - **Callees（呼び出し先）**: 変更されたコードが呼び出している関数/メソッドの実装
2. For each changed file, use Read to collect **surrounding context** (the full function/class containing the change, not just the diff lines)
3. Compile the enriched context into a summary to pass to agents

Keep this lightweight — aim for the most relevant 5-10 callers/callees per file, not an exhaustive dependency graph. If the diff is small (<50 lines), a quick Grep for function references is sufficient.

Output (keep this for Phase 2 agent dispatch):

```
## Review Scope
- Target: [branch comparison / staged / unstaged]
- Files changed: [N]
- Lines: +[added] / -[deleted]
- Languages: [detected from extensions]
- Context categories: [API/Backend, Frontend, Infrastructure, Library, Data/DB]
- Project signals: [e.g., "Next.js detected", "i18n not configured"]

## Enriched Context
[For each changed file, list key callers and callees found]
```

## Phase 2: Parallel Agent Dispatch

Launch 6 specialist agents simultaneously using the Agent tool. Each agent reviews the entire diff from its perspective.

**Important**: Dispatch all 6 agents in a single message (parallel tool calls). Do NOT wait for one agent before launching the next.

Each agent receives:
- The diff command to run (from Phase 1)
- The detected context categories and project signals
- Path to its specialist reference file under `references/agents/`
- The anti-patterns catalog path: `references/anti-patterns.md`
- Instructions to output findings in the standard format (see below)

### Agent Dispatch Template

For each agent, use the Agent tool with `subagent_type: "general-purpose"` and the following prompt structure:

```
You are a specialist code reviewer focused on [DIMENSION].

## Your Task
Review the code changes and identify issues in your area of expertise.

## Getting the Diff
Run: `git diff [DIFF_TARGET]` (from the skill's working directory)
Also run: `git diff --stat [DIFF_TARGET]` for file overview

## Context
[Insert scope output from Phase 1, including enriched context (callers/callees)]

## Your Checklist
Read the file at [SKILL_DIR]/references/agents/[AGENT].md for your detailed checklist.
Also read [SKILL_DIR]/references/anti-patterns.md for anti-pattern signatures relevant to your dimension.

## Scan Rules
- Only review code in the diff — do NOT flag issues in unchanged code
- Do NOT flag style issues that a linter/formatter should catch
- DO use the enriched context (callers/callees) provided above to understand the change's impact
- If needed, read additional surrounding context (the full file, related modules) to verify your findings
- If a criterion has no issues, skip it silently
- Spend proportionally more effort on higher-priority items in your checklist

## Scope Boundaries
Stay within YOUR dimension. Do not report issues that belong to another agent:
- Correctness owns: spec alignment, test quality, edge cases, API compatibility
- Security owns: auth, injection, XSS, secrets, data privacy, PII in logs
- Performance owns: algorithm complexity, N+1, resource management, scalability, timeouts
- Maintainability owns: SOLID, YAGNI, DRY, architectural structure, a11y, i18n
- Readability owns: naming clarity, cognitive load, local code flow, comments, test readability
- Reliability owns: error handling, resource cleanup, resilience, observability, operability

If an issue spans two dimensions (e.g., PII in logs is both Security and Reliability), report it from YOUR dimension's angle only. The coordinator will merge overlapping findings.

## Deduplication Rule for Same-Pattern Issues
When the same type of issue (e.g., SQL injection) appears in multiple locations, report it as ONE finding listing all affected lines — not one finding per location.

## Output Format
For each issue found, output EXACTLY this format (one per issue):

### [ISSUE_TITLE]
- **File**: `path/to/file.ext:LINE` (list multiple lines if same pattern repeats: `path:L1,L2,L3`)
- **Confidence**: [0-100]
- **Severity**: [MUST_FIX / SHOULD_FIX / NIT]
- **Category**: [your dimension name]
- **Description**: [1-2 sentences: what is wrong and what should change]
- **Example** (optional but encouraged for MUST_FIX/SHOULD_FIX):
  ```
  // Before (problematic)
  [1-3 lines of the actual problematic code]
  // After (recommended)
  [1-3 lines showing the fix]
  ```

### Confidence Scoring Guide
- 0-25: Uncertain — might be intentional or context-dependent
- 26-50: Plausible — looks like an issue but could be a false positive
- 51-75: Likely real — clear code smell or potential problem
- 76-90: High confidence — definitely an issue with clear impact
- 91-100: Certain — provably incorrect, exploitable, or violates specification

Be conservative. A false positive wastes the developer's time. If you're not sure, score lower.

If no issues are found in your area, output: "No issues detected in [DIMENSION]."
```

### The 6 Agents

| Agent | Reference File | Focus |
|-------|---------------|-------|
| Correctness | `references/agents/correctness.md` | Spec alignment, test quality, edge cases, API compatibility |
| Security | `references/agents/security.md` | Auth, injection, XSS, secrets, data privacy |
| Performance | `references/agents/performance.md` | Algorithm complexity, N+1, resource management, scalability |
| Maintainability | `references/agents/maintainability.md` | SOLID, YAGNI, DRY, architectural structure, a11y, i18n |
| Readability | `references/agents/readability.md` | Naming clarity, cognitive load, code flow, comments, test readability |
| Reliability | `references/agents/reliability.md` | Error handling, resource cleanup, resilience, observability, operability |

## Phase 3: Synthesize

After all 6 agents return, the coordinator (you) processes the results.

### Step 1: Collect all findings

Parse each agent's output and collect all findings into a single list.

### Step 2: Filter by confidence

Remove all findings with Confidence < 80. This threshold eliminates most false positives while retaining high-signal issues. (The threshold is deliberately high — precision over recall.)

### Step 3: Deduplicate

Aggressively deduplicate to produce a clean, non-redundant report:

1. **Same file:line, same root cause** — Merge into one finding. Keep the higher confidence score. Credit the most relevant agent (the one whose dimension best owns the issue).
2. **Same pattern across multiple lines** (e.g., SQL injection in 5 places) — Already consolidated by agents (per dispatch rules). If an agent still reported separately, merge into one finding listing all affected lines.
3. **Same issue from different dimensions** (e.g., PII in logs flagged by both Security and Reliability) — Keep only ONE finding under the primary owning dimension. Use this ownership map:
   - Input validation / injection / auth / secrets / PII → **Security**
   - Logic bugs / edge cases / test quality / API compat → **Correctness**
   - Complexity / N+1 / resource usage / scalability → **Performance**
   - SOLID / DRY / architectural structure → **Maintainability**
   - Naming / cognitive load / local code flow / comment clarity → **Readability**
   - Error handling / resource cleanup / resilience / observability → **Reliability**

### Step 4: Classify severity

Apply final severity using this guide:

| Severity | When to use |
|----------|-------------|
| MUST_FIX | Correctness bug, security vulnerability, data loss/corruption risk, spec violation that breaks functionality |
| SHOULD_FIX | Poor error handling, performance concern, design smell, missing test for critical path, silent failure |
| NIT | Naming improvement, minor style inconsistency, small readability enhancement |

## Phase 4: Report

Output the final review report:

```markdown
## Code Review Report

### Scope
- Target: [branch / staged / unstaged]
- Files: [N] changed (+[added] / -[deleted])
- Agents: Correctness, Security, Performance, Maintainability, Readability, Reliability

### Summary
- MUST_FIX: [N]
- SHOULD_FIX: [N]
- NIT: [N]
- Filtered (low confidence): [N]

### Verdict: [Ready to Merge / Needs Attention / Needs Work]

### MUST_FIX

1. **[Category]** `file/path.ts:LINE` (confidence: [N]) — [Description]
   ```
   // Before
   [problematic code]
   // After
   [recommended fix]
   ```
2. ...

### SHOULD_FIX

1. **[Category]** `file/path.ts:LINE` (confidence: [N]) — [Description]
2. ...

### NIT

1. **[Category]** `file/path.ts:LINE` (confidence: [N]) — [Description]
2. ...
```

### Verdict Rules

- **Ready to Merge**: 0 MUST_FIX, 0-2 SHOULD_FIX
- **Needs Attention**: 0 MUST_FIX, 3+ SHOULD_FIX
- **Needs Work**: 1+ MUST_FIX

### Report Rules

- Group issues by severity, not by agent
- Within each severity group, order by confidence (highest first)
- Each issue: exactly 1-2 sentences for description
- **MUST_FIX items**: include a Before/After code example showing the problematic code and recommended fix (agents provide these; if missing, add them during synthesis)
- **SHOULD_FIX items**: include code examples when the fix is non-obvious
- Omit severity sections with zero issues
- If zero issues found across all severities after filtering, output: "No issues detected. Code looks good."
- Show the count of filtered-out findings so the user knows what was suppressed

## Phase 5: Action

After the report, present next options via AskUserQuestion:

1. "Start fixing MUST_FIX items" — transition to implementation mode
2. "Explain a specific issue in detail" — user picks an issue number for deeper explanation
3. "Show filtered findings" — reveal the low-confidence findings that were suppressed
4. "Save report and finish" — review complete

## Important Notes

- **Language**: Follow CLAUDE.md preference. Fallback to English if unspecified
- **Scope discipline**: Only review code in the diff. Do not expand scope to unrelated files
- **Actionable feedback**: Every issue must include what should change, not just what is wrong
- **No false positives**: The confidence threshold exists for a reason. Precision over recall
- **Context-aware NFR**: Each agent integrates relevant NFR criteria based on detected context (see agent reference files). If context doesn't match, the agent skips those NFR checks
- **Cost awareness**: 6 parallel agents consume more tokens than a single-pass review. For very small diffs (<20 lines), consider whether a simpler review is more appropriate
