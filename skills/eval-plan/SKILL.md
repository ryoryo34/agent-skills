---
name: eval-plan
description: Self-evaluate a plan for completeness, consistency, and feasibility. Scores the plan out of 100 and identifies gaps, contradictions, and oversights. Use after dig, feedback incorporation, or plan revision. Triggers include "eval plan", "evaluate plan", "score plan", "plan review".
allowed-tools: Read, Glob, Grep, AskUserQuestion
context: fork
license: MIT
---

# Eval Plan - Plan Self-Evaluation

After a plan has been revised (post-dig, post-feedback, or post-modification), evaluate the plan on a **100-point scale** to identify gaps, contradictions, and oversights.

## When to Use

- After a `/dig` session to verify all ambiguities were resolved
- After incorporating user feedback into a plan
- After modifying a plan for any reason
- Before starting implementation to confirm readiness

## Evaluation Process

### Step 1: Read the Plan

Read the current plan file and all related context (CLAUDE.md, referenced documents, prior decisions).

### Step 2: Evaluate Against 5 Criteria

Score each criterion out of 20 points:

#### 1. Completeness (20 pts)

Does the plan cover everything needed?

| Score | Criteria |
|-------|----------|
| 18-20 | All requirements addressed, edge cases considered, nothing missing |
| 13-17 | Most requirements covered, minor gaps exist |
| 7-12  | Notable gaps in requirements or scope |
| 0-6   | Major requirements missing |

Checkpoints:
- [ ] All functional requirements have corresponding implementation steps
- [ ] Non-functional requirements (performance, security, etc.) are addressed
- [ ] Edge cases and error handling are considered
- [ ] Dependencies and prerequisites are identified

#### 2. Consistency (20 pts)

Are there contradictions within the plan?

| Score | Criteria |
|-------|----------|
| 18-20 | No contradictions, all parts align perfectly |
| 13-17 | Minor inconsistencies that don't affect execution |
| 7-12  | Contradictions that could cause confusion |
| 0-6   | Fundamental contradictions that block execution |

Checkpoints:
- [ ] Technology choices are consistent across all sections
- [ ] Naming conventions are uniform
- [ ] Data flow descriptions don't contradict each other
- [ ] Timeline/ordering of steps is logically sound

#### 3. Feasibility (20 pts)

Can the plan actually be executed?

| Score | Criteria |
|-------|----------|
| 18-20 | Clearly executable, all steps are actionable |
| 13-17 | Mostly executable, minor clarifications needed |
| 7-12  | Some steps are vague or may not be achievable |
| 0-6   | Major portions are unrealistic or unclear |

Checkpoints:
- [ ] Each step is concrete and actionable (not vague)
- [ ] Required tools, libraries, and resources are available
- [ ] Technical approach is proven or well-reasoned
- [ ] No implicit assumptions that haven't been validated

#### 4. Specificity (20 pts)

Is the plan detailed enough to implement without further questions?

| Score | Criteria |
|-------|----------|
| 18-20 | Implementation-ready, no ambiguity remains |
| 13-17 | Mostly specific, few minor details to fill in |
| 7-12  | Several areas need more detail before implementation |
| 0-6   | Too abstract to implement |

Checkpoints:
- [ ] File paths and component names are specified
- [ ] Data structures and schemas are defined
- [ ] API contracts (input/output) are clear
- [ ] Behavioral specifications are unambiguous

#### 5. Risk Awareness (20 pts)

Does the plan account for what could go wrong?

| Score | Criteria |
|-------|----------|
| 18-20 | Risks identified with mitigation strategies |
| 13-17 | Main risks noted, some mitigations missing |
| 7-12  | Risks acknowledged but not addressed |
| 0-6   | No consideration of risks or failure modes |

Checkpoints:
- [ ] Breaking changes and migration needs are identified
- [ ] Rollback strategy exists for risky changes
- [ ] Performance impact is considered
- [ ] Security implications are evaluated

### Step 3: Output Evaluation Report

Use the following format. Replace placeholders with actual evaluation results.

#### Display Rules

- **Progress bar**: Use `█` for filled and `░` for empty, always 20 characters wide. Fill count = score for per-criterion bars (out of 20). For total bar, fill count = round(score / 5).
- **Grade thresholds**: A (90-100), B (75-89), C (60-74), D (below 60)
- **Grade label**: A = "Ready to implement", B = "Minor revisions needed", C = "Significant gaps", D = "Rework required"
- **Severity markers**: 🔴 = blocks implementation, 🟡 = should fix before/during implementation, 💡 = nice-to-have improvement
- **Grouping**: Must Fix = all 🔴 + blocking 🟡 (can't start implementing without fixing, e.g. API contract undefined → can't write client code). Should Fix = non-blocking 🟡 + all 💡 (can fix during implementation, e.g. variable naming inconsistent). Omit a group header if it has zero items. If no issues exist at all, omit the entire "Next Actions" section and the "After all fixes" line.
- **Sort order**: Within each group, sort by expected gain descending (+pts highest first)
- **Action description**: 1-2 sentences max. If an issue needs 3+ sentences to describe, split it into separate action items. Do NOT expand back to multi-field format (Priority/Location/Current state/Recommended fix/Impact). The inline tags + 1-2 sentence format is mandatory.
- **Effort**: S (< 5 min), M (5-30 min), L (30+ min)

```markdown
# Plan Evaluation: [X] / 100 — Grade [A/B/C/D]

> [One-sentence summary of overall readiness and the single biggest gap. If score < 75, append: "→ Consider running `/dig` to resolve issues before implementation."]

| Criterion      | Score  | Bar                    |
|----------------|--------|------------------------|
| Completeness   | [X]/20 | [████████████████░░░░] |
| Consistency    | [X]/20 | [████████████████░░░░] |
| Feasibility    | [X]/20 | [████████████████░░░░] |
| Specificity    | [X]/20 | [████████████████░░░░] |
| Risk Awareness | [X]/20 | [████████████████░░░░] |

## Next Actions

### Must Fix

- 🔴 **[Issue title]** `[Criterion]` `Effort: [S/M/L]` `+[N]pts`
  [Location in plan] — [What to change and why, in 1-2 sentences]

- 🟡 **[Issue title]** `[Criterion]` `Effort: [S/M/L]` `+[N]pts`
  [Location in plan] — [What to change and why, in 1-2 sentences]

### Should Fix

- 🟡 **[Issue title]** `[Criterion]` `Effort: [S/M/L]` `+[N]pts`
  [Location in plan] — [What to change and why, in 1-2 sentences]

- 💡 **[Issue title]** `[Criterion]` `Effort: [S/M/L]` `+[N]pts`
  [Location in plan] — [What to change and why, in 1-2 sentences]

---

After all fixes: **[Y]/100** (Grade [current] → [target])
```

## Important Notes

- Be **honest and critical** - the purpose is to catch problems before implementation, not to validate
- A score below 75 should recommend running `/dig` to resolve issues
- Focus on **actionable feedback** - every issue should have a clear recommendation
- Compare against CLAUDE.md patterns and conventions when evaluating consistency
- **Language**: Follow CLAUDE.md preference. Fallback to English if unspecified
