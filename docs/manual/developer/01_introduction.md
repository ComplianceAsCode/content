# Introduction

This document tries to provide information useful for [ComplianceAsCode/content](https://github.com/ComplianceAsCode/content) project contributors.
We will guide you through the structure of the project.
We will explain the directory layout, used formats and the build system.

## Overview

See our [README](https://github.com/ComplianceAsCode/content#readme) for a thorough introduction.

ComplianceAsCode/content aims to provide security and compliance content for various distributions and products.

The project contains three major parts:

 - [Compliance benchmark content](03_creating_content) in a format agnostic, easy to [read and modify](06_contributing_with_content) layout.
    - Rules: checks and remediations for specific items, for example, ensuring that `/var/log` has the desired permission. This includes automation for both auditing compliance with this rule as well as handling remediation if the desired state is not met.
    - Profiles and Controls: ways of grouping rules (both in product-specific and product-agnostic settings)to achieve compliance with a specific benchmark or policy (such as PCI-DSS, STIG, CIS, &c).
 - [A build system](02_building_complianceascode) and [utilities](05_tools_and_utilities) for transforming this content into standard-compliant, scanner-agnostic content.
 - [A test harness](https://github.com/ComplianceAsCode/content/blob/master/tests/README.md) for validating this content by executing it on the target platform.

## Contributing

We welcome contributions big and small!
Feel free to open an issue or a pull request; see our [CONTRIBUTING.md](https://github.com/ComplianceAsCode/content/blob/master/CONTRIBUTING.md) file for more information.

## Communication Channels

We have various means of communication for anyone interested in learning more or reaching out to existing members:

### Mailing List

Join the mailing list at [scap-security-guide](https://lists.fedorahosted.org/archives/list/scap-security-guide@lists.fedorahosted.org/).

### Gitter

We now have a room ([`Compliance-As-Code-The/content`](https://gitter.im/Compliance-As-Code-The/content)) on Gitter.im!

### Libera.chat

We lurk on `#openscap` on the [libera.chat](https://libera.chat) network.


## Governance

The aim of the governance structure is to help the project community to self-organize and deliver required changes at a fast pace,
and to ensure that various parties can collaborate on the project without major friction.


### TLDR

We need to:

- Allow individuals and organizations in the content project to work at their own pace on parts of the project within their area of expertise, and to do so independently if they don’t influence each other.
- Introduce enter and exit criteria for roles with elevated privileges so the hierarchy can self-organize.
- Define a framework for organizations to join the project and assume responsibilities.
- Ensure that the project stays coherent and individual parts contribute to its value, and the project doesn’t become a disgusting spaghetti soup.


### Decomposition

In order to keep the project scalable, we divide the project into separate areas, and assign groups of users that can be granted commit access with the intention to develop content in respective areas.
Those areas are going to be segmented by

- Products (RHEL, Ubuntu, …) - make it easy to develop content of a product that doesn’t influence the other content or the build system.
- Product-specific profiles (PSPs s.a. Firefox STIG, Ubuntu CIS, …) and respective control files - make it easy for SMEs that only want to assign rules to profiles without going into details.
- Shared resources
  - Product-independent profiles (PIPs s.a. ANSSI, HIPAA, PCI-DSS, …) and respective control files - ensure that PIP development benefits the whole community instead of cluttering the content with “if product in [...]”.
  - Build system - decisions upon architecture of the build system impact build time, project capabilities, and can also move maintenance costs.
  - Test-related code - ensure that tests have the greatest coverage as possible, but that don’t waste time and don’t suffer from false positives.
  - Other - rules only loosely coupled to products, templates, CPEs etc. Same principles that apply to PIPs apply for the shared content as well.
- Organization administration - ability to grant and remove rights, create and delete repositories etc.


### Implementation

#### Products

- Keeping track of the decomposition: Metadata in product.yml files, CODEOWNERS file
- Area of effect: All PSPs that don’t have specific stakeholders, associated content and test scenarios.
- Guidelines: Care needs to be taken when content requires a slightly different approach for different products - don’t copy and paste, and also don’t change existing behavior for everybody.
  See the [style guide](04_style_guide.md) for more details.

##### Removal of Products
Products may be subject to removal from the project if at **least one** of the following is true:
  - Past their declared end-of-life date
  - Have not had contributions to files in their respective product folder for **two years**

The following process shall be used to start the removal of the product:
1. A GitHub issue is created proposing the removal of the product.
    The issue must contain the following:
    1. The end date and time (in UTC) of the comment period 
    1. A mention of the last contributor to the product, more than one is preferred
    1. The reason for removal (lack of contributions or product EOL)
1. A comment period of **21 days** shall be observed.
The issue description must explicitly state the date and time (in UTC) when the comment period will close.
1. In the case of lack of contributions, if there are no new contributors that volunteer once the comment period closes the product shall be removed.
   Products that are going EOL the product shall be removed unless there is an objection form a representative of product.
The pull request removing the product should include the removal of
    1. The product folder in `products/`
    1. any Jinja templates that use the product
    1. the product from all `prodtype`
    1. any product specific checks or remediatons
    1. any product specific templates

All issues and pull requests for product removal must use the [product-removal](https://github.com/ComplianceAsCode/content/labels/product-removal) label.

#### Product Specific Profiles (PSPs)

- Keeping track of the decomposition: Metadata in profile yml files, CODEOWNERS file
- Area of effect: Respective profile files
- Guidelines: N/A


#### Product Independent Profiles (PIPs)

- Keeping track of the decomposition: Metadata in control files. Any profile definitions that live as separate profile files are simply a product’s content.
- Area of effect: Just control files
- Guidelines: Individual actors don't break profiles for others.
  The control file format should help with productive collaboration.


#### Build system

- Keeping track of the decomposition: CODEOWNERS file
- Area of effect: Everything that is directly or indirectly used during the content build process
- Guidelines: We need strong protection against technical debt, increases in build time and a framework to deal with deprecations or changes of behavior.


#### Shared Resources

- Keeping track of the decomposition: CODEOWNERS file
- Area of effect: Content that impacts more products.
- Guidelines: The same as for the build system.


#### Tests

- Keeping track of the decomposition: CODEOWNERS file
- Area of effect: Test scenarios, test suite features, unit tests, gating tests
- Guidelines: Test robustness, tests performance and the rate of tests usefulness are preserved.


#### Organizational administration

- Keeping track of the decomposition: Maintainer file, readme?
- Area of effect: Github org and project settings
- Guidelines: Project rules are followed or adapted to changing conditions.
  Decisions are made when a project wants to join the ComplianceAsCode organization.


### Rights assignment

#### Individual PR approve and merge rights

TLDR: 6 non-trivial PRs within 6 months => merge rights for 1 year since the last activity.

Contributors can ask for merge rights by opening a Github issue using the `Request Merge Rights` issue template.
1. The issue must contain the following:
    1. The Github ID of the user
    1. The Reasoning for the requested merge rights
    1. The links for PRs

1. The rights can only be granted after, at least, three maintainers express their approval by commenting on the issue.

Although one can technically merge code, the code contribution guidelines still have to be obeyed.

Loss of merge rights:
- Request: A person can ask to be stripped of merge rights.
- Timeout: If a person doesn’t actively contribute to the project for a period of 12 months, their merge rights are stripped.
  Active contribution consists of either non-trivial contributions of code, non-trivial reviews, or analyses of problems in issues.
- Violation: Rights can be also revoked if coding style or conduct are consistently broken.

Standard acquisition of merge rights:
- Merit: Anybody who submits 6 non-trivial PRs that get merged in a period no longer than 6 months is entitled to get such rights, and is encouraged to ask for them.
- Renewal: When a person reapplies for merge rights less than a year after losing them, it is possible to satisfy formal conditions by submitting non-trivial PRs or non-trivial reviews -- 3 of those in 3 months.

The project maintainers decide about granting or strip of rights and about exceptions to the procedure e.g. when an applicant has deep prior experience with the project.


#### Organizations

Aside from an organization (s.a. a company or an institution) being composed of individuals with individual rights, other developers associated with the organization may get “backup” merge rights or organization administration rights.
Those rights can be granted for a period of 12 months and their renewal can be requested.
These rights can only be used in cases when regular developers aren’t available and the organization needs to get their things through.
