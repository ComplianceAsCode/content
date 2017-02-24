# Building SCAP Security Guide

## From source

1. On Red Hat Enterprise Linux and Fedora make sure the packages `cmake`, `openscap-utils`, `openscap-python`, and `python-lxml` and their dependencies are installed. We require version `1.0.8` or later of `openscap-utils` (available in Red Hat Enterprise Linux) as well as `git`.

 `# yum -y install cmake openscap-utils openscap-python python-lxml git`

 On Ubuntu make sure the packages `expat`, `libopenscap8`, `libxml2-utils`, `python-lxml`, `python-openscap`, and `xsltproc` and their dependencies are installed as well as `git`.

 `$ sudo apt -y install cmake expat libopenscap8 libxml2-utils python-lxml python-openscap xsltproc git`

 Optional: Install the ShellCheck package.

 `# dnf -y install ShellCheck`

 Optional: If you want to use the Ninja build system install the ninja-build package

 `# dnf -y install ninja-build`

2. Download the source code

 `$ git clone https://github.com/OpenSCAP/scap-security-guide.git`

3. Build the source code
  * To build all the content:

    `$ cd scap-security-guide/`
    `$ cd build/`
    `$ cmake ../`
    `$ make -j4`

  * To build everything only for one specific product:

    `$ cd scap-security-guide/`
    `$ cd build/`
    `$ cmake ../`
    `$ make -j4 rhel6`

  * Other targets only for one specific product:

    `$ cd scap-security-guide/`
    `$ cd build/`
    `$ cmake ../`
    `$ make -j4 rhel6-content  # SCAP XML files for RHEL6`
    `$ make -j4 rhel6-guides  # HTML guides for RHEL6`
    `$ make -j4 rhel6-tables  # HTML tables for RHEL6`
    `$ make -j4 rhel6  # everything above for RHEL6`

  * Configure options before building

    `$ cd scap-security-guide/`
    `$ cd build/`
    `$ cmake-gui ../`
    `$ make -j4`

  * Using the ninja-build system (requires ninja-build on the system)
    `$ cd scap-security-guide/`
    `$ cd build/`
    `$ cmake -G Ninja ../`
    `$ ninja-build`

  When the build has completed, the output will be in the build folder.
  That can be any folder you choose but if you followed the examples above
  it will be the `scap-security-guide/build` folder.

  The SCAP XML files will be called `ssg-${PRODUCT}-${TYPE}.xml`. For example
  `ssg-rhel7-ds.xml` is the Red Hat Enterprise Linux 7 source datastream.

  The human readable HTML guide index files will be called
  `ssg-${PRODUCT}-guide-index.html`. For example `ssg-rhel7-guide-index.html`.

4. Discover the following:
 * A pretty prose guide **in rhel6-guide.html** containing practical, actionable information for administrators
 * A concise spreadsheet representation (potentially useful as the basis for an SRTM document) in **rhel6-table-nistrefs-server.html**
 * Files that can be ingested by SCAP-compatible scanning tools, to enable automated checking:
    * **ssg-rhel6-xccdf.xml**
    * **ssg-rhel6-oval.xml**
    * **ssg-rhel6-ds.xml**

5. Install
  * Custom location
    `$ cd scap-security-guide/`
    `$ cd build/`
    `$ cmake ../`
    `$ make -j4`
    `$ make DESTDIR=/opt/absolute/path/to/ssg/ install`

  * System-wide installation
    `$ cd scap-security-guide/`
    `$ cd build/`
    `$ cmake ../`
    `$ make -j4`
    `$ make install`

  * System-wide installation using ninja
    `$ cd scap-security-guide/`
    `$ cd build/`
    `$ cmake -G Ninja ../`
    `$ ninja-build`
    `$ ninja-build install`

## Using Docker

Use the [Dockerfile](Dockerfile) present in the top directory and build the image.

`$ docker build --no-cache --file Dockerfile --tag oscap:$(date -u +%Y%m%d%H%M) --tag oscap:latest .`

To build all the content, run a container without any flags.

`$ docker run --cap-drop=all --name scap-security-guide oscap:latest`

To build content only for a specific distribution, add the relevant name as a flag:

`$ docker run --cap-drop=all --name scap-security-guide oscap:latest firefox`

Using `docker cp` to copy all the generated content to the your host:

`$ docker cp scap-security-guide:/home/oscap/scap-security-guide/build $(pwd)`
