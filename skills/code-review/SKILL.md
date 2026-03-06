---
name: code-review
description: 9-criteria checklist-driven code review. Evaluates spec alignment, security, RASIS, cost, SOLID, YAGNI, DRY, best practices, readability. Use when reviewing code changes, PRs, or diffs. Triggers include "code-review", "review this", "review my code".
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion
context: fork
---

# Code Review — Checklist-Driven

Review code changes using 9 prioritized criteria. Apply each criterion in order, report findings by severity.

## Phase 1: Scope

Identify the review target.

1. Check for argument: if a branch name or commit range is provided, use `git diff <base>...<head>`
2. Otherwise, check `git diff --staged` first, then `git diff` for unstaged changes
3. If no diff is found, ask the user what to review via AskUserQuestion
4. Collect changed file list and line counts: `git diff --stat`
5. If total changed lines > 400, warn and suggest per-file review

Output:

```
## Review Scope
- Target: [branch comparison / staged / unstaged]
- Files changed: [N]
- Lines: +[added] / -[deleted]
- Languages: [detected from extensions]
```

## Phase 2: Scan

Apply 9 criteria in priority order against the diff.

1. Read `references/review-criteria.md` for the full checklist
2. Read `references/anti-patterns.md` for common anti-pattern signatures
3. For each changed file:
   a. Read the file with surrounding context (not just the diff lines)
   b. Apply criteria 1-9 sequentially
   c. For each detected issue, record:
      - File path and line number
      - Criterion name (1-9)
      - Severity: 🔴 Must Fix / 🟡 Should Fix / 💡 Nit
      - 1-2 sentence description of the problem and recommendation

### Severity Guide

| Severity | When to use |
|----------|-------------|
| 🔴 Must Fix | Correctness bug, security vulnerability, data loss/corruption risk, spec violation that breaks functionality |
| 🟡 Should Fix | Poor error handling, performance concern, design smell, missing test for critical path, silent failure |
| 💡 Nit | Naming improvement, comment suggestion, minor style inconsistency, readability enhancement |

### Scan Rules

- Do NOT flag issues in unchanged code (only review the diff)
- Do NOT flag style issues that a linter/formatter should catch (delegate to tooling)
- DO consider context around changed lines (callers, related functions)
- DO cross-reference against `references/anti-patterns.md` when applying each criterion
- If a criterion has no issues, skip it silently (do not output "no issues found")

## Phase 3: Report

Output the review report in the following format:

```
## Code Review Report

### Scope
- Target: [branch / staged / unstaged]
- Files: [N] changed (+[added] / -[deleted])

### Summary
- 🔴 Must Fix: [N]
- 🟡 Should Fix: [N]
- 💡 Nit: [N]

### 🔴 Must Fix

1. **[Criterion]** `file/path.ts:LINE` — [Description of the problem and what should change]
2. ...

### 🟡 Should Fix

1. **[Criterion]** `file/path.ts:LINE` — [Description and recommendation]
2. ...

### 💡 Nit

1. **[Criterion]** `file/path.ts:LINE` — [Suggestion]
2. ...
```

### Report Rules

- Group issues by severity, not by file
- Within each severity group, order by criterion priority (1 first, 9 last)
- Each issue: exactly 1-2 sentences. If more explanation is needed, the user can ask in Phase 4
- Omit severity sections with zero issues
- If zero issues found across all severities, output: "No issues detected. Code looks good."

## Phase 4: Action

After the report, present next options via AskUserQuestion:

Options:
1. "Start fixing Must Fix items" — transition to implementation mode
2. "Explain a specific issue in detail" — user picks an issue number for deeper explanation
3. "Save report and finish" — review complete
4. "Review complete (no issues)" — only if zero issues found

## Important Notes

- **Language**: Follow CLAUDE.md preference. Fallback to English if unspecified
- **Scope discipline**: Only review code in the diff. Do not expand scope to unrelated files
- **Actionable feedback**: Every issue must include what should change, not just what is wrong
- **No false positives**: If uncertain, do not flag it. Precision over recall
- **Proportional effort**: Spend more time on criteria 1-3 (highest priority) than 7-9
