# Sometimes our users will try to do: "cd al2023; cmake ." That needs to error in a nice way.
if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the Building ComplianceAsCode section in the Developer Guide!")
endif()

set(PRODUCT "al2023")

ssg_build_product(${PRODUCT})

ssg_build_html_cce_table(${PRODUCT})

ssg_build_html_ref_tables("${PRODUCT}" "table-${PRODUCT}-{ref_id}refs" "cis;nist")

ssg_build_html_profile_table("table-${PRODUCT}-nistrefs-stig" "${PRODUCT}" "stig" "nist")

ssg_build_html_srgmap_tables(${PRODUCT})

ssg_build_html_stig_tables(${PRODUCT})
ssg_build_html_stig_tables_per_profile(${PRODUCT} "stig")
