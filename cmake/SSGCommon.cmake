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

# OSCAP_OVAL_VERSION is passed into generate-from-templates.py and it specifies
# the highest OVAL version we can use.
if(SSG_OVAL_511_ENABLED)
    set(OSCAP_OVAL_VERSION "oval_5.11")
else()
    set(OSCAP_OVAL_VERSION "oval_5.10")
endif()

macro(ssg_build_guide_xml PRODUCT)
    if(SSG_SVG_IN_XCCDF_ENABLED)
        add_custom_command(
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/guide.xml"
            COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_CURRENT_BINARY_DIR}/guide.xml" "${SSG_SHARED_TRANSFORMS}/includelogo.xslt" "${SSG_SHARED}/xccdf/shared_guide.xml"
            MAIN_DEPENDENCY "${SSG_SHARED}/xccdf/shared_guide.xml"
            DEPENDS "${SSG_SHARED_TRANSFORMS}/includelogo.xslt"
            COMMENT "[${PRODUCT}-content] generating guide.xml (SVG logo enabled)"
        )
    else()
        add_custom_command(
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/guide.xml"
            COMMAND "${CMAKE_COMMAND}" -E copy "${SSG_SHARED}/xccdf/shared_guide.xml" "${CMAKE_CURRENT_BINARY_DIR}/guide.xml"
            MAIN_DEPENDENCY "${SSG_SHARED}/xccdf/shared_guide.xml"
            COMMENT "[${PRODUCT}-content] generating guide.xml (SVG logo disabled)"
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
        COMMENT "[${PRODUCT}-content] generating shorthand.xml"
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
        COMMENT "[${PRODUCT}-content] generating xccdf-unlinked-resolved.xml"
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
        COMMENT "[${PRODUCT}-content] generating ocil-unlinked.xml"
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
        COMMENT "[${PRODUCT}-content] generating xccdf-unlinked-ocilrefs.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-xccdf-unlinked-ocilrefs.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml"
    )
endmacro()

macro(_ssg_build_remediations_for_language PRODUCT LANGUAGE)
    set(BUILD_REMEDIATIONS_DIR "${CMAKE_CURRENT_BINARY_DIR}/remediations")

    message(STATUS "Scanning for dependencies of ${PRODUCT} ${LANGUAGE} remediations...")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language ${LANGUAGE} list-inputs
        OUTPUT_VARIABLE LANGUAGE_REMEDIATIONS_DEPENDS_STR
    )
    string(REPLACE "\n" ";" LANGUAGE_REMEDIATIONS_DEPENDS "${LANGUAGE_REMEDIATIONS_DEPENDS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language ${LANGUAGE} list-outputs
        OUTPUT_VARIABLE LANGUAGE_REMEDIATIONS_OUTPUTS_STR
    )
    string(REPLACE "\n" ";" LANGUAGE_REMEDIATIONS_OUTPUTS "${LANGUAGE_REMEDIATIONS_OUTPUTS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared" --language ${LANGUAGE} list-inputs
        OUTPUT_VARIABLE SHARED_LANGUAGE_REMEDIATIONS_DEPENDS_STR
    )
    string(REPLACE "\n" ";" SHARED_LANGUAGE_REMEDIATIONS_DEPENDS "${SHARED_LANGUAGE_REMEDIATIONS_DEPENDS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared" --language ${LANGUAGE} list-outputs
        OUTPUT_VARIABLE SHARED_LANGUAGE_REMEDIATIONS_OUTPUTS_STR
    )
    string(REPLACE "\n" ";" SHARED_LANGUAGE_REMEDIATIONS_OUTPUTS "${SHARED_LANGUAGE_REMEDIATIONS_OUTPUTS_STR}")
    file(GLOB EXTRA_LANGUAGE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/templates/static/${LANGUAGE}/*")
    file(GLOB EXTRA_SHARED_LANGUAGE_DEPENDS "${SSG_SHARED}/templates/static/${LANGUAGE}/*")

    # TODO: The environment variable is not very portable
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${LANGUAGE}-remediations.xml"
        OUTPUT ${LANGUAGE_REMEDIATIONS_OUTPUTS}
        OUTPUT ${SHARED_LANGUAGE_REMEDIATIONS_OUTPUTS}
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language ${LANGUAGE} build
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared" --language ${LANGUAGE} build
        COMMAND SHARED=${SSG_SHARED} "${SSG_SHARED_UTILS}/combine-remediations.py" ${PRODUCT} ${LANGUAGE} "${BUILD_REMEDIATIONS_DIR}/shared/${LANGUAGE}" "${SSG_SHARED}/templates/static/${LANGUAGE}" "${BUILD_REMEDIATIONS_DIR}/${LANGUAGE}" "${CMAKE_CURRENT_SOURCE_DIR}/templates/static/${LANGUAGE}" "${CMAKE_CURRENT_BINARY_DIR}/${LANGUAGE}-remediations.xml"
        DEPENDS ${LANGUAGE_REMEDIATIONS_DEPENDS}
        DEPENDS ${SHARED_LANGUAGE_REMEDIATIONS_DEPENDS}
        DEPENDS ${EXTRA_LANGUAGE_DEPENDS}
        DEPENDS ${EXTRA_SHARED_LANGUAGE_DEPENDS}
        DEPENDS "${SSG_SHARED_UTILS}/generate-from-templates.py"
        DEPENDS "${SSG_SHARED_UTILS}/combine-remediations.py"
        COMMENT "[${PRODUCT}-content] generating ${LANGUAGE}-remediations.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-${LANGUAGE}-remediations.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${LANGUAGE}-remediations.xml"
        DEPENDS ${LANGUAGE_REMEDIATIONS_OUTPUTS}
        DEPENDS ${SHARED_LANGUAGE_REMEDIATIONS_OUTPUTS}
    )
endmacro()

macro(ssg_build_remediations PRODUCT)
    _ssg_build_remediations_for_language(${PRODUCT} "bash")
    _ssg_build_remediations_for_language(${PRODUCT} "ansible")
    _ssg_build_remediations_for_language(${PRODUCT} "puppet")
    _ssg_build_remediations_for_language(${PRODUCT} "anaconda")
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
        COMMENT "[${PRODUCT}-content] generating xccdf-unlinked.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-xccdf-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml"
    )
endmacro()

macro(ssg_build_oval_unlinked PRODUCT)
    file(GLOB EXTRA_OVAL_510_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/input/oval/*.xml")
    file(GLOB EXTRA_SHARED_OVAL_510_DEPS "${SSG_SHARED}/oval/*.xml")

    set(BUILD_CHECKS_DIR "${CMAKE_CURRENT_BINARY_DIR}/checks")

    message(STATUS "Scanning for dependencies of ${PRODUCT} OVAL checks...")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_CHECKS_DIR}" --language oval list-inputs
        OUTPUT_VARIABLE OVAL_CHECKS_DEPENDS_STR
    )
    string(REPLACE "\n" ";" OVAL_CHECKS_DEPENDS "${OVAL_CHECKS_DEPENDS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_CHECKS_DIR}" --language oval list-outputs
        OUTPUT_VARIABLE OVAL_CHECKS_OUTPUTS_STR
    )
    string(REPLACE "\n" ";" OVAL_CHECKS_OUTPUTS "${OVAL_CHECKS_OUTPUTS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_CHECKS_DIR}/shared" --language oval list-inputs
        OUTPUT_VARIABLE SHARED_OVAL_CHECKS_DEPENDS_STR
    )
    string(REPLACE "\n" ";" SHARED_OVAL_CHECKS_DEPENDS "${SHARED_OVAL_CHECKS_DEPENDS_STR}")
    execute_process(
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_CHECKS_DIR}/shared" --language oval list-outputs
        OUTPUT_VARIABLE SHARED_OVAL_CHECKS_OUTPUTS_STR
    )
    string(REPLACE "\n" ";" SHARED_OVAL_CHECKS_OUTPUTS "${SHARED_OVAL_CHECKS_OUTPUTS_STR}")

    # TODO: the input/oval parts will *probably* be removed once OVALs are built the same as remediations
    set(OVAL_510_COMBINE_PATHS "oval_5.10:${BUILD_CHECKS_DIR}/shared/oval" "oval_5.10:${SSG_SHARED}/oval" "oval_5.10:${SSG_SHARED}/templates/static/oval" "oval_5.10:${BUILD_CHECKS_DIR}/oval" "oval_5.10:${CMAKE_CURRENT_SOURCE_DIR}/input/oval" "oval_5.10:${CMAKE_CURRENT_SOURCE_DIR}/templates/static/oval")

    if(SSG_OVAL_511_ENABLED)
        file(GLOB EXTRA_OVAL_511_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/input/oval/oval_5.11/*.xml")
        file(GLOB EXTRA_SHARED_OVAL_511_DEPS "${SSG_SHARED}/oval/oval_5.11/*.xml")

        # TODO: the input/oval parts will *probably* be removed once OVALs are built the same as remediations
        set(OVAL_511_COMBINE_PATHS "oval_5.11:${BUILD_CHECKS_DIR}/shared/oval/oval_5.11" "oval_5.11:${SSG_SHARED}/oval/oval_5.11" "oval_5.11:${SSG_SHARED}/templates/static/oval/oval_5.11" "oval_5.11:${BUILD_CHECKS_DIR}/oval/oval_5.11" "oval_5.11:${CMAKE_CURRENT_SOURCE_DIR}/input/oval/oval_5.11" "oval_5.11:${CMAKE_CURRENT_SOURCE_DIR}/templates/static/oval/oval_5.11")

        add_custom_command(
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
            OUTPUT ${OVAL_CHECKS_OUTPUTS}
            OUTPUT ${SHARED_OVAL_CHECKS_OUTPUTS}
            COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_CHECKS_DIR}" --language oval build
            COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_CHECKS_DIR}/shared" --language oval build
            COMMAND RUNTIME_OVAL_VERSION=5.11 "${SSG_SHARED_UTILS}/combine-ovals.py" "${CMAKE_BINARY_DIR}/oval.config" "${PRODUCT}" ${OVAL_510_COMBINE_PATHS} ${OVAL_511_COMBINE_PATHS} > "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
            COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml" "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
            DEPENDS ${OVAL_CHECKS_DEPENDS}
            DEPENDS ${SHARED_OVAL_CHECKS_DEPENDS}
            DEPENDS ${EXTRA_OVAL_511_DEPS}
            DEPENDS ${EXTRA_SHARED_OVAL_511_DEPS}
            DEPENDS ${EXTRA_OVAL_510_DEPS}
            DEPENDS ${EXTRA_SHARED_OVAL_510_DEPS}
            DEPENDS "${SSG_SHARED_UTILS}/generate-from-templates.py"
            DEPENDS "${SSG_SHARED_UTILS}/combine-ovals.py"
            VERBATIM
            COMMENT "[${PRODUCT}-content] generating oval-unlinked.xml (OVAL 5.11 checks enabled)"
        )
    else()
        add_custom_command(
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
            OUTPUT ${OVAL_CHECKS_OUTPUTS}
            OUTPUT ${SHARED_OVAL_CHECKS_OUTPUTS}
            COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_CHECKS_DIR}" --language oval build
            COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_CHECKS_DIR}/shared" --language oval build
            COMMAND "${SSG_SHARED_UTILS}/combine-ovals.py" "${CMAKE_BINARY_DIR}/oval.config" "${PRODUCT}" ${OVAL_510_COMBINE_PATHS} > "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
            COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml" "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
            DEPENDS ${OVAL_CHECKS_DEPENDS}
            DEPENDS ${SHARED_OVAL_CHECKS_DEPENDS}
            DEPENDS ${EXTRA_OVAL_510_DEPS}
            DEPENDS ${EXTRA_SHARED_OVAL_510_DEPS}
            DEPENDS "${SSG_SHARED_UTILS}/generate-from-templates.py"
            DEPENDS "${SSG_SHARED_UTILS}/combine-ovals.py"
            VERBATIM
            COMMENT "[${PRODUCT}-content] generating oval-unlinked.xml (OVAL 5.11 checks disabled)"
        )
    endif()
    add_custom_target(
        generate-internal-${PRODUCT}-oval-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
        DEPENDS ${OVAL_CHECKS_OUTPUTS}
        DEPENDS ${SHARED_OVAL_CHECKS_OUTPUTS}
    )
endmacro()

macro(ssg_build_cpe_dictionary PRODUCT)
    set(SSG_CPE_DICTIONARY "${CMAKE_CURRENT_SOURCE_DIR}/input/oval/platform/${PRODUCT}-cpe-dictionary.xml")

    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
        COMMAND "${SSG_SHARED_UTILS}/cpe-generate.py" ${PRODUCT} ssg "${CMAKE_BINARY_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml" "${SSG_CPE_DICTIONARY}"
        COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml" "${SSG_SHARED_TRANSFORMS}/shared_xml-remove-unneeded-xmlns.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml" "${SSG_SHARED_TRANSFORMS}/shared_xml-remove-unneeded-xmlns.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
        DEPENDS generate-internal-${PRODUCT}-oval-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
        DEPENDS "${SSG_SHARED_UTILS}/cpe-generate.py"
        DEPENDS "${SSG_SHARED_TRANSFORMS}/shared_xml-remove-unneeded-xmlns.xslt"
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-cpe-dictionary.xml, ssg-${PRODUCT}-cpe-oval.xml"
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
        COMMENT "[${PRODUCT}-content] linking IDs, generating xccdf-linked.xml, oval-linked.xml, ocil-linked.xml"
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
        COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" "${SSG_SHARED_TRANSFORMS}/shared_xml-remove-unneeded-xmlns.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-internal-${PRODUCT}-linked-xccdf-oval-ocil.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf-removeaux.xslt"
        DEPENDS "${SSG_SHARED_UTILS}/unselect-empty-xccdf-groups.py"
        DEPENDS "${SSG_SHARED_TRANSFORMS}/shared_xml-remove-unneeded-xmlns.xslt"
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-xccdf.xml"
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
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-xccdf-1.2.xml"
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
        COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml" "${SSG_SHARED_TRANSFORMS}/shared_xml-remove-unneeded-xmlns.xslt" "${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml"
        DEPENDS generate-internal-${PRODUCT}-linked-xccdf-oval-ocil.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml"
        DEPENDS "${SSG_SHARED_TRANSFORMS}/shared_xml-remove-unneeded-xmlns.xslt"
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-oval.xml"
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
        COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml" "${SSG_SHARED_TRANSFORMS}/shared_xml-remove-unneeded-xmlns.xslt" "${CMAKE_CURRENT_BINARY_DIR}/ocil-linked.xml"
        DEPENDS generate-internal-${PRODUCT}-linked-xccdf-oval-ocil.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/ocil-linked.xml"
        DEPENDS "${SSG_SHARED_TRANSFORMS}/shared_xml-remove-unneeded-xmlns.xslt"
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-ocil.xml"
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
        COMMENT "[${PRODUCT}-content] building ssg-${PRODUCT}-pcidss-xccdf-1.2.xml from ssg-${PRODUCT}-xccdf-1.2.xml (PCI-DSS centered benchmark)"
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
    if("${PRODUCT}" MATCHES "rhel(6|7)")
        add_custom_command(
            OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
            COMMAND "${OSCAP_EXECUTABLE}" ds sds-compose "ssg-${PRODUCT}-xccdf-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${SED_EXECUTABLE}" -i 's/schematron-version="[0-9].[0-9]"/schematron-version="1.2"/' "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${OSCAP_EXECUTABLE}" ds sds-add "ssg-${PRODUCT}-cpe-dictionary.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${OSCAP_EXECUTABLE}" ds sds-add "ssg-${PRODUCT}-pcidss-xccdf-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${SSG_SHARED_UTILS}/sds-move-ocil-to-checks.py" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${SSG_SHARED_TRANSFORMS}/shared_xml-remove-unneeded-xmlns.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
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
            DEPENDS "${SSG_SHARED_TRANSFORMS}/shared_xml-remove-unneeded-xmlns.xslt"
            COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-ds.xml"
        )
    else()
        add_custom_command(
            OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
            COMMAND "${OSCAP_EXECUTABLE}" ds sds-compose "ssg-${PRODUCT}-xccdf-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${SED_EXECUTABLE}" -i 's/schematron-version="[0-9].[0-9]"/schematron-version="1.2"/' "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${OSCAP_EXECUTABLE}" ds sds-add "ssg-${PRODUCT}-cpe-dictionary.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${SSG_SHARED_UTILS}/sds-move-ocil-to-checks.py" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${SSG_SHARED_TRANSFORMS}/shared_xml-remove-unneeded-xmlns.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            DEPENDS generate-ssg-${PRODUCT}-xccdf-1.2.xml
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml"
            DEPENDS generate-ssg-${PRODUCT}-oval.xml
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
            DEPENDS generate-ssg-${PRODUCT}-ocil.xml
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
            DEPENDS generate-ssg-${PRODUCT}-cpe-dictionary.xml
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
            DEPENDS "${SSG_SHARED_TRANSFORMS}/shared_xml-remove-unneeded-xmlns.xslt"
            COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-ds.xml"
        )
    endif()
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
    if("${PRODUCT}" MATCHES "rhel(6|7)")
        ssg_build_pci_dss_xccdf(${PRODUCT})
    endif()
    ssg_build_sds(${PRODUCT})

    add_custom_target(${PRODUCT} ALL)

    add_custom_target(
        ${PRODUCT}-content
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS generate-ssg-${PRODUCT}-xccdf-1.2.xml
        DEPENDS generate-ssg-${PRODUCT}-oval.xml
        DEPENDS generate-ssg-${PRODUCT}-ocil.xml
        DEPENDS generate-ssg-${PRODUCT}-cpe-dictionary.xml
        DEPENDS generate-ssg-${PRODUCT}-ds.xml
    )
    add_dependencies(${PRODUCT} ${PRODUCT}-content)

    add_custom_target(
        ${PRODUCT}-validate
        DEPENDS validate-ssg-${PRODUCT}-xccdf.xml
        #DEPENDS validate-ssg-${PRODUCT}-xccdf-1.2.xml
        DEPENDS validate-ssg-${PRODUCT}-oval.xml
        #DEPENDS validate-ssg-${PRODUCT}-ocil.xml
        DEPENDS validate-ssg-${PRODUCT}-cpe-dictionary.xml
        DEPENDS validate-ssg-${PRODUCT}-cpe-oval.xml
        DEPENDS validate-ssg-${PRODUCT}-ds.xml
    )
    add_dependencies(validate ${PRODUCT}-validate)

    ssg_build_html_guides(${PRODUCT})

    add_custom_target(
        ${PRODUCT}-guides
        DEPENDS generate-ssg-${PRODUCT}-guide-index.html
    )
    add_dependencies(${PRODUCT} ${PRODUCT}-guides)

    add_custom_target(
        ${PRODUCT}-tables
        # dependencies are added later using add_dependency
    )
    add_dependencies(${PRODUCT} ${PRODUCT}-tables)

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
        COMMENT "[${DERIVATIVE}-content] generating ssg-${DERIVATIVE}-xccdf.xml"
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
        COMMENT "[${DERIVATIVE}-content] generating ssg-${DERIVATIVE}-ds.xml"
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
    string(REPLACE " " "%20" CMAKE_CURRENT_BINARY_DIR_NO_SPACES "${CMAKE_CURRENT_BINARY_DIR}")
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap.html"
        # We need to use xccdf-linked.xml because ssg-${PRODUCT}-xccdf.xml has the srg_support Group removed
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam map-to-items "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/xccdf-linked.xml" --output "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt" "${SSG_SHARED_REFS}/disa-os-srg-${DISA_SRG_VERSION}.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${SSG_SHARED_REFS}/disa-os-srg-${DISA_SRG_VERSION}.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML SRG map table (flat=no)"
    )
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap-flat.html"
        # We need to use xccdf-linked.xml because ssg-${PRODUCT}-xccdf.xml has the srg_support Group removed
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam flat "y" --stringparam map-to-items "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/xccdf-linked.xml" --output "${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap-flat.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt" "${SSG_SHARED_REFS}/disa-os-srg-${DISA_SRG_VERSION}.xml"
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
