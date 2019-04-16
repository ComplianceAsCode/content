# Example Product

This product was introduced to show a few aspects:

 - Serve a documentation on how to add a new product.
    - [See commit bfe5a764](https://github.com/ComplianceAsCode/content/commit/bfe5a76495973f5fc000645c68e3e6936543a09f) for the changes that were
      necessary to add a new product.
 - Create a profile that is quick to scan on RHEL-like distributions.

To build this system, follow the steps for building regularly, but
pass `-DSSG_PRODUCT_EXAMPLE=ON` to the CMake command:

    cd scap-security-guide/build
    cmake -DSSG_PRODUCT_EXAMPLE=ON ..
    make example

This will build only the example profile; this can then be used
with [OpenSCAP](https://github.com/OpenSCAP/openscap) or
[scap-workbench](https://github.com/OpenSCAP/scap-workbench) for
testing purposes.
