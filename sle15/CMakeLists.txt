# Sometimes our users will try to do: "cd sle15; cmake ." That needs to error in a nice way.
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the Building ComplianceAsCode section in the Developer Guide!")
endif()

set(PRODUCT "sle15")
ssg_build_product("sle15")

ssg_build_html_nistrefs_table(${PRODUCT} "standard")

ssg_build_html_cce_table(${PRODUCT})
