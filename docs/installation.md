---
# Page settings
layout: default
keywords:
comments: false

# Hero section
title: Installation Guide
description: Download and begin using SSG content.

# Author box
#author:
#    title: About Author
#    title_url: '#'
#    external_url: true
#    description: Author description

# Micro navigation
micro_nav: true

# Page navigation
#page_nav:
#    prev:
#        content: Previous page
#        url: '#'
#    next:
#        content: Next page
#        url: '#'
---
In progress!

## Upstream

### GitHub Releases
....


### COPR
Copr is a Fedora project to help make building and managing package repositories easy. The project's COPR repository provides unofficial builds of the latest openscap, scap-security-guide, scap-workbench, and openscap-daemon packages. The packages are suitable for use on RHEL, CentOS, and Scientific Linux.

The COPR repository is located at [https://copr.fedorainfracloud.org/coprs/openscapmaint/openscap-latest/](https://copr.fedorainfracloud.org/coprs/openscapmaint/openscap-latest/).

**If you're using a version of Linux with ``dnf``**, and have the ``dnf-plugins-core`` package installed:
```
$ sudo dnf copr enable openscapmaint/openscap-latest
$ dnf install scap-security-guide
```

**If you're on an older YUM-based distribution**, and have the ``yum-plugin-copr`` package installed:
```
$ sudo yum copr enable openscapmaint/openscap-latest
$ sudo yum install scap-security-guide
```

Alternatively, **download the YUM .repo directly from the FedoraProject**:
```
$ wget http://copr.fedoraproject.org/coprs/openscapmaint/openscap-latest/repo/epel-7/openscapmaint-openscap-latest-epel-7.repo -O /etc/yum.repos.d/openscapmaint-openscap-latest-epel-7.repo
$ sudo yum install scap-security-guide
```
