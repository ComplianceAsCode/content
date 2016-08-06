ssg_build_guide_xml("Fedora")
ssg_build_shorthand_xml("Fedora")

add_custom_target(Fedora DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml)
