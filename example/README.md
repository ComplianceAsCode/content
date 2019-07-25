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
        $NEW_PRODUCT/cpe \
        $NEW_PRODUCT/overlays \
        $NEW_PRODUCT/profiles \
        $NEW_PRODUCT/templates \
        $NEW_PRODUCT/templates/csv \
        $NEW_PRODUCT/transforms
</pre>
2. Add the product to [CMakeLists.txt](../CMakeLists.txt) by adding the following lines:
<pre>
...
option(SSG_PRODUCT_DEBIAN8 "If enabled, the Debian 8 SCAP content will be built" TRUE)
<b>option(SSG_PRODUCT_CUSTOM6 "If enabled, the Custom 6 SCAP content will be built" TRUE)</b>
option(SSG_PRODUCT_EAP6 "If enabled, the JBoss EAP6 SCAP content will be built" TRUE)
...
</pre>
<pre>
...
message(STATUS "Debian 8: ${SSG_PRODUCT_DEBIAN8}")
<b>message(STATUS "Custom 6: ${SSG_PRODUCT_CUSTOM6}")</b>
message(STATUS "JBoss EAP 6: ${SSG_PRODUCT_EAP6}")
...
</pre>
<pre>
...
if (SSG_PRODUCT_DEBIAN8)
    add_subdirectory("debian8")
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
	DEBIAN8
        <b>CUSTOM6</b>
	EAP6
...
</pre>

4. Create a new file in the product directory called `CMakeLists.txt`:
```
cat << EOF >> $NEW_PRODUCT/CMakeLists.txt
# Sometimes our users will try to do: "cd $NEW_PRODUCT; cmake ." That needs to error in a nice way.
if ("\${CMAKE_SOURCE_DIR}" STREQUAL "\${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the developer_guide.adoc for more details!")
endif()

ssg_build_product("$NEW_PRODUCT")
EOF
```
5. Create a new file under `cpe` directory called `custom6-cpe-dictionary.xml`:
```
cat << EOF >> $NEW_PRODUCT/cpe/$NEW_PRODUCT-cpe-dictionary.xml
<?xml version="1.0" encoding="UTF-8"?>
<cpe-list xmlns="http://cpe.mitre.org/dictionary/2.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://cpe.mitre.org/dictionary/2.0 http://cpe.mitre.org/files/cpe-dictionary_2.1.xsd">
      <cpe-item name="cpe:/o:$NAME:$VERSION">
            <title xml:lang="en-us">$FULL_NAME</title>
            <!-- the check references an OVAL file that contains an inventory definition -->
            <check system="http://oval.mitre.org/XMLSchema/oval-definitions-5" href="filename">installed_OS_is_$NEW_PRODUCT</check>
      </cpe-item>
</cpe-list>
EOF
```

6. Create a new file in the product directory called `product.yml` (note: you may want to change the `pkg_manager` attribute):
```
cat << EOF >> $NEW_PRODUCT/product.yml
product: $NEW_PRODUCT
full_name: $FULL_NAME
type: platform

benchmark_root: "../linux_os/guide"

profiles_root: "./profiles"

pkg_manager: "yum"

init_system: "systemd"
EOF
```

7. Create a draft profile under `profiles` directory called `standard.profile`:
```
cat << EOF >> $NEW_PRODUCT/profiles/standard.profile
documentation_complete: true

title: 'Standard System Security Profile for $FULL_NAME'

description: |-
    This profile contains rules to ensure standard security baseline
    of a $FULL_NAME system. Regardless of your system's workload
    all of these checks should pass.

selections:
    - partition_for_tmp
EOF
```

8. Create a new file under `transforms` directory called `constants.xslt` (you may want to review the links below):
```
cat << EOF >> $NEW_PRODUCT/transforms/constants.xslt
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="../../shared/transforms/shared_constants.xslt"/>

<xsl:variable name="product_long_name">$FULL_NAME</xsl:variable>
<xsl:variable name="product_short_name">$FULL_SHORT_NAME</xsl:variable>
<xsl:variable name="product_stig_id_name">${CAPITAL_NAME}_STIG</xsl:variable>
<xsl:variable name="product_guide_id_name">${CAPITAL_NAME}-$VERSION</xsl:variable>
<xsl:variable name="prod_type">$FULL_SHORT_NAME</xsl:variable>

<!-- Define URI of official Center for Internet Security Benchmark for $FULL_NAME -->
<xsl:variable name="cisuri">https://benchmarks.cisecurity.org/tools2/linux/CIS_${CAMEL_CASE_NAME}_Benchmark_v1.0.pdf</xsl:variable>
<xsl:variable name="disa-stigs-uri" select="$disa-stigs-os-unix-linux-uri"/>
<xsl:variable name="os-stigid-concat" />

<!-- Define URI for custom CCE identifier which can be used for mapping to corporate policy -->
<!--xsl:variable name="custom-cce-uri">https://www.example.org</xsl:variable-->

<!-- Define URI for custom policy reference which can be used for linking to corporate policy -->
<!--xsl:variable name="custom-ref-uri">https://www.example.org</xsl:variable-->

</xsl:stylesheet>
EOF
```
