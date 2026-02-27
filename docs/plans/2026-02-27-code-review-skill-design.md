# Code Review Skill Design

## Overview

9 observation checklist-driven code review skill. Reviews code changes (diffs/PRs) using prioritized criteria derived from the user's ADR-based review philosophy integrated with industry best practices (Google, OWASP 2025, Microsoft Research, SmartBear/Cisco).

## Priority Order

| # | Criteria | Focus |
|---|----------|-------|
| 1 | Spec-Code Alignment | Requirements match, edge cases, doc sync |
| 2 | Security | OWASP-aligned, auth/authz, input validation, supply chain |
| 3 | RASIS | Error handling, data integrity, concurrency, graceful degradation |
| 4 | Cost Efficiency | Algorithmic complexity, N+1, caching, implementation simplicity |
| 5 | SOLID | Single responsibility, dependency direction, abstraction level |
| 6 | YAGNI | Scope limitation, no speculative code, no over-abstraction |
| 7 | DRY | Deduplication, constants, automation |
| 8 | Best Practices | Idiomatic code, framework patterns, linter/formatter alignment |
| 9 | Readability | Naming, comments (Why not What), cognitive complexity |

## File Structure

```
skills/code-review/
├── SKILL.md                    # Skill body (workflow definition)
└── references/
    └── review-criteria.md      # 9-criteria detailed checklist (Progressive Disclosure)
```

## SKILL.md Frontmatter

```yaml
---
name: code-review
description: >
  9-criteria checklist-driven code review.
  Evaluates: spec alignment, security, RASIS, cost, SOLID, YAGNI, DRY, best practices, readability.
  Use when reviewing code changes, PRs, or diffs.
  Triggers: "code-review", "review this", "review"
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion
context: fork
user-invocable: true
---
```

Key decisions:
- `context: fork` — Isolated execution, no main context pollution
- No `Edit` tool — Review-only, no code modification
- `Bash` — Required for `git diff`, `git log`
- `references/` for Progressive Disclosure pattern

## Workflow: 4 Phases

```
Phase 1: Scope  →  Phase 2: Scan  →  Phase 3: Report  →  Phase 4: Action
```

### Phase 1: Scope

Identify review target:
1. `git diff` for unstaged changes
2. `git diff --staged` for staged changes
3. `git diff <base>...<head>` if branch comparison specified
4. Collect changed files and line counts
5. Warn if diff > 400 lines (suggest per-file review)

### Phase 2: Scan

Apply 9 criteria in priority order:
1. Load `references/review-criteria.md`
2. Read changed files with surrounding context
3. Apply each criterion sequentially (1 → 9)
4. Record: file path, line number, criterion, severity, description

### Phase 3: Report

Severity classification (eval-plan pattern):

| Level | Symbol | Meaning |
|-------|--------|---------|
| Must Fix | `RED_CIRCLE` | Blocks merge |
| Should Fix | `YELLOW_CIRCLE` | Degrades quality but not broken |
| Nit | `BULB` | Improvement suggestion, optional |

Output format:
```
## Code Review Report
### Scope
### Summary (counts by severity)
### Must Fix (grouped)
### Should Fix (grouped)
### Nit (grouped)
```

Each issue: `**[Criterion]** file:line — description`

### Phase 4: Action

Present options via AskUserQuestion:
- Start fixing Must Fix items
- Save report as-is
- Get detailed explanation for specific issues
- Mark review complete (no issues)

## Research Basis

- Checklist-driven reviews: +66.7% defect detection (SmartBear/Cisco)
- Optimal PR size: < 400 LOC (accuracy drops beyond)
- 75% of review-detected defects affect maintainability (Google)
- Missing context is #1 review issue for 65% of devs (Qodo 2025)
- OWASP 2025: Broken Access Control (#1, 3.73%), Supply Chain Failures (new A03)
