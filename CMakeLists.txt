cmake_minimum_required(VERSION 2.8)
project(scap-security-guide NONE)

set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake")
include(SSGCommon)
# This is set to silence GNUInstallDirs warning about no language being used with cmake
set(CMAKE_INSTALL_LIBDIR "/nowhere")
include(GNUInstallDirs)
# FIXME: This is different than the old location /usr/share/xml/scap/ssg/content
set(SSG_CONTENT_INSTALL_DIR "${CMAKE_INSTALL_DATADIR}/scap/ssg")
set(SSG_GUIDE_INSTALL_DIR "${CMAKE_INSTALL_DOCDIR}/guides")

set(SSG_MAJOR_VERSION 0)
set(SSG_MINOR_VERSION 1)
set(SSG_PATCH_VERSION 31)
set(SSG_VERSION "${SSG_MAJOR_VERSION}.${SSG_MINOR_VERSION}.${SSG_PATCH_VERSION}")

option(SSG_CHROMIUM_CONTENT_ENABLED "If enabled, the Chromium SCAP content will be built" TRUE)
option(SSG_DEBIAN8_CONTENT_ENABLED "If enabled, the Debian/8 SCAP content will be built" TRUE)
option(SSG_FEDORA_CONTENT_ENABLED "If enabled, the Fedora SCAP content will be built" TRUE)
option(SSG_FIREFOX_CONTENT_ENABLED "If enabled, the Firefox SCAP content will be built" TRUE)
option(SSG_JBOSS_EAP5_CONTENT_ENABLED "If enabled, the JBoss/EAP/5 SCAP content will be built" TRUE)
option(SSG_JBOSS_FUSE6_CONTENT_ENABLED "If enabled, the JBoss/Fuse/6 SCAP content will be built" TRUE)
option(SSG_JRE_CONTENT_ENABLED "If enabled, the JRE SCAP content will be built" TRUE)
option(SSG_OPENSUSE_CONTENT_ENABLED "If enabled, the OpenSUSE SCAP content will be built" TRUE)
option(SSG_OSP7_CONTENT_ENABLED "If enabled, the RHEL-OSP/7 SCAP content will be built" TRUE)
option(SSG_RHEL5_CONTENT_ENABLED "If enabled, the RHEL5 SCAP content will be built" TRUE)
option(SSG_RHEL6_CONTENT_ENABLED "If enabled, the RHEL6 SCAP content will be built" TRUE)
option(SSG_RHEL7_CONTENT_ENABLED "If enabled, the RHEL7 SCAP content will be built" TRUE)
option(SSG_RHEV3_CONTENT_ENABLED "If enabled, the RHEVM3 SCAP content will be built" TRUE)
option(SSG_SUSE11_CONTENT_ENABLED "If enabled, the SUSE/11 SCAP content will be built" TRUE)
option(SSG_SUSE12_CONTENT_ENABLED "If enabled, the SUSE/12 SCAP content will be built" TRUE)
option(SSG_UBUNTU1404_CONTENT_ENABLED "If enabled, the Ubuntu/14.04 SCAP content will be built" TRUE)
option(SSG_UBUNTU1604_CONTENT_ENABLED "If enabled, the Ubuntu/16.04 SCAP content will be built" TRUE)
option(SSG_WRLINUX_CONTENT_ENABLED "If enabled, the WRLinux SCAP content will be built" TRUE)
option(SSG_WEBMIN_CONTENT_ENABLED "If enabled, the Webmin SCAP content will be built" TRUE)

option(SSG_CENTOS_DERIVATIVES_ENABLED "If enabled, CentOS derivative content will be built from the RHEL content" TRUE)
option(SSG_SCIENTIFIC_LINUX_DERIVATIVES_ENABLED "If enabled, Scientific Linux derivative content will be built from the RHEL content" TRUE)

message("SCAP Security Guide ${SSG_VERSION}")
message("")

# TODO: refactor oscap detection into a find module
find_program(OSCAP_EXECUTABLE NAMES oscap)
if (NOT OSCAP_EXECUTABLE)
    message(FATAL_ERROR "The oscap tool is required!")
endif()
# OSCAP_SVG_SUPPORT == 0 means SVG is supported
execute_process(
    COMMAND ${SSG_SHARED_UTILS}/oscap-svg-support.py
    RESULT_VARIABLE OSCAP_SVG_SUPPORT
)
# TODO, 0 means OVAL 5.11 is supported
set(OSCAP_OVAL_511_SUPPORT 0)

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

message("Tools:")
message("oscap: ${OSCAP_EXECUTABLE}")
message("xsltproc: ${XSLTPROC_EXECUTABLE}")
message("xmllint: ${XMLLINT_EXECUTABLE}")
message("xmlwf: ${XMLWF_EXECUTABLE}")
message("sed: ${SED_EXECUTABLE}")
message(" ")

add_custom_target(validate)

if (SSG_CHROMIUM_CONTENT_ENABLED)
    add_subdirectory("Chromium")
endif()
if (SSG_DEBIAN8_CONTENT_ENABLED)
    add_subdirectory("Debian/8")
endif()
if (SSG_FEDORA_CONTENT_ENABLED)
    add_subdirectory("Fedora")
endif()
if (SSG_FIREFOX_CONTENT_ENABLED)
    add_subdirectory("Firefox")
endif()
if (SSG_JBOSS_EAP5_CONTENT_ENABLED)
    #add_subdirectory("JBoss/EAP/5")
endif()
if (SSG_JBOSS_FUSE6_CONTENT_ENABLED)
    add_subdirectory("JBoss/Fuse/6")
endif()
if (SSG_JRE_CONTENT_ENABLED)
    add_subdirectory("JRE")
endif()
if (SSG_OPENSUSE_CONTENT_ENABLED)
    #add_subdirectory("OpenSUSE")
endif()
if (SSG_OSP7_CONTENT_ENABLED)
    #add_subdirectory("OpenStack/RHEL-OSP/7/")
endif()
if (SSG_RHEL5_CONTENT_ENABLED)
    add_subdirectory("RHEL/5")
endif()
if (SSG_RHEL6_CONTENT_ENABLED)
    add_subdirectory("RHEL/6")
endif()
if (SSG_RHEL7_CONTENT_ENABLED)
    add_subdirectory("RHEL/7")
endif()
if (SSG_RHEV3_CONTENT_ENABLED)
    #add_subdirectory("RHEVM3")
endif()
if (SSG_SUSE11_CONTENT_ENABLED)
    #add_subdirectory("SUSE/11")
endif()
if (SSG_SUSE12_CONTENT_ENABLED)
    #add_subdirectory("SUSE/12")
endif()
if (SSG_UBUNTU1404_CONTENT_ENABLED)
    add_subdirectory("Ubuntu/14.04")
endif()
if (SSG_UBUNTU1604_CONTENT_ENABLED)
    add_subdirectory("Ubuntu/16.04")
endif()

if (SSG_WRLINUX_CONTENT_ENABLED)
    add_subdirectory("WRLinux")
endif()
if (SSG_WEBMIN_CONTENT_ENABLED)
    #add_subdirectory("Webmin")
endif()

install(FILES "${CMAKE_SOURCE_DIR}/LICENSE"
    DESTINATION ${CMAKE_INSTALL_DOCDIR})
install(FILES "${CMAKE_SOURCE_DIR}/README.md"
    DESTINATION ${CMAKE_INSTALL_DOCDIR})
install(FILES "${CMAKE_SOURCE_DIR}/Contributors.md"
    DESTINATION ${CMAKE_INSTALL_DOCDIR})

install(FILES "docs/scap-security-guide.8"
    DESTINATION "${CMAKE_INSTALL_MANDIR}/man8")

if (UNIX)
    install(CODE "
        file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATADIR}/xml/scap/ssg/)
    ")
    install(CODE "
        execute_process(COMMAND ln -sf ../../../scap/ssg ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATADIR}/xml/scap/ssg/content)
    ")
endif()

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
include(CPack)
