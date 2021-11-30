# Sometimes our users will try to do: "cd ol8; cmake ." That needs to error in a nice way.
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the Building ComplianceAsCode section in the Developer Guide!")
endif()

set(PRODUCT "ol8")

ssg_build_product(${PRODUCT})

ssg_build_html_ref_tables("${PRODUCT}" "table-${PRODUCT}-{ref_id}refs" "anssi;cui;nist;pcidss")

ssg_build_html_profile_table("table-${PRODUCT}-nistrefs-ospp" "${PRODUCT}" "ospp" "nist")
ssg_build_html_profile_table("table-${PRODUCT}-nistrefs-standard" "${PRODUCT}" "standard" "nist")
ssg_build_html_profile_table("table-${PRODUCT}-nistrefs-stig" "${PRODUCT}" "stig" "nist")

ssg_build_html_stig_tables(${PRODUCT})
ssg_build_html_stig_tables_per_profile( ${PRODUCT} "stig")
