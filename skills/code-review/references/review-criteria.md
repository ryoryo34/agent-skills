# Code Review Criteria

9-criteria checklist in priority order. Apply each criterion to the diff sequentially.

## Severity Classification

| Level | Symbol | Meaning | Action |
|-------|--------|---------|--------|
| Must Fix | 🔴 | Blocks merge — correctness bug, security vulnerability, data loss risk | Fix before merge |
| Should Fix | 🟡 | Degrades quality — poor error handling, performance issue, design smell | Strongly recommended |
| Nit | 💡 | Improvement suggestion — naming, style, minor readability | Optional |

Severity is assigned per finding, not per section. Use the context and impact of the change to determine the appropriate level.

## 1. Spec-Code Alignment

- [ ] Implementation matches the PR description / linked issue / user story
- [ ] Edge cases are handled (null, empty, zero, negative, max values, off-by-one)
- [ ] Alternative flows and failure scenarios are considered
- [ ] Related tests are added or updated for the change (see Test Quality below)
- [ ] Related documentation (API spec, README, etc.) is updated
- [ ] No unintended side effects on existing behavior

### Test Quality (t-wada / mizchi principles)

Tests must provide **根拠のある自信 (evidence-based confidence)** — tests pass → safe to deploy; tests fail → fix before proceeding. Tests exist to enable change, not to prevent it.

#### Trustworthiness — eliminate "lies" in tests

- [ ] No false negatives: tests actually catch bugs they claim to guard against (no self-fulfilling tests where test logic mirrors production logic)
- [ ] No false positives (flaky tests): tests do not fail when code is correct (no timing dependencies, no external service calls without fakes, no global state leakage)
- [ ] Skipped/disabled tests (`skip`, `xit`, `pending`) have a tracked issue or expiration — not left indefinitely

#### What to test — behavior, not implementation

- [ ] Tests verify **observable behavior** (inputs → outputs, side effects, state changes), not internal implementation details (private methods, internal data structures, call order)
- [ ] Tests survive refactoring: renaming internals or restructuring code should not break tests if behavior is unchanged
- [ ] Assertions are **diagnostic**: on failure, the actual vs expected values reveal the root cause (use `assertEqual(result, 40)` not `assertTrue(result == 40)`)

#### Test structure — size and isolation

- [ ] Test size is appropriate: prefer Small tests (single process, no I/O) over Medium/Large where possible
- [ ] Test doubles (mocks/stubs) are used strategically, not excessively — each mock increases structural coupling between test and implementation
- [ ] When mocking is needed, prefer fakes (real implementations with in-memory backing) over mocks (behavior verification) to reduce false confidence
- [ ] Pure logic is extracted and tested without mocks; I/O boundaries are tested with integration tests

#### Coverage and edge cases

- [ ] Critical paths and business logic have test coverage
- [ ] Edge cases are tested: null, empty, zero, negative, boundary values, off-by-one, NaN/Infinity
- [ ] Error paths are tested: what happens when dependencies fail?
- [ ] Bug fixes include a regression test that reproduces the bug before the fix

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
- [ ] Fallback values/behavior do not silently mask errors — fallback is permitted only when fail-safe behavior is explicitly required by the spec

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
- [ ] Liskov Substitution: subtypes are substitutable for their base types without breaking behavior
- [ ] Interface Segregation: no client is forced to depend on methods it does not use
- [ ] Dependency Inversion: depends on abstractions, not concretions
- [ ] Dependency direction is correct (high-level does not depend on low-level)
- [ ] Abstraction level is appropriate (not too high, not too low)

## 6. YAGNI

- [ ] No features beyond current requirements
- [ ] No excessive configurability added speculatively
- [ ] No code for hypothetical future requirements
- [ ] No unused imports, variables, or functions
- [ ] No premature abstraction (helper/utility for one-time use)
- [ ] No backward-compatibility shims, aliases, or dead-code preservations added speculatively
  - Justified only when: operational constraints make removal/migration impossible (e.g., live DB schema), or non-functional/operational requirements explicitly mandate it

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
- [ ] No known anti-patterns detected (see `anti-patterns.md` catalog for reference)

## 9. Readability

- [ ] Variable, function, and class names convey intent clearly
- [ ] Comments explain "Why" not "What"
- [ ] Function cognitive complexity is manageable (no deep nesting, no 100+ line functions)
- [ ] Code is logically organized and structured
- [ ] Conditionals are clear (no double negation, no complex ternaries)
