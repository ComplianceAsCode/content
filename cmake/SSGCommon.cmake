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
# $ make -j 4 rhel7-guides rhel7-stats
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
    set(OSCAP_OVAL_VERSION "5.11")
else()
    set(OSCAP_OVAL_VERSION "5.10")
endif()

if(SSG_OVAL_SCHEMATRON_VALIDATION_ENABLED)
    set(OSCAP_OVAL_SCHEMATRON_OPTION "--schematron")
else()
    set(OSCAP_OVAL_SCHEMATRON_OPTION "")
endif()

set(SSG_HTML_GUIDE_FILE_LIST "")
set(SSG_HTML_TABLE_FILE_LIST "")

macro(ssg_build_bash_remediation_functions)
    file(GLOB BASH_REMEDIATION_FUNCTIONS "${CMAKE_SOURCE_DIR}/shared/bash_remediation_functions/*.sh")

    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/bash-remediation-functions.xml"
        COMMAND "${SSG_SHARED_UTILS}/generate-bash-remediation-functions.py" --input "${SSG_SHARED}/bash_remediation_functions" --output "${CMAKE_BINARY_DIR}/bash-remediation-functions.xml"
        DEPENDS ${BASH_REMEDIATION_FUNCTIONS}
        DEPENDS "${SSG_SHARED_UTILS}/generate-bash-remediation-functions.py"
        COMMENT "[bash-remediation-functions] generating bash-remediation-functions.xml"
    )
    add_custom_target(
        generate-internal-bash-remediation-functions.xml
        DEPENDS "${CMAKE_BINARY_DIR}/bash-remediation-functions.xml"
    )
endmacro()

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
    file(GLOB OVERLAYS_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/overlays/*.xml")
    file(GLOB PROFILE_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/profiles/*.xml")
    file(GLOB_RECURSE XCCDF_RULE_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/xccdf/*.xml")
    file(GLOB_RECURSE SHARED_XCCDF_RULE_DEPS "${SSG_SHARED}/xccdf/*.xml")

    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam SHARED_RP "${SSG_SHARED}" --stringparam BUILD_RP "${CMAKE_BINARY_DIR}" --output "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml" "${CMAKE_CURRENT_SOURCE_DIR}/guide.xslt" "${CMAKE_CURRENT_BINARY_DIR}/guide.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml" "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
        DEPENDS generate-internal-bash-remediation-functions.xml
        DEPENDS "${CMAKE_BINARY_DIR}/bash-remediation-functions.xml"
        DEPENDS generate-internal-${PRODUCT}-guide.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/guide.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/guide.xslt"
        DEPENDS ${OVERLAYS_DEPS}
        DEPENDS ${PROFILE_DEPS}
        DEPENDS ${XCCDF_RULE_DEPS}
        DEPENDS ${SHARED_XCCDF_RULE_DEPS}
        COMMENT "[${PRODUCT}-content] generating shorthand.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-shorthand.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
    )
endmacro()

macro(ssg_build_xccdf_unlinked PRODUCT)
    file(GLOB STIG_REFERENCE_FILE_LIST "${SSG_SHARED_REFS}/disa-stig-${PRODUCT}-*-xccdf-manual.xml")
    list(APPEND STIG_REFERENCE_FILE_LIST "not-found")
    list(GET STIG_REFERENCE_FILE_LIST 0 STIG_REFERENCE_FILE)
    
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam ssg_version "${SSG_VERSION}" --output "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/shorthand2xccdf.xslt" "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
        COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" xccdf resolve -o "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
        COMMAND "${SSG_SHARED_UTILS}/add_stig_references.py" --disa-stig "${STIG_REFERENCE_FILE}" --unlinked-xccdf "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
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
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam ssg_version "${SSG_VERSION}" --output "${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml" "${SSG_SHARED_TRANSFORMS}/xccdf-create-ocil.xslt" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
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
    set(BUILD_REMEDIATIONS_DIR "${CMAKE_CURRENT_BINARY_DIR}/fixes")

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
    file(GLOB EXTRA_LANGUAGE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/fixes/${LANGUAGE}/*")
    file(GLOB EXTRA_SHARED_LANGUAGE_DEPENDS "${SSG_SHARED}/fixes/${LANGUAGE}/*")

    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${LANGUAGE}-fixes.xml"
        OUTPUT ${LANGUAGE_REMEDIATIONS_OUTPUTS}
        OUTPUT ${SHARED_LANGUAGE_REMEDIATIONS_OUTPUTS}
        # We have to remove the entire dir to avoid keeping remediations when user removes something from the CSV
        COMMAND "${CMAKE_COMMAND}" -E remove_directory "${BUILD_REMEDIATIONS_DIR}/${LANGUAGE}"
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_REMEDIATIONS_DIR}" --language ${LANGUAGE} build
        # We have to remove the entire dir to avoid keeping remediations when user removes something from the CSV
        COMMAND "${CMAKE_COMMAND}" -E remove_directory "${BUILD_REMEDIATIONS_DIR}/shared/${LANGUAGE}"
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_REMEDIATIONS_DIR}/shared" --language ${LANGUAGE} build
        COMMAND "${SSG_SHARED_UTILS}/combine-remediations.py" --product "${PRODUCT}" --remediation_type "${LANGUAGE}" --build_dir "${CMAKE_BINARY_DIR}" --output "${CMAKE_CURRENT_BINARY_DIR}/${LANGUAGE}-fixes.xml" "${BUILD_REMEDIATIONS_DIR}/shared/${LANGUAGE}" "${SSG_SHARED}/fixes/${LANGUAGE}" "${BUILD_REMEDIATIONS_DIR}/${LANGUAGE}" "${CMAKE_CURRENT_SOURCE_DIR}/fixes/${LANGUAGE}"
        DEPENDS generate-internal-bash-remediation-functions.xml
        DEPENDS "${CMAKE_BINARY_DIR}/bash-remediation-functions.xml"
        DEPENDS ${LANGUAGE_REMEDIATIONS_DEPENDS}
        DEPENDS ${SHARED_LANGUAGE_REMEDIATIONS_DEPENDS}
        DEPENDS ${EXTRA_LANGUAGE_DEPENDS}
        DEPENDS ${EXTRA_SHARED_LANGUAGE_DEPENDS}
        DEPENDS "${SSG_SHARED_UTILS}/generate-from-templates.py"
        DEPENDS "${SSG_SHARED_UTILS}/combine-remediations.py"
        COMMENT "[${PRODUCT}-content] generating ${LANGUAGE}-fixes.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-${LANGUAGE}-fixes.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${LANGUAGE}-fixes.xml"
    )

if (SSG_SHELLCHECK_BASH_FIXES_VALIDATION_ENABLED AND SHELLCHECK_EXECUTABLE AND "${LANGUAGE}" STREQUAL "bash")
        file(GLOB BASH_REMEDIATION_FUNCTIONS "${CMAKE_SOURCE_DIR}/shared/bash_remediation_functions/*.sh")

        add_test(
            NAME "shellcheck-${PRODUCT}-bash-fixes"
            # format gcc so that people using IDEs can click on errors to get to the problematic lines
            # SC1071: ShellCheck only supports sh/bash/ksh scripts
            # SC1091: Not following: /usr/share/scap-security-guide/remediation_functions
            # TODO: Stop ignoring the exit code as we fix the bash issues
            COMMAND "${SHELLCHECK_EXECUTABLE}" --format gcc --shell bash --exclude SC1071,SC1091 ${BASH_REMEDIATION_FUNCTIONS} ${LANGUAGE_REMEDIATIONS_DEPENDS} ${SHARED_LANGUAGE_REMEDIATIONS_DEPENDS} ${EXTRA_LANGUAGE_DEPENDS} ${EXTRA_SHARED_LANGUAGE_DEPENDS}
        )
    endif()
endmacro()

macro(ssg_build_remediations PRODUCT)
    message(STATUS "Scanning for dependencies of ${PRODUCT} fixes (bash, ansible, puppet and anaconda)...")
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
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam bash_remediations "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/bash-fixes.xml" --stringparam ansible_remediations "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/ansible-fixes.xml" --stringparam puppet_remediations "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/puppet-fixes.xml" --stringparam anaconda_remediations "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/anaconda-fixes.xml" --output "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml" "${SSG_SHARED_TRANSFORMS}/xccdf-addremediations.xslt" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml"
        DEPENDS generate-internal-${PRODUCT}-xccdf-unlinked-ocilrefs.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml"
        DEPENDS generate-internal-${PRODUCT}-bash-fixes.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/bash-fixes.xml"
        DEPENDS generate-internal-${PRODUCT}-ansible-fixes.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/ansible-fixes.xml"
        DEPENDS generate-internal-${PRODUCT}-puppet-fixes.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/puppet-fixes.xml"
        DEPENDS generate-internal-${PRODUCT}-anaconda-fixes.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/anaconda-fixes.xml"
        DEPENDS "${SSG_SHARED_TRANSFORMS}/xccdf-addremediations.xslt"
        COMMENT "[${PRODUCT}-content] generating xccdf-unlinked.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-xccdf-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml"
    )
endmacro()

macro(ssg_build_oval_unlinked PRODUCT)
    file(GLOB EXTRA_OVAL_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/checks/oval/*.xml")
    file(GLOB EXTRA_SHARED_OVAL_DEPS "${SSG_SHARED}/checks/oval/*.xml")

    set(BUILD_CHECKS_DIR "${CMAKE_CURRENT_BINARY_DIR}/checks")

    message(STATUS "Scanning for dependencies of ${PRODUCT} checks (OVAL)...")
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

    if("${PRODUCT}" MATCHES "rhel-osp7")
        # Don't traverse $(SHARED_OVAL) for the case of RHEL-OSP7 product for now
        set(OVAL_COMBINE_PATHS "${BUILD_CHECKS_DIR}/shared/oval" "${BUILD_CHECKS_DIR}/oval" "${CMAKE_CURRENT_SOURCE_DIR}/checks/oval")
    else()
        set(OVAL_COMBINE_PATHS "${BUILD_CHECKS_DIR}/shared/oval" "${SSG_SHARED}/checks/oval" "${BUILD_CHECKS_DIR}/oval" "${CMAKE_CURRENT_SOURCE_DIR}/checks/oval")
    endif()

    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
        OUTPUT ${OVAL_CHECKS_OUTPUTS}
        OUTPUT ${SHARED_OVAL_CHECKS_OUTPUTS}
        # We have to remove all old checks in case the user removed something from the CSV files
        COMMAND "${CMAKE_COMMAND}" -E remove_directory "${BUILD_CHECKS_DIR}/oval"
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${CMAKE_CURRENT_SOURCE_DIR}/templates" --output "${BUILD_CHECKS_DIR}" --language oval build
        # We have to remove all old shared checks in case the user removed something from the CSV files
        COMMAND "${CMAKE_COMMAND}" -E remove_directory "${BUILD_CHECKS_DIR}/shared/oval"
        COMMAND "${SSG_SHARED_UTILS}/generate-from-templates.py" --shared "${SSG_SHARED}" --oval_version "${OSCAP_OVAL_VERSION}" --input "${SSG_SHARED}/templates" --output "${BUILD_CHECKS_DIR}/shared" --language oval build
        COMMAND "${SSG_SHARED_UTILS}/combine-ovals.py" --ssg_version "${SSG_VERSION}" --product "${PRODUCT}" --oval_config "${CMAKE_BINARY_DIR}/oval.config" --oval_version "${OSCAP_OVAL_VERSION}" --output "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml" ${OVAL_COMBINE_PATHS}
        COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml" "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
        DEPENDS ${OVAL_CHECKS_DEPENDS}
        DEPENDS ${SHARED_OVAL_CHECKS_DEPENDS}
        DEPENDS ${EXTRA_OVAL_DEPS}
        DEPENDS ${EXTRA_SHARED_OVAL_DEPS}
        DEPENDS "${SSG_SHARED_UTILS}/generate-from-templates.py"
        DEPENDS "${SSG_SHARED_UTILS}/combine-ovals.py"
        COMMENT "[${PRODUCT}-content] generating oval-unlinked.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-oval-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
    )
endmacro()

macro(ssg_build_cpe_dictionary PRODUCT)
    set(SSG_CPE_DICTIONARY "${CMAKE_CURRENT_SOURCE_DIR}/cpe/${PRODUCT}-cpe-dictionary.xml")

    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
        COMMAND "${SSG_SHARED_UTILS}/cpe-generate.py" ${PRODUCT} ssg "${CMAKE_BINARY_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml" "${SSG_CPE_DICTIONARY}"
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
        DEPENDS generate-internal-${PRODUCT}-oval-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
        DEPENDS "${SSG_CPE_DICTIONARY}"
        DEPENDS "${SSG_SHARED_UTILS}/cpe-generate.py"
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-cpe-dictionary.xml, ssg-${PRODUCT}-cpe-oval.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-cpe-dictionary.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
    )
    add_test(
        NAME "validate-ssg-${PRODUCT}-cpe-dictionary.xml"
        COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" cpe validate "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
    )
    add_test(
        NAME "validate-ssg-${PRODUCT}-cpe-oval.xml"
        COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" oval validate ${OSCAP_OVAL_SCHEMATRON_OPTION} "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
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
        # Remove overlays Groups which are only for use in tables, and not guide output.
        COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" "${CMAKE_SOURCE_DIR}/shared/transforms/shared_xccdf-removeaux.xslt" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked.xml"
        COMMAND "${SED_EXECUTABLE}" -i "s/oval-linked.xml/ssg-${PRODUCT}-oval.xml/g" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMAND "${SED_EXECUTABLE}" -i "s/ocil-linked.xml/ssg-${PRODUCT}-ocil.xml/g" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMAND "${SSG_SHARED_UTILS}/unselect-empty-xccdf-groups.py" --input "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" xccdf resolve -o "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-internal-${PRODUCT}-linked-xccdf-oval-ocil.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked.xml"
        DEPENDS "${CMAKE_SOURCE_DIR}/shared/transforms/shared_xccdf-removeaux.xslt"
        DEPENDS "${SSG_SHARED_UTILS}/unselect-empty-xccdf-groups.py"
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-xccdf.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
    )
    add_test(
        NAME "validate-ssg-${PRODUCT}-xccdf.xml"
        COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" xccdf validate "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
    )
    add_test(
        NAME "verify-references-ssg-${PRODUCT}-xccdf.xml"
        COMMAND "${SSG_SHARED_UTILS}/verify-references.py" --rules-with-invalid-checks --ovaldefs-unused "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
    )
    add_test(
        NAME "verify-ssg-${PRODUCT}-xccdf.xml-override-true-all-profile-titles"
        COMMAND "${XMLLINT_EXECUTABLE}" --xpath "//*[local-name()=\"Profile\"]/*[local-name()=\"title\"][not(@override=\"true\")]" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
    )
    add_test(
        NAME "verify-ssg-${PRODUCT}-xccdf.xml-override-true-all-profile-descriptions"
        COMMAND "${XMLLINT_EXECUTABLE}" --xpath "//*[local-name()=\"Profile\"]/*[local-name()=\"description\"][not(@override=\"true\")]" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
    )
    # Sets WILL_FAIL property for all '*-override-true-all-profile-*' tests to
    # true as it is expected that XPath of a passing test will be empty (and
    # non-zero exit code is returned in such case).
    set_tests_properties(
        "verify-ssg-${PRODUCT}-xccdf.xml-override-true-all-profile-titles"
        "verify-ssg-${PRODUCT}-xccdf.xml-override-true-all-profile-descriptions"
        PROPERTIES
        WILL_FAIL true
    )

    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml"
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam reverse_DNS "org.${SSG_VENDOR}.content" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml" "${OPENSCAP_XCCDF_XSL_1_2}" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-xccdf-1.2.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-xccdf-1.2.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml"
    )
endmacro()

macro(ssg_build_oval_final PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml" "${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml"
        DEPENDS generate-internal-${PRODUCT}-linked-xccdf-oval-ocil.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml"
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-oval.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-oval.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
    )
    add_test(
        NAME "validate-ssg-${PRODUCT}-oval.xml"
        COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" oval validate ${OSCAP_OVAL_SCHEMATRON_OPTION} "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
    )
endmacro()

macro(ssg_build_ocil_final PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml" "${CMAKE_CURRENT_BINARY_DIR}/ocil-linked.xml"
        DEPENDS generate-internal-${PRODUCT}-linked-xccdf-oval-ocil.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/ocil-linked.xml"
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-ocil.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-ocil.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
    )
endmacro()

macro(ssg_build_pci_dss_xccdf PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-pcidss-xccdf-1.2.xml"
        COMMAND "${SSG_SHARED_TRANSFORMS}/pcidss/transform_benchmark_to_pcidss.py" "${SSG_SHARED_TRANSFORMS}/pcidss/PCI_DSS.json" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-pcidss-xccdf-1.2.xml"
        DEPENDS "${SSG_SHARED_TRANSFORMS}/pcidss/transform_benchmark_to_pcidss.py"
        DEPENDS "${SSG_SHARED_TRANSFORMS}/pcidss/PCI_DSS.json"
        DEPENDS generate-ssg-${PRODUCT}-xccdf-1.2.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml"
        COMMENT "[${PRODUCT}-content] building ssg-${PRODUCT}-pcidss-xccdf-1.2.xml from ssg-${PRODUCT}-xccdf-1.2.xml (PCI-DSS centered benchmark)"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-pcidss-xccdf-1.2.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-pcidss-xccdf-1.2.xml"
    )
endmacro()

macro(ssg_build_sds PRODUCT)
    if("${PRODUCT}" MATCHES "rhel(6|7)")
        add_custom_command(
            OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
            # use --skip-valid here to avoid repeatedly validating everything
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-compose --skip-valid "ssg-${PRODUCT}-xccdf-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${SED_EXECUTABLE}" -i 's/schematron-version="[0-9].[0-9]"/schematron-version="1.2"/' "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-add --skip-valid "ssg-${PRODUCT}-cpe-dictionary.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-add --skip-valid "ssg-${PRODUCT}-pcidss-xccdf-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${SSG_SHARED_UTILS}/sds-move-ocil-to-checks.py" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
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
            COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-ds.xml"
        )
    else()
        add_custom_command(
            OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
            # use --skip-valid here to avoid repeatedly validating everything
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-compose --skip-valid "ssg-${PRODUCT}-xccdf-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${SED_EXECUTABLE}" -i 's/schematron-version="[0-9].[0-9]"/schematron-version="1.2"/' "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-add --skip-valid "ssg-${PRODUCT}-cpe-dictionary.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${SSG_SHARED_UTILS}/sds-move-ocil-to-checks.py" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            DEPENDS generate-ssg-${PRODUCT}-xccdf-1.2.xml
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml"
            DEPENDS generate-ssg-${PRODUCT}-oval.xml
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
            DEPENDS generate-ssg-${PRODUCT}-ocil.xml
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
            DEPENDS generate-ssg-${PRODUCT}-cpe-dictionary.xml
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
            COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-ds.xml"
        )
    endif()
    add_custom_target(
        generate-ssg-${PRODUCT}-ds.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
    )

    add_test(
        NAME "validate-ssg-${PRODUCT}-ds.xml"
        COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-validate "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
    )
endmacro()

macro(ssg_build_html_guides PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/guides/ssg-${PRODUCT}-guide-index.html"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/guides"
        COMMAND "${SSG_SHARED_UTILS}/build-all-guides.py" --input "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" --output "${CMAKE_BINARY_DIR}/guides" build
        DEPENDS generate-ssg-${PRODUCT}-ds.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMENT "[${PRODUCT}-guides] generating HTML guides for all profiles in ssg-${PRODUCT}-ds.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-guide-index.html
        DEPENDS "${CMAKE_BINARY_DIR}/guides/ssg-${PRODUCT}-guide-index.html"
    )

    # despite checking just the index this actually tests all the guides because the index links to them
    # needs PARENT_SCOPE because this is done across different cmake files via add_directory(..)
    set(SSG_HTML_GUIDE_FILE_LIST "${SSG_HTML_GUIDE_FILE_LIST};${CMAKE_BINARY_DIR}/guides/ssg-${PRODUCT}-guide-index.html" PARENT_SCOPE)
endmacro()

macro(ssg_build_remediation_roles PRODUCT TEMPLATE EXTENSION)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/roles/all-roles-${PRODUCT}-${EXTENSION}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/roles"
        COMMAND "${SSG_SHARED_UTILS}/build-all-remediation-roles.py" --input "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" --output "${CMAKE_BINARY_DIR}/roles" --template "${TEMPLATE}" --extension "${EXTENSION}" build
        COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_BINARY_DIR}/roles/all-roles-${PRODUCT}-${EXTENSION}"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMENT "[${PRODUCT}-roles] generating ${TEMPLATE} remediation roles for all profiles in ssg-${PRODUCT}-xccdf.xml"
    )
    add_custom_target(
        generate-all-roles-${PRODUCT}-${EXTENSION}
        DEPENDS "${CMAKE_BINARY_DIR}/roles/all-roles-${PRODUCT}-${EXTENSION}"
    )
endmacro()

macro(ssg_make_stats_for_product PRODUCT)
    add_custom_target(${PRODUCT}-stats
        COMMAND ${CMAKE_COMMAND} -E echo "Benchmark statistics for '${PRODUCT}':"
        COMMAND "${SSG_SHARED_UTILS}/profile-stats.py" --benchmark "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" --profile all
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMENT "[${PRODUCT}-stats] generating benchmark statistics"
    )
    add_custom_target(${PRODUCT}-profile-stats
        COMMAND ${CMAKE_COMMAND} -E echo "Per profile statistics for '${PRODUCT}':"
        COMMAND "${SSG_SHARED_UTILS}/profile-stats.py" --benchmark "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMENT "[${PRODUCT}-profile-stats] generating per profile statistics"
    )
endmacro()

macro(ssg_build_product PRODUCT)
    add_custom_target(${PRODUCT}-content)

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
    add_dependencies(${PRODUCT} ${PRODUCT}-content)

    add_dependencies(
        ${PRODUCT}-content
        generate-ssg-${PRODUCT}-xccdf.xml
        generate-ssg-${PRODUCT}-xccdf-1.2.xml
        generate-ssg-${PRODUCT}-oval.xml
        generate-ssg-${PRODUCT}-ocil.xml
        generate-ssg-${PRODUCT}-cpe-dictionary.xml
        generate-ssg-${PRODUCT}-ds.xml
    )

    add_dependencies(zipfile "generate-ssg-${PRODUCT}-ds.xml")

    ssg_build_html_guides(${PRODUCT})
    ssg_build_remediation_roles(${PRODUCT} "urn:xccdf:fix:script:ansible" "yml")
    ssg_build_remediation_roles(${PRODUCT} "urn:xccdf:fix:script:sh" "sh")

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

    add_custom_target(
        ${PRODUCT}-roles
        DEPENDS generate-all-roles-${PRODUCT}-yml
        DEPENDS generate-all-roles-${PRODUCT}-sh
    )
    add_dependencies(${PRODUCT} ${PRODUCT}-roles)
    add_dependencies(zipfile "${PRODUCT}-roles")

    ssg_make_stats_for_product(${PRODUCT})
    add_dependencies(stats ${PRODUCT}-stats)
    add_dependencies(profile-stats ${PRODUCT}-profile-stats)

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
        # The globbing expression below is made loose so that it can also match
        # guides for PCIDSS centric benchmarks
        CODE "
        file(GLOB GUIDE_FILES \"${CMAKE_BINARY_DIR}/guides/ssg-${PRODUCT}-*.html\") \n
        if(NOT IS_ABSOLUTE ${SSG_GUIDE_INSTALL_DIR})
            file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/${SSG_GUIDE_INSTALL_DIR}\"
                TYPE FILE FILES \${GUIDE_FILES})
        else()
            file(INSTALL DESTINATION \"${SSG_GUIDE_INSTALL_DIR}\"
                TYPE FILE FILES \${GUIDE_FILES})
        endif()
        "
    )
    install(
        CODE "
        file(GLOB ROLE_FILES \"${CMAKE_BINARY_DIR}/roles/ssg-${PRODUCT}-role-*.yml\") \n
        if(NOT IS_ABSOLUTE ${SSG_ANSIBLE_ROLE_INSTALL_DIR})
            file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/${SSG_ANSIBLE_ROLE_INSTALL_DIR}\"
                TYPE FILE FILES \${ROLE_FILES})
        else()
            file(INSTALL DESTINATION \"${SSG_ANSIBLE_ROLE_INSTALL_DIR}\"
                TYPE FILE FILES \${ROLE_FILES})
        endif()
        "
    )
    install(
        CODE "
        file(GLOB ROLE_FILES \"${CMAKE_BINARY_DIR}/roles/ssg-${PRODUCT}-role-*.sh\") \n
        if(NOT IS_ABSOLUTE ${SSG_BASH_ROLE_INSTALL_DIR})
            file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/${SSG_BASH_ROLE_INSTALL_DIR}\"
                TYPE FILE FILES \${ROLE_FILES})
        else()
            file(INSTALL DESTINATION \"${SSG_BASH_ROLE_INSTALL_DIR}\"
                TYPE FILE FILES \${ROLE_FILES})
        endif()
        "
    )

    # grab all the kickstarts (if any) and install them
    file(GLOB KICKSTART_FILES "${CMAKE_CURRENT_SOURCE_DIR}/kickstart/ssg-${PRODUCT}-*-ks.cfg")
    install(FILES ${KICKSTART_FILES}
        DESTINATION "${SSG_KICKSTART_INSTALL_DIR}")
endmacro()

macro(ssg_build_derivative_product ORIGINAL SHORTNAME DERIVATIVE)
    add_custom_target(${DERIVATIVE}-content)

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
    add_test(
        NAME "validate-ssg-${DERIVATIVE}-xccdf.xml"
        COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${DERIVATIVE}-xccdf.xml"
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
    add_test(
        NAME "validate-ssg-${DERIVATIVE}-ds.xml"
        COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-validate "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
    )

    add_custom_target(${DERIVATIVE} ALL)
    add_dependencies(${DERIVATIVE} ${DERIVATIVE}-content)

    add_dependencies(
        ${DERIVATIVE}-content
        generate-ssg-${DERIVATIVE}-xccdf.xml
        generate-ssg-${DERIVATIVE}-ds.xml
    )

    add_dependencies(zipfile "generate-ssg-${DERIVATIVE}-ds.xml")

    ssg_build_html_guides(${DERIVATIVE})
    ssg_build_remediation_roles(${DERIVATIVE} "urn:xccdf:fix:script:ansible" "yml")
    ssg_build_remediation_roles(${DERIVATIVE} "urn:xccdf:fix:script:sh" "sh")

    add_custom_target(
        ${DERIVATIVE}-guides
        DEPENDS generate-ssg-${DERIVATIVE}-guide-index.html
    )
    add_dependencies(${DERIVATIVE} ${DERIVATIVE}-guides)

    add_custom_target(
        ${DERIVATIVE}-roles
        DEPENDS generate-all-roles-${DERIVATIVE}-yml
        DEPENDS generate-all-roles-${DERIVATIVE}-sh
    )
    add_dependencies(${DERIVATIVE} ${DERIVATIVE}-roles)

    install(FILES "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")

    # This is a common cmake trick, we need the globbing to happen at build time
    # and not configure time.
    install(
        CODE "
        file(GLOB GUIDE_FILES \"${CMAKE_BINARY_DIR}/guides/ssg-${DERIVATIVE}-guide-*.html\") \n
        if(NOT IS_ABSOLUTE ${SSG_GUIDE_INSTALL_DIR})
            file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/${SSG_GUIDE_INSTALL_DIR}\"
                TYPE FILE FILES \${GUIDE_FILES})
        else()
            file(INSTALL DESTINATION \"${SSG_GUIDE_INSTALL_DIR}\"
                TYPE FILE FILES \${GUIDE_FILES})
        endif()
        "
    )
    install(
        CODE "
        file(GLOB ROLE_FILES \"${CMAKE_BINARY_DIR}/roles/ssg-${DERIVATIVE}-role-*.yml\") \n
        if(NOT IS_ABSOLUTE ${SSG_ANSIBLE_ROLE_INSTALL_DIR})
            file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/${SSG_ANSIBLE_ROLE_INSTALL_DIR}\"
                TYPE FILE FILES \${ROLE_FILES})
        else()
            file(INSTALL DESTINATION \"${SSG_ANSIBLE_ROLE_INSTALL_DIR}\"
                TYPE FILE FILES \${ROLE_FILES})
        endif()
        "
    )
    install(
        CODE "
        file(GLOB ROLE_FILES \"${CMAKE_BINARY_DIR}/roles/ssg-${DERIVATIVE}-role-*.sh\") \n
        if(NOT IS_ABSOLUTE ${SSG_BASH_ROLE_INSTALL_DIR})
            file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/${SSG_BASH_ROLE_INSTALL_DIR}\"
                TYPE FILE FILES \${ROLE_FILES})
        else()
            file(INSTALL DESTINATION \"${SSG_BASH_ROLE_INSTALL_DIR}\"
                TYPE FILE FILES \${ROLE_FILES})
        endif()
        "
    )
endmacro()

macro(ssg_build_html_table_by_ref PRODUCT REF)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-${REF}refs.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND "${XSLTPROC_EXECUTABLE}" -stringparam ref "${REF}" --output "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-${REF}refs.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-byref.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-byref.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML table for ${REF} references"
    )
    add_custom_target(
        generate-${PRODUCT}-table-by-ref-${REF}
        DEPENDS "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-${REF}refs.html"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}-table-by-ref-${REF})

    # needs PARENT_SCOPE because this is done across different cmake files via add_directory(..)
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST};${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-${REF}refs.html" PARENT_SCOPE)

    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-${REF}refs.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_build_html_nistrefs_table PRODUCT PROFILE)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-nistrefs-${PROFILE}.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND "${XSLTPROC_EXECUTABLE}" -stringparam profile "${PROFILE}" --output "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-nistrefs-${PROFILE}.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profilenistrefs.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profilenistrefs.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML NIST refs table for ${PROFILE} profile"
    )
    add_custom_target(
        generate-${PRODUCT}-table-nistrefs-${PROFILE}
        DEPENDS "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-nistrefs-${PROFILE}.html"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}-table-nistrefs-${PROFILE})

    # needs PARENT_SCOPE because this is done across different cmake files via add_directory(..)
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST};${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-nistrefs-${PROFILE}.html" PARENT_SCOPE)

    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-nistrefs-${PROFILE}.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_build_html_anssirefs_table PRODUCT PROFILE)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-anssirefs-${PROFILE}.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND "${XSLTPROC_EXECUTABLE}" -stringparam profile "anssi_${PROFILE}" --output "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-anssirefs-${PROFILE}.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profileanssirefs.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profileanssirefs.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML ANSSI refs table for anssi_${PROFILE} profile"
    )
    add_custom_target(
        generate-${PRODUCT}-table-anssirefs-${PROFILE}
        DEPENDS "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-anssirefs-${PROFILE}.html"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}-table-anssirefs-${PROFILE})

    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-anssirefs-${PROFILE}.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_build_html_cce_table PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-cces.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-cces.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-cce.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-cce.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML CCE identifiers table"
    )
    add_custom_target(
        generate-${PRODUCT}-table-cces
        DEPENDS "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-cces.html"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}-table-cces)

    # needs PARENT_SCOPE because this is done across different cmake files via add_directory(..)
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST};${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-cces.html" PARENT_SCOPE)

    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-cces.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_build_html_srgmap_tables PRODUCT DISA_SRG_TYPE DISA_SRG_VERSION)
    # we have to encode spaces in paths before passing them as stringparams to xsltproc
    string(REPLACE " " "%20" CMAKE_CURRENT_BINARY_DIR_NO_SPACES "${CMAKE_CURRENT_BINARY_DIR}")
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        # We need to use xccdf-linked.xml because ssg-${PRODUCT}-xccdf.xml has the srg_support Group removed
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam map-to-items "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/xccdf-linked.xml" --output "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt" "${SSG_SHARED_REFS}/disa-${DISA_SRG_TYPE}-srg-${DISA_SRG_VERSION}.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${SSG_SHARED_REFS}/disa-${DISA_SRG_TYPE}-srg-${DISA_SRG_VERSION}.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML SRG map table (flat=no)"
    )
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap-flat.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        # We need to use xccdf-linked.xml because ssg-${PRODUCT}-xccdf.xml has the srg_support Group removed
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam flat "y" --stringparam map-to-items "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/xccdf-linked.xml" --output "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap-flat.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt" "${SSG_SHARED_REFS}/disa-${DISA_SRG_TYPE}-srg-${DISA_SRG_VERSION}.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${SSG_SHARED_REFS}/disa-${DISA_SRG_TYPE}-srg-${DISA_SRG_VERSION}.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML SRG map table (flat=yes)"
    )
    add_custom_target(
        generate-${PRODUCT}-table-srg
        DEPENDS "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap.html"
        DEPENDS "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap-flat.html"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}-table-srg)

    # needs PARENT_SCOPE because this is done across different cmake files via add_directory(..)
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST};${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap.html;${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap-flat.html" PARENT_SCOPE)

    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap-flat.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_build_html_stig_tables PRODUCT STIG_PROFILE DISA_STIG_VERSION)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-manual.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-manual.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-stig.xslt" "${SSG_SHARED_REFS}/disa-stig-${PRODUCT}-${DISA_STIG_VERSION}-xccdf-manual.xml"
        DEPENDS "${SSG_SHARED_REFS}/disa-stig-${PRODUCT}-${DISA_STIG_VERSION}-xccdf-manual.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-stig.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML MANUAL STIG table"
    )
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-testinfo.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND "${XSLTPROC_EXECUTABLE}" -stringparam profile "${STIG_PROFILE}" -stringparam testinfo "y" --output "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-testinfo.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profileccirefs.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profileccirefs.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML STIG test info document"
    )
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/unlinked-stig-xccdf.xml"
        COMMAND "${XSLTPROC_EXECUTABLE}" -stringparam overlay "${CMAKE_CURRENT_SOURCE_DIR}/overlays/stig_overlay.xml" --output "${CMAKE_CURRENT_BINARY_DIR}/unlinked-stig-xccdf.xml" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf-apply-overlay-stig.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf-apply-overlay-stig.xslt"
        COMMENT "[${PRODUCT}-tables] generating unlinked STIG XCCDF XML file"
    )
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-stig.xslt" "${CMAKE_CURRENT_BINARY_DIR}/unlinked-stig-xccdf.xml"
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/unlinked-stig-xccdf.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-stig.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML STIG table"
    )
    add_custom_target(
        generate-${PRODUCT}-table-stig
        DEPENDS "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig.html"
        DEPENDS "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-manual.html"
        DEPENDS "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-testinfo.html"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}-table-stig)

    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST};${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig.html;${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-manual.html" PARENT_SCOPE)

    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-testinfo.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_define_guide_and_table_tests)
    if (SSG_LINKCHECKER_VALIDATION_ENABLED AND LINKCHECKER_EXECUTABLE)
        add_test(
            NAME "linkchecker-ssg-guides"
            COMMAND "${LINKCHECKER_EXECUTABLE}" --check-extern ${SSG_HTML_GUIDE_FILE_LIST}
        )

        add_test(
            NAME "linkchecker-ssg-tables"
            COMMAND "${LINKCHECKER_EXECUTABLE}" --check-extern ${SSG_HTML_TABLE_FILE_LIST}
        )
    endif()

    if (GREP_EXECUTABLE)
        foreach(TABLE_FILE ${SSG_HTML_TABLE_FILE_LIST})
            string(REPLACE "${CMAKE_BINARY_DIR}/tables/" "" TEST_NAME "${TABLE_FILE}")
            # -z treats newlines as regular chars so we can match multi-line
            # -v inverts the match, we are trying to make sure the tables don't
            #    match this pattern
            add_test(
                NAME "sanity-ssg-tables-${TEST_NAME}"
                COMMAND "${GREP_EXECUTABLE}" "-zv" "</thead>[[:space:]]*</table>" "${TABLE_FILE}"
            )
        endforeach()
    endif()
endmacro()

macro(ssg_build_zipfile ZIPNAME)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/zipfile/${ZIPNAME}.zip"
        COMMAND ${CMAKE_COMMAND} -E remove_directory "zipfile/"
        COMMAND ${CMAKE_COMMAND} -E make_directory "zipfile/${ZIPNAME}"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/README.md" "zipfile/${ZIPNAME}"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/Contributors.md" "zipfile/${ZIPNAME}"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/LICENSE" "zipfile/${ZIPNAME}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "zipfile/${ZIPNAME}/kickstart"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/rhel{6,7}/kickstart/*-ks.cfg" "zipfile/${ZIPNAME}/kickstart"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_BINARY_DIR}/ssg-*-ds.xml" "zipfile/${ZIPNAME}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "zipfile/${ZIPNAME}/roles"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_BINARY_DIR}/roles/*.sh" "zipfile/${ZIPNAME}/roles"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_BINARY_DIR}/roles/*.yml" "zipfile/${ZIPNAME}/roles"
        COMMAND ${CMAKE_COMMAND} -E chdir "zipfile" ${CMAKE_COMMAND} -E tar "cvf" "${ZIPNAME}.zip" --format=zip "${ZIPNAME}"
        COMMENT "Building zipfile at ${CMAKE_BINARY_DIR}/zipfile/${ZIPNAME}.zip"
        )
    add_custom_target(
        zipfile
        DEPENDS "${CMAKE_BINARY_DIR}/zipfile/${ZIPNAME}.zip"
    )
endmacro()

macro(ssg_build_nist_zipfile ZIPNAME)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/nist-zipfile/${ZIPNAME}-nist.zip"
        COMMAND ${CMAKE_COMMAND} -E remove_directory "nist-zipfile/"
        COMMAND ${CMAKE_COMMAND} -E make_directory "nist-zipfile/${ZIPNAME}"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/LICENSE" "nist-zipfile/${ZIPNAME}"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_BINARY_DIR}/ssg-rhel{6,7}-ds.xml" "nist-zipfile/${ZIPNAME}"
        COMMAND ${CMAKE_COMMAND} -E chdir "nist-zipfile" ${CMAKE_COMMAND} -E tar "cvf" "${ZIPNAME}-nist.zip" --format=zip "${ZIPNAME}"
        COMMENT "Building NIST zipfile at ${CMAKE_BINARY_DIR}/nist-zipfile/${ZIPNAME}-nist.zip"
        )
    add_custom_target(
        nist-zipfile
        DEPENDS "${CMAKE_BINARY_DIR}/nist-zipfile/${ZIPNAME}-nist.zip"
    )
endmacro()
