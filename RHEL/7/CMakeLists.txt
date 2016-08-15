ssg_build_product("rhel7")

# todo: remove fake target
add_custom_target(rhel7 DEPENDS ${CMAKE_BINARY_DIR}/ssg-rhel7-xccdf.xml ${CMAKE_BINARY_DIR}/ssg-rhel7-oval.xml)
