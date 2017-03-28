ssg_build_product("rhel-osp7")

if (SSG_CENTOS_DERIVATIVES_ENABLED)
    ssg_build_derivative_product("rhel-osp7" "centos" "centos-osp7")
endif()
if (SSG_SCIENTIFIC_LINUX_DERIVATIVES_ENABLED)
    ssg_build_derivative_product("rhel-osp7" "sl" "sl-osp7")
endif()
