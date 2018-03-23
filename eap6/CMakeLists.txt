# Sometimes our users will try to do: "cd jboss_eap6; cmake ." That needs to error in a nice way.
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see BUILD.md for more details!")
endif()

set(PRODUCT "eap6")
set(DISA_SRG_VERSION "v2r1")
set(DISA_STIG_VERSION "v1r2")
set(DISA_SRG_TYPE "application")

ssg_build_product(${PRODUCT})

ssg_build_html_nistrefs_table(${PRODUCT} "stig-${PRODUCT}-disa")

ssg_build_html_cce_table(${PRODUCT})

ssg_build_html_srgmap_tables(${PRODUCT} ${DISA_SRG_TYPE} ${DISA_SRG_VERSION})

ssg_build_html_stig_tables(${PRODUCT} "stig-${PRODUCT}-disa" ${DISA_STIG_VERSION})

