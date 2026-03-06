# Anti-Patterns Catalog

Common anti-patterns to detect during code review. Each maps to one or more review criteria from `review-criteria.md`.

## How to Use

During Phase 2 (Scan), check changed code against relevant anti-patterns. If a pattern match is found, flag it under the mapped criterion with the default severity (adjustable based on context and impact).

---

## 1. Design Anti-Patterns

| # | Name | What It Looks Like | Criterion | Default Severity |
|---|------|--------------------|-----------|-----------------|
| D1 | God Object | One class/module handles unrelated responsibilities; file grows unbounded | 5. SOLID | 🟡 Should Fix |
| D2 | Shotgun Surgery | Single logical change requires edits in many unrelated files | 5. SOLID | 🟡 Should Fix |
| D3 | Feature Envy | Method uses more data/methods from another class than its own | 5. SOLID | 💡 Nit |
| D4 | Premature Generalization | Abstract base/interface created for a single concrete use | 6. YAGNI | 🟡 Should Fix |
| D5 | Speculative Feature | Code added for "future requirements" that don't exist yet | 6. YAGNI | 🟡 Should Fix |
| D8 | Backward-Compat Shim | Aliases, wrapper functions, or dead-code stubs kept solely for backward compatibility without operational justification (e.g., in-flight DB migration, explicit non-functional requirement) | 6. YAGNI | 🟡 Should Fix |
| D6 | Wrong Abstraction Unit | Abstraction boundary doesn't match the domain concept it represents | 5. SOLID | 🟡 Should Fix |
| D7 | Circular Dependency | Module A depends on B, B depends on A (directly or transitively) | 5. SOLID | 🔴 Must Fix |

## 2. Implementation Anti-Patterns

| # | Name | What It Looks Like | Criterion | Default Severity |
|---|------|--------------------|-----------|-----------------|
| I1 | Copy-Paste Programming | Identical or near-identical logic in multiple locations | 7. DRY | 🟡 Should Fix |
| I2 | Magic Numbers/Strings | Literal values without named constants or explanation | 7. DRY | 💡 Nit |
| I3 | Deep Nesting | 4+ levels of indentation in conditionals/loops | 9. Readability | 🟡 Should Fix |
| I4 | Long Method | Function exceeds 50-80 lines or has 5+ parameters | 9. Readability | 🟡 Should Fix |
| I5 | Primitive Obsession | Using primitives instead of domain types (e.g., string for email, int for money) | 5. SOLID | 💡 Nit |
| I6 | Boolean Blindness | Functions taking multiple boolean parameters with unclear meaning | 9. Readability | 💡 Nit |
| I7 | Refactor Without Tests | Structural changes made without corresponding test coverage | 1. Spec-Code Alignment | 🔴 Must Fix |

## 3. Error Handling Anti-Patterns

| # | Name | What It Looks Like | Criterion | Default Severity |
|---|------|--------------------|-----------|-----------------|
| E1 | Silent Swallowing | Empty catch block or catch that only logs and continues | 3. RASIS | 🔴 Must Fix |
| E2 | Pokemon Exception Handling | Catching generic `Exception` / `Error` / `Throwable` instead of specific types | 3. RASIS | 🟡 Should Fix |
| E3 | Error Code Ignorance | Return values from fallible operations not checked | 3. RASIS | 🔴 Must Fix |
| E4 | Incomplete Cleanup | Resources opened but not closed in finally/defer/using block | 3. RASIS | 🔴 Must Fix |
| E5 | Silent Degradation | System silently falls back without alerting when a dependency fails | 3. RASIS | 🟡 Should Fix |
| E6 | Retry Without Backoff | Unbounded retry loops without exponential backoff or circuit breaker | 3. RASIS | 🟡 Should Fix |

## 4. Security Anti-Patterns

| # | Name | What It Looks Like | Criterion | Default Severity |
|---|------|--------------------|-----------|-----------------|
| S1 | SQL Injection Surface | String concatenation or template literals in SQL queries | 2. Security | 🔴 Must Fix |
| S2 | Hardcoded Secrets | API keys, passwords, tokens embedded in source code | 2. Security | 🔴 Must Fix |
| S3 | Missing Input Validation | User input passed directly to business logic without sanitization | 2. Security | 🔴 Must Fix |
| S4 | Insecure Deserialization | Using unsafe deserialization (e.g., language-native object serialization on untrusted input, YAML without safe loader, or dynamic code execution from external data) | 2. Security | 🔴 Must Fix |
| S5 | Broken Access Control | Missing authorization checks on endpoints or data access paths | 2. Security | 🔴 Must Fix |
| S6 | Single-Layer Validation | Input validated only on client side, not re-validated on server | 2. Security | 🔴 Must Fix |
| S7 | Scattered Auth | Authentication/authorization logic duplicated across handlers instead of middleware | 2. Security | 🟡 Should Fix |

## 5. Performance Anti-Patterns

| # | Name | What It Looks Like | Criterion | Default Severity |
|---|------|--------------------|-----------|-----------------|
| P1 | N+1 Query | Loop that executes a DB query per iteration instead of batch/join | 4. Cost Efficiency | 🟡 Should Fix |
| P2 | Unbounded Collection | Loading entire table/collection into memory without pagination or limit | 4. Cost Efficiency | 🟡 Should Fix |
| P3 | Unnecessary Computation in Loop | Repeated calculation/allocation inside a loop that could be hoisted | 4. Cost Efficiency | 💡 Nit |
| P4 | Missing Cache Opportunity | Expensive identical computations repeated without memoization | 4. Cost Efficiency | 💡 Nit |

## 6. Testing Anti-Patterns

### 6a. Test Trustworthiness (false negatives — bugs exist but tests pass)

| # | Name | What It Looks Like | Criterion | Default Severity |
|---|------|--------------------|-----------|-----------------|
| T1 | Test Without Assertion | Test that runs code but doesn't verify behavior | 1. Spec-Code Alignment | 🟡 Should Fix |
| T5 | Self-Fulfilling Test | Test logic mirrors production logic instead of independently specifying expected results (e.g., both test and production code compute tax with the same formula — if the formula is wrong, both agree) | 1. Spec-Code Alignment | 🔴 Must Fix |
| T6 | Permanently Skipped Test | Tests disabled with `skip` / `xit` / `pending` / commented-out without a tracked issue or expiration date | 1. Spec-Code Alignment | 🟡 Should Fix |
| T4 | Missing Edge Case Tests | Happy path tested but null/empty/boundary values/NaN/Infinity not covered | 1. Spec-Code Alignment | 🟡 Should Fix |
| T10 | Bug Fix Without Regression Test | Bug is fixed but no test reproduces the original failure to prevent recurrence | 1. Spec-Code Alignment | 🟡 Should Fix |

### 6b. Test Trustworthiness (false positives — tests fail but code is correct)

| # | Name | What It Looks Like | Criterion | Default Severity |
|---|------|--------------------|-----------|-----------------|
| T3 | Flaky Test Patterns | Tests depending on timing (`sleep`, `setTimeout` assertions), external services, or shared global state | 3. RASIS | 🟡 Should Fix |
| T2 | Testing Implementation Details | Tests coupled to internal structure (private methods, internal data structures, call order) rather than observable behavior — breaks on refactoring even when behavior is unchanged | 1. Spec-Code Alignment | 🟡 Should Fix |
| T7 | Over-Mocking | Excessive use of mocks/stubs that couples tests to implementation structure; refactoring internals breaks tests despite unchanged behavior. Prefer: extract pure logic and test without mocks; use fakes (in-memory implementations) over mocks at I/O boundaries | 1. Spec-Code Alignment | 🟡 Should Fix |

### 6c. Test Quality

| # | Name | What It Looks Like | Criterion | Default Severity |
|---|------|--------------------|-----------|-----------------|
| T8 | Non-Diagnostic Assertion | Assertions that hide failure cause: `assertTrue(result == 40)` fails with just `false`; use `assertEqual(result, 40)` to reveal `expected 40, got 39` | 9. Readability | 💡 Nit |
| T9 | Wrong Test Size | Test classified as "unit" but performs network/DB/filesystem I/O (should be Small: single process, no I/O). Prefer downsizing via fakes (e.g., in-memory DB) rather than mocks | 4. Cost Efficiency | 🟡 Should Fix |
| T11 | Test-Implementation Structural Coupling | Test mirrors the internal structure of production code (one test class per production class, test methods map 1:1 to private methods) instead of testing behavioral contracts | 8. Best Practices | 💡 Nit |
| T12 | Shared Mutable Test State | Tests share mutable state (global variables, class-level fields, singleton state) across test cases without proper setup/teardown isolation | 3. RASIS | 🟡 Should Fix |

## 7. Domain-Specific Anti-Patterns (from ADR Experience)

These patterns were extracted from recurring architectural decision discussions and represent real-world lessons learned.

| # | Name | What It Looks Like | Criterion | Default Severity |
|---|------|--------------------|-----------|-----------------|
| X1 | Stale Reference | Config, URLs, or dependency versions referencing deprecated/removed resources | 3. RASIS | 🟡 Should Fix |
| X2 | Toolchain Cascade | Adding a build tool/dependency that pulls in a large transitive dependency tree | 4. Cost Efficiency | 🟡 Should Fix |

---

## Quick Reference: Criterion → Anti-Patterns

| Criterion | Anti-Patterns |
|-----------|--------------|
| 1. Spec-Code Alignment | I7, T1, T2, T4, T5, T6, T7, T10 |
| 2. Security | S1, S2, S3, S4, S5, S6, S7 |
| 3. RASIS | E1, E2, E3, E4, E5, E6, T3, T12, X1 |
| 4. Cost Efficiency | P1, P2, P3, P4, T9, X2 |
| 5. SOLID | D1, D2, D3, D6, D7, I5 |
| 6. YAGNI | D4, D5, D8 |
| 7. DRY | I1, I2 |
| 8. Best Practices | T11 |
| 9. Readability | I3, I4, I6, T8 |
