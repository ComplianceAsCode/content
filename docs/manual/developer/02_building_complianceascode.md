# Building ComplianceAsCode

## Fast Track
Ok, if you are eager to start contributing, seeing the things happening faster and are passionate about automation, this is what you need for now. Every technical procedure described in the next sessions of this guide is covered by the [ansible-role-openscap](https://galaxy.ansible.com/marcusburghardt/ansible_role_openscap) role.

Do you prefer to see it working before starting to use it? Please, take a look in this demo:
[![ansible-role-openscap demo](https://img.youtube.com/vi/YI5lo1P0gw0/3.jpg)](http://www.youtube.com/watch?v=YI5lo1P0gw0 "watch an ansible-role-openscap demo")

### ansible-role-openscap
Everything you need as requirement is a *Fedora* system with the `ansible` and `python3` packages installed:
```bash
dnf install -y ansible python3
```
Then you can download the ansible role:
```bash
ansible-galaxy install marcusburghardt.ansible_role_openscap
```
Now it is time to run it. To help with this, the function also comes with a pre-configured Ansible environment for this. It is recommended to use this environment in order to ensure that it is only applicable to this context, not impacting any other possible Ansible settings you may have on your computer:
```bash
cp -r ~/.ansible/roles/marcusburghardt.ansible_role_openscap/files/Ansible_Samples/ ~/Ansible
cd ~/Ansible/
ansible-playbook -K ansible_openscap.yml
```
Just watch the ansible do the hard work. In the end, you will have a "ready to go" development environment to start [contributing](https://github.com/ComplianceAsCode/content/blob/master/CONTRIBUTING.md). If this is your first contact with the project, there is also a "STARTGUIDE" to guide you through the newly prepared development environment:
```bash
less ~/OpenSCAP/STARTGUIDE.md
```


## Installing build dependencies

### Required Dependencies
On *Red Hat Enterprise Linux 7* make sure the packages `cmake`, `openscap-utils`,
`PyYAML`, `python-jinja2`, `python-setuptools` and their dependencies are installed:

```bash
yum install cmake make openscap-utils openscap-scanner PyYAML python-jinja2
```

On *Red Hat Enterprise Linux 8* and *Fedora* the package list is the same but python2 packages need to be replaced with python3 ones:

```bash
yum install cmake make openscap-utils openscap-scanner python3-pyyaml python3-jinja2 python3-setuptools
```

On *Ubuntu* and *Debian*, make sure the packages `libopenscap8`,
`libxml2-utils`, `python3-jinja2`, `python3-yaml`, `python3-setuptools`, `xsltproc` and their dependencies are
installed:

```bash
apt-get install cmake make expat libopenscap8 libxml2-utils ninja-build python3-jinja2 python3-yaml python3-setuptools xsltproc
```

IMPORTANT: Version `1.0.8` or later of `openscap-utils` is required to build the content.

### Git (Clone the Repository)

Install git if you want to clone the GitHub repository to get the
source code:

```bash
# Fedora/RHEL
yum install git

# Ubuntu/Debian
apt-get install git
```

### Shellcheck (Script Static Analysis)

Install the `ShellCheck` package to perform fix script static analysis:

```bash
# Fedora/RHEL
yum install ShellCheck

# Ubuntu/Debian
apt-get install shellcheck
```

### Bats (Bash Unit Tests)

Install the `bats` package to perform bash unit tests:

```bash
# Fedora/RHEL
yum install bats

# Ubuntu/Debian
apt-get install bats
```

### xmldiff (Python unit tests)

Install the  `xmldiff` and `lxml` packages to execute Python unit tests that use these packages.

```bash
pip3 install xmldiff

# Fedora/RHEL
yum install python3-lxml

# Ubuntu/Debian
apt-get install python-lxml
```

### Ansible Static Analysis packages

Install `yamllint` and `ansible-lint` packages to perform Ansible
playbooks checks. These checks are not enabled by default in CTest, to enable
them add `-DANSIBLE_CHECKS=ON` option to `cmake`.
```bash
# Fedora/RHEL
yum install yamllint ansible-lint

# Ubuntu/Debian (to install ansible-lint on Debian you will probably need to
# enable Debian Backports repository)
apt-get install yamllint ansible-lint
```

### Static Ansible Playbooks tests

Install `yamlpath` and `pytest` to run tests cases that analyse the Ansible
Playbooks' yaml nodes.
```bash
pip3 install yamlpath

# Fedora/RHEL
yum install python3-pytest

# Ubuntu/Debian
apt-get install python-pytest
```

### Ninja (Faster Builds)

Install the `ninja` build system if you want to use it instead of
`make` for faster builds:

```bash
# Fedora/RHEL
yum install ninja-build

# Ubuntu/Debian
apt-get install ninja-build
```

### json2html (HTML Report Statistics)

Install the `json2html` package if you want to generate HTML report statistics:

```bash
pip install json2html
```

### Sphinx packages (Developer Documentation)

Install Sphinx packages if you want to generate HTML Documentation, from source directory run:

```bash
# Fedora/RHEL
yum install python3-sphinx

# Ubuntu/Debian
apt-get install python3-sphinx
```

```bash
pip install -r docs/requirements.txt
```

### Pandas (SRG Export HTML)

Install `pandas` if you want to run `utils/create_srg_export.py`:

```bash
# Fedora/RHEL
yum install python3-pandas

# Ubuntu/Debian
apt-get install python3-pandas
```

### OpenpyXL (SRG Export XLSX)

```bash
# Fedora/RHEL
yum install python3-openpyxl

# Ubuntu/Debian
apt-get install python3-openpyxl
```

### pygithub (Ansible Playbooks to Ansible roles)

```bash
# Fedora/RHEL
yum install python3-pygithub

# Ubuntu/Debian
apt-get install python3-pygithub
```

### mypy (Static Typing)

```bash
# Fedora/RHEL
yum install python3-mypy

# Ubuntu/Debian
apt-get install python3-mypy
```

#### Type stubs

```bash
pip install types-openpyxl types-PyYAML
```
## Downloading the source code

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

## Building

### Building Everything

To build all the security content:

```bash
cd build/
cmake ../
# To build all security content
make -j4
# To build security content for one specific product, for example for *Red Hat Enterprise Linux 7*
make -j4 rhel7
```

Or use the `build_product` script from the base directory that removes
whatever is in the `build` directory and builds a specific product:

```bash
./build_product rhel7
```

For more information about available options, call `./build_product --help`.

### Building Specific Content

To build specific content for a specific product:

```bash
cd build/
cmake ../
make -j4 rhel7-content  # SCAP XML files for RHEL7
make -j4 rhel7-guides  # HTML guides for RHEL7
make -j4 rhel7-tables  # HTML tables for RHEL7
make -j4 rhel7-profile-bash-scripts  # remediation Bash scripts for all RHEL7 profiles
make -j4 rhel7-profile-playbooks # Ansible Playbooks for all RHEL7 profiles
make -j4 rhel7  # everything above for RHEL7
```

### Configuring CMake options using GUI

Configure options before building using a GUI tool:

```bash
cd build/
cmake-gui ../
make -j4
```

### Reproducible Builds

Set the environment variable `SOURCE_DATE_EPOCH` to generate [reproducible builds](https://reproducible-builds.org/).
For details about the values and meaning of this variable please check this [source](https://reproducible-builds.org/specs/source-date-epoch/):

```bash
cd build/
SOURCE_DATE_EPOCH=1614699939 make
```

### Using Ninja for Faster Builds

Use the `ninja` build system (requires the `ninja-build` package):

```bash
cd build/
cmake -G Ninja ../
ninja-build  # depending on the distribution just "ninja" may also work
```

### Generating Statistics for Products and Profiles

#### Text Output

Generate statistics for products and profiles. Some of the statistics generated are: implemented OVAL, bash, Ansible for rules, missing CCE, etc:

```bash
cd build/
cmake ../
make -j4 stats # display statistics in text format for all products
make -j4 profile-stats # display statistics in text format for all profiles in all products
```

You can also create statistics per product. Prepend the product name (e.g.: `rhel7-stats`) to the make target.

#### HTML Output

To generate an HTML output, run a similar command:

```bash
cd build/
cmake ../
make -j4 html-stats # generate statistics for all products, as a result <product>/product-statistics/statistics.html file is created.
make -j4 html-profile-stats # generate statistics for all profiles in all products, as a result <product>/profile-statistics/statistics.html file is created
```

If you want to go deeper into statistics, refer to [Profile Statistics and Utilities](manual/developer/05_tools_and_utilities.md#profile-statistics-and-utilities) section.


### Generating Sphinx Documentation
Generate HTML documentation of the project that includes developer documentation,
supported Jinja Macros documentation, python modules documentation, SSG Test Suite
documentation and release tools documentation:

```bash
cd build/
cmake ../
make -j4 docs # check docs/index.html file
```

### Building compliant SCAP 1.2 content

The build system builds SCAP content with OVAL 5.11.
This means that the SCAP 1.3 datastream conforms to SCAP standard version 1.3.
But the SCAP 1.2 datastream is not fully conformant with SCAP standard version 1.2, as up to OVAL 5.10 version is allowed.
As SCAP 1.3 allows up to OVAL 5.11 and SCAP 1.2 allows up to OVAL 5.10.
This project no longer builds content that is fully SCAP 1.2 compliant as we no longer support OVAL 5.10.
The last release supporting SCAP 1.2 content was [v0.1.64](https://github.com/ComplianceAsCode/content/releases/tag/v0.1.64).

### Building SCE (non-compliant) content

By default, the build system will try to build XCCDF/OVAL standards-compliant
content. To enable SCE content, specify the `-DSSG_SCE_ENABLED=ON` option to
CMake:

```bash
cd build
cmake -DSSG_SCE_ENABLED=ON ..
make
```

This will add SCE content into the data stream files as well as create the
`<product>/checks/sce` folder with individual SCE checks in it.

### Build outputs

When the build has completed, the output will be in the build folder.
That can be any folder you choose but if you followed the examples above
it will be the `content/build` folder.

### SCAP XML files

The SCAP XML files will be called `ssg-${PRODUCT}-${TYPE}.xml`. For example
`ssg-rhel7-ds.xml` is the SCAP 1.3 *Red Hat Enterprise Linux 7* **source datastream**,
and `ssg-rhel7-ds-1.2.xml` is the SCAP 1.2 **source datastream**.

We recommend using **source datastream** if you have a choice.
The build system also generates separate XCCDF, OVAL, OCIL and CPE files:

```bash
$ ls -1 ssg-rhel7-*.xml
ssg-rhel7-cpe-dictionary.xml
ssg-rhel7-cpe-oval.xml
ssg-rhel7-ds.xml
ssg-rhel7-ds-1.2.xml
ssg-rhel7-ocil.xml
ssg-rhel7-oval.xml
ssg-rhel7-xccdf.xml
```

These can be ingested by any SCAP-compatible scanning tool, to enable automated
checking.

### HTML Guides

The human readable HTML guide index files will be called
`ssg-${PRODUCT}-guide-index.html`. For example `ssg-rhel7-guide-index.html`.
This file will let the user browse all profiles available for that product.
The prose guide HTML contains practical, actionable information for auditors
and administrators. They are placed in the guides folder.
```bash
$ ls -1 guides/ssg-rhel7-*.html
guides/ssg-rhel7-guide-ospp42.html
guides/ssg-rhel7-guide-ospp.html
guides/ssg-rhel7-guide-pci-dss.html
...
```

### HTML Reference Tables
Spreadsheet HTML tables - potentially useful as the basis for a
*Security Requirements Traceability Matrix (SRTM) document*:

```bash
$ ls -1 tables/table-rhel7-*.html
...
tables/table-rhel7-nistrefs-ospp.html
tables/table-rhel7-nistrefs-stig.html
tables/table-rhel7-pcidssrefs.html
tables/table-rhel7-srgmap-flat.html
tables/table-rhel7-srgmap.html
tables/table-rhel7-stig.html
...
```

### Ansible Playbooks

#### Profile Ansible Playbooks
These Playbooks contain the remediations for a profile.
```bash
$ ls -1 ansible/rhel7-playbook-*.yml
ansible/rhel7-playbook-C2S.yml
ansible/rhel7-playbook-ospp.yml
ansible/rhel7-playbook-pci-dss.yml
...
```

#### Rule Ansible Playbooks
These Playbooks contain just the remediation for a rule, in the context of a profile.
```bash
$ ls -1 ansible/rhel7-playbook-*.yml
$ ls -1 rhel7/playbooks/pci-dss/*.yml
rhel7/playbooks/pci-dss/account_disable_post_pw_expiration.yml
rhel7/playbooks/pci-dss/accounts_maximum_age_login_defs.yml
rhel7/playbooks/pci-dss/accounts_password_pam_dcredit.yml
rhel7/playbooks/pci-dss/accounts_password_pam_lcredit.yml
...
```

#### Rule SCE Checks

These scripts contain SCE content for the specified rule.

```bash
$ ls -1 ubuntu2004/checks/sce/
accounts_users_own_home_directories.sh
metadata.json
```

### Profile Bash Scripts
These Bash Scripts contains the remediations for a profile.
```bash
$ ls -1 bash/rhel7-script-*.sh
bash/rhel7-script-C2S.sh
...
bash/rhel7-script-ospp.sh
bash/rhel7-script-pci-dss.sh
...
```

## Testing

To ensure validity of built artifacts prior to installation, we recommend
running our test suite against the build output. This is done with CTest.
It is a good idea to execute quick tests first using the `-L quick` option passed to `ctest`.

```bash
cd content/
./build_product
cd build
ctest -L quick
ctest -LE quick -j4
```

Note: CTest does not run [SSG Test Suite](https://github.com/ComplianceAsCode/content/tree/master/tests) which provides simple system of test scenarios for testing profiles and rule remediations.

## Profiling the buildsystem

To make sure your changes don't prolong the time that it takes to build products by using the `build_product` script too much, you can use the `-p|--profiling` switch to get a report containing build times of all build targets/files.
You can compare build times between a baseline profiling log and your current log to see exactly which targets/files are taking longer to build, what percentage of the total build time they take up, and even see what targets you have added/removed and how did that affect the build time.
You also get an interactive HTML report that visualises how much time each target/file takes up.

For details about how this works, see `section 5 - tools and utilities - Profiling the buildsystem`.

## Installation

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

## Extra Building Options

### Building a tarball

To build a tarball with all the source code:

```bash
cd build/
make package_source
```

### Building a package

To build a package for testing purposes:

```bash
cd build/
# disable any product you would not like to bundle in the package. For example:
cmake -DSSG_PRODUCT_FEDORA:BOOL=OFF../
# build the package.
make package
```

Currently, RPM and DEB packages are supported by this mechanism. We recommend
only using it for testing. Please follow downstream workflows for production
packages.

#### Use of pip3 packages when building

There may be situations during the development and testing phases where it is
convenient to use Python modules installed via pip3, as in [this example](https://github.com/ComplianceAsCode/content/pull/7376/files),
where the `yamlpath` module is needed for some tests, but it is not available
in the official distro repositories and therefore needs to be installed via pip3.

However, for some time now, Python modules installed via pip3 have been located
in a different path, to reduce the risk of user installed modules conflicting
or even breaking official distro packages that depend on related Python modules.
More information and context can be found [here](https://fedoraproject.org/wiki/Changes/Making_sudo_pip_safe).

The consequence of this is that in some situations, such as during the build
time of an RPM package, modules installed via pip3 are not detected, because in
the context of rpmbuild there is no influence from external commands (pip3).

To work around this in test environments, an OS environment variable was created
to be evaluated by CMake for this purpose. If the OS environment variable
`SSG_USE_PIP_PACKAGES` is set and has a [positive value](https://cmake.org/cmake/help/latest/command/if.html#basic-expressions), CMake will ensure that
the [PYTHONPATH](https://docs.python.org/3/tutorial/modules.html#the-module-search-path) variable is set in the Python context with the proper location
of the python packages installed via pip3.

If `SSG_USE_PIP_PACKAGES` is not set or is set to a negative value (0, Off, No, False, N),
it will simply be ignored by CMake without any effect on the build process.

In the following example, Python modules installed via pip3 will be found
during the RPM build phase, in a test environment:

```bash
export SSG_USE_PIP_PACKAGES=1
rpmbuild -v -bc /root/rpmbuild/SPECS/scap-security-guide.spec
```

### Building a ZIP file

To build a zip file with all generated source data streams and kickstarts:

```bash
cd build/
make zipfile
```

### Build the Docker container image

Find a suitable Dockerfile present in the
[Dockerfiles](https://github.com/ComplianceAsCode/content/tree/master/Dockerfiles)
directory and build the image.
This will take care of the build environment and all necessary setup.

```bash
docker build --no-cache --file Dockerfiles/ubuntu --tag oscap:$(date -u +%Y%m%d%H%M) --tag oscap:latest .
```

### Build the content using the container image

To build all the content, run a container without any flags.

```bash
docker run --cap-drop=all --name oscap-content oscap:latest
```

Using `docker cp` to copy all the generated content to the your host:

```bash
docker cp oscap-content:/home/oscap/content/build $(pwd)/container_build
```
