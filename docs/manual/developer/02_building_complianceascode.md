# Building ComplianceAsCode

## Installing build dependencies

On *Red Hat Enterprise Linux 7* make sure the packages `cmake`, `openscap-utils`,
`PyYAML`, `python-jinja2` and their dependencies are installed:

```bash
yum install cmake make openscap-utils PyYAML python-jinja2
```

On *Red Hat Enterprise Linux 8* and *Fedora* the package list is the same but python2 packages need to be replaced with python3 ones:

```bash
yum install cmake make openscap-utils python3-pyyaml python3-jinja2
```

On *Ubuntu* and *Debian*, make sure the packages `libopenscap8`,
`libxml2-utils`, `python3-jinja2`, `python3-yaml`, `xsltproc` and their dependencies are
installed:

```bash
apt-get install cmake make expat libopenscap8 libxml2-utils ninja-build python3-jinja2 python3-yaml xsltproc
```

IMPORTANT: Version `1.0.8` or later of `openscap-utils` is required to build the content.

(optional) Install git if you want to clone the GitHub repository to get the
source code:

```bash
# Fedora/RHEL
yum install git

# Ubuntu/Debian
apt-get install git
```

(optional) Install the `ShellCheck` package to perform fix script static analysis:

```bash
# Fedora/RHEL
yum install ShellCheck

# Ubuntu/Debian
apt-get install shellcheck
```

(optional) Install `yamllint` and `ansible-lint` packages to perform Ansible
playbooks checks. These checks are not enabled by default in CTest, to enable
them add `-DANSIBLE_CHECKS=ON` option to `cmake`.
```bash
# Fedora/RHEL
yum install yamllint ansible-lint

# Ubuntu/Debian (to install ansible-lint on Debian you will probably need to
# enable Debian Backports repository)
apt-get install yamllint ansible-lint
```

(optional) Install the `ninja` build system if you want to use it instead of
`make` for faster builds:

```bash
# Fedora/RHEL
yum install ninja-build

# Ubuntu/Debian
apt-get install ninja-build
```

(optional) Install the `json2html` package if you want to generate HTML report statistics:

```bash
pip install json2html
```

(optional) Install Sphinx packages if you want to generate HTML Documentation, from source directory run:

```bash
pip install -r docs/requirements.txt
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

To build all the security content:

```bash
cd build/
cmake ../
# To build all security content
make -j4
# To build security content for one specific product, for example for *Red Hat Enterprise Linux 7*
make -j4 rhel7
```

Or use the `build_product` script from base directory that removes whatever is in the `build` directory and builds specific product:

```bash
./build_product rhel7
```

(optional) To build only specific content for one specific product:

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

(optional) Configure options before building using a GUI tool:

```bash
cd build/
cmake-gui ../
make -j4
```

(optional) Use the `ninja` build system (requires the `ninja-build` package):

```bash
cd build/
cmake -G Ninja ../
ninja-build  # depending on the distribution just "ninja" may also work
```

(optional) Generate statistics for products and profiles. Some of the statistics generated are: implemented OVAL, bash, ansible for rules, missing CCE, etc:

```bash
cd build/
cmake ../
make -j4 stats # display statistics in text format for all products
make -j4 profile-stats # display statistics in text format for all profiles in all products
```

You can also create statistics per product, to do that just prepend the product name (e.g.: `rhel7-stats`) to the make target.

It is possible to generate HTML output by triggering similar command:

```bash
cd build/
cmake ../
make -j4 html-stats # generate statistics for all products, as a result <product>/product-statistics/statistics.html file is created.
make -j4 html-profile-stats # generate statistics for all profiles in all products, as a result <product>/profile-statistics/statistics.html file is created
```

If you want to go deeper into statistics, refer to [Profile Statistics and Utilities](manual/developer/05_tools_and_utilities:Profile%20Statistics%20and%20Utilities) section.


(optional) Generate HTML documentation of the project which includes developer documentation, supported Jinja Macros documentation and python modules documentation:

```bash
cd build/
cmake ../
make -j4 docs # check docs/index.html file
```

### Building compliant SCAP 1.2 content

By default, the build system builds SCAP content with OVAL 5.11. This means that the SCAP 1.3 datastream conforms to SCAP standard version 1.3. But the SCAP 1.2 datastream is not fully conformant with SCAP standard version 1.2, as up to OVAL 5.10 version is allowed.
As SCAP 1.3 allows up to OVAL 5.11 and SCAP 1.2 allows up to OVAL 5.10.

To build fully compliant SCAP 1.2 content:

If you use `build_product` script, pass `--oval510` option:

```bash
./build_product --oval510 <product-name>
```

If you use `cmake` command, pass `-DSSG_TARGET_OVAL_MINOR_VERSION:STRING=10`:

```bash
cd build/
cmake -DSSG_TARGET_OVAL_MINOR_VERSION:STRING=10 ../
make
```

And use the datastream with suffix `-1.2.xml`.

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
ssg-rhel7-pcidss-xccdf-1.2.xml
ssg-rhel7-xccdf-1.2.xml
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

### Building a ZIP file

To build a zip file with all generated source data streams and kickstarts:

```bash
cd build/
make zipfile
```

There is also target to build zip file containing contents specific for a vendor's product.

```bash
cd build/
# To build content zipfiles of all vendors:
make vendor-zipfile
# To build Red Hat zipfiles:
make redhat-zipfile
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
