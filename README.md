## Welcome!
The purpose of this project is to create *security policy content* for various
platforms -- *Red Hat Enterprise Linux*, *Fedora*, *Ubuntu*, *Debian*, and others.
Our aim is to make it as easy as possible to write new and maintain existing
security content in all the commonly used formats.

### We build security content in various formats

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

This project is an attempt to allow multiple organizations to
efficiently develop security content by avoiding redundancy, which is
possible by taking advantage of the powerful build system of this project.
The build system combines the easy-to-edit YAML rule files with OVAL checks,
Ansible task snippets, Bash fixes and other files. Templating is provided
at every step to avoid boilerplate. Security identifiers (CCE, NIST ID, STIG, ...)
appear in all of our output formats but are all sourced from the YAML rule files.

We understand that depending on your organization's needs you may need
to use a specific security content format. We let you choose.

### Scan targets

Our security content can be used to scan bare-metal machines, virtual machines,
virtual machine images (qcow2 and others), containers (including Docker) and
container images.

We use platform checks to detect whether we should or should not evaluate some
of the rules. For example: separate partition checks make perfect sense on bare-metal
machines but go against recommended practices on containers.

## Installation
The preferred method of installation is via the package manager of your
distribution. On *Red Hat Enterprise Linux* and *Fedora* you can use:
`yum install scap-security-guide`.

On Debian (sid), you can use:
`apt install ssg-debian` for Debian guides.
`apt install ssg-debderived` for Debian-based distributions (e.g. Ubuntu) guides.
`apt install ssg-nondebian` for other distributions guides (RHEL, Fedora, etc.).
`apt install ssg-applications` for application-oriented guides (Firefox, JBoss, etc.).

If SCAP Security Guide is not packaged in your distribution or if the
version that is packaged is too old, you need to build the content yourself
and install it via `make install`. Please see the [BUILD.md](BUILD.md)
document for more info. We also recommend opening an issue on that distributions
bug tracker to voice interest.

Or you can download pre-built SSG zip archive from [latest release](https://github.com/OpenSCAP/scap-security-guide/releases/latest).

## Build from the source
Please see the [BUILD.md](BUILD.md) document for detailed build instructions.

## Usage
We assume you have installed SCAP Security Guide system-wide into a
standard location as instructed in the previous section.

There are several ways to consume SCAP Security Guide content, we will only
go through a few of them here.

### `oscap` tool
The `oscap` tool is a low-level command line interface that comes from
the OpenSCAP project. It can be used to scan the local machine.
```
# oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_rht-ccp --results-arf arf.xml --report report.html --oval-results /usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml
```
After evaluation, the `arf.xml` file will contain all results in a reusable
*Result DataStream* format, `report.html` will contain a human readable
report that can be opened in a browser.

Replace the profile with other profile of your choice, you can display
all possible choices using:
```
# oscap info /usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml
```

Please see the [OpenSCAP User Manual](https://static.open-scap.org/openscap-1.2/oscap_user_manual.html)
for more info.

### SCAP Workbench
The SCAP Workbench is a graphical user interface for SCAP evaluation and
customization. It is suitable for scanning a single machine, either local
or remote (via SSH). New versions of SCAP Workbench have SSG integration
and will automatically offer it when the application is started.

Please see the [SCAP Workbench User Manual](https://static.open-scap.org/scap-workbench-1.1/)
for more info.

### `oscap-ssh` tool
`oscap-ssh` comes bundled with OpenSCAP 1.2.3 and later. It allows scanning
a remote machine via SSH with an interface resembling the `oscap` tool.

The following command evaluates machine with IP `192.168.1.123` with content
stored on local machine. Keep in mind that `oscap` has to be installed on the
remote machine but the SSG content doesn't need to be.
```
# oscap-ssh root@192.168.1.123 22 xccdf eval --profile xccdf_org.ssgproject.content_profile_usgcb-rhel6-server --results-arf arf.xml --report report.html /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml
```

### Ansible
. To see a list of available playbooks, run:
```
# ls /usr/share/scap-security-guide/ansible/
...
ssg-rhel6-role-standard.yml
ssg-rhel6-role-stig-rhel6-server-upstream.yml
ssg-rhel6-role-usgcb-rhel6-server.yml
ssg-rhel7-role-C2S.yml
ssg-rhel7-role-cjis-rhel7-server.yml
ssg-rhel7-role-common.yml
ssg-rhel7-role-docker-host.yml
ssg-rhel7-role-nist-800-171-cui.yml
...
```
These roles are generated from *SCAP* profiles available for the products.

To apply the playbook on your local machine run: (*THIS WILL CHANGE CONFIGURATION OF THE MACHINE!*)
```
# ansible-playbook -i "localhost," -c local /usr/share/scap-security-guide/ansible/ssg-rhel7-role-rht-ccp.yml
```
Each of the Ansible playbooks contain instructions on how to deploy them. Here is a snippet of the instructions:
```
...
# This file was generated by OpenSCAP 1.2.16 using:
# 	$ oscap xccdf generate fix --profile rht-ccp --template urn:xccdf:fix:script:ansible sds.xml
#
# This script is generated from an OpenSCAP profile without preliminary evaluation.
# It attempts to fix every selected rule, even if the system is already compliant.
#
# How to apply this remediation role:
# $ ansible-playbook -i "192.168.1.155," playbook.yml
# $ ansible-playbook -i inventory.ini playbook.yml
...
```

## Deprecated Content

For a list of deprecated content, review the [Deprecated Content Table](https://github.com/OpenSCAP/scap-security-guide/blob/master/docs/manual/user_guide.adoc#deprecated-content)
in the User Guide. If you need to you can still use this content by using an older release of this project.

## Support

The SSG mailing list can be found at [https://lists.fedorahosted.org/mailman/listinfo/scap-security-guide](https://lists.fedorahosted.org/mailman/listinfo/scap-security-guide).

If you encounter issues with OpenSCAP or SCAP Workbench, use [https://www.redhat.com/mailman/listinfo/open-scap-list](https://www.redhat.com/mailman/listinfo/open-scap-list)

You can also join the `#openscap` IRC channel on `chat.freenode.net`.

## COPR Repo

We have created a new COPR repository that provides unofficial builds of latest versions of openscap, scap-security-guide, scap-workbench and openscap-daemon packages. The packages are suitable for use on Red Hat Enterprise Linux 6 and 7 and CentOS 6 and 7.

The COPR repository is located on:
https://copr.fedorainfracloud.org/coprs/openscapmaint/openscap-latest/

The repo enables you to test the latest greatest OpenSCAP bits on RHEL and CentOS.

#### Health Checks
* Python Code via landscape.io: [![Code Health](https://landscape.io/github/OpenSCAP/scap-security-guide/master/landscape.png)](https://landscape.io/github/OpenSCAP/scap-security-guide/master)

## Further reading:

The SSG homepage is https://www.open-scap.org/security-policies/scap-security-guide/

 * [SSG User Manual](docs/manual/user_guide.adoc)
 * [SSG Developer Guide](docs/manual/developer_guide.adoc)
