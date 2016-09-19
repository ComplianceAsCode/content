cmake_minimum_required(VERSION 2.8)
project(scap-security-guide NONE)

set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake")
include(SSGCommon)

set(SSG_MAJOR_VERSION 0)
set(SSG_MINOR_VERSION 1)
set(SSG_PATCH_VERSION 31)
set(SSG_VERSION "${SSG_MAJOR_VERSION}.${SSG_MINOR_VERSION}.${SSG_PATCH_VERSION}")

option(SSG_CHROMIUM_CONTENT_ENABLED "If enabled, the Chromium SCAP content will be built" TRUE)
option(SSG_FEDORA_CONTENT_ENABLED "If enabled, the Fedora SCAP content will be built" TRUE)
option(SSG_RHEL5_CONTENT_ENABLED "If enabled, the RHEL6 SCAP content will be built" TRUE)
option(SSG_RHEL6_CONTENT_ENABLED "If enabled, the RHEL6 SCAP content will be built" TRUE)
option(SSG_RHEL7_CONTENT_ENABLED "If enabled, the RHEL7 SCAP content will be built" TRUE)
option(SSG_WRLINUX_CONTENT_ENABLED "If enabled, the WRLinux SCAP content will be built" TRUE)

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

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/contributors.xml
    COMMAND echo "<text>" > ${CMAKE_BINARY_DIR}/contributors.xml
    COMMAND ${SED_EXECUTABLE} -n -e "s/\\* \\(.*\\)/<contributor>\\1<\\/contributor>/p" ${CMAKE_SOURCE_DIR}/Contributors.md >> ${CMAKE_BINARY_DIR}/contributors.xml
    COMMAND echo "</text>" >> ${CMAKE_BINARY_DIR}/contributors.xml
    VERBATIM
    MAIN_DEPENDENCY ${CMAKE_SOURCE_DIR}/Contributors.md
)
add_custom_target(validate)

if (SSG_CHROMIUM_CONTENT_ENABLED)
    add_subdirectory("Chromium")
endif()
if (SSG_FEDORA_CONTENT_ENABLED)
    add_subdirectory("Fedora")
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
if (SSG_WRLINUX_CONTENT_ENABLED)
    add_subdirectory("WRLinux")
endif()
