# Creating Content

## Directory Structure

### Top Level Structure/Layout

Under the top level directory, there are directories and/or files for
different products, shared content, documentation, READMEs, Licenses,
build files/configuration, etc.

#### Important Top Level Directory Descriptions

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>Directory</p></td>
<td><p>Description</p></td>
</tr>
<tr class="even">
<td><p><code>linux_os</code></p></td>
<td><p>Contains security content for Linux operating systems. Contains rules, OVAL checks, Ansible tasks, Bash remediations, etc.</p></td>
</tr>
<tr class="odd">
<td><p><code>applications</code></p></td>
<td><p>Contains security content for applications such as OpenShift or OpenStack. Contains rules, OVAL checks, Ansible tasks, Bash remediations, etc.</p></td>
</tr>
<tr class="even">
<td><p><code>shared</code></p></td>
<td><p>Contains templates which can generate, Jinja macros, Bash remediation functions.</p></td>
</tr>
<tr class="odd">
<td><p><code>tests</code></p></td>
<td><p>Contains the test suite for content validation and testing, contains also unit tests.</p></td>
</tr>
<tr class="even">
<td><p><code>build</code></p></td>
<td><p>Can be used to build the content using CMake.</p></td>
</tr>
<tr class="odd">
<td><p><code>build-scripts</code></p></td>
<td><p>Scripts used by the build system.</p></td>
</tr>
<tr class="even">
<td><p><code>cmake</code></p></td>
<td><p>Contains the CMake build configuration files.</p></td>
</tr>
<tr class="odd">
<td><p><code>components</code></p></td>
<td><p>Contains the component files which provide mapping of operating system components to CaC rules.</p></td>
</tr>
<tr class="even">
<td><p><code>Dockerfiles</code></p></td>
<td><p>Contains Dockerfiles to build content test suite container backends.</p></td>
</tr>
<tr class="odd">
<td><p><code>docs</code></p></td>
<td><p>Contains the User Guide and Developer Guide, manual page template, etc.</p></td>
</tr>
<tr class="even">
<td><p><code>products</code></p></td>
<td><p>Contains per-product directories (such as <code>rhel8</code>) of product-specific information and profiles.</p></td>
</tr>
<tr class="odd">
<td><p><code>ssg</code></p></td>
<td><p>Contains Python <code>ssg</code> module which is used by most of the scripts in this repository.</p></td>
</tr>
<tr class="even">
<td><p><code>utils</code></p></td>
<td><p>Miscellaneous scripts used for development but not used by the build system.</p></td>
</tr>
<tr class="even">
<td><p><code>product_properties</code></p></td>
<td><p>Directory with its own README and with drop-in files that can define product properties across more products at once using jinja macros.</p></td>
</tr>
</tbody>
</table>

Note that product directories used to be top-level directories; these have now been reorganized under `products/`.

#### Important Top Level File Descriptions

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>File</p></td>
<td><p>Description</p></td>
</tr>
<tr class="even">
<td><p><code>CMakeLists.txt</code></p></td>
<td><p>Top-level CMake build configuration file</p></td>
</tr>
<tr class="odd">
<td><p><code>Contributors.md</code></p></td>
<td><p><strong>DO NOT MANUALLY EDIT</strong> script-generated file</p></td>
</tr>
<tr class="even">
<td><p><code>Contributors.xml</code></p></td>
<td><p><strong>DO NOT MANUALLY EDIT</strong> script-generated file</p></td>
</tr>
<tr class="odd">
<td><p><code>DISCLAIMER</code></p></td>
<td><p>Disclaimer for usage of content</p></td>
</tr>
<tr class="even">
<td><p><code>Dockerfile</code></p></td>
<td><p>CentOS7 Docker build file</p></td>
</tr>
<tr class="odd">
<td><p><code>LICENSE</code></p></td>
<td><p>Content license</p></td>
</tr>
<tr class="even">
<td><p><code>README.md</code></p></td>
<td><p>Project README file</p></td>
</tr>
</tbody>
</table>

### Benchmark Structure/Layout

Benchmarks are directories that contain `benchmark.yml` file. We have
multiple benchmarks in our project:

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>Name</p></td>
<td><p>Location</p></td>
</tr>
<tr class="even">
<td><p>Linux OS</p></td>
<td><p><code>/linux_os/guide</code></p></td>
</tr>
<tr class="odd">
<td><p>Applications</p></td>
<td><p><code>/applications</code> (Notice no <code>guide</code> subdirectory there!)</p></td>
</tr>
<tr class="even">
<td><p>Firefox</p></td>
<td><p><code>/products/firefox/guide</code></p></td>
</tr>
<tr class="odd">
<td><p>Chromium</p></td>
<td><p><code>/products/chromium/guide</code></p></td>
</tr>
</tbody>
</table>

The **Linux OS** benchmark describes Linux Operating System in general.
This benchmark is used by multiple ComplianceAsCode products, eg.
`rhel7`, `fedora`, `ubuntu1604`, `sle15` etc. The benchmark is located
in `/linux_os/guide`.

The products specify which benchmark they use as a source of content in
their `product.yml` file using `benchmark_root` key. For example,
`rhel7` product specifies that it uses the Linux OS benchmark.

    $ cat products/rhel7/product.yml
    product: rhel7
    full_name: Red Hat Enterprise Linux 7
    type: platform

    benchmark_root: "../linux_os/guide"

    .....

Rules from multiple locations can be used for a single Benchmark. There
is an optional key `additional_content_directories` for a list of paths
to some arbitrary Groups of Rules to be included in the benchmark. Note
that the additional directories cannot contain a benchmark file
(`benchmark.yml`), otherwise it fails to build the content. Of all the
rules collected only the following would become a part of the benchmark:

-   rules that have the `prodtype` specified in correspondence with the
    benchmark;

-   rules that have no `prodtype` metadata.

<!-- -->

    .....

    benchmark_root: "../applications"
    additional_content_directories:
        - "../linux_os/guide/services"
        - "../linux_os/guide/system"

    .....

The Benchmarks are organized into directory structure. The directories
represent either groups or rules. The group directories contain
`group.yml` and rule directories `rule.yml`. The name of the group
directory is the group ID, without the prefix. Similarly, the name of
the rule directory if the rule ID, without the prefix.

For example, the Linux OS Benchmark is structured in this way:

    .
    ├── benchmark.yml
    ├── intro
    │   ├── general-principles
    │   ├── group.yml
    │   └── how-to-use
    ├── services
    │   ├── apt
    │   ├── avahi
    │   ├── cron_and_at
    │   ├── deprecated
    │   ├── dhcp
    │   ├── dns
    │   ├── ftp
    │   ├── group.yml
    │   ├── http
    │   ├── imap
    │   ├── ldap
    │   ├── mail
    │   ├── nfs_and_rpc
    │   .......
    │   .......
    └── system
        ├── accounts
        ├── auditing
        ├── bootloader-grub2
        ├── bootloader-grub-legacy
        ├── entropy
        ├── group.yml
        ├── logging
    ......

### Product Structure/Layout

When creating a new product, use the guidelines below for the directory
layout:

-   **Do not** use capital letters

-   If product versions are required, use major or LTS versions only. For
    example, `rhel7`, `ubuntu2004`, etc.

-   If the content does not depend on specific versions,
    **do not** add version numbers. For example: `fedora`, `firefox`, etc.

Following these guidelines help with the usability and browsability of
using and navigating the content.

For example:

    $ tree -d products/rhel7
    products/rhel7
    ├── kickstart
    ├── overlays
    ├── profiles
    └── transforms

    4 directories

#### Product Level Directory Descriptions

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><p>Directory</p></td>
<td><p>Description</p></td>
</tr>
<tr class="even">
<td><p><code>kickstart</code></p></td>
<td><p><code>Optional</code> Contains product kickstart or build files to be used in testing, development, or production (not recommended) of compliance content.</p></td>
</tr>
<tr class="odd">
<td><p><code>overlays</code></p></td>
<td><p><code>Required</code> Contains overlay files for specific standards organizations such as NIST, DISA STIG, PCI-DSS, etc.</p></td>
</tr>
<tr class="even">
<td><p><code>profiles</code></p></td>
<td><p><code>Required</code> Contains profiles that are created and tailored to meet government or commercial compliance standards.</p></td>
</tr>
<tr class="odd">
<td><p><code>transforms</code></p></td>
<td><p><code>Required</code> Contains XSLT files and scripts that are used to transform the content into the expected compliance document such as XCCDF, OVAL, data stream, etc.</p></td>
</tr>
</tbody>
</table>

> **Important**
>
> For any of the `Required` directories that may not yet add
> content, add a `.gitkeep` file for any empty directories.

#### Creating a new Product

Follow these steps to create a new product in the project:

1. Create a new folder in the `products/` directory which will hold the files related to your new product.
To illustrate the process we will use the name `custom6` which basically means that the product is called `custom` and the major version is `6`.
For more details in the naming conventions and directory structure, check the [](#directory-structure) section.
You can use the following commands to create the basic directory structure, `content` is the root directory of the project:
<pre>
cd content/products
export SHORTNAME="C"
export NAME="custom"
export CAMEL_CASE_NAME="Custom"
export VERSION="6"
export FULL_NAME="$CAMEL_CASE_NAME $VERSION"
export FULL_SHORT_NAME="$SHORTNAME$VERSION"
export NEW_PRODUCT=$NAME$VERSION
export CAPITAL_NAME="CUSTOM"
mkdir $NEW_PRODUCT \
        $NEW_PRODUCT/overlays \
        $NEW_PRODUCT/profiles \
        $NEW_PRODUCT/transforms
</pre>
2. Add the product to [CMakeLists.txt](https://github.com/ComplianceAsCode/content/blob/master/CMakeLists.txt) by adding the following lines:
<pre>
...
option(SSG_PRODUCT_DEBIAN11 "If enabled, the Debian 11 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
<b>option(SSG_PRODUCT_CUSTOM6 "If enabled, the Custom 6 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})</b>
option(SSG_PRODUCT_EAP6 "If enabled, the JBoss EAP6 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
...
</pre>
<pre>
...
message(STATUS "Debian 11: ${SSG_PRODUCT_DEBIAN11}")
<b>message(STATUS "Custom 6: ${SSG_PRODUCT_CUSTOM6}")</b>
message(STATUS "JBoss EAP 6: ${SSG_PRODUCT_EAP6}")
...
</pre>
<pre>
...
if(SSG_PRODUCT_DEBIAN11)
    add_subdirectory("products/debian11")
endif()
<b>if(SSG_PRODUCT_CUSTOM6)
      add_subdirectory("products/custom6")
endif()</b>
if(SSG_PRODUCT_EAP6)
    add_subdirectory("products/eap6")
endif()
...
</pre>

3. Add the product to [build_product](../../../build_product) script:
<pre>
...
all_cmake_products=(
	CHROMIUM
	DEBIAN11
 <b>CUSTOM6</b>
	EAP6
...
</pre>

4. Add the product to [ssg/constants.py](../../../ssg/constants.py) file:
<pre>
...
product_directories = ['debian11', 'fedora', 'ol7', 'ol8', 'opensuse',
                       'rhel7', 'rhel8', 'sle12',
                       'ubuntu1604', 'ubuntu1804', 'rhosp13',
                       'chromium', 'eap6', 'firefox',
                       'example'<b>, 'custom6'</b>]
...
</pre>
<pre>
...
FULL_NAME_TO_PRODUCT_MAPPING = {
    "Chromium": "chromium",
    "Debian 11": "debian11",
    "Custom 6": "custom6",
    "JBoss EAP 6": "eap6",
    "Example": "example",
    <b>"Custom 6": "custom6",</b>
    "Fedora": "fedora",
...
</pre>
<pre>
...
MULTI_PLATFORM_LIST = ["rhel", "fedora", "rhosp", "rhv", "debian", "ubuntu",
                       "opensuse", "sle", "ol", "ocp", "example"<b>, "custom"</b>]
...
</pre>
<pre>
...
MULTI_PLATFORM_MAPPING = {
    "multi_platform_debian": ["debian10", "debian11"],
    "multi_platform_example": ["example"],
    <b>"multi_platform_custom": ["custom6"],</b>
    "multi_platform_fedora": ["fedora"],
...
</pre>
<pre>
...
MAKEFILE_ID_TO_PRODUCT_MAP = {
    'chromium': 'Google Chromium Browser',
    'fedora': 'Fedora',
    'firefox': 'Mozilla Firefox',
    'rhosp': 'Red Hat OpenStack Platform',
    'rhel': 'Red Hat Enterprise Linux',
    'rhv': 'Red Hat Virtualization',
    'debian': 'Debian',
    <b>'custom': 'Custom',</b>
    'ubuntu': 'Ubuntu',
...
</pre>


5. Create a new file in the product directory called `CMakeLists.txt`:
```
cat << EOF >  $NEW_PRODUCT/CMakeLists.txt
# Sometimes our users will try to do: "cd $NEW_PRODUCT; cmake ." That needs to error in a nice way.
if("\${CMAKE_SOURCE_DIR}" STREQUAL "\${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the Building ComplianceAsCode section in the Developer Guide!")
endif()

ssg_build_product("$NEW_PRODUCT")
EOF
```

7. Create a new file in the product directory called `product.yml` (note: you may want to change the `pkg_manager` attribute):
```
cat << EOF >  $NEW_PRODUCT/product.yml
product: $NEW_PRODUCT
full_name: $FULL_NAME
type: platform

benchmark_root: "../../linux_os/guide"

components_root: "../../components"

profiles_root: "./profiles"

pkg_manager: "yum"

init_system: "systemd"

cpes_root: "../../shared/applicability"
cpes:
  new_product:
    name: "cpe:/o:$NAME:$VERSION"
    title: "$FULL_NAME"
    check_id: installed_OS_is_$NEW_PRODUCT

reference_uris:
  cis: 'https://benchmarks.cisecurity.org/tools2/linux/CIS_${CAMEL_CASE_NAME}_Benchmark_v1.0.pdf'
EOF
```

8. Create a draft profile under `profiles` directory called `standard.profile`:
```
cat << EOF >  $NEW_PRODUCT/profiles/standard.profile
documentation_complete: true

title: 'Standard System Security Profile for $FULL_NAME'

description: |-
    This profile contains rules to ensure standard security baseline
    of a $FULL_NAME system. Regardless of your system's workload
    all of these checks should pass.

selections:
    - accounts_password_minlen_login_defs
EOF
```

9. Create a new file under `transforms` directory called `constants.xslt` (you may want to review the links below):
```
cat << EOF >  $NEW_PRODUCT/transforms/constants.xslt
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="../../../shared/transforms/shared_constants.xslt"/>

<xsl:variable name="product_long_name">$FULL_NAME</xsl:variable>
<xsl:variable name="product_short_name">$FULL_SHORT_NAME</xsl:variable>
<xsl:variable name="product_stig_id_name">${CAPITAL_NAME}_STIG</xsl:variable>
<xsl:variable name="prod_type">$NEW_PRODUCT</xsl:variable>

<!-- Define URI of official Center for Internet Security Benchmark for $FULL_NAME -->
<xsl:variable name="cisuri">https://benchmarks.cisecurity.org/tools2/linux/CIS_${CAMEL_CASE_NAME}_Benchmark_v1.0.pdf</xsl:variable>

<!-- Define URI for custom policy reference which can be used for linking to corporate policy -->
<!--xsl:variable name="custom-ref-uri">https://www.example.org</xsl:variable-->

</xsl:stylesheet>
EOF
```

11. Create a new file under `transforms` directory called `table-style.xslt`:
```
cat << EOF >  $NEW_PRODUCT/transforms/table-style.xslt
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="../../../shared/transforms/shared_table-style.xslt"/>

</xsl:stylesheet>
EOF
```

12. Create a new file under `transforms` directory called `xccdf-apply-overlay-stig.xslt`:
```
cat << EOF >  $NEW_PRODUCT/transforms/xccdf-apply-overlay-stig.xslt
<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://checklists.nist.gov/xccdf/1.1" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<xsl:include href="../../../shared/transforms/shared_xccdf-apply-overlay-stig.xslt"/>
<xsl:include href="constants.xslt"/>
<xsl:variable name="overlays" select="document($overlay)/xccdf:overlays" />

</xsl:stylesheet>
EOF
```

13. Create a new file under `transforms` directory called `xccdf2table-cce.xslt`:
```
cat << EOF >  $NEW_PRODUCT/transforms/xccdf2table-cce.xslt
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cce="http://cce.mitre.org" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<xsl:import href="../../../shared/transforms/shared_xccdf2table-cce.xslt"/>

<xsl:include href="constants.xslt"/>
<xsl:include href="table-style.xslt"/>

</xsl:stylesheet>
EOF
```

14. Create a new file under `transforms` directory called `xccdf2table-profileccirefs.xslt`:
```
cat << EOF >  $NEW_PRODUCT/transforms/xccdf2table-profileccirefs.xslt
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:cci="https://public.cyber.mil/stigs/cci" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ovalns="http://oval.mitre.org/XMLSchema/oval-definitions-5">

<xsl:import href="../../../shared/transforms/shared_xccdf2table-profileccirefs.xslt"/>

<xsl:include href="constants.xslt"/>
<xsl:include href="table-style.xslt"/>

</xsl:stylesheet>
EOF
```

15. Create a new file under `shared/checks/oval` directory called `installed_OS_is_custom6.xml`:
```
cat << EOF >  shared/checks/oval/installed_OS_is_$NEW_PRODUCT.xml
<def-group>
  <definition class="inventory" id="installed_OS_is_$NEW_PRODUCT" version="3">
    <metadata>
      <title>$FULL_NAME</title>
      <affected family="unix">
        <platform>multi_platform_all</platform>
      </affected>
      <reference ref_id="cpe:/o:$NAME:$VERSION" source="CPE" />
      <description>The operating system installed on the system is $FULL_NAME</description>
    </metadata>
    <criteria comment="current OS is $VERSION" operator="AND">
      <extend_definition comment="Installed OS is part of the Unix family" definition_ref="installed_OS_is_part_of_Unix_family" />
      <criterion comment="$CAMEL_CASE_NAME is installed" test_ref="test_$NAME" />
      <criterion comment="$FULL_NAME is installed" test_ref="test_$NEW_PRODUCT" />
    </criteria>
  </definition>

  <unix:file_test check="all" check_existence="all_exist" comment="/etc/$NAME exists" id="test_$NAME" version="1">
    <unix:object object_ref="obj_$NAME" />
  </unix:file_test>
  <unix:file_object comment="check /etc/$NAME file" id="obj_$NAME" version="1">
    <unix:filepath>/etc/$NAME</unix:filepath>
  </unix:file_object>

  <ind:textfilecontent54_test check="all" check_existence="at_least_one_exists" comment="Check Custom OS version" id="test_$NEW_PRODUCT" version="1">
    <ind:object object_ref="obj_$NEW_PRODUCT" />
  </ind:textfilecontent54_test>
  <ind:textfilecontent54_object id="obj_$NEW_PRODUCT" version="1" comment="Check $CAMEL_CASE_NAME version">
    <ind:filepath>/etc/$NAME</ind:filepath>
    <ind:pattern operation="pattern match">^${VERSION}.[0-9]+$</ind:pattern>
    <ind:instance datatype="int">1</ind:instance>
  </ind:textfilecontent54_object>

</def-group>
EOF
```


## Profiles

Profiles define the set of rules and variables aligned to a compliance
standard.

Structurally, a profile is a YAML file that represents a dictionary. A
profile YAML file has one implied attribute:

-   `id`: The primary identifier for the profile, to be referenced
    during evaluations. This is inferred from the file name.

A profile YAML file can, optionally, include metadata about the
implemented policy and experts in the field, called Subject Matter
Experts (SMEs). The SMEs usually are people familiar with the policy
requirements or how it is applied.

-   `metadata`: Dictionary for profile metadata.

-   `reference`: URL pointing to page or organization that publishes the
    policy.

-   `version`: Version of the policy implemented by the profile.

-   `SMEs`: List of people experienced with the profile, or how they are
    applied. The preferred method is the GitHub handle, but email is
    also accepted.

A profile should define these attributes:

-   `title`: Human-readable title of the profile.
-   `description`: Human-readable HTML description, which provides
    broader context for non-experts than the rationale.
-   `extends`: The `id` of a profile to be extended. A profile can make
    incremental changes based on another profile, via `extends`
    attribute. The extendee can then, via the `selections` attribute,
    select/unselect rules and change XCCDF Value selectors.
-  `selections`: List composed of items of these types:
    -   IDs of rules to be included in the profile, e.g. `accounts_tmout `,
    or
    - IDs of rules to be excluded from the profile prefixed by an exclamation mark, e.g. `!accounts_tmout`,
    or
    -   changes to XCCDF Value selectors, e.g. `var_accounts_tmout=10_min`,
    or
    -   rule refinements, e.g. `accounts_tmout.severity=high`.


## Controls

The controls add another layer on top of profiles. Controls files store the
metadata for security controls and, more importantly, concentrate the mapping
from requirement to rule at a single place.

We will explain the format using the expected workflow and we will show examples
of the format.

### Storing controls data

When we develop a new SCAP profile, we usually base it off an external standard.
Standard documents define a policy that consists of controls (or requirements).
For example, the `rhel8/profiles/cis.profile` profile was based off of the CIS
Benchmark for RHEL 8, published as a PDF document by the CIS organization. This
document is organized by sections, with each "rule" being a specific piece of
guidance. For instance, CIS for RHEL 8 1.1.1.1 "Ensure mounting of cramfs
filesystems is disabled" would map to our `kernel_module_cramfs_disabled` rule.
Other benchmarks like NIST 800-53 controls, ANSSI requirements, and STIG have
different organization, specific to their benchmark document.

To add the policy to our project repository, we will create a YAML file that
represents this policy. There is a special directory, called `controls`, in the
repository root to store these files. These files serve as a database of
controls (requirements). They are independent from profiles and products. We can
extract the relevant data from the standard document and save them in a YAML
file. Presently, control files are created manually. In the future, automatic
conversions from XML or OpenControl formats into the YAML control file format
could be used.

For example, a YAML control file would look like this:

```
$ cat controls/abcd.yml

id: abcd
title: ABCD Benchmark for securing Linux systems
version: 1.2.3
source: https://www.abcd.com/linux.pdf
controls:
  - id: R1
    title: User session timeout
    description: |-
      Remote user sessions must be closed after a certain
      period of inactivity.
  - id: R2
    title: Minimization of configuration
    description: |-
      The features configured at the level of launched services
      should be limited to the strict minimum.
  - id: R3
    title: Enabling SELinux targeted Policy
    description: |-
      It is recommended to enable SELinux in enforcing mode
      and to use the targeted policy.
```

In the real world, controls (requirements) can be nested. For example, PCI-DSS
has a tree-like structure, within requirement 2.3, we can find 2.3.a, 2.3.b,
etc. Therefore, each item in `controls` list can contain a `controls` list.

Nesting can be accomplished both by

* nesting whole control definitions, or by
* nesting references to existing controls in the `policy:control` format, where the `policy:` part can be skipped
if the reference points to a control in that policy.

Nesting using references allows reuse of controls across multiple policies.

Once we have the initial file, we can read through the policy requirements and
assess each requirement. For each control, we will have to identify whether it
can be automated by SCAP. If so, we should look if we already have existing
XCCDF rules in our project.

In the example below we identified that:

* R1 can be automatically scanned by SCAP and we already have 3 existing rules
in our repository. However, we want one of them to be selected only on RHEL 9,
but the rule is applicable to all platforms.
* R2 is up to manual checking, but we have systemd_target_multi_user which is
related to this control.
* R3 can be automatically scanned by SCAP but unfortunately we don't have any
rules implemented yet.

For each control we will add the `status` key, which describes the current
implementation status of the control. For instance, if the control requirement
can be automated by SCAP and scanning, the status will be `automated`.
The `status` key is just for informational purposes and does not have any
impact on the processing.

The  `status` key deprecates the `automated` key -
`automated: yes` translates to `status: automated`, and so on.
The `status` key is preferred as it it is capable to reflect the control state more accurately.

When XCCDF rules exist, we will assign them to the controls. We will distinguish
between XCCDF rules which directly implement the given controls (represented by
`rules` YAML key) and rules that are only related or relevant to the control
(represented by `related_rules` YAML key).

The `rules` and `related_rules` keys consist of a list of rule IDs and variable
selections.

If a rule needs to be chosen only in some of products despite its `prodtype` we
can use Jinja macros inside the controls file to choose products.

After we finish our analysis, we will insert our findings to the controls file,
the file will look like this:

```
$ cat controls/abcd.yml

id: abcd
title: ABCD Benchmark for securing Linux systems
version: 1.2.3
source: https://www.abcd.com/linux.pdf
controls:
  - id: R1
    title: User session timeout
    description: |-
      Remote user sessions must be closed after a certain
      period of inactivity.
    status: automated
    rules:
    - sshd_set_idle_timeout
    - accounts_tmout
    - var_accounts_tmout=10_min
{{% if product == "rhel9" %}}
    - cockpit_session_timeout
{{% endif %}}
  - id: R2
    title: Minimization of configuration
    description: |-
      The features configured at the level of launched services
      should be limited to the strict minimum.
    status: supported
    notes: |-
      This is individual depending on the system workload
      therefore needs to be audited manually.
    related_rules:
       - systemd_target_multi_user
  - id: R3
    title: Enabling SELinux targeted Policy
    description: |-
      It is recommended to enable SELinux in enforcing mode
      and to use the targeted policy.
    status: automated
```

Notice that each section identifier is a reference in the standard's benchmark.
Each of the values under the `rules` key maps onto a rule identifier in the
project. In the future, we could automatically assign references to rules via
this control file.

To help control length of control files content authors can create a directory with same name as the control file (without `.yml`) and add YAML files to that folder.
Then in the folder the author can crate `.yml` files for the controls.
See the example below.

```
$ cat controls/abcd.yml

id: abcd
title: ABCD Benchmark for securing Linux systems
version: 1.2.3
source: https://www.abcd.com/linux.pdf
```

```
$ cat controls/abcd/R1.yml

controls:
  - id: R1
    title: User session timeout
    description: |-
      Remote user sessions must be closed after a certain
      period of inactivity.
    status: automated
    rules:
    - sshd_set_idle_timeout
    - accounts_tmout
    - var_accounts_tmout=10_min
{{% if product == "rhel9" %}}
    - cockpit_session_timeout
{{% endif %}}
```

```
$ cat controls/abcd/R2.yml

controls:
  - id: R2
    title: Minimization of configuration
    description: |-
      The features configured at the level of launched services
      should be limited to the strict minimum.
    status: supported
    notes: |-
      This is individual depending on the system workload
      therefore needs to be audited manually.
    related_rules:
       - systemd_target_multi_user
```


### Defining levels

Some real world policies, e.g.,  ANSSI, have a concept of levels.
Level can be defined as a group of controls which logically form a single unit.

Control files can work with the concept of levels.
You can define explicit inheritance between levels e.g., the "high" level inherits all controls from "low" level adding some more controls on the top of it.

For example, let's say that ABCD benchmark would define 2 levels: low and high.
The low level would contain R1 and R2. The high level would contain everything
from the low level and R3, ie. the high level would contain R1, R2 and R3.

First, add the `levels` key to the YAML file.
This key will contain list of dictionaries - one per level.
Each level must have its `id` defined.
You can specify that the level should inherit all controls of a different level.
It can be done by adding a key called `inherits_from` to the level definition.
This key contains a list of level IDs.
Then add `levels` key to every control ID to specify a list of levels the control belongs to.
Note that if a control does not have any level specified, it is assigned to the default level, which is the first in the list of levels.

If a level is selected, all controls which are assigned to this level (see example below) are included in the resulting profile.
If a level with `inherits_from` key specified is selected, all controls from inherited levels are included together with controls assigned to the inheriting level.

```
$ cat controls/abcd.yml

id: abcd
title: ABCD Benchmark for securing Linux systems
version: 1.2.3
source: https://www.abcd.com/linux.pdf
levels:
  - id: low
  - id: high
    inherits_from:
    - low
controls:
  - id: R1
    levels:
    - low
    title: User session timeout
    description: |-
      Remote user sessions must be closed after a certain
      period of inactivity.
  - id: R2
    levels:
    - low
    title: Minimization of configuration
    description: |-
      The features configured at the level of launched services
      should be limited to the strict minimum.
  - id: R3
    levels:
    - high
    title: Enabling SELinux targeted Policy
    description: |-
      It is recommended to enable SELinux in enforcing mode
      and to use the targeted policy.
```

### Reporting status

In some cases, it's useful to know the status of a certain control for a
specific product. In order to better portray this, it's possible to set
such information on each control using the `status` key.

The `status` key may hold the following values:

* `pending`: The control is not yet evaluated for the product.

* `not applicable`: The control is not applicable to this product.

* `inherently met`: The control is inherently met by the product.

* `documentation`: The control is addressed by product documentation.

* `planned`: The control is not yet implemented, but is planned.

* `partial`: While work has been done to address this control, there is still
             work needed to fully address it.

* `supported`: The control is addressed by the product (but is missing content
                automation).

* `automated`: The control is addressed by the product and can be automatically
               checked for.

* `manual`: The control cannot or should not be automated, and should be addressed manually.

* `does not meet`: The control is not met by the product

Note that if the `status` key is missing from a control definition, the default
status will be `pending`.

When there is work on-going to address a specific control, it may be portrayed
via the `tickets` key. The aforementioned key shall contain a list of URLs that
may help the reader track what work needs to be done to address a specific
control.

```
$ cat controls/abcd.yml

id: abcd
title: ABCD Benchmark for securing Linux systems
version: 1.2.3
source: https://www.abcd.com/linux.pdf
levels:
  - id: low
  - id: high
    inherits_from:
    - low
controls:
  - id: R1
    levels:
    - low
    title: User session timeout
    description: |-
      Remote user sessions must be closed after a certain
      period of inactivity.
    status: partial
    tickets:
    - https://my-ticket-tracker.com/issue/1
    - https://my-ticket-tracker.com/issue/2
```


### Controls file format

This is a complete schema of the YAML file format.

```
id: policy ID (required key)
title: short title (required key)
original_title: used as a reference for policies not yet available in English
source: a link to the original policy, eg. a URL of a PDF document
controls_dir: a directory containing files representing controls that will be imported into this policy
levels: a list of levels, the first one is default
  - id: level ID (required key)
    inherits_from: a list of IDs of levels inheriting from

controls: a list of controls (required key)
  - id: control ID (required key)
    title: control title
    description: description of the control in a few sentences
    levels: The list of policy levels that the control belongs to
    notes: a short paragraph of text
    rules: a list of rule IDs that cover this control
    related_rules: a list of related rules only for reference
    controls: a (nested) list of either control definitions, or of control references in the policy:id format
    status: a keyword that reflects the current status of the implementation of this control
    tickets: a list of URLs reflecting the work that still needs to be done to address this control
```

Full example of a controls file:

```
id: abcd
title: ABCD Benchmark for securing Linux systems
source: https://www.abcd.com/linux.pdf
levels:
  - id: low
  - id: high
    inherits_from:
    - low
controls:
  - id: R1
    levels:
    - low
    title: User session timeout
    description: >-
      Remote user sessions must be closed after a certain
      period of inactivity.
    status: automated
    rules:
    - sshd_set_idle_timeout
    - accounts_tmout
    - var_accounts_tmout=10_min
    - configure_crypto_policy
    notes: >-
      Certain period of inactivity is vague.
  - id: R2
    title: Minimization of configuration
    description: >-
      The features configured at the level of launched services
      should be limited to the strict minimum.
    rationale: >-
        Minimization of configuration helps to reduce attack surface.
    status: supported
    notes: >-
      This is individual depending on the system workload
      therefore needs to be audited manually.
    related_rules:
       - systemd_target_multi_user
  - id: R3
    title: Enabling SELinux targeted Policy
    description: >-
      It is recommended to enable SELinux in enforcing mode
      and to use the targeted policy.
    status: automated
    rules:
      - selinux_state
  - id: R4
    title: Configure authentication
    description: >-
      Ensure authentication methods are functional to prevent
      unauthorized access to the system.
    controls:
      - id: R4.a
        title: Disable administrator accounts
        status: automated
        levels:
        - low
        rules:
          -  accounts_passwords_pam_faillock_deny_root
      - id: R4.b
        title: Enforce password quality standards
        status: automated
        levels:
        - high
        rules:
          - accounts_password_pam_minlen
          - accounts_password_pam_ocredit
          - var_password_pam_ocredit=1
      - other-policy:other-control
```

### Using controls in profiles

Later, we can use the policy requirements in profile YAML. Let's say that we
will define a “Desktop” profile built from the controls.

To use controls, we add them under `selection` keys in the profile. The entry
has the form `policy_id:control_id[:level_id]`, where `level_id` is optional.

```
$ cat rhel8/profiles/abcd-desktop.profile

documentation_complete: true
title: ABCD Desktop for Red Hat Enterprise Linux 8
description: |-
  This profile contains configuration checks that align to
  the ABCD benchmark.
selections:
  - abcd:R1
  - abcd:R2
  - abcd:R3
  - security_patches_uptodate
```

Notice we can mix the controls selections with normal rule selections.

In a similar way, we could define another profile that selects only some of the
requirements.

In the example we have selected all controls from `controls/abcd.yml` by listing
them explicitly. It is possible to shorten it using the `“all”` value which
means that all controls will be selected. Let's show how it will be easier:

```
$ cat rhel8/profiles/abcd-high.profile

documentation_complete: true
title: ABCD High for Red Hat Enterprise Linux 8
description: |-
  This profile contains configuration checks that align to
  the ABCD benchmark.
selections:
  - abcd:all
  - security_patches_uptodate
```

It is possible to use levels if the levels are defined in the controls file. For
example, `abcd:all:low` selects all rules for the ABCD low level or
`abcd:all:high` selects all rules from the ABCD high level.

Finally, when we build the content, we will automatically get a SCAP profile
which contains XCCDF rules and variables from all controls selected in profile
YAML.

The build system adds all XCCDF rules listed under `rules` key in the control to
the built profile. The rules listed under `related_rules` key are not added.
Therefore, the `related_rules` don't affect the generated source data stream.
Also, the selections from `selection` key in profile file are included.

In our example, the generated profile will contain rules
`sshd_set_idle_timeout`, `accounts_tmout`, `var_accounts_tmout=10_min` and
`security_patches_uptodate`. The profile will not contain
`systemd_target_multi_user` even if control `R2` is selected because that is
listed under `related_rules`.

The profile will be compiled to a canonical form during the build. The compiled
profiles are located in the `/build/${PRODUCT_ID}/profiles/` directory.

Example of a compiled profile:

```
$ cat build/rhel8/profiles/abcd-desktop.profile

documentation_complete: true
title: ABCD Desktop for Red Hat Enterprise Linux 8
description: |-
  This profile contains configuration checks that align to
  the ABCD benchmark.
selections:
  - sshd_set_idle_timeout
  - accounts_tmout
  - var_accounts_tmout=10_min
  - security_patches_uptodate
```

This profile is similar in content to one we could've created manually, but
instead is automatically generated during build from a semantic data source. It
seamlessly integrates with the build system to include the generated profile in
the resulting SCAP source data stream.

### Controls File Life Cycle

This flowchart represents a high level overview of the control file life cycle based on security policies.

Initial Control File creation using as source a security policy:

<div class="mermaid" style="width=100%;">
flowchart TD
    A[Security Policy V1] -->|Convert | B(Control File V1)
    B[Control File V1] --> |Map Rules | C(Existing Rules)
    B[Control File V1] --> |Create New Rules | D(Rules)
    C(Existing Rules) --> |Assign References | D(Rules)
    D(Rules) --> |Select | F(Populated Control File V1)
</div>

<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>

Control File Update with newer version of the security policy

<div class="mermaid" style="width=100%;">
flowchart TD
    control_file_v1(Control File V1) -->|Combine | A
    control_file_v1(Control File V1) -->|Compare | C
    A[Security Policy V2] -->|Generate | B(Control File V2)
    B[Control File V2] --> |Compare | C(Differences of V1 and V2)
    C[Difference of V1 and V2]-->| Process | D(Update/creation of rules and selections update)
    D(Update/creation of rules and selections update) --> |Finish | E(Populated Control File V2)

</div>

<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>

### Presentation of data

Apart to the build system, the controls files can be also processed by
different utilities.

The `render-policy.py` utility creates a HTML file where the controls are
resolved in the context of a given product. The file contains links to rule
definitions in the upstream repository. The generated file can be distributed to
subject matter experts for a review.

```
$ utils/render-policy.py --output doc.html rhel8 controls/abcd.yml
```

For more details about the `render_policy.py` tool, run `utils/render-policy.py --help`.

The `controleval.py` utility creates statistics that show the current progress
in implementing a certain level from the controls file. These are derived from
the different status options that were documented earlier in this
documentation.

```
$ utils/controleval.py stats -i cis_rhel7 -l l2_server
```

For more details about the `controleval.py` too, run `utils/controleval.py --help`.

### Creating Spreadsheets for Submission
Sometimes a control file needs to be exported to format specific for review.

#### DISA STIGs
##### Getting Started
In order for export for DISA the IDs of your control must be SRG ID form the General Purpose Operating System SRG.

If you have an existing product that you want to base your new STIG you can create the skeleton with the following command:

    $ ./utils/build_stig_control.py --split -p rhel9 -m shared/references/disa-os-srg-v2r7.xml -o controls/srg_gpos.yml

The manual (`-m`) should be an SRG XML from DISA.

##### Filling Out Content
Every control in the policy file will create at least one row in the export.
For every rule on the control there will be a row in the exported SRG.

Below is the mapping from fields in the Compliance as Code to field in the spreadsheet.
The **bolded** items are under direct control of content authors.

* IA Control -> DISA OS SRG XML
  * As of v2r1 that field is blank
* CCI -> DISA OS SRG XML
* SRGID -> The control id
* SRG Requirement ->  DISA OS SRG XML
* **Requirement** -> The rule's `srg_requirement` or if there are no rules the control's `title`.
* SRG VulDiscussion -> DISA OS SRG XML
* **Vul Discussion** -> Rule's `rationale` or the control's `rationale`
* **Status** -> Control
  * If there are rules the status should be `Applicable - Configurable`
  * The status can be set on the control as well
* SRG Check -> DISA OS SRG XML
* **Check** -> `ocil` and `ocil_clause` from the rule
  * The first part of the check comes from `ocil` of the rule
  * The last part is "If {ocil_clause}, then it is a finding"
* SRG Fix -> DISA OS SRG XML
  * As of V2R1 that field is blank
* **Fixtext** -> Rule's `fixtext` or the control's `fix`
* **Severity** -> DISA OS SRG XML or Control
  * By default, it comes from the DISA OS SRG
  * Can be overridden by the control
* **Mitigation** -> Control
* **Artifact Description** -> Control
* **Status Justification** -> Control


#### Exporting
To export the spreadsheet use the following command:

    $ ./utils/create_srg_export.py -c controls/srg_gpos.yml -p rhel9

The output by default will be out in CSV file in build directory.
By passing the `--format` flag you are able to output HTML, Markdown, or Excel files.
By default the generated file will be in the `build` folder.

#### Comparing
To compare two spreadsheets use the following command below:

    $ ./utils/srg_diff.py --base first_rhel9.xlsx --target build/1694088261_stig_export.xlsx --product rhel9

The output will be a html in the build folder with the name `srg_diff.html`.
The output will have the following sections:

* `Missing in Base` - This lists rules that are in the target spreadsheet but are not in the base spreadsheet
* `Missing in Target` - This lists rules that are int the base spreadsheet but are in the target spreadsheet
* `Deltas` - Any fields don't match between base and target will be listed here formatted as a diff.

#### Importing
To import changes by a third-party you can import the changes by using the following command:

    $ ./utils/import_srg_spreadsheet.py --current build/1694088261_stig_export.xlsx --changed changed.xlsx --product rhel9 --changed-name "RHEL 9"

```{note}
The STIG ID column needs to contain a valid CCE ID and that CCE ID must be defined in a rule in the project as that how the script matches rows to rules.
```

The `--changed-name` is the name that used in the spreadsheet for the product.
For example in the spreadsheet for RHEL9 "Red Hat Enterprise Linux 9" was changed to "RHEL 9".
You may need to pass `--end-row` with the correct end row number if your spreadsheet has more than 600 rows.
After the script is ran you will need to review changes made to the rules using Git and make changes as needed.

## Components

The `/components` directory contains files that provide mapping of operating system components to individual rules.

The component in ComplianceAsCode doesn't necessary have to correspond to operating system components, we are free to define our components where we see fit.
For example, SELinux is spread into `policycoreutils`, `libselinux` and others, but ComplianceAsCode has a `selinux` component.

Each component is represented by a separate YAML file in the `/components` directory.
The component YAML file name is equal to the component name.

YAML file keys:

- `name` (string) - component name
- `rules` (list) - rules that belong to this component
- `groups` (list) - groups that indicate that rules in these groups should belong to this component (optional)
- `packages` (list) - names of packages that are part of this component (optional)
- `templates` (list) - templates that indicate that rules using these templates should belong to this component (optional)
- `changelog` (list) - records substantial changes in the given component that affected rules and remediations (optional)

Each rule in the benchmark in the `/linux_os/guide` directory must be a member of at least 1 component.

Products specify a path to the directory with component files by the `components_root` key in the `product.yml`.

The mappings of components to rules can be converted to HTML by the `utils/render_components.py` script.


## Preventing Problems

This section outlines some situations that are uncontrollably recurring, and that could cause problems in the project if they are handled impulsively.
Following subsections aim to provide a helping hand to navigate through the risks consciously, and to prevent taking of completely wrong decisions.

### Handling Rule Updates

Handling rule updates and changes is an essential aspect of maintaining a project's rules and ensuring their relevance and effectiveness along the time.
As products evolve and components undergo modifications, it becomes necessary to update the rules that configure them within the project.
These updates may involve addressing divergences in rule behavior, which can arise due to differences between products, versions, or architectures.

In this section, we will explore the approaches and considerations involved in handling rule divergences, including the use of conditionals and spawning new rules.

By effectively managing these updates, we can ensure that the project's rules remain up to date and aligned with the evolving landscape of supported products.

#### Updates and Changes

By design it is expected that the rules in the project will be shared and used by the supported products.
And during the lifespan of a product a component may change and require that one or more rules be updated.

When a component supported by CaC undergoes changes, it is essential to update and align the rules configuring it in the project accordingly.
This is necessary to keep the rules in the project up to date and relevant.

But some changes may not apply to all products, sometimes a change is specific to a Linux distro, or a specific minor version or architecture of that distro.
In these situations the behavior of the rule needs to be different for a product or one of its versions.
The rule behavior needs to diverge according to the product and version.

A rule can diverge in two ways:

- Cross-product wise
- In-product wise

A *cross-product divergence* is a difference in rule behavior stemming from product differences.

In other words, a rule that configures a different key, or value, in different products.

These divergences are the most common in the project since we support a wide range of products, examples of these kinds of divergences are:

- Package names that differ between products. e.g.: In rule `package_audit_installed`, some products have the "audit" package and others have the "auditd" package.
- File paths that differ between products. e.g.: The faillock directory, some products use `/var/run/faillock` and others use `/var/log/faillock`

These divergences are handled in the content

- Jinja conditionals (e.g.: [{{{% if product in ... }}}](https://github.com/ComplianceAsCode/content/blob/328eac5d78ee756d158c389a91633f5dd74a5d60/linux_os/guide/system/software/integrity/fips/enable_fips_mode/rule.yml#L8)) - commonly used in rule descriptions and remediations.
- Product identifiers (e.g.: [attribute@ubuntu1604](https://github.com/ComplianceAsCode/content/blob/328eac5d78ee756d158c389a91633f5dd74a5d60/linux_os/guide/system/auditing/package_audit_installed/rule.yml#LL62C9-L62C9)) - commonly used in templated rules and when defining references.
- Product properties (in [product.yml](https://github.com/ComplianceAsCode/content/blob/328eac5d78ee756d158c389a91633f5dd74a5d60/products/rhel8/product.yml#LL32C35-L32C35) file or `product_properties` directory) - useful for more generic properties, applicable to different rules.
- Product-specific files (e.g.: [sle12.yml](https://github.com/ComplianceAsCode/content/blob/master/linux_os/guide/system/auditing/auditd_configure_rules/audit_privileged_commands/audit_rules_privileged_commands_kmod/ansible/sle12.yml)) - Less common option which is usually used when the differences are drastic and it is not worth using the other options.

An *in-product divergence* is a difference in rule behavior stemming from component changes between a product’s minor versions or supported architectures.

In other words, a rule that configures a different key, or value, in different versions of the same product from the standpoint of ComplianceAsCode, typically because

- a component changed between minor product versions, or
- behaves differently on different architectures.

These divergences emerge as the result of continued support of a minor version, in other words, once a new minor version of a product is released the previous version doesn’t go End Of Life immediately and needs support.

Examples of in-product divergences are:

- Configuration of [SSHD Compression](https://github.com/ComplianceAsCode/content/blob/328eac5d78ee756d158c389a91633f5dd74a5d60/linux_os/guide/services/ssh/ssh_server/sshd_disable_compression/rule.yml#L52), which makes sense only on rhel < 7.4.
- Configuration of [systemd's StopIdleSessionSec](https://github.com/ComplianceAsCode/content/blob/328eac5d78ee756d158c389a91633f5dd74a5d60/linux_os/guide/system/accounts/accounts-physical/logind_session_timeout/rule.yml#L22), which are available on rhel >= 8.7 and rhel > 9.0.
- Different configurations for different architectures. e.g. [audit_access_failed](https://github.com/ComplianceAsCode/content/blob/328eac5d78ee756d158c389a91633f5dd74a5d60/linux_os/guide/system/auditing/policy_rules/audit_access_failed/rule.yml#L34), [audit_access_failed_aarch64](https://github.com/ComplianceAsCode/content/blob/328eac5d78ee756d158c389a91633f5dd74a5d60/linux_os/guide/system/auditing/policy_rules/audit_access_failed_aarch64/rule.yml#L31) and [audit_access_failed_ppc64le](https://github.com/ComplianceAsCode/content/blob/328eac5d78ee756d158c389a91633f5dd74a5d60/linux_os/guide/system/auditing/policy_rules/audit_access_failed_ppc64le/rule.yml#L29) configure different audit rules in each architecture.

Note: The fist two examples above didn't require a new rule to be spawned because they are only limiting the applicability to specific minor versions.
The divergence is the absence of configuration in the complementary set of minor versions.
The third example differs in one single syscall (`open`) not present in aarch64 and ppc64le but present in x86.
In that case there is no mechanism currently available to dynamically update the rule description or the rule parameters, limiting the options to rule spawning.

### Approaches How to Handle Rule Divergence

Basically rule’s divergence can be handled in two ways: Either by

- expanding the affected rule, typically by adding a conditional; or by
- spawning a new rule.

Expansion of a rule allows it to handle the divergence, whereas spawning creates a new rule according to the new behavior, resulting in two separate single-purpose rules.
Each approach has its benefits and drawbacks that need to be evaluated, and they are discussed in the next section.


#### Adding Conditionals to a Rule

One way to handle divergences in a rule is to add conditionals to it.
The conditionals need to be explained in the rule description and added to the checks and remediations, so that each divergence is identified and checked correctly.
In general, the remediation process should be capable of identifying all compliant states, ensuring idempotence, while also favoring a specific approach in cases where the system is incompliant.

If the divergence is cross-product, the conditionals can be handled at build-time through the techniques mentioned previously.
An in-product divergence will require the use of conditionals that can be evaluated at scan-time.

#### Spawning a New Rule

Another way to handle divergences is to create rules that will handle the newly required behavior.
Each rule will describe what they check for and remediate, they will be pretty similar but different regarding their specific divergence.

If the divergence is cross-product, the rule only needs to have the appropriate prototype.
If the divergence is in-product, the rules will need to have disjoint applicabilities in their platforms.

### Aspects to Consider When Picking One Approach

There is no direct guidance on how to handle every case of divergence.
Evaluate the following aspects against the rule update you are dealing, and pick your poison.

#### Granularity and Reusability

##### Conditionals

Pros

- Expected behavior of the rule is maintained, no expectation is violated.
- Rules may already be expected to handle different conditions, now it’s only one more such condition.
- Lower granularity means less rules in the project without compromising on the abilities of the project.

Cons

- Profiles or policies that allow or require only one of the behaviors don’t align well with polymorphic rules.

##### Spawning

Pros

- The original rule and the spawned one are clear and direct about what they do.
- The increased rule granularity promotes reusability, making such rules great  blocks for profiles and controls.

Cons

- Too much granularity in profiles and controls may create noise and impact the user experience.
- Spawning may result in creation of almost identical rules without any real benefit of granularity.
- Bugs affecting multiple spawned rules may be more laborious to be consistently fixed along the time.

#### Profile and control selections

##### Conditionals

Pros

- Unlike with spawning, no changes in profile selections, controls or tailoring.

##### Spawning

Remarks

- The ability to define extendable controls may mitigate the shortcomings mentioned right above.

#### Content Clarity

##### Conditionals

Cons

- Difficulty knowing what the rule is checking for and what it configures.
- Difficulty to write a concise rule description.
- Difficulty to interpret a rule check (why it passed/failed?)
- Tendency to have an opinionated approach to remediations, or remediations full of conditionals that need to be checked for coverage and consistency.

Remarks

- The Conditionals approach works better when the individual rule conditions are equivalent or it doesn’t matter which approach is applied on the system.
- Analysis of results can be facilitated by oscap-report as an interface to ARF/results files.

##### Spawning

Cons

- Need to ensure that new and existing rules have distinct titles and descriptions, so the difference between them is clear, specially in tiny changes, like a single syscall in a list of multiple syscalls in a rule.

#### Code duplication

Reducing code duplication is important to keep the maintenance costs low.

Both of the update approaches are susceptible to code duplication.


A rule that spawns another rule will lead to duplication of code, especially if templates or macros are not used in the new rule.

Similarly, rule updates solved with conditionals can also lead to code duplication if the behavior handled by the new conditional is similar and doesn’t use templates or macros.


In summary, code duplication is mitigated by refactoring or using templates and macros.
Transform the existing code into a macro or template, and use it in the new rule or conditional.

#### Stability

##### Conditionals

Pros

- Customers expect rules to be capable of dealing with new behaviors, like compatibility with RainerScript syntax in rsyslog rules, for example.

Cons

- Rule may break expectations from customers, especially if they use it in a tailoring to handle a specific case - a rule that once accepted just one posture as compliant, will start accepting multiple postures as compliant.

##### Spawning

Pros

- Rule doesn’t change, it just slowly erodes.
  But less changes means less surface for emerging problems.

Cons

- Customers will have to actively select spawned rules in case of e.g. extending profiles by tailoring.

#### Deprecation and Removal

The need to configure a component can appear and disappear, just as the component itself.

Once a rule is deemed obsolete or unnecessary it is deprecated so that new products don’t pick it up into their content.
The rule deprecation process is detailed here.

Once no product is including the deprecated rule in their content the rule can be removed.

##### Conditionals

Pros

- Opportunity to remove "dead" code sooner than a "dead" rule, since a rule cannot be removed from a product's data stream, but unnecessary code can.

Cons

- Getting rid of "dead" conditionals requires refactoring.
- Unless actively pruned, the conditionals in the rule might stay there indefinitely.

##### Spawning

Pros

- Spawn that is not needed any more can just be unselected in the profile, control or tailoring.
- Eventually, it can be removed from the project by removing files without closer examination.
