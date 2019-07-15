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

1. Create a new folder in the root directory which will holds the files related to your new product. To illustrate the process we will use the name `custom6` which basically means that the product is called `custom` and the major version is `6`.
<pre>
cd content
mkdir custom6
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
<b>if (SSG_PRODUCT_CUSTOM6
      add_subdirectory("custom6")
endif()</b>
if (SSG_PRODUCT_EAP6)
    add_subdirectory("eap6")
endif()
...
</pre>
