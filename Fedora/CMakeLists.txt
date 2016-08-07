ssg_build_guide_xml("fedora")
ssg_build_shorthand_xml("fedora")
ssg_build_unlinked_xccdf("fedora")
ssg_build_unlinked_ocil("fedora")
ssg_build_xccdf_ocilrefs("fedora")

# todo: remove fake target
add_custom_target(Fedora DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml)
