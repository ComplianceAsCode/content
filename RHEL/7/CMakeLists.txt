ssg_build_guide_xml("rhel7")
ssg_build_shorthand_xml("rhel7")
ssg_build_unlinked_xccdf("rhel7")
ssg_build_unlinked_ocil("rhel7")
ssg_build_xccdf_ocilrefs("rhel7")
ssg_build_bash_remediations("rhel7")
ssg_build_xccdf_with_remediations("rhel7")

# todo: remove fake target
add_custom_target(rhel7 DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-withremediations.xml)
