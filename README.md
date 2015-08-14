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

The SSG homepage is https://fedorahosted.org/scap-security-guide/

## How to use
We assume you have installed SCAP Security Guide system-wide into a
standard location -- via a package or via `make install`.

There are several ways to consume SCAP Security Guide content, we will only
go through a few of them here.

### `oscap` tool
The `oscap` tool is a low-level command line interface that comes from
the OpenSCAP project. It can be used to scan the local machine.
```
# oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_usgcb-rhel6-server /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml
```

Replace the profile with other profile of your choice, you can display
all possible choices using:
```
# oscap info /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml
```

The SSG mailing list can be found at [https://lists.fedorahosted.org/mailman/listinfo/scap-security-guide](https://lists.fedorahosted.org/mailman/listinfo/scap-security-guide).

#### Health Checks
* Python Code via landscape.io: [![Code Health](https://landscape.io/github/OpenSCAP/scap-security-guide/master/landscape.png)](https://landscape.io/github/OpenSCAP/scap-security-guide/master)
