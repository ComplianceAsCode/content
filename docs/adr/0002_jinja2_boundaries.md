---
content-version: 0.1.78
title: ADR-0002 - Define Jinja2 Boundaries
status: proposed
---
# Define Jinja2 Boundaries

## Context
Since 2017~2018 there is a capability to use Jinja2 macros in the project.
This allows maintainers to reuse content while preserving product specific details during building time.
It also allows to reduce content duplication in similar rules.

While there are good cases where the use of Jinja2 macros can contribute to an easier maintenance,
it also brings some side effects, such as increasing the building time and impacting the readability.

Another aspect of Jinja2 macros is that they are rendered internally by SSG, in building time.
It makes it harder for integrations to consume CaC/content externally without bringing complexity on the integration side, or demanding extension of SSG on CaC/content side. Both options are not straight forward, limiting the collaboration to the project.

Therefore, we should keep advantage of Jinja2 macros where they help more but avoid its use where it is not necessary.

Here are few PRs that can bring more context on some challenges we faced in order to integrate external automation with CaC/content:
- https://github.com/ComplianceAsCode/content/pull/12816
- https://github.com/ComplianceAsCode/content/pull/12797
- https://github.com/ComplianceAsCode/content/pull/12717

## Decision

We will keep using Jinja2 macros in:
- rules, including their descriptions, checks and remediation files
- exclusively internal use, such as build scripts.

We will not use Jinja2 macros in:
- control files, except for files in `srg_ctr` and `srg_gpos`.
  - Profiles using product agnostic control files, such as PCI-DSS, ANSSI and HIPAA must customize rules and variables on profile level.
  - `srg_ctr` and `srg_gpos` content are not directly consumed but used as references for new control files.
- variables files
  - Variables must be generic. New options can be included and explicitly used in control files and/or profiles.
- profiles files
  - The only existing cases are {{{ full_name }}}, which is a static information at this level so can be safely replaced by the literal product name.

## Consequences

By not using Jinja2 in control files, product maintainers must ensure their profile files properly select or unselect rules and variables when consuming a control file. This is already a common practice in the project.

By not using Jinja2 in variables, product maintainers must ensure their control files and profiles are using the correct options. This is also already a common practice in the project.

There are currently 5 variables for banners content that have macros to "regexify" the text specifically for OVAL. These variables will need to include the text already processed, as instructed by the [already documented process](https://github.com/ComplianceAsCode/content/blob/master/docs/manual/developer/05_tools_and_utilities.md#generating-login-banner-regular-expressions). In the medium and long term, a new mechanism to "regexify" these 5 variables in building time could be introduced. However, considering the change history of these variables, using the documented process when necessary seems already enough and a new mechanism is up to maintainers to decide "if" and "when" to implement.

Unnecessary macros are removed by the following PRs:
- https://github.com/ComplianceAsCode/content/pull/13180
- https://github.com/ComplianceAsCode/content/pull/13573
- https://github.com/ComplianceAsCode/content/pull/13584
- https://github.com/ComplianceAsCode/content/pull/13592
