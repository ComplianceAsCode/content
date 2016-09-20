ssg_build_product("rhel6")

if (SSG_CENTOS_DERIVATIVES_ENABLED)
    ssg_build_derivative_product("rhel6" "centos" "centos6")
endif()
if (SSG_SCIENTIFIC_LINUX_DERIVATIVES_ENABLED)
    ssg_build_derivative_product("rhel6" "sl" "sl6")
endif()
