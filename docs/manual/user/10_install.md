# Installing

By installing distribution packages, you will get the built content.
For example, on Red Hat-based distributions, those will be files under the `/usr/share/xml/scap/ssg/content/` directory.
What files will that be depends on the distribution, but for example on Fedora, you will get the Fedora data stream at `/usr/share/xml/scap/ssg/content/ssg-fedora-ds.xml`.


## Installing from distribution packages

### Fedora / Red Hat Enterprise Linux 8+
```
$ sudo dnf -y install scap-security-guide
```

### Debian
```
$ sudo apt install ssg-debian  # for Debian guides
$ sudo apt install ssg-debderived  # for Debian-based distributions (e.g. Ubuntu) guides
$ sudo apt install ssg-nondebian  # for other distributions guides (RHEL, Fedora, etc.)
$ sudo apt install ssg-applications  # for application-oriented guides (Firefox, JBoss, etc.)
```

## Installing content from upstream

If you need to use upstream content rather than what is shipped in the distribution, you can download the nightly build, or build it yourself.

The nightly builds are performed by [GitHub Actions](https://docs.github.com/en/actions) nightly. Below is a direct link to the latest build:

* [https://nightly.link/ComplianceAsCode/content/workflows/nightly_build/master/Nightly%20Build.zip](https://nightly.link/ComplianceAsCode/content/workflows/nightly_build/master/Nightly%20Build.zip)

If you wish to build the content yourself, please, refer to the [Developer Guide](../developer/02_building_complianceascode.md#building-complianceascode).
