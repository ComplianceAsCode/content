ssg_build_product("fedora")

add_custom_target(
    fedora ALL
    DEPENDS ${CMAKE_BINARY_DIR}/ssg-fedora-xccdf.xml
    DEPENDS ${CMAKE_BINARY_DIR}/ssg-fedora-oval.xml
    DEPENDS ${CMAKE_BINARY_DIR}/ssg-fedora-ocil.xml
    DEPENDS ${CMAKE_BINARY_DIR}/ssg-fedora-ds.xml
)
