cmake_minimum_required(VERSION 2.8)

# Inspired and referenced from https://blog.kitware.com/cmake-and-the-default-build-type
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting build type to 'Release' as none was specified.")
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
        "MinSizeRel" "RelWithDebInfo")
endif()

project(scap-security-guide NONE)

set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake")
# This is set to silence GNUInstallDirs warning about no language being used with cmake
set(CMAKE_INSTALL_LIBDIR "/nowhere")
include(GNUInstallDirs)
include(FindPythonModule)

if ( "$ENV{PYTHONPATH}" STREQUAL "" )
    set(ENV{PYTHONPATH} "${PROJECT_SOURCE_DIR}")
else()
    set(ENV{PYTHONPATH} "${PROJECT_SOURCE_DIR}:$ENV{PYTHONPATH}")
endif()

set(SSG_CONTENT_INSTALL_DIR "${CMAKE_INSTALL_DATADIR}/xml/scap/ssg/content")
set(SSG_GUIDE_INSTALL_DIR "${CMAKE_INSTALL_DOCDIR}/guides")
set(SSG_TABLE_INSTALL_DIR "${CMAKE_INSTALL_DOCDIR}/tables")
set(SSG_ANSIBLE_ROLE_INSTALL_DIR "${CMAKE_INSTALL_DATADIR}/scap-security-guide/ansible")
set(SSG_BASH_ROLE_INSTALL_DIR "${CMAKE_INSTALL_DATADIR}/scap-security-guide/bash")
set(SSG_KICKSTART_INSTALL_DIR "${CMAKE_INSTALL_DATADIR}/scap-security-guide/kickstart")
set(SSG_TAILORING_INSTALL_DIR "${CMAKE_INSTALL_DATADIR}/scap-security-guide/tailoring")

set(SSG_MAJOR_VERSION 0)
set(SSG_MINOR_VERSION 1)
set(SSG_PATCH_VERSION 63)
set(SSG_VERSION "${SSG_MAJOR_VERSION}.${SSG_MINOR_VERSION}.${SSG_PATCH_VERSION}")

set(SSG_VENDOR "ssgproject" CACHE STRING "Specify the XCCDF 1.2 vendor string.")

set(SSG_TARGET_OVAL_MAJOR_VERSION "5" CACHE STRING "Which major version of OVAL are we targetting. Only 5 is supported at the moment.")
set(SSG_TARGET_OVAL_MINOR_VERSION "11" CACHE STRING "Which minor version of OVAL are we targetting. Possible choices are 10 or 11.")

set(SSG_TARGET_OVAL_VERSION "${SSG_TARGET_OVAL_MAJOR_VERSION}.${SSG_TARGET_OVAL_MINOR_VERSION}")

option(SSG_BUILD_SCAP_12_DS "If enabled, ssg-*-ds-1.2.xml will be built along with ssg-*-ds.xml" TRUE)
option(SSG_OVAL_SCHEMATRON_VALIDATION_ENABLED "If enabled, schematron validation will be performed as part of the ctest tests. Schematron takes a lot of time to complete but can find more issues than just plain XSD validation." TRUE)
option(SSG_SHELLCHECK_BASH_FIXES_VALIDATION_ENABLED "If enabled, shellcheck validation of bash fixes will be performed as part of the ctest tests. Shellcheck tests don't pass right now, this option is discouraged until that's fixed." TRUE)
option(SSG_LINKCHECKER_VALIDATION_ENABLED "If enabled, linkchecker will be used to validate URLs in all the HTML guides and tables." TRUE)
option(SSG_SVG_IN_XCCDF_ENABLED "If enabled, the built XCCDFs will include the SVG SCAP Security Guide logo." TRUE)
option(SSG_SEPARATE_SCAP_FILES_ENABLED "If enabled, separate SCAP files (OVAL, XCCDF, CPE dict, ...) will be installed alongside the source data-streams" TRUE)
option(SSG_ANSIBLE_PLAYBOOKS_ENABLED "If enabled, Ansible Playbooks for each profile will be built and installed." TRUE)
option(SSG_ANSIBLE_PLAYBOOKS_PER_RULE_ENABLED "If enabled, Ansible Playbooks for each rule will be built and installed." FALSE)
option(SSG_BASH_SCRIPTS_ENABLED "If enabled, Bash remediation scripts for each profile will be built and installed." TRUE)
option(SSG_JINJA2_CACHE_ENABLED "If enabled, the jinja2 templating files will be cached into bytecode. Also see SSG_JINJA2_CACHE_DIR." TRUE)
option(SSG_BATS_TESTS_ENABLED "If enabled, bats will be used to run unit-tests of bash remediations." TRUE)
option(SSG_BUILD_DISA_DELTA_FILES "If enabled, If the product has automated content from DISA for its STIG a tailoring file will be created with rules not covered by DISA's content enabled." TRUE)
option(SSG_SCE_ENABLED "If enabled, additional SCE audit content will be enabled alongside OVAL-based auditing." FALSE)
set(SSG_JINJA2_CACHE_DIR "${CMAKE_BINARY_DIR}/jinja2_cache" CACHE PATH "Where the jinja2 cached bytecode should be stored. This speeds up builds at the expense of disk space. You can use one location for multiple SSG builds for performance improvements.")

# SSG_PRODUCT_DEFAULT modifies the behavior of all other options. Products
# which should be built by default should use the value ${SSG_PRODUCT_DEFAULT}
# instead of the boolean True. This allows us disable all default products by
# passing `-DSSG_PRODUCT_DEFAULT=OFF` and then manually specifying a list of
# products to build.
option(SSG_PRODUCT_DEFAULT "If enabled, all default release products will be built; otherwise only explicitly enabled products will be" TRUE)

# Products to build content for. These generally correspond to directories in
# the root of this project. Note that the example product is always disabled
# unless explicitly asked for.
option(SSG_PRODUCT_ALINUX2 "If enabled, the Alinux 2 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_ALINUX3 "If enabled, the Alinux 3 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_CHROMIUM "If enabled, the Chromium SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_DEBIAN9 "If enabled, the Debian 9 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_DEBIAN10 "If enabled, the Debian 10 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_DEBIAN11 "If enabled, the Debian 11 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_EKS "If enabled, the EKS SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_EXAMPLE "If enabled, the Example SCAP content will be built" FALSE)
option(SSG_PRODUCT_FEDORA "If enabled, the Fedora SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_FIREFOX "If enabled, the Firefox SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_FUSE6 "If enabled, the JBoss Fuse6 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_JRE "If enabled, the JRE SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_MACOS1015 "If enabled, the Apple macOS 10.15 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_OCP4 "If enabled, the OCP4 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_RHCOS4 "If enabled, the RHCOS4 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_OL7 "If enabled, the Oracle Linux 7 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_OL8 "If enabled, the Oracle Linux 8 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_OL9 "If enabled, the Oracle Linux 9 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_OPENSUSE "If enabled, the openSUSE SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_RHEL7 "If enabled, the RHEL7 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_RHEL8 "If enabled, the RHEL8 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_RHEL9 "If enabled, the RHEL9 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_RHV4 "If enabled, the RHV4 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_SLE12 "If enabled, the SLE12 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_SLE15 "If enabled, the SLE15 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_UBUNTU1604 "If enabled, the Ubuntu 16.04 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_UBUNTU1804 "If enabled, the Ubuntu 18.04 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_UBUNTU2004 "If enabled, the Ubuntu 20.04 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_UOS20 "If enabled, the Uos 20 SCAP content will be built" ${SSG_PRODUCT_DEFAULT})
option(SSG_PRODUCT_VSEL "If enabled, the McAfee VSEL SCAP content will be built" ${SSG_PRODUCT_DEFAULT})

option(SSG_CENTOS_DERIVATIVES_ENABLED "If enabled, CentOS derivative content will be built from the RHEL content" TRUE)
option(SSG_SCIENTIFIC_LINUX_DERIVATIVES_ENABLED "If enabled, Scientific Linux derivative content will be built from the RHEL content" TRUE)

option(FORCE_VALIDATE_EVERYTHING "If enabled, perform all validation tests regardless of oscap version requirements. By default, the build system may not perform validation of some content types if the openscap used to build it is not up-to-date" FALSE)

set(SSG_SHARED "${CMAKE_SOURCE_DIR}/shared")
set(SSG_SHARED_REFS "${SSG_SHARED}/references")
set(SSG_SHARED_TRANSFORMS "${SSG_SHARED}/transforms")
set(SSG_BUILD_SCRIPTS "${CMAKE_SOURCE_DIR}/build-scripts")

message(STATUS "SCAP Security Guide ${SSG_VERSION}")
message(STATUS "(see ${CMAKE_SOURCE_DIR}/docs/manual/developer_guide.adoc for build instructions)")
message(STATUS "")

# Strictly speaking in-source will work but will be very messy, let's
# discourage our users from using them
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR "In-source builds are not supported! Please use out of source builds:\n"
       "$ cd content\n"
       "$ rm CMakeCache.txt\n"
       "$ cd build\n"
       "$ cmake ../\n"
       "$ make -j4"
    )
endif()


set(Python_ADDITIONAL_VERSIONS 3 2)
find_package(PythonInterp REQUIRED)

find_python_module(yaml REQUIRED)
find_python_module(jinja2 REQUIRED)
find_python_module(pytest)
find_python_module(pytest_cov)
find_python_module(json2html)
find_python_module(yamlpath)

# sphinx documentation requirements
find_python_module(sphinx)
find_python_module(sphinxcontrib.autojinja)
find_python_module(sphinx_rtd_theme)
find_python_module(recommonmark)


include(CMakeDependentOption)
cmake_dependent_option(ENABLE_PYTHON_COVERAGE "Enable Python tests with coverage support" ON "PY_PYTEST_COV" OFF)

find_package(OpenSCAP REQUIRED)

if (SSG_TARGET_OVAL_MAJOR_VERSION EQUAL "5" AND SSG_TARGET_OVAL_VERSION_MINOR EQUAL "11" AND NOT "${OSCAP_V_OUTPUT}" MATCHES "OVAL Version: 5.11")
    message(FATAL_ERROR "Your version of OpenSCAP does not support OVAL 5.11, please switch the OVAL target version to 5.10 or lower. $ cmake -DSSG_TARGET_OVAL_MINOR_VERSION=10 ../")
endif()

if (NOT SSG_TARGET_OVAL_VERSION VERSION_EQUAL "5.10" AND NOT SSG_TARGET_OVAL_VERSION VERSION_EQUAL "5.11")
    message(WARNING "You are targetting OVAL version ${SSG_TARGET_OVAL_VERSION}. In SSG we support/test 5.10 and 5.11 only!")
endif()

execute_process(
    COMMAND "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/oscap_svg_support.py" "${OPENSCAP_OSCAP_EXECUTABLE}"
    RESULT_VARIABLE OSCAP_SVG_SUPPORT_RESULT
)
# OSCAP_SVG_SUPPORT_RESULT == 0 means SVG is supported
if (SSG_SVG_IN_XCCDF_ENABLED AND NOT OSCAP_SVG_SUPPORT_RESULT EQUAL 0)
    set(SSG_SVG_IN_XCCDF_ENABLED OFF CACHE BOOL "SVG in XCCDF disabled because your version OpenSCAP doesn't support it" FORCE)
    message(WARNING "Your version of OpenSCAP does not support having the SVG logo in the XCCDF, disabling SVG logo.")
endif()

# OCP4 requires non-standard extensions. Vanilla OpenSCAP 1.2 doesn't support
# it. See also: https://github.com/ComplianceAsCode/content/issues/6798
if ("${OSCAP_VERSION}" VERSION_LESS "1.3.4" AND SSG_PRODUCT_OCP4)
    set(SSG_PRODUCT_OCP4 OFF)
    message(WARNING "Won't build OCP4 content as it requires an OpenSCAP version with OCP4 support. See also: https://github.com/ComplianceAsCode/content/issues/6798. n.b.: if 1.3.4 fails to build OCP4 content, please update to 1.3.5")
endif()

# EKS requires non-standard extensions. Vanilla OpenSCAP 1.2 doesn't support
# it. See also: https://github.com/ComplianceAsCode/content/issues/6798
if ("${OSCAP_VERSION}" VERSION_LESS "1.3.4" AND SSG_PRODUCT_EKS)
    set(SSG_PRODUCT_EKS OFF)
    message(WARNING "Won't build EKS content as it requires an OpenSCAP version with EKS support. See also: https://github.com/ComplianceAsCode/content/issues/6798. n.b.: if 1.3.4 fails to build EKS content, please update to 1.3.5")
endif()


if (SSG_JINJA2_CACHE_ENABLED)
    file(MAKE_DIRECTORY "${SSG_JINJA2_CACHE_DIR}")
    if (NOT EXISTS "${SSG_JINJA2_CACHE_DIR}")
        message(FATAL_ERROR "jinja2 cache dir was set to '${SSG_JINJA2_CACHE_DIR}'. This directory doesn't seem to exist and attempt to create it has failed.")
    endif()
    set(SSG_JINJA2_CACHE_ENABLED_BOOL "true")
else()
    set(SSG_JINJA2_CACHE_ENABLED_BOOL "false")
endif()

find_program(XSLTPROC_EXECUTABLE NAMES xsltproc)
if (NOT XSLTPROC_EXECUTABLE)
    message(SEND_ERROR "xsltproc is required!")
endif()

find_program(XMLLINT_EXECUTABLE NAMES xmllint)
if (NOT XMLLINT_EXECUTABLE)
    message(SEND_ERROR "xmllint is required!")
endif()

find_program(XMLWF_EXECUTABLE NAMES xmlwf)
if (NOT XMLWF_EXECUTABLE)
    message(SEND_ERROR "xmlwf is required!")
endif()

find_program(SED_EXECUTABLE NAMES sed)
if (NOT SED_EXECUTABLE)
    message(SEND_ERROR "sed is required!")
endif()

find_program(SHELLCHECK_EXECUTABLE NAMES shellcheck)
find_program(LINKCHECKER_EXECUTABLE NAMES linkchecker)
find_program(BATS_EXECUTABLE NAMES bats)
find_program(GREP_EXECUTABLE NAMES grep)
find_program(ANSIBLE_PLAYBOOK_EXECUTABLE NAMES ansible-playbook)
find_program(ANSIBLE_LINT_EXECUTABLE NAMES ansible-lint)
find_program(YAMLLINT_EXECUTABLE NAMES yamllint)

configure_file("${CMAKE_SOURCE_DIR}/build_config.yml.in" "${CMAKE_BINARY_DIR}/build_config.yml" @ONLY)

message(STATUS "CMake:")
message(STATUS "build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "generator: ${CMAKE_GENERATOR}")
message(STATUS "source directory: ${CMAKE_SOURCE_DIR}")
message(STATUS "build directory: ${CMAKE_BINARY_DIR}")
message(STATUS " ")

message(STATUS "Tools:")
message(STATUS "python: ${PYTHON_EXECUTABLE} (version: ${PYTHON_VERSION_STRING})")
message(STATUS "python yaml module: ${PY_YAML}")
message(STATUS "python jinja2 module: ${PY_JINJA2}")
message(STATUS "oscap: ${OPENSCAP_OSCAP_EXECUTABLE} (version: ${OSCAP_VERSION})")
message(STATUS "xsltproc: ${XSLTPROC_EXECUTABLE}")
message(STATUS "xmllint: ${XMLLINT_EXECUTABLE}")
message(STATUS "xmlwf: ${XMLWF_EXECUTABLE}")
message(STATUS "sed: ${SED_EXECUTABLE}")
message(STATUS "shellcheck (optional): ${SHELLCHECK_EXECUTABLE}")
message(STATUS "linkchecker (optional): ${LINKCHECKER_EXECUTABLE}")
message(STATUS "grep (optional): ${GREP_EXECUTABLE}")
message(STATUS "python pytest module (optional): ${PY_PYTEST}")
message(STATUS "ansible-playbook module (optional): ${ANSIBLE_PLAYBOOK_EXECUTABLE}")
message(STATUS "ansible-lint module (optional): ${ANSIBLE_LINT_EXECUTABLE}")
message(STATUS "yamllint module (optional): ${YAMLLINT_EXECUTABLE}")
message(STATUS "yamlpath module (optional): ${PY_YAMLPATH}")
message(STATUS "BATS framework (optional): ${BATS_EXECUTABLE}")
message(STATUS "python sphinx module (optional): ${PY_SPHINX}")
message(STATUS "python sphinxcontrib.autojinja module (optional): ${PY_SPHINXCONTRIB.AUTOJINJA}")
message(STATUS "python sphinx_rtd_theme module (optional): ${PY_SPHINX_RTD_THEME}")
message(STATUS "python recommonmark module (optional): ${PY_RECOMMONMARK}")
message(STATUS " ")

message(STATUS "Build options:")
message(STATUS "SSG vendor string: ${SSG_VENDOR}")
message(STATUS "Target OVAL version: ${SSG_TARGET_OVAL_VERSION}")
message(STATUS "Build SCAP 1.2 source data streams: ${SSG_BUILD_SCAP_12_DS}")
message(STATUS "OVAL schematron validation: ${SSG_OVAL_SCHEMATRON_VALIDATION_ENABLED}")
message(STATUS "shellcheck bash fixes validation: ${SSG_SHELLCHECK_BASH_FIXES_VALIDATION_ENABLED}")
message(STATUS "SVG logo in XCCDFs: ${SSG_SVG_IN_XCCDF_ENABLED}")
message(STATUS "Separate SCAP files: ${SSG_SEPARATE_SCAP_FILES_ENABLED}")
message(STATUS "Ansible Playbooks: ${SSG_ANSIBLE_PLAYBOOKS_ENABLED}")
message(STATUS "Ansible Playbooks Per Rule: ${SSG_ANSIBLE_PLAYBOOKS_PER_RULE_ENABLED}")
message(STATUS "Bash scripts: ${SSG_BASH_SCRIPTS_ENABLED}")
if (SSG_JINJA2_CACHE_ENABLED)
    message(STATUS "jinja2 cache: enabled")
    message(STATUS "jinja2 cache dir: ${SSG_JINJA2_CACHE_DIR}")
else()
    message(STATUS "jinja2 cache: disabled")
endif()
message(STATUS "STIG Delta Taloring files: ${SSG_BUILD_DISA_DELTA_FILES}")
message(STATUS " ")

message(STATUS "Products:")
message(STATUS "Alinux 2: ${SSG_PRODUCT_ALINUX2}")
message(STATUS "Alinux 3: ${SSG_PRODUCT_ALINUX3}")
message(STATUS "Chromium: ${SSG_PRODUCT_CHROMIUM}")
message(STATUS "Debian 9: ${SSG_PRODUCT_DEBIAN9}")
message(STATUS "Debian 10: ${SSG_PRODUCT_DEBIAN10}")
message(STATUS "Debian 11: ${SSG_PRODUCT_DEBIAN11}")
message(STATUS "Example: ${SSG_PRODUCT_EXAMPLE}")
message(STATUS "EKS: ${SSG_PRODUCT_EKS}")
message(STATUS "Fedora: ${SSG_PRODUCT_FEDORA}")
message(STATUS "Firefox: ${SSG_PRODUCT_FIREFOX}")
message(STATUS "JBoss Fuse 6: ${SSG_PRODUCT_FUSE6}")
message(STATUS "JRE: ${SSG_PRODUCT_JRE}")
message(STATUS "MacOS 1015: ${SSG_PRODUCT_MACOS1015}")
message(STATUS "OCP4: ${SSG_PRODUCT_OCP4}")
message(STATUS "RHCOS4: ${SSG_PRODUCT_RHCOS4}")
message(STATUS "Oracle Linux 7: ${SSG_PRODUCT_OL7}")
message(STATUS "Oracle Linux 8: ${SSG_PRODUCT_OL8}")
message(STATUS "Oracle Linux 9: ${SSG_PRODUCT_OL9}")
message(STATUS "openSUSE: ${SSG_PRODUCT_OPENSUSE}")
message(STATUS "RHEL 7: ${SSG_PRODUCT_RHEL7}")
message(STATUS "RHEL 8: ${SSG_PRODUCT_RHEL8}")
message(STATUS "RHEL 9: ${SSG_PRODUCT_RHEL9}")
message(STATUS "RHV 4: ${SSG_PRODUCT_RHV4}")
message(STATUS "SUSE 12: ${SSG_PRODUCT_SLE12}")
message(STATUS "SUSE 15: ${SSG_PRODUCT_SLE15}")
message(STATUS "Ubuntu 16.04: ${SSG_PRODUCT_UBUNTU1604}")
message(STATUS "Ubuntu 18.04: ${SSG_PRODUCT_UBUNTU1804}")
message(STATUS "Ubuntu 20.04: ${SSG_PRODUCT_UBUNTU2004}")
message(STATUS "Uos 20: ${SSG_PRODUCT_UOS20}")
message(STATUS "McAfee VSEL: ${SSG_PRODUCT_VSEL}")




message(STATUS " ")

# Remove this option when we would like to run ansible-lint and yamllint against our playbooks by default.
# Right now these checks are not performed and need to be enabled by adding -DANSIBLE_CHECKS=ON to cmake
# before running ctest.
option(ANSIBLE_CHECKS "Set to ON to enable ansible-lint and yamllint checks" OFF)
enable_testing()

include(SSGCommon)

add_subdirectory("tests")

# Targets 'stats', 'profile-stats' and 'zipfile' need to be added
# before any product because they will receive dependencies from products added
if(SSG_TARGET_OVAL_VERSION VERSION_EQUAL "5.11")
    ssg_build_zipfile_target("scap-security-guide-${SSG_VERSION}")
else()
    ssg_build_zipfile_target("scap-security-guide-${SSG_VERSION}-oval-${SSG_TARGET_OVAL_VERSION}")
endif()

add_custom_target(stats)
add_custom_target(profile-stats)

add_custom_target(html-stats)
add_custom_target(html-profile-stats)

if(PY_SPHINX AND PY_SPHINXCONTRIB.AUTOJINJA AND PY_SPHINX_RTD_THEME AND PY_RECOMMONMARK)
    message(STATUS "Enabling docs directory as system supports Sphinx builds.")
    add_subdirectory("docs")
endif()

ssg_build_man_page()

if (SSG_PRODUCT_ALINUX2)
    add_subdirectory("products/alinux2" "alinux2")
endif()
if (SSG_PRODUCT_ALINUX3)
    add_subdirectory("products/alinux3" "alinux3")
endif()
if (SSG_PRODUCT_CHROMIUM)
    add_subdirectory("products/chromium" "chromium")
endif()
if (SSG_PRODUCT_DEBIAN9)
    add_subdirectory("products/debian9" "debian9")
endif()
if (SSG_PRODUCT_DEBIAN10)
    add_subdirectory("products/debian10" "debian10")
endif()
if (SSG_PRODUCT_DEBIAN11)
    add_subdirectory("products/debian11" "debian11")
endif()
if (SSG_PRODUCT_EXAMPLE)
    add_subdirectory("products/example" "example")
endif()
if (SSG_PRODUCT_EKS)
    add_subdirectory("products/eks" "eks")
endif()
if (SSG_PRODUCT_FEDORA)
    add_subdirectory("products/fedora" "fedora")
endif()
if (SSG_PRODUCT_FIREFOX)
    add_subdirectory("products/firefox" "firefox")
endif()
if (SSG_PRODUCT_FUSE6)
    add_subdirectory("products/fuse6" "fuse6")
endif()
if (SSG_PRODUCT_JRE)
    add_subdirectory("products/jre" "jre")
endif()
if (SSG_PRODUCT_MACOS1015)
    add_subdirectory("products/macos1015" "macos1015")
endif()
if (SSG_PRODUCT_OCP4)
    add_subdirectory("products/ocp4" "ocp4")
endif()
if (SSG_PRODUCT_RHCOS4)
    add_subdirectory("products/rhcos4" "rhcos4")
endif()
if (SSG_PRODUCT_OL7)
    add_subdirectory("products/ol7" "ol7")
endif()
if (SSG_PRODUCT_OL8)
    add_subdirectory("products/ol8" "ol8")
endif()
if (SSG_PRODUCT_OL9)
    add_subdirectory("products/ol9" "ol9")
endif()
if (SSG_PRODUCT_OPENSUSE)
    add_subdirectory("products/opensuse" "opensuse")
endif()
if (SSG_PRODUCT_RHEL7)
    add_subdirectory("products/rhel7" "rhel7")
endif()
if (SSG_PRODUCT_RHEL8)
    add_subdirectory("products/rhel8" "rhel8")
endif()
if (SSG_PRODUCT_RHEL9)
    add_subdirectory("products/rhel9" "rhel9")
endif()
if (SSG_PRODUCT_RHV4)
    add_subdirectory("products/rhv4" "rhv4")
endif()
if (SSG_PRODUCT_SLE12)
    add_subdirectory("products/sle12" "sle12")
endif()
if (SSG_PRODUCT_SLE15)
    add_subdirectory("products/sle15" "sle15")
endif()
if (SSG_PRODUCT_UBUNTU1604)
    add_subdirectory("products/ubuntu1604" "ubuntu1604")
endif()
if (SSG_PRODUCT_UBUNTU1804)
    add_subdirectory("products/ubuntu1804" "ubuntu1804")
endif()
if (SSG_PRODUCT_UBUNTU2004)
    add_subdirectory("products/ubuntu2004" "ubuntu2004")
endif()
if (SSG_PRODUCT_UOS20)
    add_subdirectory("products/uos20" "uos20")
endif()
if (SSG_PRODUCT_VSEL)
    add_subdirectory("products/vsel" "vsel")
endif()

# ZIP only contains source datastreams and kickstarts, people who
# want sources to build from should get the tarball instead.
if(SSG_TARGET_OVAL_VERSION VERSION_EQUAL "5.11")
    ssg_build_zipfile("scap-security-guide-${SSG_VERSION}")
else()
    ssg_build_zipfile("scap-security-guide-${SSG_VERSION}-oval-${SSG_TARGET_OVAL_VERSION}")
endif()

ssg_define_guide_and_table_tests()

install(FILES "${CMAKE_SOURCE_DIR}/LICENSE"
    DESTINATION ${CMAKE_INSTALL_DOCDIR})
install(FILES "${CMAKE_SOURCE_DIR}/README.md"
    DESTINATION ${CMAKE_INSTALL_DOCDIR})
install(FILES "${CMAKE_SOURCE_DIR}/Contributors.md"
    DESTINATION ${CMAKE_INSTALL_DOCDIR})

install(FILES "${CMAKE_BINARY_DIR}/scap-security-guide.8"
    DESTINATION "${CMAKE_INSTALL_MANDIR}/man8")

# We use CPack to generate the tarball with all sources and
# packages for testing

# only CPack should follow
set(CPACK_CMAKE_GENERATOR "Unix Makefiles")
set(CPACK_SOURCE_GENERATOR "TBZ2")
set(CPACK_SOURCE_PACKAGE_FILE_NAME "scap-security-guide-${SSG_VERSION}" CACHE INTERNAL "tarball basename")
set(CPACK_SOURCE_IGNORE_FILES
"\\\\.git.*"
"\\\\.pyc"
"__pycache__"

"build/"
"~$"

"\\\\CMakeLists.txt.user"
)
# Common definitions for RPM and DEB packages
set(CPACK_PACKAGE_VERSION ${SSG_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Security guidance and baselines in SCAP formats")
set(CPACK_PACKAGE_VENDOR "scap-security-guide")
# The package contact is needed to build the deb package
set(CPACK_PACKAGE_CONTACT "open-scap-list@redhat.com")
set(CPACK_PACKAGE_RELOCATABLE FALSE)

# This adds "${?dist} to Release field in spec file
set(CPACK_RPM_PACKAGE_RELEASE "1%{?dist}")
set(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/usr/share/xml;/usr/share/man;/usr/share/man/man8")
set(CPACK_RPM_PACKAGE_GROUP "Applications/System")
set(CPACK_RPM_PACKAGE_LICENSE "BSD-3-Clause")
set(CPACK_RPM_PACKAGE_URL "https://www.open-scap.org/security-policies/scap-security-guide/")
set(CPACK_RPM_PACKAGE_ARCHITECTURE "noarch")
set(CPACK_RPM_PACKAGE_REQUIRES "xml-common, openscap-utils >= 1.0.8")
set(CPACK_RPM_PACKAGE_PROVIDES "openscap-content")
set(CPACK_RPM_PACKAGE_DESCRIPTION "The %{name} project provides a guide for configuration of the
system from the final system's security point of view. The guidance is
specified in the Security Content Automation Protocol (SCAP) format and
constitutes a catalog of practical hardening advice, linked to government
requirements where applicable. The project bridges the gap between generalized
policy requirements and specific implementation guidelines. The system
administrator can use the oscap command-line tool from the openscap-utils
package to verify that the system conforms to provided guidelines.
The %{name} package also contains HTML formatted documents containing
hardening guidances that have been generated from XCCDF benchmarks.
")

# Change the default file name of the RPMs
# %{release} includes release number and dist type
# This only has effect with cmake v3.6 or higher
set(CPACK_RPM_FILE_NAME "%{name}-%{version}-%{release}.rpm")
# For older versions of cmake (e.g. v2.8) file name is defined like below
set(CPACK_PACKAGE_FILE_NAME "scap-security-guide-${SSG_VERSION}")
set(CPACK_PACKAGE_CHECKSUM SHA512)

set(CPACK_GENERATOR "RPM;DEB")
include(CPack)
