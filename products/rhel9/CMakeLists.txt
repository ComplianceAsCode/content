# Sometimes our users will try to do: "cd rhel9; cmake ." That needs to error in a nice way.
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the Building ComplianceAsCode section in the Developer Guide!")
endif()

set(PRODUCT "rhel9")

ssg_build_product(${PRODUCT})

ssg_build_html_cce_table(${PRODUCT})

ssg_build_html_srgmap_tables(${PRODUCT})

# ssg_build_html_stig_tables(${PRODUCT} "stig")

#ssg_build_html_stig_tables(${PRODUCT} "ospp")

if (SSG_CENTOS_DERIVATIVES_ENABLED)
    ssg_build_derivative_product(${PRODUCT} "centos" "cs9")
endif()
