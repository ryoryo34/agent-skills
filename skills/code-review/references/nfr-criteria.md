# Non-Functional Requirements Criteria

7-criteria checklist for non-functional requirements. Each section specifies applicable context types in parentheses; apply only when the detected context matches.

## Severity Classification

| Level | Symbol | Meaning | Action |
|-------|--------|---------|--------|
| Must Fix | 🔴 | Blocks merge — security, data loss, severe a11y defects | Fix before merge |
| Should Fix | 🟡 | Degrades quality — operational issues, best practice violations | Strongly recommended |
| Nit | 💡 | Improvement suggestion | Optional |

Severity is assigned per finding, not per section. Use the context and impact of the change to determine the appropriate level.

## NF1. Observability (API/Backend, Infrastructure)

### Logging

- [ ] Important operations are logged at appropriate log levels
- [ ] Log output is structured (JSON)
- [ ] No PII in log messages
- [ ] Error logs include stack trace and context (request ID)

### Tracing

- [ ] Spans are properly created and closed (try/finally)
- [ ] Logs include trace_id and span_id
- [ ] Context propagation follows W3C Trace Context

### Metrics

- [ ] No high-cardinality attributes in metric labels
- [ ] RED metrics (Rate, Errors, Duration) are available for main endpoints

## NF2. Scalability (API/Backend, Infrastructure, Data/DB)

### Stateless Design

- [ ] No local filesystem session or cache
- [ ] In-memory state is not assumed to be shared across instances
- [ ] Stateful processing is delegated to an external store

### Resource Management

- [ ] Timeouts are set on all external calls
- [ ] Connection pool sizes are configurable
- [ ] Batch processing uses pagination or chunking

### Database

- [ ] No unbounded SELECT * without LIMIT
- [ ] Indexes match query patterns
- [ ] Lock granularity is appropriate (row-level preferred over table-level)

## NF3. Accessibility (Web Frontend)

### Semantic HTML

- [ ] Correct elements are used (button for actions, a for navigation)
- [ ] Landmark elements are present (main, nav, header, footer)
- [ ] Heading hierarchy is logical (no skipped levels)

### Images / Media

- [ ] alt attribute on all img elements (alt="" for decorative images)
- [ ] Video content has captions
- [ ] Animations respect prefers-reduced-motion

### Forms

- [ ] label for/id association on all inputs
- [ ] aria-describedby used for error messages
- [ ] Error indicators are not color-only

### Keyboard

- [ ] Visible focus styles on interactive elements
- [ ] tabindex uses only 0 or -1 (no positive values)
- [ ] ARIA roles are set on custom interactive components

## NF4. i18n (Web Frontend)

### String Management

- [ ] No hardcoded UI strings in source code
- [ ] ICU MessageFormat used for plurals and gender
- [ ] No string concatenation for building user-facing messages

### Locale

- [ ] Intl API or CLDR-based library used for date/number formatting
- [ ] No hardcoded date/number formats
- [ ] html lang attribute is set correctly

### Text

- [ ] UTF-8 encoding is explicit
- [ ] RTL/LTR text direction is considered
- [ ] Layout handles text expansion (up to 200% for short strings)

## NF5. API Compatibility (API/Backend, Library/SDK)

### Breaking Change Detection

- [ ] No URL or HTTP method changes to existing endpoints
- [ ] No removal or type change of required fields
- [ ] No default value changes for existing parameters
- [ ] No authentication/authorization scheme changes
- [ ] No error response format changes

### Versioning

- [ ] API version is incremented for breaking changes
- [ ] Semver is followed for library/SDK releases
- [ ] Type definitions match exported implementations

### Backward Compatibility

- [ ] New fields are optional with sensible defaults
- [ ] Deprecation notice is added before removal
- [ ] Migration path is documented and provided

## NF6. Operability (API/Backend, Infrastructure)

### Config Management

- [ ] No hardcoded environment-specific values
- [ ] Configuration is externalized (env vars, config files, secrets manager)
- [ ] Fail-safe defaults are defined for all config values

### Health / Monitoring

- [ ] Health check endpoints are implemented
- [ ] Dependency health is included in health checks
- [ ] Metrics are available for alerting thresholds

### Deploy / Rollback

- [ ] Database migrations are backward-compatible
- [ ] Feature flags are used for gradual rollout
- [ ] No manual steps required in deploy process

## NF7. Data Privacy (API/Backend, Data/DB)

### PII Handling

- [ ] No PII in logs, traces, or error messages
- [ ] Data is encrypted at rest and in transit
- [ ] Proper access control is enforced for PII stores

### Data Minimization

- [ ] No unnecessary data collection beyond stated purpose
- [ ] TTL or auto-deletion is configured for transient data
- [ ] API responses filter fields to return only what is needed

### Consent / Rights

- [ ] No data processing without verified consent
- [ ] Right to be forgotten (data deletion) is supported
- [ ] Data portability (export) is supported
