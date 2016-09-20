ssg_build_product("rhel5")

if (SSG_CENTOS_DERIVATIVES_ENABLED)
    ssg_build_derivative_product("rhel5" "centos" "centos5")
endif()
if (SSG_SCIENTIFIC_LINUX_DERIVATIVES_ENABLED)
    ssg_build_derivative_product("rhel5" "sl" "sl5")
endif()
