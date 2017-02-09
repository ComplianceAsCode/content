ssg_build_product("rhel7")
ssg_build_html_table_by_ref("rhel7" "nist")

if (SSG_CENTOS_DERIVATIVES_ENABLED)
    ssg_build_derivative_product("rhel7" "centos" "centos7")
endif()
if (SSG_SCIENTIFIC_LINUX_DERIVATIVES_ENABLED)
    ssg_build_derivative_product("rhel7" "sl" "sl7")
endif()
