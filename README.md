## Welcome!
The purpose of this project is to create *SCAP content* for various
platforms -- Red Hat Enterprise Linux 6, Red Hat Enterprise Linux 7,
Fedora, and others.  *"SCAP content"* refers to documents  in the *XCCDF*,
*OVAL* and *Source DataStream* formats.  These documents can be presented
in different forms and by different organizations to meet their security
automation and technical implementation needs.

This project is an attempt to allow multiple organizations to
efficiently develop such content by avoiding redundancy, which is
possible by taking advantage of features of the *SCAP standards*. First,
*SCAP content* is easily transformed programmatically.  XCCDF also supports
selection of subsets of content through a "profile" and granular adjustment
of settings through a "refine-value."

The goal of this project to enable the creation of multiple security
baselines from a single set of high-quality SCAP content.

The SSG homepage is https://www.open-scap.org/security-policies/scap-security-guide/

## Installation
The preferred method of installation is via the package manager of your
distribution. On RHEL and Fedora you can use:
`yum install scap-security-guide`.

If SCAP Security Guide is not packaged in your distribution or if the
version that is packaged is too old, you need to build the content yourself
and install it via `make install`. Please see the [BUILD.md](BUILD.md)
document for more info.

## Usage
We assume you have installed SCAP Security Guide system-wide into a
standard location as instructed in the previous section.

There are several ways to consume SCAP Security Guide content, we will only
go through a few of them here.

### `oscap` tool
The `oscap` tool is a low-level command line interface that comes from
the OpenSCAP project. It can be used to scan the local machine.
```
# oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_usgcb-rhel6-server --results-arf arf.xml --report report.html /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml
```
After evaluation, the `arf.xml` file will contain all results in a reusable
*Result DataStream* format, `report.html` will contain a human readable
report that can be opened in a browser.

Replace the profile with other profile of your choice, you can display
all possible choices using:
```
# oscap info /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml
```

Please see the [User Manual](http://static.open-scap.org/openscap-1.0/oscap_user_manual.html)
for more info.

### SCAP Workbench
The SCAP Workbench is a graphical user interface for SCAP evaluation and
customization. It is suitable for scanning a single machine, either local
or remote (via SSH). New versions of SCAP Workbench have SSG integration
and will automatically offer it when the application is started.

Please see the [User Manual](http://static.open-scap.org/scap-workbench-1.1/)
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

## Support

The SSG mailing list can be found at [https://lists.fedorahosted.org/mailman/listinfo/scap-security-guide](https://lists.fedorahosted.org/mailman/listinfo/scap-security-guide).

If you encounter issues with OpenSCAP or SCAP Workbench, use [https://www.redhat.com/mailman/listinfo/open-scap-list](https://www.redhat.com/mailman/listinfo/open-scap-list)

You can also join the `#openscap` IRC channel on `chat.freenode.net`.

## COPR Repo

We have created a new COPR repository that provides unofficial builds of latest versions of openscap, scap-security-guide, scap-workbench and openscap-daemon packages. The packages are suitable for use on Red Hat Enterprise Linux 5, 6 and 7 and CentOS 5, 6 and 7.

The COPR repository is located on:
https://copr.fedorainfracloud.org/coprs/openscapmaint/openscap-latest/

The repo enables you to test the latest greatest OpenSCAP bits on RHEL and CentOS.

The former repository isimluk/OpenSCAP will not be maintained anymore. Sorry for inconvenience.

#### Health Checks
* Python Code via landscape.io: [![Code Health](https://landscape.io/github/OpenSCAP/scap-security-guide/master/landscape.png)](https://landscape.io/github/OpenSCAP/scap-security-guide/master)
