# Welcome!
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-121-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

[![Release](https://img.shields.io/github/release/ComplianceAsCode/content.svg)](https://github.com/ComplianceAsCode/content/releases/latest)
[![Nightly ZIP Status](https://jenkins.complianceascode.io/job/scap-security-guide-nightly-zip/badge/icon?subject=Nightly%20OVAL-5.11%20ZIP&status=Download)](https://jenkins.complianceascode.io/job/scap-security-guide-nightly-zip/lastSuccessfulBuild/artifact/scap-security-guide-nightly.zip)
[![Nightly 5.10 ZIP Status](https://jenkins.complianceascode.io/job/scap-security-guide-nightly-oval510-zip/badge/icon?subject=Nightly%20OVAL-5.10%20ZIP&status=Download)](https://jenkins.complianceascode.io/job/scap-security-guide-nightly-oval510-zip/lastSuccessfulBuild/artifact/scap-security-guide-nightly-oval-510.zip)
[![Link-checker Status](https://jenkins.complianceascode.io/job/scap-security-guide-linkcheck/badge/icon?subject=Link%20Checker)](https://jenkins.complianceascode.io/job/scap-security-guide-linkcheck/)
[![CentOS CI Status](https://ci.centos.org/job/openscap-scap-security-guide/badge/icon?subject=CentOS%20CI%20Build)](https://ci.centos.org/job/openscap-scap-security-guide/)
[![Travis CI Build Status](https://img.shields.io/travis/OpenSCAP/scap-security-guide/master.svg?label=Travis%20CI%20Build)](https://travis-ci.org/OpenSCAP/scap-security-guide)
[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/ComplianceAsCode/content/badges/quality-score.png?b=master)](https://scrutinizer-ci.com/g/ComplianceAsCode/content/?branch=master)
[![Profile Statistics](https://jenkins.complianceascode.io/job/scap-security-guide-stats/badge/icon?subject=Statistics)](https://jenkins.complianceascode.io/job/scap-security-guide-stats/Statistics/)

<a href="docs/readme_images/report_sample.png"><img align="right" width="250" src="docs/readme_images/report_sample.png" alt="Evaluation report sample"></a>

The purpose of this project is to create *security policy content* for various
platforms -- *Red Hat Enterprise Linux*, *Fedora*, *Ubuntu*, *Debian*, ... --
as well as products -- *Firefox*, *Chromium*, *JRE*, ...
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
    <pre>MaxKeepAliveRequests <sub idref="var_max_keepalive_requests" /></pre>

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

### From COPR

We maintain a COPR repository that provides unofficial builds of latest versions
of openscap, scap-security-guide, scap-workbench, and openscap-daemon.
The packages are suitable for use on Red Hat Enterprise Linux and CentOS.

See https://copr.fedorainfracloud.org/coprs/openscapmaint/openscap-latest/ for
detailed instructions.

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

Please see the [OpenSCAP](https://www.open-scap.org/)
for more info.

### SCAP Workbench

The SCAP Workbench is a graphical user interface for SCAP evaluation and
customization. It is suitable for scanning a single machine, either local
or remote (via SSH). New versions of SCAP Workbench have SSG integration
and will automatically offer it when the application is started.

Please see the
[SCAP Workbench](https://www.open-scap.org/tools/scap-workbench/)
for more info.

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

You can also join the `#openscap` IRC channel on `chat.freenode.net`.

## A little bit of history

This project started in 2011 as a collaboration between government agencies and
commercial operating system vendors. The original name was SCAP Security Guide.
The original scope was to create SCAP datastreams. Over time, it grew into the
biggest open-source beyond-SCAP content project.

The next few years saw the introduction of not just government-specific security
profiles but also commercial, such as PCI-DSS.

Later, the industry starts moving towards different security content formats,
such as Ansible, Puppet, and Chef InSpec. The community reacted by evolving the
tooling and helped transform SSG into a more general-purpose security content
project. This change happened over time in 2017 and 2018. In September 2018, we
decided to change the name of the project to avoid confusion.

We envision that the future will be format-agnostic. That's why opted for an
abstraction instead of using XCCDF for the input format.

## Further reading

The SSG homepage is [https://www.open-scap.org/security-policies/scap-security-guide/](https://www.open-scap.org/security-policies/scap-security-guide/).

* [SSG User Manual](docs/manual/user_guide.adoc)
* [SSG Developer Guide](https://complianceascode.readthedocs.io/)
* [Compliance As Code Blog](https://complianceascode.github.io/)

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/redhatrises"><img src="https://avatars2.githubusercontent.com/u/8398836?v=4" width="100px;" alt=""/><br /><sub><b>Gabe Alford</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=redhatrises" title="Code">💻</a> <a href="https://github.com/ComplianceAsCode/content/issues?q=author%3Aredhatrises" title="Bug reports">🐛</a> <a href="#blog-redhatrises" title="Blogposts">📝</a> <a href="#business-redhatrises" title="Business development">💼</a> <a href="#content-redhatrises" title="Content">🖋</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=redhatrises" title="Documentation">📖</a> <a href="#design-redhatrises" title="Design">🎨</a> <a href="#example-redhatrises" title="Examples">💡</a> <a href="#eventOrganizing-redhatrises" title="Event Organizing">📋</a> <a href="#fundingFinding-redhatrises" title="Funding Finding">🔍</a> <a href="#ideas-redhatrises" title="Ideas, Planning, & Feedback">🤔</a> <a href="#infra-redhatrises" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#maintenance-redhatrises" title="Maintenance">🚧</a> <a href="#platform-redhatrises" title="Packaging/porting to new platform">📦</a> <a href="#projectManagement-redhatrises" title="Project Management">📆</a> <a href="#question-redhatrises" title="Answering Questions">💬</a> <a href="https://github.com/ComplianceAsCode/content/pulls?q=is%3Apr+reviewed-by%3Aredhatrises" title="Reviewed Pull Requests">👀</a> <a href="#tool-redhatrises" title="Tools">🔧</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=redhatrises" title="Tests">⚠️</a> <a href="#tutorial-redhatrises" title="Tutorials">✅</a> <a href="#talk-redhatrises" title="Talks">📢</a> <a href="#userTesting-redhatrises" title="User Testing">📓</a> <a href="#video-redhatrises" title="Videos">📹</a></td>
    <td align="center"><a href="http://isimluk.com"><img src="https://avatars1.githubusercontent.com/u/6666052?v=4" width="100px;" alt=""/><br /><sub><b>Šimon Lukašík</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=isimluk" title="Code">💻</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=isimluk" title="Tests">⚠️</a> <a href="https://github.com/ComplianceAsCode/content/issues?q=author%3Aisimluk" title="Bug reports">🐛</a> <a href="#blog-isimluk" title="Blogposts">📝</a> <a href="#content-isimluk" title="Content">🖋</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=isimluk" title="Documentation">📖</a> <a href="#example-isimluk" title="Examples">💡</a> <a href="#ideas-isimluk" title="Ideas, Planning, & Feedback">🤔</a> <a href="#infra-isimluk" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#maintenance-isimluk" title="Maintenance">🚧</a> <a href="#platform-isimluk" title="Packaging/porting to new platform">📦</a> <a href="#plugin-isimluk" title="Plugin/utility libraries">🔌</a> <a href="#question-isimluk" title="Answering Questions">💬</a> <a href="https://github.com/ComplianceAsCode/content/pulls?q=is%3Apr+reviewed-by%3Aisimluk" title="Reviewed Pull Requests">👀</a> <a href="#tool-isimluk" title="Tools">🔧</a> <a href="#tutorial-isimluk" title="Tutorials">✅</a> <a href="#talk-isimluk" title="Talks">📢</a> <a href="#userTesting-isimluk" title="User Testing">📓</a> <a href="#video-isimluk" title="Videos">📹</a></td>
    <td align="center"><a href="https://github.com/iokomin"><img src="https://avatars3.githubusercontent.com/u/9279159?v=4" width="100px;" alt=""/><br /><sub><b>Ilya Okomin</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=iokomin" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/lsteinke"><img src="https://avatars3.githubusercontent.com/u/8420657?v=4" width="100px;" alt=""/><br /><sub><b>lsteinke</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=lsteinke" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/abergmann"><img src="https://avatars3.githubusercontent.com/u/4102163?v=4" width="100px;" alt=""/><br /><sub><b>Alexander Bergmann</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=abergmann" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/70k10"><img src="https://avatars3.githubusercontent.com/u/1051437?v=4" width="100px;" alt=""/><br /><sub><b>Jayson Cofell</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=70k10" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/yuumasato"><img src="https://avatars0.githubusercontent.com/u/7460169?v=4" width="100px;" alt=""/><br /><sub><b>Watson Yuuma Sato</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=yuumasato" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/iankko"><img src="https://avatars2.githubusercontent.com/u/8414918?v=4" width="100px;" alt=""/><br /><sub><b>Jan Lieskovsky</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=iankko" title="Code">💻</a> <a href="https://github.com/ComplianceAsCode/content/issues?q=author%3Aiankko" title="Bug reports">🐛</a> <a href="#content-iankko" title="Content">🖋</a> <a href="#blog-iankko" title="Blogposts">📝</a> <a href="#example-iankko" title="Examples">💡</a> <a href="#eventOrganizing-iankko" title="Event Organizing">📋</a> <a href="#ideas-iankko" title="Ideas, Planning, & Feedback">🤔</a> <a href="#maintenance-iankko" title="Maintenance">🚧</a> <a href="#platform-iankko" title="Packaging/porting to new platform">📦</a> <a href="https://github.com/ComplianceAsCode/content/pulls?q=is%3Apr+reviewed-by%3Aiankko" title="Reviewed Pull Requests">👀</a> <a href="#tool-iankko" title="Tools">🔧</a> <a href="#talk-iankko" title="Talks">📢</a></td>
    <td align="center"><a href="https://github.com/jan-cerny"><img src="https://avatars3.githubusercontent.com/u/9050916?v=4" width="100px;" alt=""/><br /><sub><b>Jan Černý</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/issues?q=author%3Ajan-cerny" title="Bug reports">🐛</a> <a href="#blog-jan-cerny" title="Blogposts">📝</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=jan-cerny" title="Code">💻</a> <a href="#content-jan-cerny" title="Content">🖋</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=jan-cerny" title="Documentation">📖</a> <a href="#example-jan-cerny" title="Examples">💡</a> <a href="#ideas-jan-cerny" title="Ideas, Planning, & Feedback">🤔</a> <a href="#maintenance-jan-cerny" title="Maintenance">🚧</a> <a href="#platform-jan-cerny" title="Packaging/porting to new platform">📦</a> <a href="#question-jan-cerny" title="Answering Questions">💬</a> <a href="https://github.com/ComplianceAsCode/content/pulls?q=is%3Apr+reviewed-by%3Ajan-cerny" title="Reviewed Pull Requests">👀</a> <a href="#tool-jan-cerny" title="Tools">🔧</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=jan-cerny" title="Tests">⚠️</a> <a href="#talk-jan-cerny" title="Talks">📢</a></td>
    <td align="center"><a href="https://github.com/jeffblank"><img src="https://avatars1.githubusercontent.com/u/6351503?v=4" width="100px;" alt=""/><br /><sub><b>jeffblank</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/issues?q=author%3Ajeffblank" title="Bug reports">🐛</a> <a href="#business-jeffblank" title="Business development">💼</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=jeffblank" title="Code">💻</a> <a href="#content-jeffblank" title="Content">🖋</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=jeffblank" title="Documentation">📖</a> <a href="#example-jeffblank" title="Examples">💡</a> <a href="#eventOrganizing-jeffblank" title="Event Organizing">📋</a> <a href="#financial-jeffblank" title="Financial">💵</a> <a href="#fundingFinding-jeffblank" title="Funding Finding">🔍</a> <a href="#talk-jeffblank" title="Talks">📢</a> <a href="#tutorial-jeffblank" title="Tutorials">✅</a> <a href="#video-jeffblank" title="Videos">📹</a></td>
    <td align="center"><a href="https://cipherboy.com"><img src="https://avatars2.githubusercontent.com/u/914030?v=4" width="100px;" alt=""/><br /><sub><b>Alexander Scheel</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=cipherboy" title="Code">💻</a> <a href="#blog-cipherboy" title="Blogposts">📝</a></td>
    <td align="center"><a href="https://github.com/matejak"><img src="https://avatars2.githubusercontent.com/u/2823847?v=4" width="100px;" alt=""/><br /><sub><b>Matěj Týč</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/issues?q=author%3Amatejak" title="Bug reports">🐛</a> <a href="#blog-matejak" title="Blogposts">📝</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=matejak" title="Code">💻</a> <a href="#content-matejak" title="Content">🖋</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=matejak" title="Documentation">📖</a> <a href="#example-matejak" title="Examples">💡</a> <a href="#eventOrganizing-matejak" title="Event Organizing">📋</a> <a href="#ideas-matejak" title="Ideas, Planning, & Feedback">🤔</a> <a href="#maintenance-matejak" title="Maintenance">🚧</a> <a href="#platform-matejak" title="Packaging/porting to new platform">📦</a> <a href="https://github.com/ComplianceAsCode/content/pulls?q=is%3Apr+reviewed-by%3Amatejak" title="Reviewed Pull Requests">👀</a> <a href="#tool-matejak" title="Tools">🔧</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=matejak" title="Tests">⚠️</a> <a href="#tutorial-matejak" title="Tutorials">✅</a> <a href="#talk-matejak" title="Talks">📢</a></td>
    <td align="center"><a href="http://shawnwells.io"><img src="https://avatars1.githubusercontent.com/u/5713754?v=4" width="100px;" alt=""/><br /><sub><b>Shawn Wells</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/issues?q=author%3Ashawndwells" title="Bug reports">🐛</a> <a href="#blog-shawndwells" title="Blogposts">📝</a> <a href="#business-shawndwells" title="Business development">💼</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=shawndwells" title="Code">💻</a> <a href="#content-shawndwells" title="Content">🖋</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=shawndwells" title="Documentation">📖</a> <a href="#example-shawndwells" title="Examples">💡</a> <a href="#eventOrganizing-shawndwells" title="Event Organizing">📋</a> <a href="#financial-shawndwells" title="Financial">💵</a> <a href="#fundingFinding-shawndwells" title="Funding Finding">🔍</a> <a href="#ideas-shawndwells" title="Ideas, Planning, & Feedback">🤔</a> <a href="#maintenance-shawndwells" title="Maintenance">🚧</a> <a href="#projectManagement-shawndwells" title="Project Management">📆</a> <a href="#question-shawndwells" title="Answering Questions">💬</a> <a href="https://github.com/ComplianceAsCode/content/pulls?q=is%3Apr+reviewed-by%3Ashawndwells" title="Reviewed Pull Requests">👀</a> <a href="#tool-shawndwells" title="Tools">🔧</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=shawndwells" title="Tests">⚠️</a> <a href="#tutorial-shawndwells" title="Tutorials">✅</a> <a href="#talk-shawndwells" title="Talks">📢</a> <a href="#userTesting-shawndwells" title="User Testing">📓</a> <a href="#video-shawndwells" title="Videos">📹</a></td>
    <td align="center"><a href="https://github.com/ggbecker"><img src="https://avatars3.githubusercontent.com/u/18730394?v=4" width="100px;" alt=""/><br /><sub><b>Gabriel Gaspar Becker</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/issues?q=author%3Aggbecker" title="Bug reports">🐛</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=ggbecker" title="Code">💻</a> <a href="#content-ggbecker" title="Content">🖋</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=ggbecker" title="Documentation">📖</a> <a href="#maintenance-ggbecker" title="Maintenance">🚧</a> <a href="#question-ggbecker" title="Answering Questions">💬</a> <a href="https://github.com/ComplianceAsCode/content/pulls?q=is%3Apr+reviewed-by%3Aggbecker" title="Reviewed Pull Requests">👀</a> <a href="#tool-ggbecker" title="Tools">🔧</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=ggbecker" title="Tests">⚠️</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/vojtapolasek"><img src="https://avatars0.githubusercontent.com/u/1188069?v=4" width="100px;" alt=""/><br /><sub><b>vojtapolasek</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=vojtapolasek" title="Code">💻</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=vojtapolasek" title="Tests">⚠️</a> <a href="https://github.com/ComplianceAsCode/content/issues?q=author%3Avojtapolasek" title="Bug reports">🐛</a> <a href="https://github.com/ComplianceAsCode/content/pulls?q=is%3Apr+reviewed-by%3Avojtapolasek" title="Reviewed Pull Requests">👀</a> <a href="#question-vojtapolasek" title="Answering Questions">💬</a></td>
    <td align="center"><a href="https://github.com/dahaic"><img src="https://avatars0.githubusercontent.com/u/1931718?v=4" width="100px;" alt=""/><br /><sub><b>Marek Haičman</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/issues?q=author%3Adahaic" title="Bug reports">🐛</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=dahaic" title="Code">💻</a> <a href="#projectManagement-dahaic" title="Project Management">📆</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=dahaic" title="Tests">⚠️</a> <a href="#talk-dahaic" title="Talks">📢</a></td>
    <td align="center"><a href="https://www.adelton.com/"><img src="https://avatars2.githubusercontent.com/u/2536912?v=4" width="100px;" alt=""/><br /><sub><b>Jan Pazdziora</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=adelton" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/matusmarhefka"><img src="https://avatars0.githubusercontent.com/u/3180425?v=4" width="100px;" alt=""/><br /><sub><b>Matus Marhefka</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=matusmarhefka" title="Code">💻</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=matusmarhefka" title="Tests">⚠️</a> <a href="https://github.com/ComplianceAsCode/content/pulls?q=is%3Apr+reviewed-by%3Amatusmarhefka" title="Reviewed Pull Requests">👀</a> <a href="#question-matusmarhefka" title="Answering Questions">💬</a></td>
    <td align="center"><a href="https://github.com/diastelo"><img src="https://avatars2.githubusercontent.com/u/7083369?v=4" width="100px;" alt=""/><br /><sub><b>Maura Dailey</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=diastelo" title="Code">💻</a></td>
    <td align="center"><a href="http://www.reseau-libre.net"><img src="https://avatars0.githubusercontent.com/u/1446563?v=4" width="100px;" alt=""/><br /><sub><b>Philippe Thierry</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=PThierry" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/mildas"><img src="https://avatars2.githubusercontent.com/u/18598137?v=4" width="100px;" alt=""/><br /><sub><b>Milan Lysonek</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=mildas" title="Code">💻</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=mildas" title="Tests">⚠️</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/redhat-rmcallis"><img src="https://avatars2.githubusercontent.com/u/35341114?v=4" width="100px;" alt=""/><br /><sub><b>Robert McAllister</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=redhat-rmcallis" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/jhrozek"><img src="https://avatars1.githubusercontent.com/u/715522?v=4" width="100px;" alt=""/><br /><sub><b>Jakub Hrozek</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=jhrozek" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/xiruiyang"><img src="https://avatars0.githubusercontent.com/u/37544436?v=4" width="100px;" alt=""/><br /><sub><b>Xirui Yang</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=xiruiyang" title="Code">💻</a></td>
    <td align="center"><a href="https://www.linkedin.com/in/thosjo"><img src="https://avatars1.githubusercontent.com/u/7956715?v=4" width="100px;" alt=""/><br /><sub><b>Thomas Sjögren</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=konstruktoid" title="Code">💻</a></td>
    <td align="center"><a href="https://maltekraus.de/"><img src="https://avatars1.githubusercontent.com/u/1694194?v=4" width="100px;" alt=""/><br /><sub><b>maltek</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=maltek" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/keithkjackson"><img src="https://avatars0.githubusercontent.com/u/49038158?v=4" width="100px;" alt=""/><br /><sub><b>Keith Jackson</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=keithkjackson" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/MollyJoBault"><img src="https://avatars1.githubusercontent.com/u/20548572?v=4" width="100px;" alt=""/><br /><sub><b>MollyJoBault</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=MollyJoBault" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/eradot4027"><img src="https://avatars3.githubusercontent.com/u/26237898?v=4" width="100px;" alt=""/><br /><sub><b>Jon Thompson</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=eradot4027" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/electrosenpai"><img src="https://avatars2.githubusercontent.com/u/15051509?v=4" width="100px;" alt=""/><br /><sub><b>Jean-Baptiste DONNETTE</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=electrosenpai" title="Code">💻</a></td>
    <td align="center"><a href="https://www.twitter.com/jaosorior"><img src="https://avatars3.githubusercontent.com/u/145564?v=4" width="100px;" alt=""/><br /><sub><b>Juan Osorio Robles</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=JAORMX" title="Code">💻</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=JAORMX" title="Tests">⚠️</a> <a href="#ideas-JAORMX" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/ComplianceAsCode/content/pulls?q=is%3Apr+reviewed-by%3AJAORMX" title="Reviewed Pull Requests">👀</a> <a href="#talk-JAORMX" title="Talks">📢</a></td>
    <td align="center"><a href="https://github.com/Eric-Sparks"><img src="https://avatars2.githubusercontent.com/u/12659891?v=4" width="100px;" alt=""/><br /><sub><b>Eric Christensen</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=Eric-Sparks" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/ptitoliv"><img src="https://avatars3.githubusercontent.com/u/567505?v=4" width="100px;" alt=""/><br /><sub><b>Olivier Bonhomme</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=ptitoliv" title="Code">💻</a></td>
    <td align="center"><a href="https://martin.preisler.me"><img src="https://avatars1.githubusercontent.com/u/753153?v=4" width="100px;" alt=""/><br /><sub><b>Martin Preisler</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/issues?q=author%3Ampreisler" title="Bug reports">🐛</a> <a href="#blog-mpreisler" title="Blogposts">📝</a> <a href="#business-mpreisler" title="Business development">💼</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=mpreisler" title="Code">💻</a> <a href="#content-mpreisler" title="Content">🖋</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=mpreisler" title="Documentation">📖</a> <a href="#design-mpreisler" title="Design">🎨</a> <a href="#example-mpreisler" title="Examples">💡</a> <a href="#eventOrganizing-mpreisler" title="Event Organizing">📋</a> <a href="#fundingFinding-mpreisler" title="Funding Finding">🔍</a> <a href="#ideas-mpreisler" title="Ideas, Planning, & Feedback">🤔</a> <a href="#infra-mpreisler" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#maintenance-mpreisler" title="Maintenance">🚧</a> <a href="#platform-mpreisler" title="Packaging/porting to new platform">📦</a> <a href="#projectManagement-mpreisler" title="Project Management">📆</a> <a href="#question-mpreisler" title="Answering Questions">💬</a> <a href="https://github.com/ComplianceAsCode/content/pulls?q=is%3Apr+reviewed-by%3Ampreisler" title="Reviewed Pull Requests">👀</a> <a href="#tool-mpreisler" title="Tools">🔧</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=mpreisler" title="Tests">⚠️</a> <a href="#tutorial-mpreisler" title="Tutorials">✅</a> <a href="#talk-mpreisler" title="Talks">📢</a> <a href="#userTesting-mpreisler" title="User Testing">📓</a> <a href="#video-mpreisler" title="Videos">📹</a></td>
    <td align="center"><a href="https://github.com/lukek1"><img src="https://avatars0.githubusercontent.com/u/8418811?v=4" width="100px;" alt=""/><br /><sub><b>lukek1</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=lukek1" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/davesmith2"><img src="https://avatars1.githubusercontent.com/u/6530077?v=4" width="100px;" alt=""/><br /><sub><b>Dave Smith</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/issues?q=author%3Adavesmith2" title="Bug reports">🐛</a> <a href="#blog-davesmith2" title="Blogposts">📝</a> <a href="#business-davesmith2" title="Business development">💼</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=davesmith2" title="Code">💻</a> <a href="#content-davesmith2" title="Content">🖋</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=davesmith2" title="Documentation">📖</a> <a href="#design-davesmith2" title="Design">🎨</a> <a href="#example-davesmith2" title="Examples">💡</a> <a href="#eventOrganizing-davesmith2" title="Event Organizing">📋</a> <a href="#fundingFinding-davesmith2" title="Funding Finding">🔍</a> <a href="#ideas-davesmith2" title="Ideas, Planning, & Feedback">🤔</a> <a href="#infra-davesmith2" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#maintenance-davesmith2" title="Maintenance">🚧</a> <a href="#platform-davesmith2" title="Packaging/porting to new platform">📦</a> <a href="#projectManagement-davesmith2" title="Project Management">📆</a> <a href="#question-davesmith2" title="Answering Questions">💬</a> <a href="https://github.com/ComplianceAsCode/content/pulls?q=is%3Apr+reviewed-by%3Adavesmith2" title="Reviewed Pull Requests">👀</a> <a href="#tool-davesmith2" title="Tools">🔧</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=davesmith2" title="Tests">⚠️</a> <a href="#tutorial-davesmith2" title="Tutorials">✅</a> <a href="#talk-davesmith2" title="Talks">📢</a> <a href="#userTesting-davesmith2" title="User Testing">📓</a> <a href="#video-davesmith2" title="Videos">📹</a></td>
    <td align="center"><a href="https://github.com/thenefield"><img src="https://avatars1.githubusercontent.com/u/10131401?v=4" width="100px;" alt=""/><br /><sub><b>Trey Henefield</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=thenefield" title="Code">💻</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=thenefield" title="Tests">⚠️</a></td>
    <td align="center"><a href="http://www.scientificlinux.org/"><img src="https://avatars0.githubusercontent.com/u/3534830?v=4" width="100px;" alt=""/><br /><sub><b>Pat Riehecky</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=jcpunk" title="Code">💻</a></td>
    <td align="center"><a href="https://twitter.com/LucyCloudBling"><img src="https://avatars0.githubusercontent.com/u/8429622?v=4" width="100px;" alt=""/><br /><sub><b>Lucy Kerner</b></sub></a><br /><a href="#blog-lkerner" title="Blogposts">📝</a> <a href="#business-lkerner" title="Business development">💼</a> <a href="#eventOrganizing-lkerner" title="Event Organizing">📋</a> <a href="#fundingFinding-lkerner" title="Funding Finding">🔍</a> <a href="#ideas-lkerner" title="Ideas, Planning, & Feedback">🤔</a> <a href="#tutorial-lkerner" title="Tutorials">✅</a> <a href="#talk-lkerner" title="Talks">📢</a> <a href="#video-lkerner" title="Videos">📹</a></td>
    <td align="center"><a href="https://github.com/jamescassell"><img src="https://avatars1.githubusercontent.com/u/5522890?v=4" width="100px;" alt=""/><br /><sub><b>James Cassell</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=jamescassell" title="Code">💻</a></td>
    <td align="center"><a href="https://d0m.tech"><img src="https://avatars2.githubusercontent.com/u/24304777?v=4" width="100px;" alt=""/><br /><sub><b>Dominique Blaze</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=DominiqueDevinci" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/justin-stephenson"><img src="https://avatars3.githubusercontent.com/u/13416969?v=4" width="100px;" alt=""/><br /><sub><b>Justin Stephenson</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=justin-stephenson" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/evgenyz"><img src="https://avatars2.githubusercontent.com/u/429134?v=4" width="100px;" alt=""/><br /><sub><b>Evgeny Kolesnikov</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=evgenyz" title="Code">💻</a> <a href="#ideas-evgenyz" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="https://github.com/tedbrunell"><img src="https://avatars1.githubusercontent.com/u/17598873?v=4" width="100px;" alt=""/><br /><sub><b>tedbrunell</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=tedbrunell" title="Code">💻</a> <a href="#business-tedbrunell" title="Business development">💼</a> <a href="#fundingFinding-tedbrunell" title="Funding Finding">🔍</a> <a href="#tutorial-tedbrunell" title="Tutorials">✅</a> <a href="#talk-tedbrunell" title="Talks">📢</a> <a href="#video-tedbrunell" title="Videos">📹</a></td>
    <td align="center"><a href="https://github.com/mpalmi"><img src="https://avatars0.githubusercontent.com/u/7817675?v=4" width="100px;" alt=""/><br /><sub><b>Mike Palmiotto</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=mpalmi" title="Code">💻</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=mpalmi" title="Tests">⚠️</a> <a href="#tool-mpalmi" title="Tools">🔧</a> <a href="#platform-mpalmi" title="Packaging/porting to new platform">📦</a></td>
    <td align="center"><a href="https://github.com/csreynolds"><img src="https://avatars2.githubusercontent.com/u/7391197?v=4" width="100px;" alt=""/><br /><sub><b>Chris Reynolds</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=csreynolds" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/dehuo0"><img src="https://avatars2.githubusercontent.com/u/25168768?v=4" width="100px;" alt=""/><br /><sub><b>dehuo0</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=dehuo0" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/brianmillett"><img src="https://avatars3.githubusercontent.com/u/20796164?v=4" width="100px;" alt=""/><br /><sub><b>brianmillett</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=brianmillett" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/GautamSatish"><img src="https://avatars3.githubusercontent.com/u/16253354?v=4" width="100px;" alt=""/><br /><sub><b>Gautam Satish</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/issues?q=author%3AGautamSatish" title="Bug reports">🐛</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=GautamSatish" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/cyarbrough76"><img src="https://avatars0.githubusercontent.com/u/42849651?v=4" width="100px;" alt=""/><br /><sub><b>cyarbrough76</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=cyarbrough76" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/lfisher47"><img src="https://avatars2.githubusercontent.com/u/4379348?v=4" width="100px;" alt=""/><br /><sub><b>lfisher47</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=lfisher47" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/kharyam"><img src="https://avatars1.githubusercontent.com/u/1548496?v=4" width="100px;" alt=""/><br /><sub><b>Khary Mendez</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=kharyam" title="Code">💻</a> <a href="#talk-kharyam" title="Talks">📢</a></td>
    <td align="center"><a href="http://portfolio.secureagc.com/"><img src="https://avatars3.githubusercontent.com/u/23314594?v=4" width="100px;" alt=""/><br /><sub><b>Alijohn Ghassemlouei</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=aghassemlouei" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/Mixer9"><img src="https://avatars0.githubusercontent.com/u/35545791?v=4" width="100px;" alt=""/><br /><sub><b>Mixer9</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=Mixer9" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/roysjosh"><img src="https://avatars3.githubusercontent.com/u/601535?v=4" width="100px;" alt=""/><br /><sub><b>Joshua Roys</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=roysjosh" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/hex2a"><img src="https://avatars2.githubusercontent.com/u/8384544?v=4" width="100px;" alt=""/><br /><sub><b>hex2a</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=hex2a" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="http://axel.nennker.de/"><img src="https://avatars0.githubusercontent.com/u/1721863?v=4" width="100px;" alt=""/><br /><sub><b>Axel Nennker</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=AxelNennker" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/pcactr"><img src="https://avatars3.githubusercontent.com/u/11899921?v=4" width="100px;" alt=""/><br /><sub><b>Paul</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=pcactr" title="Code">💻</a></td>
    <td align="center"><a href="http://www.cyberrange.live"><img src="https://avatars1.githubusercontent.com/u/1019703?v=4" width="100px;" alt=""/><br /><sub><b>Kenneth Peeples</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=kpeeples" title="Code">💻</a></td>
    <td align="center"><a href="https://kenyonralph.com/"><img src="https://avatars3.githubusercontent.com/u/68514?v=4" width="100px;" alt=""/><br /><sub><b>Kenyon Ralph</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=kenyon" title="Code">💻</a></td>
    <td align="center"><a href="http://www.kitware.com/company/team/atkins.html"><img src="https://avatars0.githubusercontent.com/u/320135?v=4" width="100px;" alt=""/><br /><sub><b>Chuck Atkins</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=chuckatkins" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/chrisruffalo"><img src="https://avatars3.githubusercontent.com/u/2073493?v=4" width="100px;" alt=""/><br /><sub><b>Chris Ruffalo</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=chrisruffalo" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/carbonin"><img src="https://avatars0.githubusercontent.com/u/12697904?v=4" width="100px;" alt=""/><br /><sub><b>Nick Carboni</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=carbonin" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="http://caitelatte.com"><img src="https://avatars3.githubusercontent.com/u/4994062?v=4" width="100px;" alt=""/><br /><sub><b>Caitlin</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=caitelatte" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/tianzhenjia"><img src="https://avatars0.githubusercontent.com/u/57520621?v=4" width="100px;" alt=""/><br /><sub><b>jiatianzhen</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=tianzhenjia" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/rwilmoth"><img src="https://avatars3.githubusercontent.com/u/5857005?v=4" width="100px;" alt=""/><br /><sub><b>rwilmoth</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=rwilmoth" title="Code">💻</a> <a href="#ideas-rwilmoth" title="Ideas, Planning, & Feedback">🤔</a> <a href="#talk-rwilmoth" title="Talks">📢</a> <a href="#business-rwilmoth" title="Business development">💼</a></td>
    <td align="center"><a href="https://github.com/robinpriceii"><img src="https://avatars3.githubusercontent.com/u/33264661?v=4" width="100px;" alt=""/><br /><sub><b>rprice</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=rprice" title="Code">💻</a> <a href="#talk-rprice" title="Talks">📢</a> <a href="#business-rprice" title="Business development">💼</a></td>
    <td align="center"><a href="https://github.com/robinpriceii"><img src="https://avatars1.githubusercontent.com/u/969440?v=4" width="100px;" alt=""/><br /><sub><b>Robin Price II</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=robinpriceii" title="Code">💻</a> <a href="#talk-robinpriceii" title="Talks">📢</a> <a href="#video-robinpriceii" title="Videos">📹</a> <a href="#tutorial-robinpriceii" title="Tutorials">✅</a></td>
    <td align="center"><a href="https://github.com/nkinder"><img src="https://avatars3.githubusercontent.com/u/2062339?v=4" width="100px;" alt=""/><br /><sub><b>Nathan Kinder</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=nkinder" title="Code">💻</a> <a href="#business-nkinder" title="Business development">💼</a></td>
    <td align="center"><a href="https://github.com/neo-aeon"><img src="https://avatars3.githubusercontent.com/u/8938489?v=4" width="100px;" alt=""/><br /><sub><b>neo-aeon</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=neo-aeon" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/k-stailey"><img src="https://avatars3.githubusercontent.com/u/3269304?v=4" width="100px;" alt=""/><br /><sub><b>k-stailey</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=k-stailey" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/Scronkfinkle"><img src="https://avatars2.githubusercontent.com/u/11369800?v=4" width="100px;" alt=""/><br /><sub><b>Jesse Roland</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=Scronkfinkle" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/Joeri-MS"><img src="https://avatars2.githubusercontent.com/u/19310105?v=4" width="100px;" alt=""/><br /><sub><b>Stephan Joerrens</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=Joeri-MS" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/Cooper-ORNL"><img src="https://avatars0.githubusercontent.com/u/32870287?v=4" width="100px;" alt=""/><br /><sub><b>cooper-ornl</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=cooper-ornl" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/rodneymercer"><img src="https://avatars2.githubusercontent.com/u/8418659?v=4" width="100px;" alt=""/><br /><sub><b>rodneymercer</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=rodneymercer" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/joenall"><img src="https://avatars0.githubusercontent.com/u/51613?v=4" width="100px;" alt=""/><br /><sub><b>Joe Nall</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=joenall" title="Code">💻</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=joenall" title="Tests">⚠️</a> <a href="https://github.com/ComplianceAsCode/content/issues?q=author%3Ajoenall" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/agilmore2"><img src="https://avatars2.githubusercontent.com/u/6852298?v=4" width="100px;" alt=""/><br /><sub><b>agilmore2</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=agilmore2" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/Jibzzz"><img src="https://avatars1.githubusercontent.com/u/9675277?v=4" width="100px;" alt=""/><br /><sub><b>Jibzzz</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=Jibzzz" title="Code">💻</a></td>
    <td align="center"><a href="http://security-plus-data-science.blogspot.com/"><img src="https://avatars2.githubusercontent.com/u/18726848?v=4" width="100px;" alt=""/><br /><sub><b>Steve Grubb</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=stevegrubb" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/shaneboulden"><img src="https://avatars2.githubusercontent.com/u/1834999?v=4" width="100px;" alt=""/><br /><sub><b>shaneboulden</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=shaneboulden" title="Code">💻</a> <a href="#business-shaneboulden" title="Business development">💼</a></td>
    <td align="center"><a href="https://github.com/sdunne"><img src="https://avatars1.githubusercontent.com/u/7119497?v=4" width="100px;" alt=""/><br /><sub><b>sdunne</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=sdunne" title="Code">💻</a> <a href="#business-sdunne" title="Business development">💼</a></td>
    <td align="center"><a href="https://github.com/rrenshaw"><img src="https://avatars0.githubusercontent.com/u/10158660?v=4" width="100px;" alt=""/><br /><sub><b>Rick Renshaw</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=rrenshaw" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/pvrabec"><img src="https://avatars1.githubusercontent.com/u/8696003?v=4" width="100px;" alt=""/><br /><sub><b>Peter Vrabec</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/issues?q=author%3Apvrabec" title="Bug reports">🐛</a> <a href="#blog-pvrabec" title="Blogposts">📝</a> <a href="#business-pvrabec" title="Business development">💼</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=pvrabec" title="Code">💻</a> <a href="#fundingFinding-pvrabec" title="Funding Finding">🔍</a> <a href="#ideas-pvrabec" title="Ideas, Planning, & Feedback">🤔</a> <a href="#projectManagement-pvrabec" title="Project Management">📆</a> <a href="#question-pvrabec" title="Answering Questions">💬</a> <a href="https://github.com/ComplianceAsCode/content/pulls?q=is%3Apr+reviewed-by%3Apvrabec" title="Reviewed Pull Requests">👀</a> <a href="#tool-pvrabec" title="Tools">🔧</a> <a href="https://github.com/ComplianceAsCode/content/commits?author=pvrabec" title="Tests">⚠️</a> <a href="#tutorial-pvrabec" title="Tutorials">✅</a> <a href="#talk-pvrabec" title="Talks">📢</a> <a href="#video-pvrabec" title="Videos">📹</a></td>
    <td align="center"><a href="https://github.com/pschneiders"><img src="https://avatars2.githubusercontent.com/u/57761736?v=4" width="100px;" alt=""/><br /><sub><b>Bryan Schneiders</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=pschneiders" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/opoplawski"><img src="https://avatars1.githubusercontent.com/u/814662?v=4" width="100px;" alt=""/><br /><sub><b>Orion Poplawski</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=opoplawski" title="Code">💻</a></td>
    <td align="center"><a href="http://people.redhat.com/mrogers"><img src="https://avatars3.githubusercontent.com/u/3697177?v=4" width="100px;" alt=""/><br /><sub><b>Matt Rogers</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=mrogers950" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/mralph-rh"><img src="https://avatars2.githubusercontent.com/u/55860499?v=4" width="100px;" alt=""/><br /><sub><b>mralph-rh</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=mralph-rh" title="Code">💻</a></td>
    <td align="center"><a href="http://maxp.info"><img src="https://avatars0.githubusercontent.com/u/194949?v=4" width="100px;" alt=""/><br /><sub><b>Max P</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=maxrp" title="Code">💻</a></td>
    <td align="center"><a href="https://hwarf.com/"><img src="https://avatars1.githubusercontent.com/u/392493?v=4" width="100px;" alt=""/><br /><sub><b>Joshua Glemza</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=jglemza" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/finkr"><img src="https://avatars2.githubusercontent.com/u/13090680?v=4" width="100px;" alt=""/><br /><sub><b>Frank lin Piat</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=finkr" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/dthurston"><img src="https://avatars2.githubusercontent.com/u/1986197?v=4" width="100px;" alt=""/><br /><sub><b>Derek Thurston</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=dthurston" title="Code">💻</a> <a href="#business-dthurston" title="Business development">💼</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/dhanushkar-wso2"><img src="https://avatars3.githubusercontent.com/u/5975012?v=4" width="100px;" alt=""/><br /><sub><b>dhanushkar-wso2</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=dhanushkar-wso2" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/VadimDor"><img src="https://avatars1.githubusercontent.com/u/29509093?v=4" width="100px;" alt=""/><br /><sub><b>VadimDor</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=VadimDor" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/OnceUponALoop"><img src="https://avatars1.githubusercontent.com/u/3958336?v=4" width="100px;" alt=""/><br /><sub><b>Firas AlShafei</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=OnceUponALoop" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/yasirimam1980"><img src="https://avatars0.githubusercontent.com/u/29631706?v=4" width="100px;" alt=""/><br /><sub><b>Yasir Imam</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=yasirimam1980" title="Code">💻</a> <a href="#business-yasirimam1980" title="Business development">💼</a> <a href="#talk-yasirimam1980" title="Talks">📢</a></td>
    <td align="center"><a href="https://github.com/rchayes"><img src="https://avatars2.githubusercontent.com/u/27025189?v=4" width="100px;" alt=""/><br /><sub><b>RCHAYES</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=rchayes" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/mshoger"><img src="https://avatars3.githubusercontent.com/u/14096981?v=4" width="100px;" alt=""/><br /><sub><b>Mark Shoger</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=mshoger" title="Code">💻</a> <a href="#business-mshoger" title="Business development">💼</a></td>
    <td align="center"><a href="https://github.com/jstookey"><img src="https://avatars3.githubusercontent.com/u/2437590?v=4" width="100px;" alt=""/><br /><sub><b>jstookey</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=jstookey" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/ghylock"><img src="https://avatars2.githubusercontent.com/u/10871129?v=4" width="100px;" alt=""/><br /><sub><b>ghylock</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=ghylock" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/angystardust"><img src="https://avatars1.githubusercontent.com/u/1568397?v=4" width="100px;" alt=""/><br /><sub><b>angystardust</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=angystardust" title="Code">💻</a></td>
    <td align="center"><a href="https://klaas.is"><img src="https://avatars0.githubusercontent.com/u/320967?v=4" width="100px;" alt=""/><br /><sub><b>Klaas</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=Klaas" title="Code">💻</a></td>
    <td align="center"><a href="http://noslzzp.com/"><img src="https://avatars1.githubusercontent.com/u/1154653?v=4" width="100px;" alt=""/><br /><sub><b>NoSLZZP</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=noslzzp" title="Code">💻</a> <a href="#business-noslzzp" title="Business development">💼</a> <a href="#ideas-noslzzp" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="http://termlen0.github.io"><img src="https://avatars3.githubusercontent.com/u/18330662?v=4" width="100px;" alt=""/><br /><sub><b>Ajay Chenampara</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=termlen0" title="Code">💻</a></td>
    <td align="center"><a href="http://www.secureoss.jp"><img src="https://avatars1.githubusercontent.com/u/18388388?v=4" width="100px;" alt=""/><br /><sub><b>Kazuki Omo</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=omok314159" title="Code">💻</a></td>
    <td align="center"><a href="http://he-insanity.blogspot.com/"><img src="https://avatars3.githubusercontent.com/u/22501234?v=4" width="100px;" alt=""/><br /><sub><b>J. Alexander Jacocks</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=ajacocks" title="Code">💻</a> <a href="#business-ajacocks" title="Business development">💼</a> <a href="#talk-ajacocks" title="Talks">📢</a> <a href="#video-ajacocks" title="Videos">📹</a> <a href="#tutorial-ajacocks" title="Tutorials">✅</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/gregelin"><img src="https://avatars0.githubusercontent.com/u/24979?v=4" width="100px;" alt=""/><br /><sub><b>Greg Elin</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=gregelin" title="Code">💻</a> <a href="#talk-gregelin" title="Talks">📢</a> <a href="#video-gregelin" title="Videos">📹</a></td>
    <td align="center"><a href="https://github.com/fcaviggia"><img src="https://avatars3.githubusercontent.com/u/6098307?v=4" width="100px;" alt=""/><br /><sub><b>Frank Caviggia</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=fcaviggia" title="Code">💻</a></td>
    <td align="center"><a href="https://jaredhocutt.com/"><img src="https://avatars2.githubusercontent.com/u/203993?v=4" width="100px;" alt=""/><br /><sub><b>Jared Hocutt</b></sub></a><br /><a href="#business-jaredhocutt" title="Business development">💼</a> <a href="#blog-jaredhocutt" title="Blogposts">📝</a> <a href="#ideas-jaredhocutt" title="Ideas, Planning, & Feedback">🤔</a> <a href="#talk-jaredhocutt" title="Talks">📢</a> <a href="#video-jaredhocutt" title="Videos">📹</a></td>
    <td align="center"><a href="https://www.redhat.com"><img src="https://avatars3.githubusercontent.com/u/2224957?v=4" width="100px;" alt=""/><br /><sub><b>Brad</b></sub></a><br /><a href="#business-dischord01" title="Business development">💼</a> <a href="#ideas-dischord01" title="Ideas, Planning, & Feedback">🤔</a> <a href="#talk-dischord01" title="Talks">📢</a> <a href="#video-dischord01" title="Videos">📹</a> <a href="#tutorial-dischord01" title="Tutorials">✅</a></td>
    <td align="center"><a href="https://github.com/matmille"><img src="https://avatars2.githubusercontent.com/u/22505310?v=4" width="100px;" alt=""/><br /><sub><b>matmille</b></sub></a><br /><a href="#business-matmille" title="Business development">💼</a> <a href="#ideas-matmille" title="Ideas, Planning, & Feedback">🤔</a> <a href="#talk-matmille" title="Talks">📢</a> <a href="#tutorial-matmille" title="Tutorials">✅</a></td>
    <td align="center"><a href="https://medium.com/@dudash"><img src="https://avatars0.githubusercontent.com/u/116840?v=4" width="100px;" alt=""/><br /><sub><b>Jason Dudash</b></sub></a><br /><a href="#ideas-dudash" title="Ideas, Planning, & Feedback">🤔</a> <a href="#talk-dudash" title="Talks">📢</a> <a href="#tutorial-dudash" title="Tutorials">✅</a></td>
    <td align="center"><a href="http://project.fortnebula.com"><img src="https://avatars1.githubusercontent.com/u/15927081?v=4" width="100px;" alt=""/><br /><sub><b>Donny Davis</b></sub></a><br /><a href="#ideas-donnydavis" title="Ideas, Planning, & Feedback">🤔</a> <a href="#talk-donnydavis" title="Talks">📢</a> <a href="#tutorial-donnydavis" title="Tutorials">✅</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/bhirsch70"><img src="https://avatars1.githubusercontent.com/u/17462822?v=4" width="100px;" alt=""/><br /><sub><b>Bill Hirsch</b></sub></a><br /><a href="#ideas-bhirsch70" title="Ideas, Planning, & Feedback">🤔</a> <a href="#talk-bhirsch70" title="Talks">📢</a> <a href="#tutorial-bhirsch70" title="Tutorials">✅</a> <a href="#video-bhirsch70" title="Videos">📹</a></td>
    <td align="center"><a href="https://github.com/rlucente-se-jboss"><img src="https://avatars2.githubusercontent.com/u/794078?v=4" width="100px;" alt=""/><br /><sub><b>rlucente-se-jboss</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=rlucente-se-jboss" title="Code">💻</a> <a href="#ideas-rlucente-se-jboss" title="Ideas, Planning, & Feedback">🤔</a> <a href="#talk-rlucente-se-jboss" title="Talks">📢</a> <a href="#tutorial-rlucente-se-jboss" title="Tutorials">✅</a></td>
    <td align="center"><a href="https://github.com/lkinser"><img src="https://avatars0.githubusercontent.com/u/11739646?v=4" width="100px;" alt=""/><br /><sub><b>Lee Kinser</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=lkinser" title="Code">💻</a> <a href="#ideas-lkinser" title="Ideas, Planning, & Feedback">🤔</a> <a href="#talk-lkinser" title="Talks">📢</a> <a href="#tutorial-lkinser" title="Tutorials">✅</a></td>
    <td align="center"><a href="https://github.com/mmsrubar"><img src="https://avatars0.githubusercontent.com/u/4816654?v=4" width="100px;" alt=""/><br /><sub><b>Michal Šrubař</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=mmsrubar" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/lamawithonel"><img src="https://avatars3.githubusercontent.com/u/532659?v=4" width="100px;" alt=""/><br /><sub><b>Lucas Yamanishi</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=lamawithonel" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/pekramp"><img src="https://avatars2.githubusercontent.com/u/44277487?v=4" width="100px;" alt=""/><br /><sub><b>pekramp</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=pekramp" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/npoyant"><img src="https://avatars1.githubusercontent.com/u/16897713?v=4" width="100px;" alt=""/><br /><sub><b>Nick</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=npoyant" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/crleekwc"><img src="https://avatars2.githubusercontent.com/u/18608257?v=4" width="100px;" alt=""/><br /><sub><b>Christopher Lee</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=crleekwc" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/anixon-rh"><img src="https://avatars2.githubusercontent.com/u/55244503?v=4" width="100px;" alt=""/><br /><sub><b>anixon-rh</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=anixon-rh" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
