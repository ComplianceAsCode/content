ssg_build_product("fedora")

# todo: remove fake target
add_custom_target(fedora DEPENDS ${CMAKE_BINARY_DIR}/ssg-fedora-ds.xml)
