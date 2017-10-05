# Sometimes our users will try to do: "cd rhel6; cmake ." That needs to error in a nice way.
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see BUILD.md for more details!")
endif()

set(PRODUCT "rhel6")
set(DISA_SRG_VERSION "v1r4")
set(DISA_STIG_VERSION "v1r16")
set(DISA_SRG_TYPE "os")

ssg_build_product(${PRODUCT})

ssg_build_html_table_by_ref(${PRODUCT} "nist")
ssg_build_html_table_by_ref(${PRODUCT} "cis")
ssg_build_html_table_by_ref(${PRODUCT} "pcidss")

ssg_build_html_nistrefs_table(${PRODUCT} "common")
ssg_build_html_nistrefs_table(${PRODUCT} "C2S")

ssg_build_html_cce_table(${PRODUCT})

ssg_build_html_srgmap_tables(${PRODUCT} ${DISA_SRG_TYPE} ${DISA_SRG_VERSION})

ssg_build_html_stig_tables(${PRODUCT} "stig-${PRODUCT}-server-upstream" ${DISA_STIG_VERSION})

if (SSG_CENTOS_DERIVATIVES_ENABLED)
    ssg_build_derivative_product(${PRODUCT} "centos" "centos6")
endif()
if (SSG_SCIENTIFIC_LINUX_DERIVATIVES_ENABLED)
    ssg_build_derivative_product(${PRODUCT} "sl" "sl6")
endif()
