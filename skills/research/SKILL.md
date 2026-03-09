---
name: research
description: Source-quality-guaranteed research skill. Investigates best practices, academic papers, and real-world case studies with explicit reliability tiers and source verification. Use when the user asks to research, investigate, survey, or look up best practices, papers, technical trends, latest examples, industry patterns, or architectural decisions. Triggers include "research", "investigate", "survey", "look up", "best practice", "what's the latest on", "how do companies do X", "find papers on", "state of the art".
allowed-tools: WebSearch, WebFetch, AskUserQuestion
context: fork
---

# Research — Source-Quality-Guaranteed Investigation

Conduct research on a given topic with verifiable, high-quality sources. Every claim must trace back to a source with an explicit reliability tier.

## Source Reliability Framework

All sources are classified into 3 tiers. Higher tiers are preferred. If only lower-tier sources are available, explicitly note this in the report.

### Best Practices

| Tier | Source Type | Examples |
|------|-----------|----------|
| S | Official docs, standards bodies, RFCs | MDN, IETF RFC, W3C Spec, language official docs (go.dev, docs.python.org, etc.) |
| A | Major tech company engineering blogs, widely-adopted OSS docs | Google AI Blog, Netflix Tech Blog, Stripe Engineering, Meta Engineering, repos with 5k+ GitHub Stars |
| B | Well-known practitioners, high-signal community resources | Martin Fowler, Kent Beck, ThoughtWorks Tech Radar, Stack Overflow answers with 100+ votes |

Reject: personal blogs without track record, Medium posts without author verification, SEO-optimized content farms, AI-generated summaries without primary source.

### Academic Papers

| Tier | Source Type | Criteria |
|------|-----------|----------|
| S | Top-tier venues | NeurIPS, ICML, ICLR, ACL, CVPR, SIGMOD, VLDB, OSDI, SOSP, Nature, Science — OR citation count 200+ |
| A | Peer-reviewed conferences/journals | Published in recognized venues, citation count 50+ |
| B | Preprints with traction | arXiv/SSRN papers from known research groups, citation count 10+, or widely discussed in the community |

Reject: unpublished manuscripts, predatory journal papers, preprints with 0 citations and no institutional backing.

### Case Studies & Latest Examples

| Tier | Source Type | Examples |
|------|-----------|----------|
| S | Official company announcements, conference talks | AWS re:Invent talks, Google I/O, KubeCon talks, official company blog posts about their own systems |
| A | Established tech media, industry reports | InfoQ, The New Stack, Gartner reports, ThoughtWorks Technology Radar, QCon presentations |
| B | Verified practitioner accounts | Conference lightning talks, podcast interviews with named engineers, detailed post-mortems on established platforms |

Reject: anonymous anecdotes, unverified social media claims, press releases without technical detail, secondhand accounts without primary source link.

## Phase 1: Scope

Clarify the research scope before searching.

1. Parse the user's request to identify:
   - **Topic**: what to investigate
   - **Type**: best practices / papers / case studies / mixed
   - **Constraints**: time range, specific technologies, industry, scale
2. If the request is ambiguous, ask up to 2 clarifying questions via AskUserQuestion
3. Define 3-5 search queries covering different angles of the topic

Output:

```
## Research Scope
- Topic: [identified topic]
- Type: [best practices / papers / case studies / mixed]
- Constraints: [time range, tech stack, industry, etc.]
- Search queries: [list of planned queries]
```

## Phase 2: Search & Collect

Execute searches systematically. Breadth first, then depth.

1. Run all planned search queries via WebSearch
2. For each result, assess source reliability tier before reading
3. Prioritize Tier S and A sources — only use Tier B if S/A coverage is insufficient
4. For each promising result, fetch the full page via WebFetch and extract:
   - Key claims and findings
   - Supporting evidence or data
   - **Date of publication** (check page header, URL path, meta tags, footer — always record this)
   - Author and affiliation
5. Cross-reference claims across multiple sources — a claim backed by 2+ independent sources is stronger

### Search Rules

- Execute at least 3 distinct search queries per topic to avoid single-source bias
- If the first page of results is dominated by low-quality sources, reformulate the query (add "site:github.com", "site:arxiv.org", author names, conference names, etc.)
- For papers, prefer searching Google Scholar, Semantic Scholar, or arXiv directly
- For best practices, prefer official documentation sites and established engineering blogs
- Always check publication date — flag anything older than 3 years as potentially outdated (unless it's a foundational work)

## Phase 3: Synthesize & Report

Compile findings into a structured markdown report.

```markdown
# Research Report: [Topic]

## Executive Summary
[2-3 sentence overview of key findings]

## Findings

### [Finding 1 Title]
[Description with specific details, data points, or recommendations]

**Sources:**
- ★★★★★ (理由) [S] Author/Org, "Title", URL, YYYY-MM
- ★★★★☆ (理由) [A] Author/Org, "Title", URL, YYYY-MM

### [Finding 2 Title]
...

## Source Reliability Summary

| Tier | Count | Notes |
|------|-------|-------|
| S    | [N]   | [e.g., "Official docs, top-venue papers"] |
| A    | [N]   | [e.g., "Major tech blogs, peer-reviewed"] |
| B    | [N]   | [e.g., "Community resources — used only where S/A unavailable"] |

## Source List
[Full numbered list of all sources used, with relevance rating, reason, tier, author, title, URL, and date]

## Caveats
- [Any gaps in coverage, areas where only lower-tier sources were available, conflicting findings, etc.]
```

### Report Rules

- Every factual claim must have at least one source citation
- Each source must include its reliability tier in brackets: [S], [A], or [B]
- Each source must include a relevance rating (★1-5) with a short reason explaining how directly the source addresses the research topic:
  - ★★★★★: Directly addresses the core question with specific, actionable detail
  - ★★★★☆: Highly relevant — covers major aspects of the topic
  - ★★★☆☆: Moderately relevant — useful context or partial coverage
  - ★★☆☆☆: Tangentially relevant — related domain but not directly on-topic
  - ★☆☆☆☆: Minimally relevant — only peripherally touches on the topic (avoid including these)
- If findings conflict across sources, present both sides and note the disagreement
- Every source MUST include a publication date (YYYY-MM or YYYY). If the exact date is not visible on the page, check the URL path, meta tags, or page footer for date clues. If truly undeterminable, write "Date unknown" explicitly — never silently omit the date
- The Caveats section is mandatory — even if it's just "No significant caveats"
- Aim for 5-15 sources per report (fewer if the topic is narrow, more if it's broad)

## Phase 4: Review

After presenting the report, offer next steps via AskUserQuestion:

1. "Deep-dive into a specific finding" — expand one section with more sources
2. "Search for additional perspectives" — broaden the search to cover gaps
3. "Research complete" — done

## Important Notes

- **No hallucinated sources**: Every URL must come from an actual search result. Never fabricate titles, authors, or URLs
- **Recency awareness**: Default to preferring recent sources (last 2 years) unless the topic calls for foundational/historical references
- **Conflict transparency**: When experts disagree, present the disagreement rather than picking a side
- **Language**: Follow CLAUDE.md preference. Fallback to English if unspecified
