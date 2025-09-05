# Sometimes our users will try to do: "cd ol8; cmake ." That needs to error in a nice way.
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the Building ComplianceAsCode section in the Developer Guide!")
endif()

set(PRODUCT "ol8")

ssg_build_product(${PRODUCT})

ssg_build_html_table_by_ref(${PRODUCT} "nist")
ssg_build_html_table_by_ref(${PRODUCT} "cui")
ssg_build_html_table_by_ref(${PRODUCT} "pcidss")
ssg_build_html_table_by_ref(${PRODUCT} "anssi")

ssg_build_html_nistrefs_table(${PRODUCT} "standard")
ssg_build_html_nistrefs_table(${PRODUCT} "ospp")
