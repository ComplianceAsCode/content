# Welcome!

[![Docs](https://img.shields.io/readthedocs/complianceascode)](https://complianceascode.readthedocs.io/en/latest/)
[![Release](https://img.shields.io/github/release/ComplianceAsCode/content.svg)](https://github.com/ComplianceAsCode/content/releases/latest)
[![Nightly ZIP Status](https://github.com/ComplianceAsCode/content/actions/workflows/nightly_build.yml/badge.svg)](https://nightly.link/ComplianceAsCode/content/workflows/nightly_build/master/Nightly%20Build.zip)
[![Nightly 5.10 ZIP Status](https://github.com/ComplianceAsCode/content/actions/workflows/nightly_build_5_10.yml/badge.svg)](https://nightly.link/ComplianceAsCode/content/workflows/nightly_build_5_10/master/Nightly%20Build%20OVAL%205.10.zip)
[![Maintainability](https://api.codeclimate.com/v1/badges/62c1f8d8064b2163db3e/maintainability)](https://codeclimate.com/github/ComplianceAsCode/content/maintainability)
[![Stats, Guides, Tables](https://github.com/ComplianceAsCode/content/actions/workflows/gh-pages.yaml/badge.svg)](https://complianceascode.github.io/content-pages/)
[![Join the chat at https://gitter.im/Compliance-As-Code-The/content](https://badges.gitter.im/Compliance-As-Code-The/content.svg)](https://gitter.im/Compliance-As-Code-The/content?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-908a85?logo=gitpod)](https://gitpod.io/#https://github.com/ComplianceAsCode/content)

<a href="docs/readme_images/report_sample.png"><img align="right" width="250" src="docs/readme_images/report_sample.png" alt="Evaluation report sample"></a>

The purpose of this project is to create *security policy content* for various
platforms &mdash; *Red Hat Enterprise Linux*, *Fedora*, *Ubuntu*, *Debian*, *SUSE Linux Enterprise Server (SLES)*,... &mdash;
as well as products &mdash; *Firefox*, *Chromium*, *JRE*, ...
We aim to make it as easy as possible to write new and maintain existing
security content in all the commonly used formats.

## We build security content in various formats

![NIST logo](docs/readme_images/nist_logo.svg "NIST logo") &nbsp; &nbsp; ![Ansible logo](docs/readme_images/ansible_logo.svg "Ansible logo") &nbsp; &nbsp; ![Bash logo](docs/readme_images/bash_logo.png "Bash logo")

*"SCAP content"* refers to documents  in the *XCCDF*, *OVAL* and
*Source DataStream* formats.  These documents can be presented
in different forms and by different organizations to meet their security
automation and technical implementation needs.  For general use, we
recommend *Source DataStreams* because they contain all the data you
need to evaluate and put machines into compliance. The datastreams are
part of our release ZIP archives.

*"Ansible content"* refers to Ansible playbooks generated from security
profiles.  These can be used both in check-mode to evaluate compliance,
as well as run-mode to put machines into compliance.  We publish these
on *Ansible Galaxy* as well as in release ZIP archives.

*"Bash fix files"* refers to *Bash* scripts generated from security
profiles.  These are meant to be run on machines to put them into
compliance.  We recommend using other formats but understand that for
some deployment scenarios bash is the only option.

### Why?

We want multiple organizations to be able to efficiently develop security
content. By taking advantage of the powerful build system of this project,
we avoid as much redundancy as possible.

The build system combines the easy-to-edit YAML rule files with OVAL checks,
Ansible task snippets, Bash fixes, and other files. Templating is provided
at every step to avoid boilerplate. Security identifiers
(CCE, NIST ID, STIG, ...) appear in all of our output formats but are all
sourced from the YAML rule files.

We understand that depending on your organization's needs you may need
to use a specific security content format. We let you choose.

![Build system schema](docs/readme_images/build_schema.svg "Build system schema")

---
We use an OpenControl-inspired YAML rule format for input. Write once and
generate security content in XCCDF, Ansible, and others.

```YAML
prodtype: rhel7

title: 'Configure The Number of Allowed Simultaneous Requests'

description: |-
    The <tt>MaxKeepAliveRequests</tt> directive should be set and configured to
    <sub idref="var_max_keepalive_requests" /> or greater by setting the following
    in <tt>/etc/httpd/conf/httpd.conf</tt>:
    <pre>MaxKeepAliveRequests {{{ xccdf_value("var_max_keepalive_requests") }}}</pre>

rationale: |-
    Resource exhaustion can occur when an unlimited number of concurrent requests
    are allowed on a web site, facilitating a denial of service attack. Mitigating
    this kind of attack will include limiting the number of concurrent HTTP/HTTPS
    requests per IP address and may include, where feasible, limiting parameter
    values associated with keepalive, (i.e., a parameter used to limit the amount of
    time a connection may be inactive).

severity: medium

identifiers:
    cce: "80551-5"
```

---

### Scan targets

Our security content can be used to scan bare-metal machines, virtual machines,
virtual machine images (qcow2 and others), containers (including Docker), and
container images.

We use platform checks to detect whether we should or should not evaluate some
of the rules. For example: separate partition checks make perfect sense on bare-metal
machines but go against recommended practices on containers.

## Installation

### From packages

The preferred method of installation is via the package manager of your
distribution. On *Red Hat Enterprise Linux* and *Fedora* you can use:

```bash
yum install scap-security-guide
```

On Debian (sid), you can use:

```bash
apt install ssg-debian  # for Debian guides
apt install ssg-debderived  # for Debian-based distributions (e.g. Ubuntu) guides
apt install ssg-nondebian  # for other distributions guides (RHEL, Fedora, etc.)
apt install ssg-applications  # for application-oriented guides (Firefox, JBoss, etc.)
```

### From release ZIP files

Download pre-built SSG zip archive from
[the release page](https://github.com/ComplianceAsCode/content/releases/latest).
Each zip file is an archive with ready-made SCAP source datastreams.


### From source

If ComplianceAsCode is not packaged in your distribution (it may be present there as `scap-security-guide` package), or if the
version that is packaged is too old, you need to build the content yourself
and install it via `make install`. Please see the [Developer Guide](https://complianceascode.readthedocs.io/en/latest/manual/developer/02_building_complianceascode.html)
document for more info. We also recommend opening an issue on that distributions
bug tracker to voice interest.

## Usage

We assume you have installed ComplianceAsCode system-wide into a
standard location from current upstream sources as instructed in the previous section.

There are several ways to consume ComplianceAsCode content, we will only
go through a few of them here.

### `oscap` tool

The `oscap` tool is a low-level command line interface that comes from
the OpenSCAP project. It can be used to scan the local machine.

```bash
oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_rht-ccp --results-arf arf.xml --report report.html --oval-results /usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml
```

After evaluation, the `arf.xml` file will contain all results in a reusable
*Result DataStream* format, `report.html` will contain a human readable
report that can be opened in a browser.

Replace the profile with other profile of your choice, you can display
all possible choices using:

```bash
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml
```

Please see the [OpenSCAP](https://www.open-scap.org/) website for more information.

### SCAP Workbench

The SCAP Workbench is a graphical user interface for SCAP evaluation and
customization. It is suitable for scanning a single machine, either local
or remote (via SSH). New versions of SCAP Workbench have SSG integration
and will automatically offer it when the application is started.

Please see the [SCAP Workbench](https://www.open-scap.org/tools/scap-workbench/) website for more information.

### `oscap-ssh` tool

`oscap-ssh` comes bundled with OpenSCAP 1.2.3 and later. It allows scanning
a remote machine via SSH with an interface resembling the `oscap` tool.

The following command evaluates a machine with IP `192.168.1.123` with content
stored on the local machine. Keep in mind that `oscap` has to be installed on the
remote machine but the SSG content doesn't need to be.

```bash
oscap-ssh root@192.168.1.123 22 xccdf eval --profile xccdf_org.ssgproject.content_profile_standard --results-arf arf.xml --report report.html /usr/share/xml/scap/ssg/content/ssg-fedora-ds.xml
```

### Ansible

To see a list of available Ansible Playbooks, run:

```bash
ls /usr/share/scap-security-guide/ansible/
```

These Ansible Playbooks are generated from *SCAP* profiles available for the products.

To apply the playbook on your local machine run:
(*THIS WILL CHANGE CONFIGURATION OF THE MACHINE!*)

```bash
ansible-playbook -i "localhost," -c local /usr/share/scap-security-guide/ansible/rhel7-playbook-rht-ccp.yml
```

Each of the Ansible Playbooks contains instructions on how to deploy them. Here
is a snippet of the instructions:

```YAML
...
# This file was generated by OpenSCAP 1.2.16 using:
#   $ oscap xccdf generate fix --profile rht-ccp --template urn:xccdf:fix:script:ansible sds.xml
#
# This script is generated from an OpenSCAP profile without preliminary evaluation.
# It attempts to fix every selected rule, even if the system is already compliant.
#
# How to apply this remediation role:
# $ ansible-playbook -i "192.168.1.155," playbook.yml
# $ ansible-playbook -i inventory.ini playbook.yml
...
```

### Bash
To see a list of available Bash scripts, run:

```bash
# ls /usr/share/scap-security-guide/bash/
...
rhel7-script-hipaa.sh
rhel7-script-ospp.sh
rhel7-script-pci-dss.sh
...
```

These Bash scripts are generated from *SCAP* profiles available for the products.
Similar to Ansible Playbooks, each of the Bash scripts contain instructions on how to deploy them.

## Support

The SSG mailing list can be found at [https://lists.fedorahosted.org/mailman/listinfo/scap-security-guide](https://lists.fedorahosted.org/mailman/listinfo/scap-security-guide).

If you encounter issues with OpenSCAP or SCAP Workbench, use [https://www.redhat.com/mailman/listinfo/open-scap-list](https://www.redhat.com/mailman/listinfo/open-scap-list)

If you prefer more interactive contact with the community, you can join us on Gitter and IRC:
- Gitter: https://gitter.im/Compliance-As-Code-The/content
- IRC: join the `#openscap` IRC channel on `libera.chat`.

## A little bit of history

This project started in 2011 as a collaboration between United States Government agencies and commercial operating system vendors.
The original name was SCAP Security Guide, commonly abbreviated as SSG.
The original scope was to create SCAP datastreams. Over time, it grew into the
biggest open-source beyond-SCAP content project.

The next few years saw the introduction of not just government-specific security
profiles but also commercial, such as PCI-DSS and CIS.

Later, the industry starts moving towards different security content formats,
such as Ansible, Puppet, and Chef InSpec. The community reacted by evolving the
tooling and helped transform SSG into a more general-purpose security content
project. This change happened over time in 2017 and 2018. In September 2018, we
decided to change the name of the project to `ComplianceAsCode`, in order to avoid confusion.

We envision that the future will be format-agnostic. That's why opted for an
abstraction instead of using XCCDF for the input format.

## Further reading

The SSG homepage is [https://www.open-scap.org/security-policies/scap-security-guide/](https://www.open-scap.org/security-policies/scap-security-guide/).

* [SSG User Manual](docs/manual/user_guide.adoc)
* [SSG Developer Guide](https://complianceascode.readthedocs.io/)
* [Compliance As Code Blog](https://complianceascode.github.io/)
* [Online Workshops - Perfect as a starting point](docs/workshop/README.adoc)

## Contributors
This project is welcome to new contributors. We are continually trying to remove the complexities to make contributions easier and more enjoyable for everyone. This is a nice project and a friendly community.

There are many ways to contribute. Check the documentation for more details:
https://complianceascode.readthedocs.io/en/latest/manual/developer/01_introduction.html

Check the updated list of [Contributors](Contributors.md).
