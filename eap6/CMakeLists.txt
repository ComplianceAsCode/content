# Sometimes our users will try to do: "cd jboss_eap6; cmake ." That needs to error in a nice way.
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the developer_guide.adoc for more details!")
endif()

set(PRODUCT "eap6")
set(DISA_SRG_TYPE "application")

ssg_build_product(${PRODUCT})

ssg_build_html_nistrefs_table(${PRODUCT} "stig")

ssg_build_html_cce_table(${PRODUCT})

ssg_build_html_srgmap_tables(${PRODUCT} "stig" ${DISA_SRG_TYPE})

ssg_build_html_stig_tables(${PRODUCT} "stig")

