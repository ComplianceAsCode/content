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
export NEW_PRODUCT="custom6"
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
