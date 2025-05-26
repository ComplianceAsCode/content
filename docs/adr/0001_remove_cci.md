---
content-version: 0.1.77
title: ADR-0001 - Removing CCI References
status: accepted
---
# Removing CCIs

## Context
Most rules that are in STIG profiles have a CCI reference.
The CCI references come from the STIGs published by DISA.
After some review it appears the CCI numbers for the same control vary widely from
product to product.
Even between products in the family (RHEL 8 and RHEL 9, for example) the CCI references from DISA are very different.


To aid in keeping the content updated there was an effort to automate the updates to CCI.
However, as discussed above since each product was so different this was not possible.

## Decision
We will remove and not add CCI references to the project.

## Consequences
There will be less information to users in reports.
However, the information we have today is wrong, so this might be better overall.
