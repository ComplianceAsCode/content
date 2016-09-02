ssg_build_product("rhel6")

add_custom_target(
    rhel6 ALL
    DEPENDS ${CMAKE_BINARY_DIR}/ssg-rhel6-xccdf.xml
    DEPENDS ${CMAKE_BINARY_DIR}/ssg-rhel6-oval.xml
    DEPENDS ${CMAKE_BINARY_DIR}/ssg-rhel6-ocil.xml
    DEPENDS ${CMAKE_BINARY_DIR}/ssg-rhel6-ds.xml
)
