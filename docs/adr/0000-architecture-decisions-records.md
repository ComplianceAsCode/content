---
content-version: 0.1.77
title: ADR-0000 - Architecture Decisions Records
status: proposed # Valid statuses are proposed, accepted, rejected, postponed, withdrawn, or replaced
---

## Context

We need to record the architectural decisions made on this project.
Historically, architectural changes were decided or made in different ways:
* in PRs with or without a related issue
* in Issues
* in GitHub discussions
* in Meetings
* etc

Although a less formal approach can bring flexibility to maintainers, it also has some side-effects:
* It is hard to track significant changes and respective context along the time
* It is not always visible enough for potential stakeholders
* The lack of visibility leads to a lack of feedback from the community
* There isn't a formal assessment process to measure the impact and consequences

References:
* https://en.wikipedia.org/wiki/Architectural_decision
* https://adr.github.io/
* https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions


## Decision

* We will use Architecture Decision Records, as [described by Michael Nygard](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions).
* We will store the ADRs at `docs/adr` directory using the format `XXXX - title`, where `XXXX` is a sequential number.
* We will inform the last released version in the ADR header for a better temporal context of each ADR.
* We will require at least 4 PRs approvals to merge an ADR.
* We may still use other channels for a less formal discussion of a proposal in early stages.


## Consequences

* We will need to measure and document positive and negative consequences of each decision.
* The community can quickly see the history and understand the reason of architectural decisions.
* Maintainers and contributors will need to document architecture decisions.
