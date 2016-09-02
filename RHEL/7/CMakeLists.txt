ssg_build_product("rhel7")

add_custom_target(
    rhel7 ALL
    DEPENDS ${CMAKE_BINARY_DIR}/ssg-rhel7-xccdf.xml
    DEPENDS ${CMAKE_BINARY_DIR}/ssg-rhel7-oval.xml
    DEPENDS ${CMAKE_BINARY_DIR}/ssg-rhel7-ocil.xml
    DEPENDS ${CMAKE_BINARY_DIR}/ssg-rhel7-ds.xml
)
