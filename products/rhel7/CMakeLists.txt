# Sometimes our users will try to do: "cd rhel7; cmake ." That needs to error in a nice way.
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the Building ComplianceAsCode section in the Developer Guide!")
endif()

set(PRODUCT "rhel7")

ssg_build_product(${PRODUCT})

ssg_build_html_ref_tables("${PRODUCT}" "table-${PRODUCT}-{ref_id}refs" "anssi;cis;cui;nist;ospp;pcidss")

ssg_build_html_profile_table("table-${PRODUCT}-nistrefs-C2S" "${PRODUCT}" "C2S" "nist")
ssg_build_html_profile_table("table-${PRODUCT}-nistrefs-ospp" "${PRODUCT}" "ospp" "nist")
ssg_build_html_profile_table("table-${PRODUCT}-nistrefs-standard" "${PRODUCT}" "standard" "nist")
ssg_build_html_profile_table("table-${PRODUCT}-nistrefs-stig" "${PRODUCT}" "stig" "nist")

ssg_build_html_profile_table("table-${PRODUCT}-anssirefs-nt28_minimal" "${PRODUCT}" "anssi_nt28_minimal" "anssi")
ssg_build_html_profile_table("table-${PRODUCT}-anssirefs-nt28_enhanced" "${PRODUCT}" "anssi_nt28_enhanced" "anssi")
ssg_build_html_profile_table("table-${PRODUCT}-anssirefs-nt28_intermediary" "${PRODUCT}" "anssi_nt28_intermediary" "anssi")
ssg_build_html_profile_table("table-${PRODUCT}-anssirefs-nt28_high" "${PRODUCT}" "anssi_nt28_high" "anssi")

ssg_build_html_cce_table(${PRODUCT})

ssg_build_html_srgmap_tables(${PRODUCT})

ssg_build_html_stig_tables(${PRODUCT})
ssg_build_html_stig_tables_per_profile( ${PRODUCT} "stig")
ssg_build_html_stig_tables_per_profile( ${PRODUCT} "stig_gui")

if (SSG_CENTOS_DERIVATIVES_ENABLED)
    ssg_build_derivative_product(${PRODUCT} "centos" "centos7")
endif()
if (SSG_SCIENTIFIC_LINUX_DERIVATIVES_ENABLED)
    ssg_build_derivative_product(${PRODUCT} "sl" "sl7")
endif()
