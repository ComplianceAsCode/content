# Sometimes our users will try to do: "cd docs; cmake ." That needs to error in a nice way.
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the Building ComplianceAsCode section in the Developer Guide!")
endif()

add_custom_target(docs
    COMMAND env sphinx-build -b html ${PROJECT_SOURCE_DIR}/docs ${CMAKE_BINARY_DIR}/docs
    COMMENT "[docs] generating html documentation"
)
