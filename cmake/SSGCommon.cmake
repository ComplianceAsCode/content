# Important developer notes:

# Minimal build targets
# ============================================================================
#
# For the build system to be efficient it makes sense to separate build
# targets as much as possible. Please do not be lazy and group multiple
# files into one add_custom_command. This prevents parallelization and slows
# down the builds!
#
#
# Avoid input output overlap
# ============================================================================
#
# If there is any overlap in inputs and/or outputs of build targets the build
# system will needlessly rebuild the target every time you run the build.
# Please avoid this because it slows down incremental builds. Incremental
# builds are done all the time by SSG developers so it makes sense to have
# them as fast as possible.
#
#
# Wrapper targets
# ============================================================================
#
# Notice that most (if not all) add_custom_command calls are immediately
# followed with a wrapper add_custom_target. We do that to generate proper
# dependency directed graphs so that dependencies can be shared. Without
# this wrapper you wouldn't have been able to do parallel builds of multiple
# targets at once. E.g.:
#
# $ make -j 4 rhel7-guides rhel7-validate
#
# Without the wrapper targets the command above would start generating the
# XCCDF, OVAL and OCIL files 2 times in parallel which would result in
# broken files.
#
# Please keep this in mind when modifying the build system.
#
# Read:
# https://samthursfield.wordpress.com/2015/11/21/cmake-dependencies-between-targets-and-files-and-custom-commands/
# for more info.
#
#
# Folders should not be build inputs or outputs
# ============================================================================
#
# It may be tempting to mark an entire folder as build output but doing that
# has unexpected consequences. Please avoid that and always list the files.
#
#
# Good luck hacking the SCAP Security Guide build system!


set(SSG_SHARED "${CMAKE_SOURCE_DIR}/shared")
set(SSG_SHARED_REFS "${SSG_SHARED}/references")
set(SSG_SHARED_TRANSFORMS "${SSG_SHARED}/transforms")
set(SSG_SHARED_UTILS "${SSG_SHARED}/utils")
set(SSG_VENDOR "ssgproject")

set(OSCAP_OVAL_511_SUPPORT 0)

if(OSCAP_OVAL_511_SUPPORT EQUAL 0)
    set(OSCAP_OVAL_VERSION "oval_5.11")
else()
    set(OSCAP_OVAL_VERSION "oval_5.10")
endif()

macro(ssg_build_guide_xml PRODUCT)
    if(OSCAP_SVG_SUPPORT EQUAL 0)
        add_custom_command(
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/guide.xml"
            COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_CURRENT_BINARY_DIR}/guide.xml" "${SSG_SHARED_TRANSFORMS}/includelogo.xslt" "${SSG_SHARED}/xccdf/shared_guide.xml"
            MAIN_DEPENDENCY "${SSG_SHARED}/xccdf/shared_guide.xml"
            DEPENDS "${SSG_SHARED_TRANSFORMS}/includelogo.xslt"
            COMMENT "[${PRODUCT}] generating guide.xml (SVG logo enabled)"
        )
    else()
        add_custom_command(
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/guide.xml"
            COMMAND "${CMAKE_COMMAND}" -E copy "${SSG_SHARED}/xccdf/shared_guide.xml" "${CMAKE_CURRENT_BINARY_DIR}/guide.xml"
            MAIN_DEPENDENCY "${SSG_SHARED}/xccdf/shared_guide.xml"
            COMMENT "[${PRODUCT}] generating guide.xml (SVG logo disabled)"
        )
    endif()

    add_custom_target(
        generate-internal-${PRODUCT}-guide.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/guide.xml"
    )
endmacro()

macro(ssg_build_shorthand_xml PRODUCT)
    file(GLOB AUXILIARY_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/input/auxiliary/*.xml")
    file(GLOB PROFILE_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/input/profiles/*.xml")
    file(GLOB XCCDF_RULE_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/input/xccdf/**/*.xml")

    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam SHARED_RP "${SSG_SHARED}" --output "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml" "${CMAKE_CURRENT_SOURCE_DIR}/input/guide.xslt" "${CMAKE_CURRENT_BINARY_DIR}/guide.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml" "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
        DEPENDS generate-internal-${PRODUCT}-guide.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/guide.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/input/guide.xslt"
        DEPENDS ${AUXILIARY_DEPS}
        DEPENDS ${PROFILE_DEPS}
        DEPENDS ${XCCDF_RULE_DEPS}
        COMMENT "[${PRODUCT}] generating shorthand.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-shorthand.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
    )
endmacro()

macro(ssg_build_xccdf_unlinked PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam ssg_version "${SSG_VERSION}" --output "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/shorthand2xccdf.xslt" "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
        COMMAND "${OSCAP_EXECUTABLE}" xccdf resolve -o "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
        DEPENDS generate-internal-${PRODUCT}-shorthand.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/shorthand2xccdf.xslt"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/constants.xslt"
        DEPENDS "${SSG_SHARED_TRANSFORMS}/shared_constants.xslt"
        COMMENT "[${PRODUCT}] generating xccdf-unlinked-resolved.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-xccdf-unlinked-resolved.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
    )
endmacro()

macro(ssg_build_ocil_unlinked PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml"
        COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml" "${SSG_SHARED_TRANSFORMS}/xccdf-create-ocil.xslt" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml" "${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml"
        DEPENDS generate-internal-${PRODUCT}-xccdf-unlinked-resolved.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
        DEPENDS "${SSG_SHARED_TRANSFORMS}/xccdf-create-ocil.xslt"
        COMMENT "[${PRODUCT}] generating ocil-unlinked.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-ocil-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml"
    )

    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml"
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam product ${PRODUCT} --output "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml" "${SSG_SHARED_TRANSFORMS}/xccdf-ocilcheck2ref.xslt" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
        DEPENDS generate-internal-${PRODUCT}-xccdf-unlinked-resolved.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
        DEPENDS generate-internal-${PRODUCT}-ocil-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml"
        DEPENDS "${SSG_SHARED_TRANSFORMS}/xccdf-ocilcheck2ref.xslt"
        COMMENT "[${PRODUCT}] generating xccdf-unlinked-ocilrefs.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-xccdf-unlinked-ocilrefs.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml"
    )
endmacro()

macro(ssg_build_remediations PRODUCT)
    set(BUILD_REMEDIATIONS_DIR "${CMAKE_CURRENT_BINARY_DIR}/remediations")

    message(STATUS "Scanning for dependencies of ${PRODUCT} bash remediations...")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language bash list-inputs
        OUTPUT_VARIABLE BASH_REMEDIATIONS_DEPENDS_STR
    )
    string(REPLACE "\n" ";" BASH_REMEDIATIONS_DEPENDS "${BASH_REMEDIATIONS_DEPENDS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language bash list-outputs
        OUTPUT_VARIABLE BASH_REMEDIATIONS_OUTPUTS_STR
    )
    string(REPLACE "\n" ";" BASH_REMEDIATIONS_OUTPUTS "${BASH_REMEDIATIONS_OUTPUTS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared" --language bash list-inputs
        OUTPUT_VARIABLE SHARED_BASH_REMEDIATIONS_DEPENDS_STR
    )
    string(REPLACE "\n" ";" SHARED_BASH_REMEDIATIONS_DEPENDS "${SHARED_BASH_REMEDIATIONS_DEPENDS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared" --language bash list-outputs
        OUTPUT_VARIABLE SHARED_BASH_REMEDIATIONS_OUTPUTS_STR
    )
    string(REPLACE "\n" ";" SHARED_BASH_REMEDIATIONS_OUTPUTS "${SHARED_BASH_REMEDIATIONS_OUTPUTS_STR}")

    # TODO: The environment variable is not very portable
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/bash-remediations.xml"
        OUTPUT ${BASH_REMEDIATIONS_OUTPUTS}
        OUTPUT ${SHARED_BASH_REMEDIATIONS_OUTPUTS}
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language bash build
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared/" --language bash build
        COMMAND SHARED=${SSG_SHARED} "${SSG_SHARED_UTILS}/combine-remediations.py" ${PRODUCT} bash "${BUILD_REMEDIATIONS_DIR}/shared/bash" "${SSG_SHARED}/templates/static/bash" "${BUILD_REMEDIATIONS_DIR}/bash" "${CMAKE_CURRENT_SOURCE_DIR}/templates/static/bash" "${CMAKE_CURRENT_BINARY_DIR}/bash-remediations.xml"
        DEPENDS ${BASH_REMEDIATIONS_DEPENDS}
        DEPENDS ${SHARED_BASH_REMEDIATIONS_DEPENDS}
        DEPENDS "${SSG_SHARED_UTILS}/combine-remediations.py"
        COMMENT "[${PRODUCT}] generating bash-remediations.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-bash-remediations.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/bash-remediations.xml"
        DEPENDS ${BASH_REMEDIATIONS_OUTPUTS}
        DEPENDS ${SHARED_BASH_REMEDIATIONS_OUTPUTS}
    )

    message(STATUS "Scanning for dependencies of ${PRODUCT} ansible remediations...")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language ansible list-inputs
        OUTPUT_VARIABLE ANSIBLE_REMEDIATIONS_DEPENDS_STR
    )
    string(REPLACE "\n" ";" ANSIBLE_REMEDIATIONS_DEPENDS "${ANSIBLE_REMEDIATIONS_DEPENDS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language ansible list-outputs
        OUTPUT_VARIABLE ANSIBLE_REMEDIATIONS_OUTPUTS_STR
    )
    string(REPLACE "\n" ";" ANSIBLE_REMEDIATIONS_OUTPUTS "${ANSIBLE_REMEDIATIONS_OUTPUTS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared" --language ansible list-inputs
        OUTPUT_VARIABLE SHARED_ANSIBLE_REMEDIATIONS_DEPENDS_STR
    )
    string(REPLACE "\n" ";" SHARED_ANSIBLE_REMEDIATIONS_DEPENDS "${SHARED_ANSIBLE_REMEDIATIONS_DEPENDS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared" --language ansible list-outputs
        OUTPUT_VARIABLE SHARED_ANSIBLE_REMEDIATIONS_OUTPUTS_STR
    )
    string(REPLACE "\n" ";" SHARED_ANSIBLE_REMEDIATIONS_OUTPUTS "${SHARED_ANSIBLE_REMEDIATIONS_OUTPUTS_STR}")

    # TODO: The environment variable is not very portable
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/ansible-remediations.xml"
        OUTPUT ${ANSIBLE_REMEDIATIONS_OUTPUTS}
        OUTPUT ${SHARED_ANSIBLE_REMEDIATIONS_OUTPUTS}
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language ansible build
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared/" --language ansible build
        COMMAND SHARED=${SSG_SHARED} "${SSG_SHARED_UTILS}/combine-remediations.py" ${PRODUCT} ansible "${BUILD_REMEDIATIONS_DIR}/shared/ansible" "${SSG_SHARED}/templates/static/ansible" "${BUILD_REMEDIATIONS_DIR}/ansible" "${CMAKE_CURRENT_SOURCE_DIR}/templates/static/ansible" "${CMAKE_CURRENT_BINARY_DIR}/ansible-remediations.xml"
        DEPENDS ${ANSIBLE_REMEDIATIONS_DEPENDS}
        DEPENDS ${SHARED_ANSIBLE_REMEDIATIONS_DEPENDS}
        DEPENDS "${SSG_SHARED_UTILS}/combine-remediations.py"
        COMMENT "[${PRODUCT}] generating ansible-remediations.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-ansible-remediations.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/ansible-remediations.xml"
    )

    message(STATUS "Scanning for dependencies of ${PRODUCT} puppet remediations...")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language puppet list-inputs
        OUTPUT_VARIABLE PUPPET_REMEDIATIONS_DEPENDS_STR
    )
    string(REPLACE "\n" ";" PUPPET_REMEDIATIONS_DEPENDS "${PUPPET_REMEDIATIONS_DEPENDS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language puppet list-outputs
        OUTPUT_VARIABLE PUPPET_REMEDIATIONS_OUTPUTS_STR
    )
    string(REPLACE "\n" ";" PUPPET_REMEDIATIONS_OUTPUTS "${PUPPET_REMEDIATIONS_OUTPUTS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared" --language puppet list-inputs
        OUTPUT_VARIABLE SHARED_PUPPET_REMEDIATIONS_DEPENDS_STR
    )
    string(REPLACE "\n" ";" SHARED_PUPPET_REMEDIATIONS_DEPENDS "${SHARED_PUPPET_REMEDIATIONS_DEPENDS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared" --language puppet list-outputs
        OUTPUT_VARIABLE SHARED_PUPPET_REMEDIATIONS_OUTPUTS_STR
    )
    string(REPLACE "\n" ";" SHARED_PUPPET_REMEDIATIONS_OUTPUTS "${SHARED_PUPPET_REMEDIATIONS_OUTPUTS_STR}")

    # TODO: The environment variable is not very portable
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/puppet-remediations.xml"
        OUTPUT ${PUPPET_REMEDIATIONS_OUTPUTS}
        OUTPUT ${SHARED_PUPPET_REMEDIATIONS_OUTPUTS}
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language puppet build
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared/" --language puppet build
        COMMAND SHARED=${SSG_SHARED} "${SSG_SHARED_UTILS}/combine-remediations.py" ${PRODUCT} puppet "${BUILD_REMEDIATIONS_DIR}/shared/puppet" "${SSG_SHARED}/templates/static/puppet" "${BUILD_REMEDIATIONS_DIR}/puppet" "${CMAKE_CURRENT_SOURCE_DIR}/templates/static/puppet" "${CMAKE_CURRENT_BINARY_DIR}/puppet-remediations.xml"
        DEPENDS ${PUPPET_REMEDIATIONS_DEPENDS}
        DEPENDS ${SHARED_PUPPET_REMEDIATIONS_DEPENDS}
        DEPENDS "${SSG_SHARED_UTILS}/combine-remediations.py"
        COMMENT "[${PRODUCT}] generating puppet-remediations.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-puppet-remediations.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/puppet-remediations.xml"
    )

    message(STATUS "Scanning for dependencies of ${PRODUCT} anaconda remediations...")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language anaconda list-inputs
        OUTPUT_VARIABLE ANACONDA_REMEDIATIONS_DEPENDS_STR
    )
    string(REPLACE "\n" ";" ANACONDA_REMEDIATIONS_DEPENDS "${ANACONDA_REMEDIATIONS_DEPENDS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language anaconda list-outputs
        OUTPUT_VARIABLE ANACONDA_REMEDIATIONS_OUTPUTS_STR
    )
    string(REPLACE "\n" ";" ANACONDA_REMEDIATIONS_OUTPUTS "${ANACONDA_REMEDIATIONS_OUTPUTS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared" --language anaconda list-inputs
        OUTPUT_VARIABLE SHARED_ANACONDA_REMEDIATIONS_DEPENDS_STR
    )
    string(REPLACE "\n" ";" SHARED_ANACONDA_REMEDIATIONS_DEPENDS "${SHARED_ANACONDA_REMEDIATIONS_DEPENDS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared" --language anaconda list-outputs
        OUTPUT_VARIABLE SHARED_ANACONDA_REMEDIATIONS_OUTPUTS_STR
    )
    string(REPLACE "\n" ";" SHARED_ANACONDA_REMEDIATIONS_OUTPUTS "${SHARED_ANACONDA_REMEDIATIONS_OUTPUTS_STR}")

    # TODO: The environment variable is not very portable
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/anaconda-remediations.xml"
        OUTPUT ${ANACONDA_REMEDIATIONS_OUTPUTS}
        OUTPUT ${SHARED_ANACONDA_REMEDIATIONS_OUTPUTS}
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language anaconda build
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared/" --language anaconda build
        COMMAND SHARED=${SSG_SHARED} "${SSG_SHARED_UTILS}/combine-remediations.py" ${PRODUCT} anaconda "${BUILD_REMEDIATIONS_DIR}/shared/anaconda" "${SSG_SHARED}/templates/static/anaconda" "${BUILD_REMEDIATIONS_DIR}/anaconda" "${CMAKE_CURRENT_SOURCE_DIR}/templates/static/anaconda" "${CMAKE_CURRENT_BINARY_DIR}/anaconda-remediations.xml"
        DEPENDS ${ANACONDA_REMEDIATIONS_DEPENDS}
        DEPENDS ${SHARED_ANACONDA_REMEDIATIONS_DEPENDS}
        DEPENDS "${SSG_SHARED_UTILS}/combine-remediations.py"
        COMMENT "[${PRODUCT}] generating anaconda-remediations.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-anaconda-remediations.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/anaconda-remediations.xml"
    )
endmacro()

macro(ssg_build_xccdf_with_remediations PRODUCT)
    # we have to encode spaces in paths before passing them as stringparams to xsltproc
    string(REPLACE " " "%20" CMAKE_CURRENT_BINARY_DIR_NO_SPACES "${CMAKE_CURRENT_BINARY_DIR}")
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml"
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam bash_remediations "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/bash-remediations.xml" --stringparam ansible_remediations "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/ansible-remediations.xml" --stringparam puppet_remediations "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/puppet-remediations.xml" --stringparam anaconda_remediations "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/anaconda-remediations.xml" --output "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml" "${SSG_SHARED_TRANSFORMS}/xccdf-addremediations.xslt" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml"
        DEPENDS generate-internal-${PRODUCT}-xccdf-unlinked-ocilrefs.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml"
        DEPENDS generate-internal-${PRODUCT}-bash-remediations.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/bash-remediations.xml"
        DEPENDS generate-internal-${PRODUCT}-ansible-remediations.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/ansible-remediations.xml"
        DEPENDS generate-internal-${PRODUCT}-puppet-remediations.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/puppet-remediations.xml"
        DEPENDS generate-internal-${PRODUCT}-anaconda-remediations.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/anaconda-remediations.xml"
        DEPENDS "${SSG_SHARED_TRANSFORMS}/xccdf-addremediations.xslt"
        COMMENT "[${PRODUCT}] generating xccdf-unlinked.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-xccdf-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml"
    )
endmacro()

macro(ssg_build_oval_unlinked PRODUCT)
    set(OVAL_DEPS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/input/oval")
    file(GLOB OVAL_DEPS "${OVAL_DEPS_DIR}/*.xml")
    set(SHARED_OVAL_DEPS_DIR "${SSG_SHARED}/oval")
    file(GLOB SHARED_OVAL_DEPS "${SHARED_OVAL_DEPS_DIR}/*.xml")
    set(OVAL_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/oval")

    if(OSCAP_OVAL_511_SUPPORT EQUAL 0)
        set(OVAL_511_DEPS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/input/oval/${OSCAP_OVAL_VERSION}")
        file(GLOB OVAL_511_DEPS "${OVAL_511_DEPS_DIR}/*.xml")
        set(SHARED_OVAL_511_DEPS_DIR "${SSG_SHARED}/oval/${OSCAP_OVAL_VERSION}")
        file(GLOB SHARED_OVAL_511_DEPS "${SHARED_OVAL_511_DEPS_DIR}/*.xml")

        add_custom_command(
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
            # TODO: output directory
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/oval"
            # TODO: config
            COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${CMAKE_CURRENT_BINARY_DIR}/" --language oval build
            COMMAND RUNTIME_OVAL_VERSION=5.11 "${SSG_SHARED_UTILS}/combine-ovals.py" "${CMAKE_SOURCE_DIR}/config" "${PRODUCT}" "oval_5.10:${SHARED_OVAL_DEPS_DIR}" "oval_5.10:${OVAL_DEPS_DIR}" "oval_5.11:${SHARED_OVAL_511_DEPS_DIR}" "oval_5.11:${OVAL_511_DEPS_DIR}" "oval_5.11:${OVAL_BUILD_DIR}" > "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
            COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml" "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
            DEPENDS ${OVAL_DEPS}
            DEPENDS ${OVAL_511_DEPS}
            DEPENDS ${SHARED_OVAL_DEPS}
            DEPENDS ${SHARED_OVAL_511_DEPS}
            DEPENDS "${SSG_SHARED_UTILS}/combine-ovals.py"
            VERBATIM
            COMMENT "[${PRODUCT}] generating oval-unlinked.xml (OVAL 5.11 checks enabled)"
        )
    else()
        add_custom_command(
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
            # TODO: output directory
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/oval"
            # TODO: config
            COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${CMAKE_CURRENT_BINARY_DIR}/" --language oval build
            COMMAND "${SSG_SHARED_UTILS}/combine-ovals.py" "${CMAKE_SOURCE_DIR}/config" ${PRODUCT} "oval_5.10:${OVAL_DEPS_DIR}" "oval_5.10:${SHARED_OVAL_DEPS_DIR}" "oval_5.10:${OVAL_BUILD_DIR}" > "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
            COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml" "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
            DEPENDS ${OVAL_DEPS}
            DEPENDS ${SHARED_OVAL_DEPS}
            DEPENDS "${SSG_SHARED_UTILS}/combine-ovals.py"
            VERBATIM
            COMMENT "[${PRODUCT}] generating oval-unlinked.xml (OVAL 5.11 checks disabled)"
        )
    endif()
    add_custom_target(
        generate-internal-${PRODUCT}-oval-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
    )
endmacro()

macro(ssg_build_cpe_dictionary PRODUCT)
    set(SSG_CPE_DICTIONARY "${CMAKE_CURRENT_SOURCE_DIR}/input/oval/platform/${PRODUCT}-cpe-dictionary.xml")

    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
        COMMAND "${SSG_SHARED_UTILS}/cpe-generate.py" ${PRODUCT} ssg "${CMAKE_BINARY_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml" "${SSG_CPE_DICTIONARY}"
        DEPENDS generate-internal-${PRODUCT}-oval-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
        DEPENDS "${SSG_SHARED_UTILS}/cpe-generate.py"
        COMMENT "[${PRODUCT}] generating ssg-${PRODUCT}-cpe-dictionary.xml, ssg-${PRODUCT}-cpe-oval.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-cpe-dictionary.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
    )
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-cpe-dictionary.xml"
        COMMAND "${OSCAP_EXECUTABLE}" cpe validate "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-cpe-dictionary.xml"
        DEPENDS generate-ssg-${PRODUCT}-cpe-dictionary.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        COMMENT "[${PRODUCT}-validate] validating ssg-${PRODUCT}-cpe-dictionary.xml"
    )
    add_custom_target(
        validate-ssg-${PRODUCT}-cpe-dictionary.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-cpe-dictionary.xml"
    )
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-cpe-oval.xml"
        COMMAND "${OSCAP_EXECUTABLE}" oval validate --schematron "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
        COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-cpe-oval.xml"
        DEPENDS generate-ssg-${PRODUCT}-cpe-dictionary.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
        COMMENT "[${PRODUCT}-validate] validating ssg-${PRODUCT}-cpe-oval.xml"
    )
    add_custom_target(
        validate-ssg-${PRODUCT}-cpe-oval.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-cpe-oval.xml"
    )
endmacro()

macro(ssg_build_link_xccdf_oval_ocil PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked.xml"
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml"
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/ocil-linked.xml"
        COMMAND "${SSG_SHARED_UTILS}/relabel-ids.py" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml" ssg
        DEPENDS generate-internal-${PRODUCT}-xccdf-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml"
        DEPENDS generate-internal-${PRODUCT}-oval-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
        DEPENDS generate-internal-${PRODUCT}-ocil-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml"
        DEPENDS "${SSG_SHARED_UTILS}/relabel-ids.py"
        COMMENT "[${PRODUCT}] linking IDs, generating xccdf-linked.xml, oval-linked.xml, ocil-linked.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-linked-xccdf-oval-ocil.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked.xml"
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml"
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/ocil-linked.xml"
    )
endmacro()

macro(ssg_build_xccdf_final PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        # Remove auxiliary Groups which are only for use in tables, and not guide output.
        COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf-removeaux.xslt" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked.xml"
        COMMAND "${SED_EXECUTABLE}" -i "s/oval-linked.xml/ssg-${PRODUCT}-oval.xml/g" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMAND "${SED_EXECUTABLE}" -i "s/ocil-linked.xml/ssg-${PRODUCT}-ocil.xml/g" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMAND "${SSG_SHARED_UTILS}/unselect-empty-xccdf-groups.py" --input "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMAND "${OSCAP_EXECUTABLE}" xccdf resolve -o "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-internal-${PRODUCT}-linked-xccdf-oval-ocil.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf-removeaux.xslt"
        DEPENDS "${SSG_SHARED_UTILS}/unselect-empty-xccdf-groups.py"
        COMMENT "[${PRODUCT}] generating ssg-${PRODUCT}-xccdf.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
    )
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-xccdf.xml"
        COMMAND "${OSCAP_EXECUTABLE}" xccdf validate "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMAND "${SSG_SHARED_UTILS}/verify-references.py" --rules-with-invalid-checks --ovaldefs-unused "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-oval.xml  # because of verify-references
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
        COMMENT "[${PRODUCT}-validate] validating ssg-${PRODUCT}-xccdf.xml"
    )
    add_custom_target(
        validate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-xccdf.xml"
    )

    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml"
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam reverse_DNS "org.${SSG_VENDOR}.content" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml" "/usr/share/openscap/xsl/xccdf_1.1_to_1.2.xsl" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMENT "[${PRODUCT}] generating ssg-${PRODUCT}-xccdf-1.2.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-xccdf-1.2.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml"
    )
    #add_custom_command(
    #    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-xccdf-1.2.xml"
    #    COMMAND "${OSCAP_EXECUTABLE}" xccdf-1.2 validate "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml"
    #    COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-xccdf-1.2.xml"
    #    DEPENDS generate-ssg-${PRODUCT}-xccdf-1.2.xml
    #    DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml"
    #    COMMENT "[${PRODUCT}-validate] validating ssg-${PRODUCT}-xccdf-1.2.xml"
    #)
    #add_custom_target(
    #    validate-ssg-${PRODUCT}-xccdf-1.2.xml
    #    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-xccdf-1.2.xml"
    #)
endmacro()

macro(ssg_build_oval_final PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
        COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
        DEPENDS generate-internal-${PRODUCT}-linked-xccdf-oval-ocil.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml"
        COMMENT "[${PRODUCT}] generating ssg-${PRODUCT}-oval.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-oval.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
    )
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-oval.xml"
        COMMAND "${OSCAP_EXECUTABLE}" oval validate --schematron "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
        COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-oval.xml"
        DEPENDS generate-ssg-${PRODUCT}-oval.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
        COMMENT "[${PRODUCT}-validate] validating ssg-${PRODUCT}-oval.xml"
    )
    add_custom_target(
        validate-ssg-${PRODUCT}-oval.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-oval.xml"
    )
endmacro()

macro(ssg_build_ocil_final PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_BINARY_DIR}/ocil-linked.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        DEPENDS generate-internal-${PRODUCT}-linked-xccdf-oval-ocil.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/ocil-linked.xml"
        COMMENT "[${PRODUCT}] generating ssg-${PRODUCT}-ocil.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-ocil.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
    )
    #add_custom_command(
    #    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-ocil.xml"
    #    COMMAND "${OSCAP_EXECUTABLE}" ocil validate "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
    #    COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-ocil.xml"
    #    DEPENDS generate-ssg-${PRODUCT}-ocil.xml
    #    DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
    #    COMMENT "[${PRODUCT}-validate] validating ssg-${PRODUCT}-ocil.xml"
    #)
    #add_custom_target(
    #    validate-ssg-${PRODUCT}-ocil.xml
    #    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-ocil.xml"
    #)
endmacro()

macro(ssg_build_pci_dss_xccdf PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-pcidss-xccdf-1.2.xml"
        COMMAND "${SSG_SHARED_TRANSFORMS}/pcidss/transform_benchmark_to_pcidss.py" "${SSG_SHARED_TRANSFORMS}/pcidss/PCI_DSS.json" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-pcidss-xccdf-1.2.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf-1.2.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml"
        COMMENT "[${PRODUCT}] building ssg-${PRODUCT}-pcidss-xccdf-1.2.xml from ssg-${PRODUCT}-xccdf-1.2.xml (PCI-DSS centered benchmark)"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-pcidss-xccdf-1.2.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-pcidss-xccdf-1.2.xml"
    )
    #add_custom_command(
    #    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-pcidss-xccdf-1.2.xml"
    #    COMMAND "${OSCAP_EXECUTABLE}" xccdf validate "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-pcidss-xccdf-1.2.xml"
    #    COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-pcidss-xccdf-1.2.xml"
    #    DEPENDS generate-ssg-${PRODUCT}-pcidss-xccdf-1.2.xml
    #    DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-pcidss-xccdf-1.2.xml"
    #    COMMENT "[${PRODUCT}-validate] validating ssg-${PRODUCT}-pcidss-xccdf-1.2.xml"
    #)
    #add_custom_target(
    #    validate-ssg-${PRODUCT}-pcidss-xccdf-1.2.xml
    #    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-pcidss-xccdf-1.2.xml"
    #)
endmacro()

macro(ssg_build_sds PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMAND "${OSCAP_EXECUTABLE}" ds sds-compose "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMAND "${SED_EXECUTABLE}" -i 's/schematron-version="[0-9].[0-9]"/schematron-version="1.2"/' "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMAND "${OSCAP_EXECUTABLE}" ds sds-add "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMAND "${OSCAP_EXECUTABLE}" ds sds-add "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-pcidss-xccdf-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMAND "${SSG_SHARED_UTILS}/sds-move-ocil-to-checks.py" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf-1.2.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml"
        DEPENDS generate-ssg-${PRODUCT}-oval.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
        DEPENDS generate-ssg-${PRODUCT}-ocil.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        DEPENDS generate-ssg-${PRODUCT}-cpe-dictionary.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
        DEPENDS generate-ssg-${PRODUCT}-pcidss-xccdf-1.2.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-pcidss-xccdf-1.2.xml"
        COMMENT "[${PRODUCT}] generating ssg-${PRODUCT}-ds.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-ds.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
    )
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-ds.xml"
        COMMAND "${OSCAP_EXECUTABLE}" ds sds-validate "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-ds.xml"
        DEPENDS generate-ssg-${PRODUCT}-ds.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMENT "[${PRODUCT}-validate] validating ssg-${PRODUCT}-ds.xml"
    )
    add_custom_target(
        validate-ssg-${PRODUCT}-ds.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-ds.xml"
    )
endmacro()

macro(ssg_build_html_guides PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-guide-index.html"
        COMMAND "${SSG_SHARED_UTILS}/build-all-guides.py" --input "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" --output "${CMAKE_BINARY_DIR}/" build
        DEPENDS generate-ssg-${PRODUCT}-ds.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMENT "[${PRODUCT}-guides] generating HTML guides for all profiles in ssg-${PRODUCT}-ds.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-guide-index.html
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-guide-index.html"
    )
endmacro()

macro(ssg_build_product PRODUCT)
    ssg_build_guide_xml(${PRODUCT})
    ssg_build_shorthand_xml(${PRODUCT})
    ssg_build_xccdf_unlinked(${PRODUCT})
    ssg_build_ocil_unlinked(${PRODUCT})
    ssg_build_remediations(${PRODUCT})
    ssg_build_xccdf_with_remediations(${PRODUCT})
    ssg_build_oval_unlinked(${PRODUCT})
    ssg_build_cpe_dictionary(${PRODUCT})
    ssg_build_link_xccdf_oval_ocil(${PRODUCT})
    ssg_build_xccdf_final(${PRODUCT})
    ssg_build_oval_final(${PRODUCT})
    ssg_build_ocil_final(${PRODUCT})
    ssg_build_pci_dss_xccdf(${PRODUCT})
    ssg_build_sds(${PRODUCT})

    add_custom_target(
        ${PRODUCT} ALL
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS generate-ssg-${PRODUCT}-xccdf-1.2.xml
        DEPENDS generate-ssg-${PRODUCT}-oval.xml
        DEPENDS generate-ssg-${PRODUCT}-ocil.xml
        DEPENDS generate-ssg-${PRODUCT}-cpe-dictionary.xml
        DEPENDS generate-ssg-${PRODUCT}-ds.xml
    )
    add_custom_target(
        ${PRODUCT}-validate
        DEPENDS validate-ssg-${PRODUCT}-xccdf.xml
        #DEPENDS validate-ssg-${PRODUCT}-xccdf-1.2.xml
        DEPENDS validate-ssg-${PRODUCT}-oval.xml
        #DEPENDS validate-ssg-${PRODUCT}-ocil.xml
        DEPENDS validate-ssg-${PRODUCT}-cpe-dictionary.xml
        DEPENDS validate-ssg-${PRODUCT}-cpe-oval.xml
        DEPENDS validate-ssg-${PRODUCT}-ds.xml
        COMMENT "[${PRODUCT}-validate] validating outputs"
    )
    add_dependencies(validate ${PRODUCT}-validate)

    ssg_build_html_guides(${PRODUCT})

    add_custom_target(
        ${PRODUCT}-guides ALL
        DEPENDS generate-ssg-${PRODUCT}-guide-index.html
    )

    add_custom_target(
        ${PRODUCT}-tables ALL
        # dependencies are added later using add_dependency
    )

    install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")

    # This is a common cmake trick, we need the globbing to happen at build time
    # and not configure time.
    install(
       CODE "
           file(GLOB GUIDE_FILES \"${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-guide-*.html\") \n
           file(INSTALL DESTINATION \"${CMAKE_INSTALL_PREFIX}/${SSG_GUIDE_INSTALL_DIR}\"
           TYPE FILE FILES \${GUIDE_FILES}
       )"
    )
endmacro()

macro(ssg_build_derivative_product ORIGINAL SHORTNAME DERIVATIVE)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml"
        COMMAND "${SSG_SHARED_UTILS}/enable-derivatives.py" --enable-${SHORTNAME} -i "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-xccdf.xml" -o "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml"
        DEPENDS generate-ssg-${ORIGINAL}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-xccdf.xml"
        DEPENDS "${SSG_SHARED_UTILS}/enable-derivatives.py"
        COMMENT "[${DERIVATIVE}] generating ssg-${DERIVATIVE}-xccdf.xml"
    )
    add_custom_target(
        generate-ssg-${DERIVATIVE}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml"
    )
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${DERIVATIVE}-xccdf.xml"
        COMMAND "${OSCAP_EXECUTABLE}" xccdf validate "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml"
        COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${DERIVATIVE}-xccdf.xml"
        DEPENDS generate-ssg-${DERIVATIVE}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml"
        COMMENT "[${DERIVATIVE}-validate] validating ssg-${DERIVATIVE}-xccdf.xml"
    )
    add_custom_target(
        validate-ssg-${DERIVATIVE}-xccdf.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${DERIVATIVE}-xccdf.xml"
    )

    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        COMMAND "${SSG_SHARED_UTILS}/enable-derivatives.py" --enable-${SHORTNAME} -i "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-ds.xml" -o "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        DEPENDS generate-ssg-${ORIGINAL}-ds.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-ds.xml"
        DEPENDS "${SSG_SHARED_UTILS}/enable-derivatives.py"
        COMMENT "[${DERIVATIVE}] generating ssg-${DERIVATIVE}-ds.xml"
    )
    add_custom_target(
        generate-ssg-${DERIVATIVE}-ds.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
    )
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${DERIVATIVE}-ds.xml"
        COMMAND "${OSCAP_EXECUTABLE}" ds sds-validate "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${DERIVATIVE}-ds.xml"
        DEPENDS generate-ssg-${DERIVATIVE}-ds.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        COMMENT "[${DERIVATIVE}-validate] validating ssg-${DERIVATIVE}-ds.xml"
    )
    add_custom_target(
        validate-ssg-${DERIVATIVE}-ds.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${DERIVATIVE}-ds.xml"
    )

    ssg_build_html_guides(${DERIVATIVE})

    add_custom_target(
        ${DERIVATIVE} ALL
        DEPENDS generate-ssg-${DERIVATIVE}-xccdf.xml
        # We use the original product's OVAL
        #DEPENDS generate-ssg-${DERIVATIVE}-oval.xml
        DEPENDS generate-ssg-${DERIVATIVE}-ds.xml
        DEPENDS generate-ssg-${DERIVATIVE}-guide-index.html
    )
    add_custom_target(
        ${DERIVATIVE}-validate
        DEPENDS validate-ssg-${DERIVATIVE}-xccdf.xml
        DEPENDS validate-ssg-${DERIVATIVE}-ds.xml
        COMMENT "[${DERIVATIVE}-validate] validating outputs"
    )
    add_dependencies(validate ${DERIVATIVE}-validate)

    install(FILES "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")

    # This is a common cmake trick, we need the globbing to happen at build time
    # and not configure time.
    install(
       CODE "
       file(GLOB GUIDE_FILES \"${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-guide-*.html\") \n
           file(INSTALL DESTINATION \"${CMAKE_INSTALL_PREFIX}/${SSG_GUIDE_INSTALL_DIR}\"
           TYPE FILE FILES \${GUIDE_FILES}
       )"
    )
endmacro()

macro(ssg_build_html_table_by_ref PRODUCT REF)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-${REF}refs.html"
        COMMAND "${XSLTPROC_EXECUTABLE}" -stringparam ref "${REF}" --output "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-${REF}refs.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-byref.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-byref.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML table for ${REF} references"
    )
    add_custom_target(
        generate-${PRODUCT}-table-by-ref-${REF}
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-${REF}refs.html"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}-table-by-ref-${REF})

    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-${REF}refs.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_build_html_nistrefs_table PRODUCT PROFILE)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-nistrefs-${PROFILE}.html"
        COMMAND "${XSLTPROC_EXECUTABLE}" -stringparam profile "${PROFILE}" --output "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-nistrefs-${PROFILE}.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profilenistrefs.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profilenistrefs.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML NIST refs table for ${PROFILE} profile"
    )
    add_custom_target(
        generate-${PRODUCT}-table-nistrefs-${PROFILE}
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-nistrefs-${PROFILE}.html"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}-table-nistrefs-${PROFILE})

    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-nistrefs-${PROFILE}.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_build_html_cce_table PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-cces.html"
        COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-cces.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-cce.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-cce.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML CCE identifiers table"
    )
    add_custom_target(
        generate-${PRODUCT}-table-cces
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-cces.html"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}-table-cces)

    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-cces.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_build_html_srgmap_tables PRODUCT DISA_SRG_VERSION)
    # we have to encode spaces in paths before passing them as stringparams to xsltproc
    string(REPLACE " " "%20" CMAKE_BINARY_DIR_NO_SPACES "${CMAKE_BINARY_DIR}")
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap.html"
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam map-to-items "${CMAKE_BINARY_DIR_NO_SPACES}/ssg-${PRODUCT}-xccdf.xml" --output "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt" "${SSG_SHARED_REFS}/disa-os-srg-${DISA_SRG_VERSION}.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${SSG_SHARED_REFS}/disa-os-srg-${DISA_SRG_VERSION}.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML SRG map table (flat=no)"
    )
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap-flat.html"
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam flat "y" --stringparam map-to-items "${CMAKE_BINARY_DIR_NO_SPACES}/ssg-${PRODUCT}-xccdf.xml" --output "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap-flat.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt" "${SSG_SHARED_REFS}/disa-os-srg-${DISA_SRG_VERSION}.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${SSG_SHARED_REFS}/disa-os-srg-${DISA_SRG_VERSION}.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML SRG map table (flat=yes)"
    )
    add_custom_target(
        generate-${PRODUCT}-table-srg
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap.html"
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap-flat.html"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}-table-srg)

    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap-flat.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_build_html_stig_tables PRODUCT STIG_PROFILE DISA_STIG_VERSION)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-stig.html"
        COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-stig.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-stig.xslt" "${SSG_SHARED_REFS}/disa-stig-${PRODUCT}-${DISA_STIG_VERSION}-xccdf-manual.xml"
        DEPENDS "${SSG_SHARED_REFS}/disa-stig-${PRODUCT}-${DISA_STIG_VERSION}-xccdf-manual.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-stig.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML STIG table"
    )
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-stig-testinfo.html"
        COMMAND "${XSLTPROC_EXECUTABLE}" -stringparam profile "${STIG_PROFILE}" -stringparam testinfo "y" --output "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-stig-testinfo.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profileccirefs.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profileccirefs.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML STIG test info document"
    )
    add_custom_target(
        generate-${PRODUCT}-table-stig
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-stig.html"
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-stig-testinfo.html"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}-table-stig)

    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-stig.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-stig-testinfo.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()
