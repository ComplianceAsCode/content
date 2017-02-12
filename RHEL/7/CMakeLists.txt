ssg_build_product("rhel7")

ssg_build_html_table_by_ref("rhel7" "nist")
ssg_build_html_table_by_ref("rhel7" "cis")
ssg_build_html_table_by_ref("rhel7" "pcidss")

ssg_build_html_nistrefs_table("rhel7" "common")
ssg_build_html_nistrefs_table("rhel7" "ospp-rhel7-server")
ssg_build_html_nistrefs_table("rhel7" "C2S")

ssg_build_html_cce_table("rhel7")

ssg_build_html_srgmap_tables("rhel7")

ssg_build_html_stig_tables("rhel7" "stig-rhel7-server")

if (SSG_CENTOS_DERIVATIVES_ENABLED)
    ssg_build_derivative_product("rhel7" "centos" "centos7")
endif()
if (SSG_SCIENTIFIC_LINUX_DERIVATIVES_ENABLED)
    ssg_build_derivative_product("rhel7" "sl" "sl7")
endif()
