---
name: generalize-and-apply
description: Transform concrete examples, references, prior conversations, research findings, competitor patterns, screenshots, or user-provided cases into reusable principles, then apply those principles back to a specific product, design, strategy, implementation, or decision. Use when the user asks to learn from examples, compare how others do it, derive an optimal approach, turn specifics into abstractions, or use a "concrete to abstract to concrete" / "1を学び10を悟り100に応用" thinking flow.
allowed-tools: Read, Glob, Grep, WebSearch, WebFetch, AskUserQuestion
context: fork
license: MIT
---

# Generalize And Apply

Use this skill to move deliberately from concrete examples, to abstract principles, back to concrete recommendations.

## Core Flow

1. **Concrete**: Gather or inspect real examples.
2. **Abstract**: Extract shared structures, forces, tradeoffs, and principles.
3. **Concrete**: Reapply those principles to the user's specific context as actionable recommendations.

Do not stop at a list of examples. The value of this skill is the translation layer: what the examples teach, and what the user should do because of it.

## Abstraction Lens

Abstraction depends on purpose.

When the purpose is fixed, abstraction usually has an **N to 1** shape: many concrete examples are grouped into one useful principle, category, or decision rule.

When the purpose is not fixed, one concrete example may produce **1 to M** abstractions because the same object has many valid aspects. For example, one full-bodied man can abstract to "man" through the lens of gender, and to "full-bodied" through the lens of body type.

Before abstracting, identify the lens:

- **Decision lens**: What decision should this abstraction help make?
- **Comparison lens**: Which aspect of the examples is being compared?
- **Transfer lens**: Which property needs to survive when applied to the user's context?

If the lens is clear, compress many examples toward one or a few principles. If the lens is unclear, first surface multiple possible abstractions, then choose the one that serves the user's goal.

Treat abstraction and concretion as a hierarchy. A concrete example can become an abstract principle, and that principle can become a new concrete recommendation. This visible hierarchy is the practical form of "learn 1, understand 10, apply to 100."

## Workflow

### 1. Define The Target Question

Restate the decision the user is trying to make in one sentence.

Prefer questions like:

- "What should this product's first UI model be?"
- "Which interaction pattern fits this feature?"
- "What structure should this document, strategy, or system use?"
- "What can we learn from similar examples and apply here?"

If the user's goal is vague, infer a practical target question and proceed. Ask only when the missing detail would materially change the examples to inspect.

### 2. Collect Concrete Inputs

Use the best available concrete sources:

- User-provided conversations, notes, screenshots, artifacts, or code.
- Comparable products, games, apps, documents, workflows, or systems.
- Existing project files and local implementation details.
- Web research when current external examples, sources, or citations are needed.

Choose examples for relevance, not fame. Prefer 3-7 examples that vary enough to reveal structure.

For each example, capture:

- What the user experiences.
- What mechanism creates that experience.
- What lesson transfers to the target question.

Use a compact table when comparing examples.

### 3. Abstract The Pattern

Extract principles that are portable across examples.

Start by naming the abstraction lens. If the user has already provided a clear goal, use it to form an N to 1 abstraction. If not, list the plausible 1 to M abstractions first and choose the lens that best serves the target question.

Good abstractions describe:

- **Structure**: the shape the examples share.
- **Causality**: why that shape works.
- **Tradeoffs**: what it improves and what it costs.
- **Fit conditions**: when the principle should or should not be used.
- **Failure modes**: how the pattern becomes weak if copied superficially.

Avoid shallow abstractions like "make it simple" or "improve UX." Convert them into operational rules, such as "make the field itself the menu so each function is anchored to a meaningful object."

### 4. Reapply To The User's Context

Translate the abstractions into specific decisions for the user's project.

Include:

- A recommended direction.
- The concrete shape of the solution.
- What to build first.
- What to avoid or defer.
- How the recommendation maps back to the extracted principles.

When useful, include a sketch, object map, information architecture, implementation checklist, or phased plan.

### 5. Validate The Fit

Check the recommendation against the target question:

- Does it solve the actual decision?
- Does it preserve the user's unique context instead of copying references?
- Are the examples strong enough to support the conclusion?
- Are there assumptions or uncertainties that need a follow-up test?

Name weak evidence honestly. If the examples point in different directions, present the fork and explain which condition decides between them.

## Quality Bar

Before answering, check that the output contains:

- At least one specific observation from each important example.
- A clear distinction between observed facts and inferred lessons.
- The abstraction lens or purpose that explains why these examples are being grouped.
- Principles that can transfer beyond the original examples.
- A recommendation that is more specific than "copy the reference."
- First steps small enough to execute or test.

If any item is missing, tighten the answer before presenting it.

## Output Shape

Use this default structure unless the user asks for another format:

```markdown
## Target Question

...

## Concrete Examples

| Example | What it does | Transferable lesson |
| --- | --- | --- |
| ... | ... | ... |

## Abstracted Principles

1. ...
2. ...
3. ...

## Applied Recommendation

...

## First Concrete Steps

1. ...
2. ...
3. ...
```

For lightweight chats, compress this into:

- "Concrete examples show..."
- "Abstracting that..."
- "So in your case..."

## Example: Game UI Decision

If the user asks whether to add a field or room to a pet/game UI:

- Concrete: Animal Crossing, Ameba Pigg, Habbo, Cozy Grove, and Webkinz show that spatial ownership, visible characters, and object-based actions create attachment.
- Abstract: Strong sandbox UI often makes the field itself the menu, puts characters before information, gives locations semantic meaning, accumulates small visible changes, and frames dailies as events.
- Concrete: A virtual-pet app being designed should start with a one-screen "room" where the pet, task board, storage shelf, and door are clickable world objects, instead of a menu-first navigation structure.

This example is illustrative, not a fixed template. Reuse the reasoning pattern, not the exact answer.
