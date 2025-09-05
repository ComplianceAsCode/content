# Sometimes our users will try to do: "cd rhel8; cmake ." That needs to error in a nice way.
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the Building ComplianceAsCode section in the Developer Guide!")
endif()

set(PRODUCT "rhel8")

ssg_build_product(${PRODUCT})

ssg_build_html_ref_tables("${PRODUCT}" "table-${PRODUCT}-{ref_id}refs" "anssi;cis;cui;nist;pcidss")

ssg_build_html_profile_table("table-${PRODUCT}-nistrefs-ospp" "${PRODUCT}" "ospp" "nist")
ssg_build_html_profile_table("table-${PRODUCT}-nistrefs-standard" "${PRODUCT}" "standard" "nist")
ssg_build_html_profile_table("table-${PRODUCT}-nistrefs-stig" "${PRODUCT}" "stig" "nist")

ssg_build_html_profile_table("table-${PRODUCT}-anssirefs-bp28_minimal" "${PRODUCT}" "anssi_bp28_minimal" "anssi")
ssg_build_html_profile_table("table-${PRODUCT}-anssirefs-bp28_enhanced" "${PRODUCT}" "anssi_bp28_enhanced" "anssi")
ssg_build_html_profile_table("table-${PRODUCT}-anssirefs-bp28_intermediary" "${PRODUCT}" "anssi_bp28_intermediary" "anssi")
ssg_build_html_profile_table("table-${PRODUCT}-anssirefs-bp28_high" "${PRODUCT}" "anssi_bp28_high" "anssi")

ssg_build_html_cce_table(${PRODUCT})

ssg_build_html_srgmap_tables(${PRODUCT})

ssg_build_html_stig_tables(${PRODUCT})
ssg_build_html_stig_tables_per_profile( ${PRODUCT} "stig")
ssg_build_html_stig_tables_per_profile( ${PRODUCT} "stig_gui")

#ssg_build_html_stig_tables(${PRODUCT} "ospp")

if (SSG_CENTOS_DERIVATIVES_ENABLED)
    ssg_build_derivative_product(${PRODUCT} "centos" "centos8")
endif()
