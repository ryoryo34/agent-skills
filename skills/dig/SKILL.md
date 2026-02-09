---
name: dig
description: Clarify ambiguities in plans with structured questions. Use when a plan is presented, requirements are unclear, or decisions need to be made before implementation. Triggers include "dig", "clarify plan", "deep dive".
allowed-tools: Read, Glob, Grep, Edit, AskUserQuestion
context: fork
---

# Dig - Plan Ambiguity Clarifier

Read the current plan and interview the user in detail about **all unclear points** until every ambiguity is resolved, then write the decisions back to the plan.

Dig doesn't just ask questions — it **detects contradictions**, **surfaces hidden assumptions**, **forms hypotheses**, and **maps how decisions cascade** into each other.

## Phases

### Phase 1: Deep Context Analysis

Read available context files (CLAUDE.md, plan files, README.md) and perform three-layer analysis:

#### Layer 1: Identify Ambiguities

Categorize unclear points across:

- **Product Spec**: Missing requirements, undefined scope, unclear acceptance criteria
- **Architecture**: Unresolved technical decisions, missing component relationships
- **Data**: Undefined schemas, unclear data flow, missing validation rules
- **API**: Undefined endpoints, unclear request/response formats
- **UI/UX**: Missing interaction details, undefined states, unclear flows
- **Testing**: Undefined test strategy, missing edge cases
- **DevOps**: Unclear deployment, missing environment config
- **Scope**: Ambiguous boundaries, undefined out-of-scope items

#### Layer 2: Detect Contradictions & Hidden Assumptions

Actively scan the plan for:

- **Contradictions**: Statements that conflict with each other (e.g., "real-time sync" but "batch processing only")
- **Hidden assumptions**: Things everyone seems to take for granted but nobody stated explicitly (e.g., assuming single-tenant when multi-tenant is possible)
- **Impossible combinations**: Requirements that cannot coexist under real constraints (e.g., "zero downtime" + "full DB migration" + "no read replicas")

Output detected issues before asking questions:

```markdown
## Detected Issues

### Contradictions
- ⚡ [Statement A] conflicts with [Statement B] — [why they can't coexist]

### Hidden Assumptions
- 💭 The plan assumes [assumption] — but this is never stated. If wrong, [consequence]

### Impossible Combinations
- 🚫 [Requirement X] + [Requirement Y] cannot coexist because [reason]
```

#### Layer 3: Map Decision Dependencies

Before asking anything, identify which decisions depend on each other:

```markdown
## Decision Dependency Map

[Decision A] → affects → [Decision B] → affects → [Decision C]
[Decision D] ← independent
```

Use this map to determine **question order** — always resolve upstream decisions first, because downstream options change based on upstream answers.

### Phase 2: Hypothesis-Driven Questions

Instead of asking from scratch, **form a hypothesis first** based on context clues, then ask the user to confirm or correct it.

<rules>
- Question count: **2-4** per round (adjust based on ambiguity level)
- Each question has **2-4 concrete options**
- Each option includes **pros/cons** briefly
- **Lead with a hypothesis**: "Based on [context clue], I think [hypothesis]. Which is closest?"
- Mark hypothesized option with "(Hypothesized)" suffix in the label
- Avoid open-ended questions
- "Other" option is auto-added — don't include it
- Align options with existing patterns from CLAUDE.md (if available)
- Use AskUserQuestion tool — not conversational questions
- **Resolve upstream decisions first** following the dependency map from Phase 1
</rules>

**Hypothesis formation strategy:**
- Read CLAUDE.md, existing code, and config for style/pattern clues
- Infer from what IS stated to guess what ISN'T stated
- When a contradiction is found, hypothesize which side the user intended
- State confidence level: "fairly confident" / "best guess" / "could go either way"

### Phase 3: Record Decisions & Map Impact Chain

After receiving answers, output:

```markdown
## Decisions

| Item | Choice | Reason | Notes |
|------|--------|--------|-------|
| [Decision item] | [Selected option] | [Why this was chosen] | [Additional context] |

## Impact Chain

Decision: [A = chosen option]
  └→ Narrows [B] options to: [remaining options]
  └→ Makes [C] default to: [implied choice]
  └→ Eliminates [D] option: [removed option] (no longer compatible)
```

**Automatically propagate constraints**: When an upstream decision eliminates or implies downstream choices, note them immediately. If a downstream decision becomes obvious, state it rather than asking.

### Phase 4: Re-analyze & Iterate

After recording decisions:

1. **Re-check for new contradictions** — did any decision create a new conflict with existing plan items?
2. **Re-check hidden assumptions** — did any answer reveal a new unspoken assumption?
3. **Update the dependency map** — mark resolved decisions and see if new dependencies emerged
4. If unclear points remain, return to Phase 2 with updated hypotheses

Continue until all ambiguities are resolved.

### Phase 5: Apply & Summarize

Write all decisions back to the plan file and output:

```markdown
## Summary

- Clarified items: [number]
- Contradictions resolved: [number]
- Hidden assumptions surfaced: [number]
- Decisions made: [list]
- Remaining open items: [list or "None"]

## Decision Chain (Final)

[Visual representation of all decisions and their cascading effects]

## Next Steps

1. **[First task]**
   - Details...
2. **[Second task]**
   - Details...
```

## Important Notes

- **Must use AskUserQuestion tool** for all questions — not conversational questions
- **Language**: Follow CLAUDE.md preference. Fallback to English if unspecified
- Keep digging until **all** unclear points are resolved — don't stop early
- Each option must include pros/cons
- Always lead with a hypothesis — never ask "from zero"
- Resolve upstream decisions before downstream ones
- When a decision eliminates downstream ambiguity, state it instead of asking
- Use multiSelect sparingly (default: false)
