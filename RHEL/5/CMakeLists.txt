# Sometimes our users will try to do: "cd RHEL/5; cmake ." That needs to error in a nice way.
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see BUILD.md for more details!")
endif()

ssg_build_product("rhel5")

if (SSG_CENTOS_DERIVATIVES_ENABLED)
    ssg_build_derivative_product("rhel5" "centos" "centos5")
endif()
if (SSG_SCIENTIFIC_LINUX_DERIVATIVES_ENABLED)
    ssg_build_derivative_product("rhel5" "sl" "sl5")
endif()
