# Sometimes our users will try to do: "cd rhel8; cmake ." That needs to error in a nice way.
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the Building ComplianceAsCode section in the Developer Guide!")
endif()

set(PRODUCT "rhel8")
set(DISA_SRG_TYPE "os")

ssg_build_product(${PRODUCT})

ssg_build_html_table_by_ref(${PRODUCT} "nist")
set(NIST_REF_FORMAT "'.*-(\\\\d+)(?:\\\\((\\\\d+)\\\\))?'")
ssg_build_html_ref_table("new-table-${PRODUCT}-nist" "${PRODUCT}" "nist" "${NIST_REF_FORMAT}")
ssg_build_html_table_by_ref(${PRODUCT} "cui")
set(CUI_REF_FORMAT "'(\\\\d+)(?:\\\\.(\\\\w+)(?:\\\\.(\\\\w+)(?:\\\\.(\\\\w+))?)?)?'")
ssg_build_html_ref_table("new-table-${PRODUCT}-cui" "${PRODUCT}" "cui" "${CUI_REF_FORMAT}")
ssg_build_html_table_by_ref(${PRODUCT} "cis")
set(CIS_REF_FORMAT "'(\\\\d+)\\\\.(\\\\d+)(?:\\\\.(\\\\w+)(?:\\\\.(\\\\w+)(?:\\\\.(\\\\w+))?)?)?'")
ssg_build_html_ref_table("new-table-${PRODUCT}-cis" "${PRODUCT}" "cis" "${CIS_REF_FORMAT}")
ssg_build_html_table_by_ref(${PRODUCT} "pcidss")
set(PCIDSS_REF_FORMAT "'Req-(\\\\d+)(?:\\\\.(\\\\w+)(?:\\\\.(\\\\w+)(?:\\\\.(\\\\w+))?)?)?'")
ssg_build_html_ref_table("new-table-${PRODUCT}-pcidss" "${PRODUCT}" "pcidss" "${PCIDSS_REF_FORMAT}")
ssg_build_html_table_by_ref(${PRODUCT} "anssi")

ssg_build_html_nistrefs_table(${PRODUCT} "standard")
ssg_build_html_nistrefs_table(${PRODUCT} "ospp")
ssg_build_html_nistrefs_table(${PRODUCT} "stig")

set(ANSSI_REF_FORMAT "'BP28\\\\(R(\\\\d+)\\\\)'")
ssg_build_html_profile_table("new-table-${PRODUCT}-anssirefs-bp28_minimal" "${PRODUCT}" "anssi_bp28_minimal" "anssi" "${ANSSI_REF_FORMAT}")
ssg_build_html_profile_table("new-table-${PRODUCT}-anssirefs-bp28_enhanced" "${PRODUCT}" "anssi_bp28_enhanced" "anssi" "${ANSSI_REF_FORMAT}")
ssg_build_html_profile_table("new-table-${PRODUCT}-anssirefs-bp28_intermediary" "${PRODUCT}" "anssi_bp28_intermediary" "anssi" "${ANSSI_REF_FORMAT}")
ssg_build_html_profile_table("new-table-${PRODUCT}-anssirefs-bp28_high" "${PRODUCT}" "anssi_bp28_high" "anssi" "${ANSSI_REF_FORMAT}")

ssg_build_html_anssirefs_table(${PRODUCT} "bp28_minimal")
ssg_build_html_anssirefs_table(${PRODUCT} "bp28_intermediary")
ssg_build_html_anssirefs_table(${PRODUCT} "bp28_enhanced")
ssg_build_html_anssirefs_table(${PRODUCT} "bp28_high")

ssg_build_html_cce_table(${PRODUCT})

ssg_build_html_srgmap_tables(${PRODUCT} "stig" ${DISA_SRG_TYPE})

ssg_build_html_stig_tables(${PRODUCT})
ssg_build_html_stig_tables_per_profile( ${PRODUCT} "stig")
ssg_build_html_stig_tables_per_profile( ${PRODUCT} "stig_gui")

#ssg_build_html_stig_tables(${PRODUCT} "ospp")

if (SSG_CENTOS_DERIVATIVES_ENABLED)
    ssg_build_derivative_product(${PRODUCT} "centos" "centos8")
endif()
