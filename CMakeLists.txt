cmake_minimum_required(VERSION 2.8)
project(scap-security-guide NONE)

set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake")
include(SSGCommon)

set(SSG_MAJOR_VERSION 0)
set(SSG_MINOR_VERSION 1)
set(SSG_PATCH_VERSION 31)
set(SSG_VERSION "${SSG_MAJOR_VERSION}.${SSG_MINOR_VERSION}.${SSG_PATCH_VERSION}")

option(SSG_FEDORA_CONTENT_ENABLED "If enabled, the Fedora SCAP content will be built" TRUE)

message("SCAP Security Guide ${SSG_VERSION}")
message("")

find_program(OSCAP_EXECUTABLE NAMES oscap)
if (NOT OSCAP_EXECUTABLE)
    message(FATAL_ERROR "The oscap tool is required!")
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

message("Tools:")
message("oscap: ${OSCAP_EXECUTABLE}")
message("xsltproc: ${XSLTPROC_EXECUTABLE}")
message("xmllint: ${XMLLINT_EXECUTABLE}")
message("xmlwf: ${XMLWF_EXECUTABLE}")
message(" ")

if (SSG_FEDORA_CONTENT_ENABLED)
    add_subdirectory("Fedora")
endif()
