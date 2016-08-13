ssg_build_product("rhel7")

# todo: remove fake target
add_custom_target(rhel7 DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-withremediations.xml)
