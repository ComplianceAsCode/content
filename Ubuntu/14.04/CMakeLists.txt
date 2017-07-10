# Sometimes our users will try to do: "cd Ubuntu/14.04; cmake ." That needs to error in a nice way.
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see BUILD.md for more details!")
endif()

set(PRODUCT "ubuntu1404")

ssg_build_product(${PRODUCT})

ssg_build_html_table_by_ref(${PRODUCT} "anssi")
