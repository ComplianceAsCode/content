ssg_build_product("fedora")

# todo: remove fake target
add_custom_target(fedora DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked.xml ${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml)
