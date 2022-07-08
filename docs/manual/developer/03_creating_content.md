# Creating Content

## Directory Structure/Layout

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
<td><p><code>Dockerfiles</code></p></td>
<td><p>Contains Dockerfiles to build content test suite container backends.</p></td>
</tr>
<tr class="even">
<td><p><code>docs</code></p></td>
<td><p>Contains the User Guide and Developer Guide, manual page template, etc.</p></td>
</tr>
<tr class="odd">
<td><p><code>products</code></p></td>
<td><p>Contains per-product directories (such as <code>rhel8</code>) of product-specific information and profiles.</p></td>
</tr>
<tr class="even">
<td><p><code>ssg</code></p></td>
<td><p>Contains Python <code>ssg</code> module which is used by most of the scripts in this repository.</p></td>
</tr>
<tr class="odd">
<td><p><code>utils</code></p></td>
<td><p>Miscellaneous scripts used for development but not used by the build system.</p></td>
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
<td><p>Java Runtime Environment</p></td>
<td><p><code>/products/jre/guide</code></p></td>
</tr>
<tr class="odd">
<td><p>Fuse 6</p></td>
<td><p><code>/products/fuse6/guide</code></p></td>
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
<td><p><code>Required</code> Contains XSLT files and scripts that are used to transform the content into the expected compliance document such as XCCDF, OVAL, Datastream, etc.</p></td>
</tr>
</tbody>
</table>

> **Important**
>
> For any of the `Required` directories that may not yet add
> content, add a `.gitkeep` file for any empty directories.

#### Creating a new Product

Follow these steps to create a new product in the project:

1. Create a new folder in the `products/` directory which will hold the files related to your new product. To illustrate the process we will use the name `custom6` which basically means that the product is called `custom` and the major version is `6`. For more details in the naming conventions and directory structure, check the `Product/Structure Layout` section in the [Developer Guide](../docs/manual/developer_guide.adoc). You can use the following commands to create the basic directory structure, `content` is the root directory of the project:
<pre>
cd content
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
2. Add the product to [CMakeLists.txt](../CMakeLists.txt) by adding the following lines:
<pre>
...
option(SSG_PRODUCT_DEBIAN9 "If enabled, the Debian 9 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
<b>option(SSG_PRODUCT_CUSTOM6 "If enabled, the Custom 6 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})</b>
option(SSG_PRODUCT_EAP6 "If enabled, the JBoss EAP6 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
...
</pre>
<pre>
...
message(STATUS "Debian 9: ${SSG_PRODUCT_DEBIAN9}")
<b>message(STATUS "Custom 6: ${SSG_PRODUCT_CUSTOM6}")</b>
message(STATUS "JBoss EAP 6: ${SSG_PRODUCT_EAP6}")
...
</pre>
<pre>
...
if (SSG_PRODUCT_DEBIAN9)
    add_subdirectory("debian9")
endif()
<b>if (SSG_PRODUCT_CUSTOM6)
      add_subdirectory("custom6")
endif()</b>
if (SSG_PRODUCT_EAP6)
    add_subdirectory("eap6")
endif()
...
</pre>

3. Add the product to [build_product](../../../build_product) script:
<pre>
...
all_cmake_products=(
	CHROMIUM
	DEBIAN9
        <b>CUSTOM6</b>
	EAP6
...
</pre>

4. Add the product to [constants.py](../../../ssg/constants.py) file:
<pre>
...
product_directories = ['debian9', 'fedora', 'ol7', 'ol8', 'opensuse',
                       'rhel7', 'rhel8', 'sle12',
                       'ubuntu1604', 'ubuntu1804', 'rhosp13',
                       'chromium', 'eap6', 'firefox', 'fuse6', 'jre',
                       'example'<b>, 'custom6'</b>]
...
</pre>
<pre>
...
FULL_NAME_TO_PRODUCT_MAPPING = {
    "Chromium": "chromium",
    "Debian 8": "debian9",
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
    "multi_platform_debian": ["debian9", "debian10"],
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
    'jre': 'Java Runtime Environment',
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
cat << EOF >> $NEW_PRODUCT/CMakeLists.txt
# Sometimes our users will try to do: "cd $NEW_PRODUCT; cmake ." That needs to error in a nice way.
if ("\${CMAKE_SOURCE_DIR}" STREQUAL "\${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the Building ComplianceAsCode section in the Developer Guide!")
endif()

ssg_build_product("$NEW_PRODUCT")
EOF
```

7. Create a new file in the product directory called `product.yml` (note: you may want to change the `pkg_manager` attribute):
```
cat << EOF >> $NEW_PRODUCT/product.yml
product: $NEW_PRODUCT
full_name: $FULL_NAME
type: platform

benchmark_root: "../linux_os/guide"

profiles_root: "./profiles"

pkg_manager: "yum"

init_system: "systemd"

cpes_root: "../shared/applicability"
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
cat << EOF >> $NEW_PRODUCT/profiles/standard.profile
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
cat << EOF >> $NEW_PRODUCT/transforms/constants.xslt
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="../../shared/transforms/shared_constants.xslt"/>

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
cat << EOF >> $NEW_PRODUCT/transforms/table-style.xslt 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="../../shared/transforms/shared_table-style.xslt"/>

</xsl:stylesheet>
EOF
```

12. Create a new file under `transforms` directory called `xccdf-apply-overlay-stig.xslt`:
```
cat << EOF >> $NEW_PRODUCT/transforms/xccdf-apply-overlay-stig.xslt
<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://checklists.nist.gov/xccdf/1.1" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<xsl:include href="../../shared/transforms/shared_xccdf-apply-overlay-stig.xslt"/>
<xsl:include href="constants.xslt"/>
<xsl:variable name="overlays" select="document($overlay)/xccdf:overlays" />

</xsl:stylesheet>
EOF
```

13. Create a new file under `transforms` directory called `xccdf2table-byref.xslt`:
```
cat << EOF >> $NEW_PRODUCT/transforms/xccdf2table-byref.xslt 
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<xsl:import href="../../shared/transforms/shared_xccdf2table-byref.xslt"/>

<xsl:include href="constants.xslt"/>
<xsl:include href="table-style.xslt"/>

</xsl:stylesheet>
EOF
```

14. Create a new file under `transforms` directory called `xccdf2table-cce.xslt`:
```
cat << EOF >> $NEW_PRODUCT/transforms/xccdf2table-cce.xslt
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cce="http://cce.mitre.org" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<xsl:import href="../../shared/transforms/shared_xccdf2table-cce.xslt"/>

<xsl:include href="constants.xslt"/>
<xsl:include href="table-style.xslt"/>

</xsl:stylesheet>
EOF
```

15. Create a new file under `transforms` directory called `xccdf2table-profileanssirefs.xslt `:
```
cat << EOF >> $NEW_PRODUCT/transforms/xccdf2table-profileanssirefs.xslt 
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<!-- this style sheet expects parameter $profile, which is the id of the Profile to be shown -->

<xsl:include href="constants.xslt"/>
<xsl:include href="table-style.xslt"/>

	<xsl:template match="/">
		<html>
		<head>
			<title><xsl:value-of select="/cdf:Benchmark/cdf:Profile[@id=$profile]/cdf:title" /></title>
		</head>
		<body>
			<br/>
			<br/>
			<div style="text-align: center; font-size: x-large; font-weight:bold"><xsl:value-of select="/cdf:Benchmark/cdf:Profile[@id=$profile]/cdf:title" /></div>
			<br/>
			<br/>
			<xsl:apply-templates select="cdf:Benchmark"/>
		</body>
		</html>
	</xsl:template>


	<xsl:template match="cdf:Benchmark">
		<xsl:call-template name="table-style" />

		<table>
			<thead>
				<td>Rule Title</td>
				<td>Description</td>
				<td>Rationale</td>
				<td>Variable Setting</td>
				<td>ANSSI Best practice Mapping</td>
			</thead>
		<xsl:for-each select="/cdf:Benchmark/cdf:Profile[@id=$profile]/cdf:select">
			<xsl:variable name="idrefer" select="@idref" />
			<xsl:variable name="enabletest" select="@selected" />
			<xsl:for-each select="//cdf:Rule">
				<xsl:call-template name="ruleplate">
					<xsl:with-param name="idreference" select="$idrefer" />
					<xsl:with-param name="enabletest" select="$enabletest" />
				</xsl:call-template>
			</xsl:for-each>
		</xsl:for-each>

		</table>
	</xsl:template>


	<xsl:template match="cdf:Rule" name="ruleplate">
		<xsl:param name="idreference" />
		<xsl:param name="enabletest" />
		<xsl:if test="@id=$idreference and $enabletest='true'">
		<tr>
			<td> <xsl:value-of select="cdf:title" /></td>
			<td> <xsl:apply-templates select="cdf:description"/> </td>
			<!-- call template to grab text and also child nodes (which should all be xhtml)  -->
			<td> <xsl:apply-templates select="cdf:rationale"/> </td>
			<!-- need to resolve <sub idref=""> here  -->
			<td> <!-- TODO: print refine-value from profile associated with rule --> </td>
			<td> 
				<xsl:for-each select="cdf:reference[@href=$anssiuri]">
					<xsl:value-of select="text()"/>
					<br/>
				</xsl:for-each>
			</td> 
		</tr>
		</xsl:if>
	</xsl:template>


	<xsl:template match="cdf:check">
		<xsl:for-each select="cdf:check-export">
			<xsl:variable name="rulevar" select="@value-id" />
				<!--<xsl:value-of select="$rulevar" />:-->
				<xsl:for-each select="/cdf:Benchmark/cdf:Profile[@id=$profile]/cdf:refine-value">
					<xsl:if test="@idref=$rulevar">
						<xsl:value-of select="@selector" />
					</xsl:if>
				</xsl:for-each>
		</xsl:for-each>
	</xsl:template>


    <!-- getting rid of XHTML namespace -->
	<xsl:template match="xhtml:*">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="node()|@*"/>
		</xsl:element>
	</xsl:template>

    <xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

    <xsl:template match="cdf:description">
             <!-- print all the text and children (xhtml elements) of the description -->
        <xsl:apply-templates select="@*|node()" />
            </xsl:template>

    <xsl:template match="cdf:rationale">
             <!-- print all the text and children (xhtml elements) of the description -->
        <xsl:apply-templates select="@*|node()" />
            </xsl:template>



</xsl:stylesheet>
EOF
```

16. Create a new file under `transforms` directory called `xccdf2table-profileccirefs.xslt`:
```
cat << EOF >> $NEW_PRODUCT/transforms/xccdf2table-profileccirefs.xslt
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:cci="https://public.cyber.mil/stigs/cci" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ovalns="http://oval.mitre.org/XMLSchema/oval-definitions-5">

<xsl:import href="../../shared/transforms/shared_xccdf2table-profileccirefs.xslt"/>

<xsl:include href="constants.xslt"/>
<xsl:include href="table-style.xslt"/>

</xsl:stylesheet>
EOF
```

17. Create a new file under `transforms` directory called `xccdf2table-profilecisrefs.xslt`:
```
cat << EOF >> $NEW_PRODUCT/transforms/xccdf2table-profilecisrefs.xslt
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<xsl:import href="../../shared/transforms/shared_xccdf2table-profilecisrefs.xslt"/>

<xsl:include href="constants.xslt"/>
<xsl:include href="table-style.xslt"/>

</xsl:stylesheet>
EOF
```

18. Create a new file under `transforms` directory called `xccdf2table-profilenistrefs.xslt`:
```
cat << EOF >> $NEW_PRODUCT/transforms/xccdf2table-profilenistrefs.xslt
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<xsl:import href="../../shared/transforms/shared_xccdf2table-profilenistrefs.xslt"/>
<xsl:include href="constants.xslt"/>
<xsl:include href="table-style.xslt"/>

</xsl:stylesheet>
EOF
```

19. Create a new file under `transforms` directory called `xccdf2table-stig.xslt`:
```
cat << EOF >> $NEW_PRODUCT/transforms/xccdf2table-stig.xslt
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<xsl:import href="../../shared/transforms/shared_xccdf2table-stig.xslt"/>

<xsl:include href="constants.xslt"/>
<xsl:include href="table-style.xslt"/>

</xsl:stylesheet>
EOF
```

20. Create a new file under `shared/checks/oval` directory called `installed_OS_is_custom6.xml`:
```
cat << EOF >> shared/checks/oval/installed_OS_is_$NEW_PRODUCT.xml
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

-   `selections`: List composed of items of these types:

-   `` id`s of rules to be included in the profile, e.g. `accounts_tmout ``,
    or

-   `` id`s of rules to be excluded from the profile prefixed by an exclamation mark, e.g. `!accounts_tmout ``,
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
* R3 can be automatically scanned by SCAP but unfortunately we don’t have any
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
    note: |-
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
    note: |-
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
source: a link to the original policy, eg. a URL of a PDF document
controls_dir: a directory containing files representing controls that will be imported into this policy
levels: a list of levels, the first one is default.
  - id: level ID (required key)
    inherits_from: a list of IDs of levels inheriting from

controls: a list of controls (required key)
  - id: control ID (required key)
    title: control title
    description: description of the control in a few sentences
    levels: The list of policy levels that the control belongs to.
    notes: a short paragraph of text
    rules: a list of rule IDs that cover this control
    related_rules: a list of related rules
    note: a short paragraph of text
    controls: a nested list of controls
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
    note: >-
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
```

### Using controls in profiles

Later, we can use the policy requirements in profile YAML. Let’s say that we
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
means that all controls will be selected. Let’s show how it will be easier:

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

### Creating spreadsheets for submission
Sometimes a control file needs to be exported to format specific for review.

#### DISA STIGs
##### Getting Started
In order for export for DISA the IDs of your control must be SRG ID form the General Purpose Operating System SRG.

If you have an existing product that you want to base your new STIG you can create the skeleton with the following command:

    $ ./utils/build_stig_control.py --split -p rhel9 -m shared/references/disa-os-srg-v2r3.xml -o controls/srg_gpos.yml

The manual (`-m`) should be an SRG XML from DISA.  

##### Filling out content
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
The file will be a csv file named as the UNIX timestamp of when the file was created.
