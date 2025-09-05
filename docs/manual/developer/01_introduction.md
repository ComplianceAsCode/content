# Introduction

This document tries to provide information useful for [ComplianceAsCode/content](https://github.com/ComplianceAsCode/content) project contributors.
We will guide you through the structure of the project.
We will explain the directory layout, used formats and the build system.

## Overview

See our [README](https://github.com/ComplianceAsCode/content#readme) for a thorough introduction.

ComplianceAsCode/content aims to provide security and compliance content for various distributions and products.

The project contains three major parts:

 - [Compliance benchmark content](03_creating_content.html) in an format agnostic, easy to [read and modify](06_contributing_with_content.html) layout.
    - Rules: checks and remediations for specific items, for example, ensuring that `/var/log` has the desired permission. This includes automation for both auditing compliance with this rule as well as handling remediation if the desired state is not met.
    - Profiles and Controls: ways of grouping rules (both in product-specific and product-agnostic settings)to achieve compliance with a specific benchmark or policy (such as PCI-DSS, STIG, CIS, &c).
 - [A build system](02_building_complianceascode.html) and [utilities](05_tools_and_utilities.html) for transforming this content into standard-compliant, scanner-agnostic content.
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
