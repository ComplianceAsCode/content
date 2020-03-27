# Welcome!
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-22-orange.svg?style=flat-square)](#contributors-)
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
Our aim is to make it as easy as possible to write new and maintain existing
security content in all the commonly used formats.

## We build security content in various formats

![NIST logo](docs/readme_images/nist_logo.svg "NIST logo") &nbsp; &nbsp; ![Ansible logo](docs/readme_images/ansible_logo.svg "Ansible logo") &nbsp; &nbsp; ![Bash logo](docs/readme_images/bash_logo.png "Bash logo")

*"SCAP content"* refers to documents  in the *XCCDF*, *OVAL* and
*Source DataStream* formats.  These documents can be presented
in different forms and by different organizations to meet their security
automation and technical implementation needs.  For general use we
recommend *Source DataStreams* because they contain all the data you
need to evaluate and put machines into compliance. The datastreams are
part of our release ZIP archives.

*"Ansible content"* refers to Ansible playbooks generated from security
profiles.  These can be used both in check-mode to evaluate compliance,
as well as run-mode to put machines into compliance.  We publish these
on *Ansible Galaxy* as well as in release ZIP archives.

*"Bash fix files"* refers to *Bash* scripts generate from security
profiles.  These are meant to be run on machines to put them into
compliance.  We recommend using other formats but understand that for
some deployment scenarios bash is the only option.

### Why?

We want multiple organizations to be able to efficiently develop security
content. By taking advantage of the powerful build system of this project,
we avoid as much redundancy as possible.

The build system combines the easy-to-edit YAML rule files with OVAL checks,
Ansible task snippets, Bash fixes and other files. Templating is provided
at every step to avoid boilerplate. Security identifiers
(CCE, NIST ID, STIG, ...) appear in all of our output formats but are all
sourced from the YAML rule files.

We understand that depending on your organization's needs you may need
to use a specific security content format. We let you choose.

![Build system schema](docs/readme_images/build_schema.svg "Build system schema")

---
We use an OpenControl-inspired YAML rule format for input. Write once and
generate security content in XCCDF, Ansible and others.

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
virtual machine images (qcow2 and others), containers (including Docker) and
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
of openscap, scap-security-guide, scap-workbench and openscap-daemon.
The packages are suitable for use on Red Hat Enterprise Linux 6 and 7 and CentOS 6 and 7.

See https://copr.fedorainfracloud.org/coprs/openscapmaint/openscap-latest/ for
detailed instructions.

### From source

If ComplianceAsCode is not packaged in your distribution (it may be present there as `scap-security-guide` package), or if the
version that is packaged is too old, you need to build the content yourself
and install it via `make install`. Please see the [Developer Guide](docs/manual/developer_guide.adoc)
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

Please see the [OpenSCAP User Manual](https://static.open-scap.org/openscap-1.2/oscap_user_manual.html)
for more info.

### SCAP Workbench

The SCAP Workbench is a graphical user interface for SCAP evaluation and
customization. It is suitable for scanning a single machine, either local
or remote (via SSH). New versions of SCAP Workbench have SSG integration
and will automatically offer it when the application is started.

Please see the
[SCAP Workbench User Manual](https://static.open-scap.org/scap-workbench-1.1/)
for more info.

### `oscap-ssh` tool

`oscap-ssh` comes bundled with OpenSCAP 1.2.3 and later. It allows scanning
a remote machine via SSH with an interface resembling the `oscap` tool.

The following command evaluates machine with IP `192.168.1.123` with content
stored on local machine. Keep in mind that `oscap` has to be installed on the
remote machine but the SSG content doesn't need to be.

```bash
oscap-ssh root@192.168.1.123 22 xccdf eval --profile xccdf_org.ssgproject.content_profile_usgcb-rhel6-server --results-arf arf.xml --report report.html /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml
```

### Ansible

To see a list of available Ansible Playbooks, run:

```bash
# ls /usr/share/scap-security-guide/ansible/
...
rhel6-playbook-standard.yml
rhel6-playbook-stig-rhel6-server-upstream.yml
rhel6-playbook-usgcb-rhel6-server.yml
rhel7-playbook-C2S.yml
rhel7-playbook-cjis-rhel7-server.yml
rhel7-playbook-common.yml
rhel7-playbook-docker-host.yml
rhel7-playbook-cui.yml
...
```

These Ansible Playbooks are generated from *SCAP* profiles available for the products.

To apply the playbook on your local machine run:
(*THIS WILL CHANGE CONFIGURATION OF THE MACHINE!*)

```bash
ansible-playbook -i "localhost," -c local /usr/share/scap-security-guide/ansible/rhel7-playbook-rht-ccp.yml
```

Each of the Ansible Playbooks contain instructions on how to deploy them. Here
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

Later, the industry starting moving towards different security content formats,
such as Ansible, Puppet and Chef InSpec. The community reacted by evolving the
tooling and helped transform SSG into a more general-purpose security content
project. This change happened over time in 2017 and 2018. In September 2018, we
decided to change the name of the project to avoid confusion.

We envision that the future will be format-agnostic. That's why opted for an
abstraction instead of using XCCDF for the input format.

## Further reading

The SSG homepage is [https://www.open-scap.org/security-policies/scap-security-guide/](https://www.open-scap.org/security-policies/scap-security-guide/).

* [SSG User Manual](docs/manual/user_guide.adoc)
* [SSG Developer Guide](docs/manual/developer_guide.adoc)
* [Compliance As Code Blog](https://complianceascode.github.io/)

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/redhatrises"><img src="https://avatars2.githubusercontent.com/u/8398836?v=4" width="100px;" alt=""/><br /><sub><b>Gabe Alford</b></sub></a><br /><a href="https://github.com/ComplianceAsCode/content/commits?author=redhatrises" title="Code">💻</a></td>
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
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!