# Building SCAP Security Guide

## From source

### Installing build dependencies

On *Red Hat Enterprise Linux* make sure the packages `cmake`, `openscap-utils`,
`PyYAML`, `python-jinja2` and their dependencies are installed. We require
version `1.0.8` or later of `openscap-utils`.

```bash
yum install cmake openscap-utils PyYAML python-jinja2
```

On Fedora the package list is the same, but their names are a bit different:

```bash
dnf install cmake openscap-utils python3-pyyaml python3-jinja2
```

On *Ubuntu* and *Debian*, make sure the packages `libopenscap8`,
`libxml2-utils`, `xsltproc`, `python-jinja2` and their dependencies are
installed.

```bash
apt-get install cmake expat libopenscap8 libxml2-utils ninja-build python3-jinja2 python3-yaml xsltproc
```

(optional) Install git if you want to clone the GitHub repository to get the
source code:

```bash
yum install git
```

(optional) Install the `ShellCheck` package to perform fix script static analysis:

```bash
yum install ShellCheck
```

(optional) Install `yamllint` and `ansible-lint` packages to perform Ansible
playbooks checks. These checks are not enabled by default in CTest, to enable
them add `-DANSIBLE_CHECKS=ON` option to `cmake`.
```bash
yum install yamllint ansible-lint
```

(optional) Install the `ninja` build system if you want to use it instead of
`make` for faster builds:

```bash
yum install ninja-build
```

### Downloading the source code

Download and extract a tarball from the [list of releases](https://github.com/ComplianceAsCode/content/releases):

```bash
# change X.Y.Z for desired version
ssg_version="X.Y.Z"
wget "https://github.com/ComplianceAsCode/content/releases/download/v$ssg_version/scap-security-guide-$ssg_version.tar.bz2"
tar -xvjf ./scap-security-guide-$ssg_version.tar.bz2
cd ./scap-security-guide-$ssg_version/
```

Or clone the GitHub repository:

```bash
git clone https://github.com/ComplianceAsCode/content.git
cd content/
# (optional) select release version - change X.Y.Z for desired version
git checkout vX.Y.Z
# (optional) select latest development version
git checkout master
```

### Building

To build all the security content:

```bash
cd content/
cd build/
cmake ../
make -j4
```

(optional) To build everything only for one specific product - for example all
security content only for *Red Hat Enterprise Linux 7*:

```bash
cd content/
cd build/
cmake ../
make -j4 rhel7
```

(optional) To build only specific content for one specific product:

```bash
cd content/
cd build/
cmake ../
make -j4 rhel7-content  # SCAP XML files for RHEL7
make -j4 rhel7-guides  # HTML guides for RHEL7
make -j4 rhel7-tables  # HTML tables for RHEL7
make -j4 rhel7-roles  # remediation roles for RHEL7
make -j4 rhel7  # everything above for RHEL7
```

(optional) Configure options before building using a GUI tool:

```bash
cd content/
cd build/
cmake-gui ../
make -j4
```

(optional) Use the `ninja` build system (requires the `ninja-build` package):

```bash
cd content/
cd build/
cmake -G Ninja ../
ninja-build  # depending on the distribution just "ninja" may also work
```

### Build outputs

When the build has completed, the output will be in the build folder.
That can be any folder you choose but if you followed the examples above
it will be the `scap-security-guide/build` folder.

The SCAP XML files will be called `ssg-${PRODUCT}-${TYPE}.xml`. For example
`ssg-rhel7-ds.xml` is the *Red Hat Enterprise Linux 7* **source datastream**.
We recommend using **source datastream** if you have a choice but the build
system also generates separate XCCDF, OVAL, OCIL and CPE files:

```bash
$ ls -1 ssg-rhel7-*.xml
ssg-rhel7-cpe-dictionary.xml
ssg-rhel7-cpe-oval.xml
ssg-rhel7-ds.xml
ssg-rhel7-ocil.xml
ssg-rhel7-oval.xml
ssg-rhel7-pcidss-xccdf-1.2.xml
ssg-rhel7-xccdf-1.2.xml
ssg-rhel7-xccdf.xml
```

These can be ingested by any SCAP-compatible scanning tool, to enable automated
checking.

The human readable HTML guide index files will be called
`ssg-${PRODUCT}-guide-index.html`. For example `ssg-rhel7-guide-index.html`.
This file will let the user browse all profiles available for that product.
The prose guide HTML contains practical, actionable information for auditors
and administrators.

Spreadsheet HTML tables - potentially useful as the basis for an
*SRTM document*:

```bash
$ ls -1 tables/table-rhel7-*.html
...
tables/table-rhel7-nistrefs-ospp-rhel7.html
tables/table-rhel7-nistrefs-stig-rhel7-disa.html
tables/table-rhel7-pcidssrefs.html
tables/table-rhel7-srgmap-flat.html
tables/table-rhel7-srgmap.html
tables/table-rhel7-stig.html
...
```

### Testing

To ensure validity of built artifacts prior to installation, we recommend
running our test suite against the build output. This is done with CTest:

```bash
cd content/
cd build/
cmake ../
make -j4
ctest -j4
```

Note: CTest does not run [SSG Test Suite](tests/README.md) which provides simple system of test scenarios for testing profiles and rule remediations.

### Installation

System-wide installation:

```bash
cd content/
cd build/
cmake ../
make -j4
sudo make install
```

(optional) Custom install location:

```bash
cd content/
cd build/
cmake ../
make -j4
sudo make DESTDIR=/opt/absolute/path/to/ssg/ install
```

(optional) System-wide installation using ninja:

```bash
cd content/
cd build/
cmake -G Ninja ../
ninja-build
ninja-build install
```

### (optional) Building a tarball

To build a tarball with all the source code:

```bash
cd build/
make package_source
```

### (optional) Building a package

To build a package for testing purposes:

```bash
cd build/
# disable any product you would not like to bundle in the package. For example:
cmake -DSSG_PRODUCT_JBOSS_EAP5:BOOL=OFF../
# build the package.
make package
```

Currently, RPM and DEB packages are supported by this mechanism. We recommend
only using it for testing. Please follow downstream workflows for production
packages.

### (optional) Building a ZIP file

To build a zip file with all generated source data streams and kickstarts:

```bash
cd build/
make zipfile
```

## Using containers

### Build the docker container image

Use a suitable Dockerfile present in the [Dockerfiles](Dockerfiles)
directory and build the image.
This will take care of the build environment and all necessary setup.

```bash
docker build --no-cache --file Dockerfile --tag oscap:$(date -u +%Y%m%d%H%M) --tag oscap:latest .
```

### Build SSG using the container image

To build all the content, run a container without any flags.

```bash
docker run --cap-drop=all --name scap-security-guide oscap:latest
```

Using `docker cp` to copy all the generated content to the your host:

```bash
docker cp scap-security-guide:/home/oscap/scap-security-guide/build $(pwd)/container_build
```
