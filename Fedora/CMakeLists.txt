ssg_build_product("fedora")

# todo: remove fake target
add_custom_target(fedora DEPENDS ${CMAKE_BINARY_DIR}/ssg-fedora-xccdf.xml ${CMAKE_BINARY_DIR}/ssg-fedora-oval.xml)
