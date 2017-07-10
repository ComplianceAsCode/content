cmake_minimum_required(VERSION 2.8)
project(scap-security-guide NONE)

set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake")
# This is set to silence GNUInstallDirs warning about no language being used with cmake
set(CMAKE_INSTALL_LIBDIR "/nowhere")
include(GNUInstallDirs)
set(SSG_CONTENT_INSTALL_DIR "${CMAKE_INSTALL_DATADIR}/xml/scap/ssg/content")
set(SSG_GUIDE_INSTALL_DIR "${CMAKE_INSTALL_DOCDIR}/guides")
set(SSG_TABLE_INSTALL_DIR "${CMAKE_INSTALL_DOCDIR}/tables")
set(SSG_ANSIBLE_ROLE_INSTALL_DIR "${CMAKE_INSTALL_DATADIR}/scap-security-guide/ansible")
set(SSG_BASH_ROLE_INSTALL_DIR "${CMAKE_INSTALL_DATADIR}/scap-security-guide/bash")
set(SSG_KICKSTART_INSTALL_DIR "${CMAKE_INSTALL_DATADIR}/scap-security-guide/kickstart")

set(SSG_MAJOR_VERSION 0)
set(SSG_MINOR_VERSION 1)
set(SSG_PATCH_VERSION 34)
set(SSG_VERSION "${SSG_MAJOR_VERSION}.${SSG_MINOR_VERSION}.${SSG_PATCH_VERSION}")

set(SSG_VENDOR "ssgproject" CACHE STRING "Specify the XCCDF 1.2 vendor string.")

option(SSG_OVAL_511_ENABLED "If enabled, OVAL 5.11 and OVAL 5.10 checks will be used in the final content. Otherwise only 5.10 checks will be used." TRUE)
option(SSG_SVG_IN_XCCDF_ENABLED "If enabled, the built XCCDFs will include the SVG SCAP Security Guide logo." TRUE)

option(SSG_PRODUCT_CHROMIUM "If enabled, the Chromium SCAP content will be built" TRUE)
option(SSG_PRODUCT_DEBIAN8 "If enabled, the Debian/8 SCAP content will be built" TRUE)
option(SSG_PRODUCT_DEBIAN9 "If enabled, the Debian/9 SCAP content will be built" TRUE)
option(SSG_PRODUCT_FEDORA "If enabled, the Fedora SCAP content will be built" TRUE)
option(SSG_PRODUCT_FIREFOX "If enabled, the Firefox SCAP content will be built" TRUE)
option(SSG_PRODUCT_JBOSS_EAP5 "If enabled, the JBoss/EAP/5 SCAP content will be built" TRUE)
option(SSG_PRODUCT_JBOSS_EAP6 "If enabled, the JBoss/EAP/6 SCAP content will be built" TRUE)
option(SSG_PRODUCT_JBOSS_FUSE6 "If enabled, the JBoss/Fuse/6 SCAP content will be built" TRUE)
option(SSG_PRODUCT_JRE "If enabled, the JRE SCAP content will be built" TRUE)
option(SSG_PRODUCT_OPENSUSE "If enabled, the OpenSUSE SCAP content will be built" TRUE)
option(SSG_PRODUCT_OSP7 "If enabled, the RHEL-OSP/7 SCAP content will be built" TRUE)
option(SSG_PRODUCT_RHEL5 "If enabled, the RHEL5 SCAP content will be built" TRUE)
option(SSG_PRODUCT_RHEL6 "If enabled, the RHEL6 SCAP content will be built" TRUE)
option(SSG_PRODUCT_RHEL7 "If enabled, the RHEL7 SCAP content will be built" TRUE)
option(SSG_PRODUCT_RHEV3 "If enabled, the RHEVM3 SCAP content will be built" TRUE)
option(SSG_PRODUCT_SUSE11 "If enabled, the SUSE/11 SCAP content will be built" TRUE)
option(SSG_PRODUCT_SUSE12 "If enabled, the SUSE/12 SCAP content will be built" TRUE)
option(SSG_PRODUCT_UBUNTU1404 "If enabled, the Ubuntu/14.04 SCAP content will be built" TRUE)
option(SSG_PRODUCT_UBUNTU1604 "If enabled, the Ubuntu/16.04 SCAP content will be built" TRUE)
option(SSG_PRODUCT_WRLINUX "If enabled, the WRLinux SCAP content will be built" TRUE)
option(SSG_PRODUCT_WEBMIN "If enabled, the Webmin SCAP content will be built" TRUE)

option(SSG_CENTOS_DERIVATIVES_ENABLED "If enabled, CentOS derivative content will be built from the RHEL content" TRUE)
option(SSG_SCIENTIFIC_LINUX_DERIVATIVES_ENABLED "If enabled, Scientific Linux derivative content will be built from the RHEL content" TRUE)

set(SSG_SHARED "${CMAKE_SOURCE_DIR}/shared")
set(SSG_SHARED_REFS "${SSG_SHARED}/references")
set(SSG_SHARED_TRANSFORMS "${SSG_SHARED}/transforms")
set(SSG_SHARED_UTILS "${SSG_SHARED}/utils")

message("SCAP Security Guide ${SSG_VERSION}")
message("(see ${CMAKE_SOURCE_DIR}/BUILD.md for build instructions)")
message("")

# Strictly speaking in-source will work but will be very messy, let's
# discourage our users from using them
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR "In-source builds are not supported! Please use out of source builds:\n"
       "$ cd scap-security-guide\n"
       "$ rm CMakeCache.txt\n"
       "$ cd build\n"
       "$ cmake ../\n"
       "$ make -j4"
    )
endif()

# TODO: refactor oscap detection into a find module
find_program(OSCAP_EXECUTABLE NAMES oscap)
if (NOT OSCAP_EXECUTABLE)
    message(FATAL_ERROR "The oscap tool is required!")
endif()

execute_process(
    COMMAND "${OSCAP_EXECUTABLE}" --v
    OUTPUT_VARIABLE OSCAP_V_OUTPUT
)
if (SSG_OVAL_511_ENABLED AND NOT "${OSCAP_V_OUTPUT}" MATCHES "OVAL Version: 5.11")
    set(SSG_OVAL_511_ENABLED OFF CACHE BOOL "OVAL 5.11 disabled because your version of OpenSCAP doesn't support it" FORCE)
    message("Your version of OpenSCAP does not support OVAL 5.11, disabling OVAL 5.11 for the SSG build.")
endif()

execute_process(
    COMMAND "${SSG_SHARED_UTILS}/oscap-svg-support.py" "${OSCAP_EXECUTABLE}"
    RESULT_VARIABLE OSCAP_SVG_SUPPORT_RESULT
)
# OSCAP_SVG_SUPPORT_RESULT == 0 means SVG is supported
if (SSG_SVG_IN_XCCDF_ENABLED AND NOT OSCAP_SVG_SUPPORT_RESULT EQUAL 0)
    set(SSG_SVG_IN_XCCDF_ENABLED OFF CACHE BOOL "SVG in XCCDF disabled because your version OpenSCAP doesn't support it" FORCE)
    message("Your version of OpenSCAP does not support having the SVG logo in the XCCDF, disabling SVG logo.")
endif()

find_program(XSLTPROC_EXECUTABLE NAMES xsltproc)
if (NOT XSLTPROC_EXECUTABLE)
    message(FATAL_ERROR "xsltproc is required!")
endif()

find_program(XMLLINT_EXECUTABLE NAMES xmllint)
if (NOT XMLLINT_EXECUTABLE)
    message(FATAL_ERROR "xmllint is required!")
endif()

find_program(XMLWF_EXECUTABLE NAMES xmlwf)
if (NOT XMLWF_EXECUTABLE)
    message(FATAL_ERROR "xmlwf is required!")
endif()

find_program(SED_EXECUTABLE NAMES sed)
if (NOT SED_EXECUTABLE)
    message(FATAL_ERROR "sed is required!")
endif()

find_program(SHELLCHECK_EXECUTABLE NAMES shellcheck)

configure_file("${CMAKE_SOURCE_DIR}/oval.config.in" "${CMAKE_BINARY_DIR}/oval.config")

message("Tools:")
message("oscap: ${OSCAP_EXECUTABLE}")
message("xsltproc: ${XSLTPROC_EXECUTABLE}")
message("xmllint: ${XMLLINT_EXECUTABLE}")
message("xmlwf: ${XMLWF_EXECUTABLE}")
message("sed: ${SED_EXECUTABLE}")
message("shellcheck (optional): ${SHELLCHECK_EXECUTABLE}")
message(" ")

message("Build options:")
message("SSG vendor string: ${SSG_VENDOR}")
message("OVAL 5.11: ${SSG_OVAL_511_ENABLED}")
message("SVG logo in XCCDFs: ${SSG_SVG_IN_XCCDF_ENABLED}")
message(" ")

message("Products:")
message("Chromium: ${SSG_PRODUCT_CHROMIUM}")
message("Debian 8: ${SSG_PRODUCT_DEBIAN8}")
message("Debian 9: ${SSG_PRODUCT_DEBIAN9}")
message("Fedora: ${SSG_PRODUCT_FEDORA}")
message("Firefox: ${SSG_PRODUCT_FIREFOX}")
message("JBoss EAP 5: ${SSG_PRODUCT_JBOSS_EAP5} (broken, disabled)")
message("JBoss EAP 6: ${SSG_PRODUCT_JBOSS_EAP6}")
message("JBoss Fuse 6: ${SSG_PRODUCT_JBOSS_FUSE6}")
message("JRE: ${SSG_PRODUCT_JRE}")
message("OpenSUSE: ${SSG_PRODUCT_OPENSUSE}")
message("RHEL-OSP7: ${SSG_PRODUCT_OSP7}")
message("RHEL 5: ${SSG_PRODUCT_RHEL5}")
message("RHEL 6: ${SSG_PRODUCT_RHEL6}")
message("RHEL 7: ${SSG_PRODUCT_RHEL7}")
message("RHEVM 3: ${SSG_PRODUCT_RHEV3} (broken, disabled)")
message("SUSE 11: ${SSG_PRODUCT_SUSE11}")
message("SUSE 12: ${SSG_PRODUCT_SUSE12}")
message("Ubuntu 14.04: ${SSG_PRODUCT_UBUNTU1404}")
message("Ubuntu 16.04: ${SSG_PRODUCT_UBUNTU1604}")
message("WRLinux: ${SSG_PRODUCT_WRLINUX}")
message("Webmin: ${SSG_PRODUCT_WEBMIN}")

message(" ")

include(SSGCommon)

# Targets 'validate', 'stats', 'profile-stats' and 'zipfile' need to be added
# before any product because they will receive dependencies from products added

add_custom_target(validate)
add_custom_target(stats)
add_custom_target(profile-stats)

ssg_build_bash_remediation_functions()

# ZIP only contains source datastreams and kickstarts, people who
# want sources to build from should get the tarball instead.
if(SSG_OVAL_511_ENABLED)
    ssg_build_zipfile("scap-security-guide-${SSG_VERSION}")
else()
    ssg_build_zipfile("scap-security-guide-${SSG_VERSION}-oval-5.10")
endif()

if (SSG_PRODUCT_CHROMIUM)
    add_subdirectory("Chromium")
endif()
if (SSG_PRODUCT_DEBIAN8)
    add_subdirectory("Debian/8")
endif()
if (SSG_PRODUCT_DEBIAN9)
    add_subdirectory("Debian/9")
endif()
if (SSG_PRODUCT_FEDORA)
    add_subdirectory("Fedora")
endif()
if (SSG_PRODUCT_FIREFOX)
    add_subdirectory("Firefox")
endif()
if (SSG_PRODUCT_JBOSS_EAP5)
    #add_subdirectory("JBoss/EAP/5")
endif()
if (SSG_PRODUCT_JBOSS_EAP6)
    add_subdirectory("JBoss/EAP/6")
endif()
if (SSG_PRODUCT_JBOSS_FUSE6)
    add_subdirectory("JBoss/Fuse/6")
endif()
if (SSG_PRODUCT_JRE)
    add_subdirectory("JRE")
endif()
if (SSG_PRODUCT_OPENSUSE)
    add_subdirectory("OpenSUSE")
endif()
if (SSG_PRODUCT_OSP7)
    add_subdirectory("OpenStack/RHEL-OSP/7/")
endif()
if (SSG_PRODUCT_RHEL5)
    add_subdirectory("RHEL/5")
endif()
if (SSG_PRODUCT_RHEL6)
    add_subdirectory("RHEL/6")
endif()
if (SSG_PRODUCT_RHEL7)
    add_subdirectory("RHEL/7")
endif()
if (SSG_PRODUCT_RHEV3)
    #add_subdirectory("RHEVM3")
endif()
if (SSG_PRODUCT_SUSE11)
    add_subdirectory("SUSE/11")
endif()
if (SSG_PRODUCT_SUSE12)
    add_subdirectory("SUSE/12")
endif()
if (SSG_PRODUCT_UBUNTU1404)
    add_subdirectory("Ubuntu/14.04")
endif()
if (SSG_PRODUCT_UBUNTU1604)
    add_subdirectory("Ubuntu/16.04")
endif()

if (SSG_PRODUCT_WRLINUX)
    add_subdirectory("WRLinux")
endif()
if (SSG_PRODUCT_WEBMIN)
    add_subdirectory("Webmin")
endif()

install(FILES "${CMAKE_SOURCE_DIR}/LICENSE"
    DESTINATION ${CMAKE_INSTALL_DOCDIR})
install(FILES "${CMAKE_SOURCE_DIR}/README.md"
    DESTINATION ${CMAKE_INSTALL_DOCDIR})
install(FILES "${CMAKE_SOURCE_DIR}/Contributors.md"
    DESTINATION ${CMAKE_INSTALL_DOCDIR})

install(FILES "docs/scap-security-guide.8"
    DESTINATION "${CMAKE_INSTALL_MANDIR}/man8")

# We use CPack to generate the tarball with all sources and
# packages for testing

# only CPack should follow
set(CPACK_CMAKE_GENERATOR "Unix Makefiles")
set(CPACK_SOURCE_GENERATOR "TBZ2")
set(CPACK_SOURCE_PACKAGE_FILE_NAME "scap-security-guide-${SSG_VERSION}" CACHE INTERNAL "tarball basename")
set(CPACK_SOURCE_IGNORE_FILES
"\\\\.git.*"

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
set(CPACK_RPM_PACKAGE_LICENSE "Public Domain")
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

set(CPACK_GENERATOR "RPM;DEB")
include(CPack)
