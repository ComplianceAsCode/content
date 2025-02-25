---
content-version: 0.1.77
title: ADR-0000 - Architecture Decisions Records
status: accepted
---

## Context

An "Architecture Decision" is a decision that impacts the system's structure, design principles, or key dependencies in a way that affects long-term maintainability, scalability, or interoperability.

We need to record the architectural decisions made on this project.
Historically, architectural changes were decided or implemented in different ways:
* in PRs with or without a related issue
* in Issues
* in GitHub discussions
* in Meetings

Although a less formal approach can bring flexibility to maintainers and contributors, it also has some side-effects:
* It is hard to track significant changes and respective context along the time
* It is not always visible enough for potential stakeholders
* The lack of visibility leads to a lack of feedback from the Community
* There isn't a formal assessment process to measure the impact and consequences of Architectural Decisions

The goal of Architecture Decision Records is to bring value to project:
* Reasoning Architecture Decisions in a collaborative way
* Centralizing accurate and objective documentation about architectural changes
* Providing the necessary information for new comers to more easily on-board and start contributing
* Formalizing the base of a mechanism to a better Change Management Process

Architecture Decision Records should not be abused:
* It shall be used in alignment to the concept of an "Architecture Decision"
* If in doubt if an ADR needs to be proposed, start a discussion in our existing channels or consult project maintainers
* Ultimately the project maintainers will decide when a ADR is necessary or not

References:
* https://en.wikipedia.org/wiki/Architectural_decision
* https://adr.github.io/
* https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions


## Decision

* We will use Architecture Decision Records
    * Each ADR will include three main sections: Context, Decision, and Consequences
    * We will store the ADRs at `docs/adr` directory using the format `XXXX_title.md`, where:
        * `XXXX` is a sequential number
        * `title` is a short and meaningful title for the AD separated by "_" when composed by multiple words
    * We will inform the last released version in the ADR header for a better temporal context of each ADR
    * We will use the following statuses for ADRs:
        * proposed, accepted, rejected, postponed, withdrawn, or replaced
* We will require the approval of at least three maintainers to merge an ADR
* We may still use other channels for a less formal discussion of a proposal in early stages


## Consequences

* Maintainers need to assess positive and negative consequences of Architecture Decisions
* Maintainers need to ensure Architecture Decisions are documented
* Contributors need to check Architecture Decisions Records to more quickly understand the context of Architecture Decisions
* Community are able to more easily see the history of Architectural Decisions.
