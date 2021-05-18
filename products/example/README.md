# Example Product

This product was introduced to show a few aspects:

 - Serve a documentation on how to add a new product.
    - [See commit bfe5a764](https://github.com/ComplianceAsCode/content/commit/bfe5a76495973f5fc000645c68e3e6936543a09f) for the changes that were
      necessary to add a new product.
 - Create a profile that is quick to scan on RHEL-like distributions.

To build this system, follow the steps for building regularly, but
pass `-DSSG_PRODUCT_EXAMPLE=ON` to the CMake command:

    cd content/build
    cmake -DSSG_PRODUCT_EXAMPLE=ON ..
    make example

This will build only the example profile; this can then be used
with [OpenSCAP](https://github.com/OpenSCAP/openscap) or
[scap-workbench](https://github.com/OpenSCAP/scap-workbench) for
testing purposes.

## Creating a new Product

Follow these steps to create a new product in the project:

1. Create a new folder in the root directory which will hold the files related to your new product. To illustrate the process we will use the name `custom6` which basically means that the product is called `custom` and the major version is `6`. For more details in the naming conventions and directory structure, check the `Product/Structure Layout` section in the [Developer Guide](../docs/manual/developer_guide.adoc). You can use the following commands to create the basic directory structure, `content` is the root directory of the project:
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

3. Add the product to [build_product](../build_product) script:
<pre>
...
all_cmake_products=(
	CHROMIUM
	DEBIAN9
        <b>CUSTOM6</b>
	EAP6
...
</pre>

4. Add the product to [constants.py](../ssg/constants.py) file:
<pre>
...
product_directories = ['debian9', 'fedora', 'ol7', 'ol8', 'opensuse',
                       'rhel7', 'rhel8', 'sle12',
                       'ubuntu1604', 'ubuntu1804', 'wrlinux', 'rhosp13',
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
                       "wrlinux", "opensuse", "sle", "ol", "ocp", "example"<b>, "custom"</b>]
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
<xsl:variable name="product_guide_id_name">${CAPITAL_NAME}-$VERSION</xsl:variable>
<xsl:variable name="prod_type">$NEW_PRODUCT</xsl:variable>

<!-- Define URI of official Center for Internet Security Benchmark for $FULL_NAME -->
<xsl:variable name="cisuri">https://benchmarks.cisecurity.org/tools2/linux/CIS_${CAMEL_CASE_NAME}_Benchmark_v1.0.pdf</xsl:variable>
<xsl:variable name="disa-stigs-uri" select="$disa-stigs-os-unix-linux-uri"/>

<!-- Define URI for custom CCE identifier which can be used for mapping to corporate policy -->
<!--xsl:variable name="custom-cce-uri">https://www.example.org</xsl:variable-->

<!-- Define URI for custom policy reference which can be used for linking to corporate policy -->
<!--xsl:variable name="custom-ref-uri">https://www.example.org</xsl:variable-->

</xsl:stylesheet>
EOF
```

10. Create a new file under `transforms` directory called `shorthand2xccdf.xslt`:
```
cat << EOF >> $NEW_PRODUCT/transforms/shorthand2xccdf.xslt
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="../../shared/transforms/shared_shorthand2xccdf.xslt"/>

<xsl:include href="constants.xslt"/>
<xsl:param name="ssg_version">unknown</xsl:param>

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

12. Create a new file under `transforms` directory called `table-srgmap.xslt`:
```
cat << EOF >> $NEW_PRODUCT/transforms/table-srgmap.xslt 
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<xsl:include href="../../shared/transforms/shared_table-srgmap.xslt"/>
<xsl:include href="constants.xslt"/>
<xsl:include href="table-style.xslt"/>

<xsl:variable name="items" select="document($map-to-items)//*[cdf:reference]" />
<xsl:variable name="title" select="document($map-to-items)/cdf:Benchmark/cdf:title" />

</xsl:stylesheet>
EOF
```

13. Create a new file under `transforms` directory called `xccdf-apply-overlay-stig.xslt`:
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

14. Create a new file under `transforms` directory called `xccdf2table-byref.xslt`:
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

15. Create a new file under `transforms` directory called `xccdf2table-cce.xslt`:
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

16. Create a new file under `transforms` directory called `xccdf2table-profileanssirefs.xslt `:
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

17. Create a new file under `transforms` directory called `xccdf2table-profileccirefs.xslt`:
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

18. Create a new file under `transforms` directory called `xccdf2table-profilecisrefs.xslt`:
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

19. Create a new file under `transforms` directory called `xccdf2table-profilenistrefs.xslt`:
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

20. Create a new file under `transforms` directory called `xccdf2table-stig.xslt`:
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

21. Create a new file under `shared/checks/oval` directory called `installed_OS_is_custom6.xml`:
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
