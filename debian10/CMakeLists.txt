# Sometimes our users will try to do: "cd debian10; cmake ." That needs to error in a nice way.
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the developer_guide.adoc for more details!")
endif()

ssg_build_product("debian10")
