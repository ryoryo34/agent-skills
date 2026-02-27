# Code Review Skill Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a 9-criteria checklist-driven code review skill that reviews diffs/PRs by priority order (spec alignment → security → RASIS → cost → SOLID → YAGNI → DRY → best practices → readability).

**Architecture:** Single SKILL.md with `context: fork` for isolated execution, plus `references/review-criteria.md` for Progressive Disclosure of the detailed checklist. Follows the eval-plan pattern for severity classification (Must Fix / Should Fix / Nit).

**Tech Stack:** Agent Skills Specification (SKILL.md frontmatter), Markdown, git CLI

---

### Task 1: Create references/review-criteria.md

**Files:**
- Create: `skills/code-review/references/review-criteria.md`

**Step 1: Create directory structure**

Run: `mkdir -p skills/code-review/references`
Expected: Directory created, no output

**Step 2: Write the review criteria reference file**

Create `skills/code-review/references/review-criteria.md` with the following content:

```markdown
# Code Review Criteria

9-criteria checklist in priority order. Apply each criterion to the diff sequentially.

## Severity Classification

| Level | Symbol | Meaning | Action |
|-------|--------|---------|--------|
| Must Fix | 🔴 | Blocks merge — correctness bug, security vulnerability, data loss risk | Fix before merge |
| Should Fix | 🟡 | Degrades quality — poor error handling, performance issue, design smell | Strongly recommended |
| Nit | 💡 | Improvement suggestion — naming, style, minor readability | Optional |

## 1. Spec-Code Alignment

- [ ] Implementation matches the PR description / linked issue / user story
- [ ] Edge cases are handled (null, empty, zero, negative, max values, off-by-one)
- [ ] Alternative flows and failure scenarios are considered
- [ ] Related tests are added or updated for the change
- [ ] Related documentation (API spec, README, etc.) is updated
- [ ] No unintended side effects on existing behavior

## 2. Security

- [ ] User input is validated and sanitized (allow-list approach)
- [ ] SQL queries are parameterized (no string concatenation)
- [ ] Authentication and authorization checks are in place
- [ ] No hardcoded secrets, API keys, or passwords
- [ ] XSS prevention (output encoding, CSP) where applicable
- [ ] No known vulnerabilities in added/updated dependencies
- [ ] Logs do not contain PII, tokens, or passwords
- [ ] Session management is correct (token entropy, expiration, cookie flags)

## 3. RASIS (Reliability, Availability, Serviceability, Integrity, Security)

- [ ] Errors are caught and handled with specific exception types (no silent swallowing)
- [ ] Resources (DB connections, file handles, streams) are cleaned up (try-finally, using, defer)
- [ ] External calls have timeout, retry, and circuit breaker where appropriate
- [ ] Data integrity is maintained (transaction boundaries, optimistic locking)
- [ ] Concurrency safety (race conditions, deadlocks, thread safety)
- [ ] Audit logging records user, timestamp, action, and outcome
- [ ] Graceful degradation is considered for external dependency failures

## 4. Cost Efficiency

- [ ] Algorithm complexity is appropriate (watch for O(n^2)+ in hot paths)
- [ ] No N+1 query patterns
- [ ] No unnecessary network calls or API invocations
- [ ] Caching strategy is leveraged where beneficial
- [ ] No memory leaks or unnecessary object retention
- [ ] Implementation is proportionally simple for the problem it solves

## 5. SOLID Principles

- [ ] Single Responsibility: each function/class has one reason to change
- [ ] Open/Closed: extensible without modifying existing code
- [ ] Dependency Inversion: depends on abstractions, not concretions
- [ ] Dependency direction is correct (high-level does not depend on low-level)
- [ ] Abstraction level is appropriate (not too high, not too low)

## 6. YAGNI

- [ ] No features beyond current requirements
- [ ] No excessive configurability added speculatively
- [ ] No code for hypothetical future requirements
- [ ] No unused imports, variables, or functions
- [ ] No premature abstraction (helper/utility for one-time use)

## 7. DRY

- [ ] No duplicated logic across multiple locations
- [ ] Magic numbers and magic strings are extracted to constants
- [ ] No hardcoded configuration values
- [ ] Automatable manual processes are identified

## 8. Best Practices Compliance

- [ ] Follows language-specific idiomatic patterns
- [ ] Follows framework-recommended patterns
- [ ] Consistent with project linter/formatter configuration
- [ ] Adheres to project style guide and coding conventions
- [ ] No deprecated APIs or patterns in use

## 9. Readability

- [ ] Variable, function, and class names convey intent clearly
- [ ] Comments explain "Why" not "What"
- [ ] Function cognitive complexity is manageable (no deep nesting, no 100+ line functions)
- [ ] Code is logically organized and structured
- [ ] Conditionals are clear (no double negation, no complex ternaries)
```

**Step 3: Commit**

```bash
git add skills/code-review/references/review-criteria.md
git commit -m "feat(code-review): add review criteria reference checklist

9-criteria checklist covering spec alignment, security, RASIS, cost,
SOLID, YAGNI, DRY, best practices, and readability."
```

---

### Task 2: Create SKILL.md

**Files:**
- Create: `skills/code-review/SKILL.md`

**Step 1: Write the skill definition**

Create `skills/code-review/SKILL.md` with the following content:

```markdown
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
2. For each changed file:
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
```

**Step 2: Commit**

```bash
git add skills/code-review/SKILL.md
git commit -m "feat(code-review): add SKILL.md with 4-phase review workflow

Checklist-driven code review skill with:
- Phase 1: Scope (diff target identification)
- Phase 2: Scan (9 criteria applied in priority order)
- Phase 3: Report (Must Fix / Should Fix / Nit classification)
- Phase 4: Action (next steps via AskUserQuestion)"
```

---

### Task 3: Register in marketplace.json

**Files:**
- Modify: `.claude-plugin/marketplace.json:17-21` (skills array)

**Step 1: Add the skill to the plugins list**

In `.claude-plugin/marketplace.json`, add `"./skills/code-review"` to the `skills` array:

```json
"skills": [
  "./skills/suggest-skill",
  "./skills/dig",
  "./skills/eval-plan",
  "./skills/code-review"
]
```

**Step 2: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "feat(code-review): register skill in marketplace"
```

---

### Task 4: Verify skill loads correctly

**Step 1: Check file structure**

Run: `find skills/code-review -type f | sort`
Expected:
```
skills/code-review/SKILL.md
skills/code-review/references/review-criteria.md
```

**Step 2: Validate SKILL.md frontmatter**

Run: `head -8 skills/code-review/SKILL.md`
Expected: Valid YAML frontmatter with name, description, allowed-tools, context fields

**Step 3: Validate marketplace.json is valid JSON**

Run: `python3 -c "import json; json.load(open('.claude-plugin/marketplace.json')); print('Valid JSON')"`
Expected: `Valid JSON`

**Step 4: Verify skill count**

Run: `grep -c 'skills/code-review' .claude-plugin/marketplace.json`
Expected: `1`

**Step 5: Commit verification notes (if any fixes needed)**

Only commit if fixes were required in previous steps.
