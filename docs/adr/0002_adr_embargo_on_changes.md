---
content-version: 0.1.77
title: ADR-0002 - Embargo all ADR-incited changes to the project until the ADR is accepted
status: accepted
---
# Embargo all ADR-incited changes to the project until ADR is accepeted

## Context
The project should not be affected by any change related to a proposed ADR
until a descision is made on ADR itself.

## Decision
We will mark all PRs that support or are justified by a proposed ADR as drafts
until the ADR is merged.

## Consequences
ADR changes will be confined until ADR is accepted.