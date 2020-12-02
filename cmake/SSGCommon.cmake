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


if(SSG_OVAL_SCHEMATRON_VALIDATION_ENABLED)
    set(OSCAP_OVAL_SCHEMATRON_OPTION "--schematron")
else()
    set(OSCAP_OVAL_SCHEMATRON_OPTION "")
endif()

set(SSG_HTML_GUIDE_FILE_LIST "")
set(SSG_HTML_TABLE_FILE_LIST "")

# Define VALIDATE_PRODUCT to FALSE if a successful product validation is known to require newer oscap
# that the one that is picked by the build system.
macro(define_validate_product PRODUCT)
    set(VALIDATE_PRODUCT TRUE)
    if ("${OSCAP_VERSION}" VERSION_LESS "1.4.0")
	    if ("${PRODUCT}" MATCHES "^(ocp4|ANOTHER_PROBLEMATIC_PRODUCT)$")
            message(STATUS "Won't validate ${PRODUCT}, as it requires the OpenSCAP scanner that is capable of the validation.")
            set(VALIDATE_PRODUCT FALSE)
        endif ()
    endif ()
endmacro()

macro(ssg_build_bash_remediation_functions)
    file(GLOB BASH_REMEDIATION_FUNCTIONS "${CMAKE_SOURCE_DIR}/shared/bash_remediation_functions/*.sh")

    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/bash-remediation-functions.xml"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/generate_bash_remediation_functions.py" --input "${SSG_SHARED}/bash_remediation_functions" --output "${CMAKE_BINARY_DIR}/bash-remediation-functions.xml"
        DEPENDS ${BASH_REMEDIATION_FUNCTIONS}
        DEPENDS "${SSG_BUILD_SCRIPTS}/generate_bash_remediation_functions.py"
        COMMENT "[bash-remediation-functions] generating bash-remediation-functions.xml"
    )
    add_custom_target(
        generate-internal-bash-remediation-functions.xml
        DEPENDS "${CMAKE_BINARY_DIR}/bash-remediation-functions.xml"
    )
endmacro()

macro(ssg_build_man_page)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/scap-security-guide.8"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/generate_man_page.py" --template "${CMAKE_SOURCE_DIR}/docs/man_page_template.jinja" --input_dir "${CMAKE_BINARY_DIR}" --output "${CMAKE_BINARY_DIR}/scap-security-guide.8"
        COMMENT "[man-page] generating man page"
    )
    add_custom_target(
        man_page
        ALL
        DEPENDS "${CMAKE_BINARY_DIR}/scap-security-guide.8"
    )
endmacro()

macro(ssg_build_shorthand_xml PRODUCT)
    set(BASH_REMEDIATION_FNS "")
    set(BASH_REMEDIATION_FNS_DEPENDS "")
    if ("${PRODUCT_BASH_REMEDIATION_ENABLED}")
        list(APPEND BASH_REMEDIATION_FNS "--bash-remediation-fns" "${CMAKE_BINARY_DIR}/bash-remediation-functions.xml")
        list(APPEND BASH_REMEDIATION_FNS_DEPENDS "generate-internal-bash-remediation-functions.xml" "${CMAKE_BINARY_DIR}/bash-remediation-functions.xml")
    endif()

    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/profiles"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/profiles"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/compile_profiles.py" --build-config-yaml "${CMAKE_BINARY_DIR}/build_config.yml" --product-yaml "${CMAKE_CURRENT_SOURCE_DIR}/product.yml" -o "${CMAKE_CURRENT_BINARY_DIR}/profiles/{name}.profile"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/profiles/"
        COMMENT "[${PRODUCT}-content] compiling profiles"
    )

    add_custom_command(
        # The command also produces the directory with rules, but this is done before the the shorthand XML.
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
        COMMAND "${CMAKE_COMMAND}" -E remove_directory "${CMAKE_CURRENT_BINARY_DIR}/rules"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/yaml_to_shorthand.py" --resolved-rules-dir "${CMAKE_CURRENT_BINARY_DIR}/rules" --build-config-yaml "${CMAKE_BINARY_DIR}/build_config.yml" --product-yaml "${CMAKE_CURRENT_SOURCE_DIR}/product.yml" ${BASH_REMEDIATION_FNS} --profiles-root "${CMAKE_CURRENT_BINARY_DIR}/profiles" --output "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml" "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
        DEPENDS ${BASH_REMEDIATION_FNS_DEPENDS}
        DEPENDS "${SSG_BUILD_SCRIPTS}/yaml_to_shorthand.py"
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/profiles"
        COMMENT "[${PRODUCT}-content] generating shorthand.xml"
    )

    add_custom_target(
        generate-internal-${PRODUCT}-shorthand.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
    )
endmacro()

macro(ssg_build_xccdf_unlinked_no_stig PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam ssg_version "${SSG_VERSION}" --output "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/shorthand2xccdf.xslt" "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
        COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" xccdf resolve -o "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
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

macro(ssg_build_xccdf_unlinked_stig PRODUCT STIG_REFERENCE_FILE)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam ssg_version "${SSG_VERSION}" --output "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/shorthand2xccdf.xslt" "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
        COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" xccdf resolve -o "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/add_stig_references.py" --disa-stig "${STIG_REFERENCE_FILE}" --unlinked-xccdf "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
        DEPENDS generate-internal-${PRODUCT}-shorthand.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/shorthand2xccdf.xslt"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/constants.xslt"
        DEPENDS "${SSG_SHARED_TRANSFORMS}/shared_constants.xslt"
        DEPENDS "${STIG_REFERENCE_FILE}"
        COMMENT "[${PRODUCT}-content] generating xccdf-unlinked-resolved.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-xccdf-unlinked-resolved.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml"
    )
endmacro()

macro(ssg_build_xccdf_unlinked PRODUCT)
    file(GLOB STIG_REFERENCE_FILE_LIST "${SSG_SHARED_REFS}/disa-stig-${PRODUCT}-*-xccdf-manual.xml")
    list(APPEND STIG_REFERENCE_FILE_LIST "not-found")
    list(GET STIG_REFERENCE_FILE_LIST 0 STIG_REFERENCE_FILE)

    if (STIG_REFERENCE_FILE STREQUAL "not-found")
        ssg_build_xccdf_unlinked_no_stig(${PRODUCT})
    else()
        ssg_build_xccdf_unlinked_stig(${PRODUCT} ${STIG_REFERENCE_FILE})
    endif()
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

macro(ssg_build_templated_content PRODUCT)
    set(BUILD_CHECKS_DIR "${CMAKE_CURRENT_BINARY_DIR}/checks")
    set(BUILD_REMEDIATIONS_DIR "${CMAKE_CURRENT_BINARY_DIR}/fixes_from_templates")
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/templated-content-${PRODUCT}"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/build_templated_content.py" --resolved-rules-dir "${CMAKE_CURRENT_BINARY_DIR}/rules" --templates-dir "${SSG_SHARED}/templates" --checks-dir "${BUILD_CHECKS_DIR}" --remediations-dir "${BUILD_REMEDIATIONS_DIR}" --build-config-yaml "${CMAKE_BINARY_DIR}/build_config.yml" --product-yaml "${CMAKE_CURRENT_SOURCE_DIR}/product.yml"
        COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_CURRENT_BINARY_DIR}/templated-content-${PRODUCT}"
        # Actually we mean that it depends on resolved rules.
        DEPENDS generate-internal-${PRODUCT}-shorthand.xml
        DEPENDS "${SSG_BUILD_SCRIPTS}/build_templated_content.py"
        COMMENT "[${PRODUCT}-content] generating templated content"
    )
    add_custom_target(
        generate-internal-templated-content-${PRODUCT}
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/templated-content-${PRODUCT}"
    )
endmacro()

macro(_ssg_build_remediations_for_language PRODUCT LANGUAGES)
    foreach(LANGUAGE ${LANGUAGES})
      set(ALL_FIXES_DIR "${CMAKE_CURRENT_BINARY_DIR}/fixes/${LANGUAGE}")

      add_custom_command(
          OUTPUT "${ALL_FIXES_DIR}"
          COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/combine_remediations.py" --resolved-rules-dir "${CMAKE_CURRENT_BINARY_DIR}/rules" --build-config-yaml "${CMAKE_BINARY_DIR}/build_config.yml" --product-yaml "${CMAKE_CURRENT_SOURCE_DIR}/product.yml" --remediation-type "${LANGUAGE}" --output-dir "${ALL_FIXES_DIR}" "${BUILD_REMEDIATIONS_DIR}/shared/${LANGUAGE}" "${BUILD_REMEDIATIONS_DIR}/${LANGUAGE}"
          # Acutally we mean that it depends on resolved rules.
          DEPENDS generate-internal-${PRODUCT}-shorthand.xml
          DEPENDS "${SSG_BUILD_SCRIPTS}/combine_remediations.py"
          COMMENT "[${PRODUCT}-content] collecting all ${LANGUAGE} fixes"
      )
      add_custom_target(
          generate-internal-${PRODUCT}-${LANGUAGE}-all-fixes
          DEPENDS "${ALL_FIXES_DIR}"
      )
      add_dependencies(generate-internal-${PRODUCT}-${LANGUAGE}-all-fixes generate-internal-templated-content-${PRODUCT})

      add_custom_command(
          OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${LANGUAGE}-fixes.xml"
          COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/generate_fixes_xml.py" --remediation_type "${LANGUAGE}" --build_dir "${CMAKE_BINARY_DIR}" --output "${CMAKE_CURRENT_BINARY_DIR}/${LANGUAGE}-fixes.xml" "${ALL_FIXES_DIR}"
          DEPENDS "${SSG_BUILD_SCRIPTS}/generate_fixes_xml.py"
          DEPENDS generate-internal-${PRODUCT}-${LANGUAGE}-all-fixes
          COMMENT "[${PRODUCT}-content] generating ${LANGUAGE}-fixes.xml"
      )
      add_custom_target(
          generate-internal-${PRODUCT}-${LANGUAGE}-fixes.xml
          DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${LANGUAGE}-fixes.xml"
      )
    endforeach()
endmacro()

macro(ssg_build_ansible_playbooks PRODUCT)
    set(ANSIBLE_FIXES_DIR "${CMAKE_CURRENT_BINARY_DIR}/fixes/ansible")
    set(ANSIBLE_PLAYBOOKS_DIR "${CMAKE_CURRENT_BINARY_DIR}/playbooks")
    add_custom_command(
        OUTPUT "${ANSIBLE_PLAYBOOKS_DIR}"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/build_rule_playbooks.py" --ssg-root "${CMAKE_SOURCE_DIR}" --product "${PRODUCT}" --resolved-rules-dir "${CMAKE_CURRENT_BINARY_DIR}/rules" --resolved-profiles-dir "${CMAKE_CURRENT_BINARY_DIR}/profiles" --output-dir "${ANSIBLE_PLAYBOOKS_DIR}"
        DEPENDS "${ANSIBLE_FIXES_DIR}"
        DEPENDS generate-internal-${PRODUCT}-ansible-all-fixes
        DEPENDS "${SSG_BUILD_SCRIPTS}/build_rule_playbooks.py"
        COMMENT "[${PRODUCT}-content] Generating Ansible Playbooks"
    )
    add_custom_target(
        generate-${PRODUCT}-ansible-playbooks
        DEPENDS "${ANSIBLE_PLAYBOOKS_DIR}"
    )
    add_test(
        NAME "${PRODUCT}-ansible-playbooks-generated-for-all-rules"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/tests/ansible_playbooks_generated_for_all_rules.py" --build-dir "${CMAKE_BINARY_DIR}" --product "${PRODUCT}"
    )
    set_tests_properties("${PRODUCT}-ansible-playbooks-generated-for-all-rules" PROPERTIES LABELS quick)
    if("${PRODUCT}" MATCHES "rhel")
        add_test(
            NAME "${PRODUCT}-ansible-assert-playbooks-schema"
            COMMAND sh -c "${PYTHON_EXECUTABLE} $@" _ "${CMAKE_SOURCE_DIR}/tests/assert_ansible_schema.py" ${CMAKE_BINARY_DIR}/${PRODUCT}/playbooks/all/*
        )
    endif()
endmacro()

macro(ssg_build_remediations PRODUCT)
    message(STATUS "Scanning for dependencies of ${PRODUCT} fixes (bash, ansible, puppet, anaconda, ignition and kubernetes)...")

    _ssg_build_remediations_for_language(${PRODUCT} "${PRODUCT_REMEDIATION_LANGUAGES}")

    if ("${PRODUCT_ANSIBLE_REMEDIATION_ENABLED}")
        # only enable the ansible syntax checks if we are using openscap 1.2.17 or higher
        # older openscap causes syntax errors, see https://github.com/OpenSCAP/openscap/pull/977
        if (ANSIBLE_PLAYBOOK_EXECUTABLE AND "${OSCAP_VERSION}" VERSION_GREATER "1.2.16")
            add_test(
                NAME "ansible-playbook-syntax-check-${PRODUCT}"
                COMMAND "${CMAKE_SOURCE_DIR}/tests/ansible_playbook_check.sh" "${ANSIBLE_PLAYBOOK_EXECUTABLE}" "${CMAKE_BINARY_DIR}/ansible" "${PRODUCT}"
            )
        endif()
        if (ANSIBLE_CHECKS)
            if (ANSIBLE_LINT_EXECUTABLE AND "${OSCAP_VERSION}" VERSION_GREATER "1.2.16")
                add_test(
                    NAME "ansible-playbook-ansible-lint-check-${PRODUCT}"
                    COMMAND "${CMAKE_SOURCE_DIR}/tests/ansible_playbook_check.sh" "${ANSIBLE_LINT_EXECUTABLE}" "${CMAKE_BINARY_DIR}/${PRODUCT}/playbooks" "${CMAKE_SOURCE_DIR}/tests/ansible-lint_config.yml"
                )
            endif()
            if (YAMLLINT_EXECUTABLE AND "${OSCAP_VERSION}" VERSION_GREATER "1.2.16")
                add_test(
                    NAME "ansible-playbook-yamllint-check-${PRODUCT}"
                    COMMAND "${CMAKE_SOURCE_DIR}/tests/ansible_playbook_check.sh" "${YAMLLINT_EXECUTABLE}" "${CMAKE_BINARY_DIR}/${PRODUCT}/playbooks" "${CMAKE_SOURCE_DIR}/tests/yamllint_config.yml"
                )
            endif()
        endif()
    endif()
endmacro()

macro(ssg_build_xccdf_with_remediations PRODUCT)
    # we have to encode spaces in paths before passing them as stringparams to xsltproc
    string(REPLACE " " "%20" CMAKE_CURRENT_BINARY_DIR_NO_SPACES "${CMAKE_CURRENT_BINARY_DIR}")
    set(PRODUCT_XSLT_LANGUAGE_PARAMS "")
    set(PRODUCT_LANGUAGE_DEPENDS "")
    foreach(LANGUAGE ${PRODUCT_REMEDIATION_LANGUAGES})
        list(APPEND PRODUCT_XSLT_LANGUAGE_PARAMS --stringparam ${LANGUAGE}_remediations ${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/${LANGUAGE}-fixes.xml )
        list(APPEND PRODUCT_LANGUAGE_DEPENDS generate-internal-${PRODUCT}-${LANGUAGE}-fixes.xml ${CMAKE_CURRENT_BINARY_DIR}/${LANGUAGE}-fixes.xml )
    endforeach()
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml"
        COMMAND "${XSLTPROC_EXECUTABLE}" ${PRODUCT_XSLT_LANGUAGE_PARAMS} --output "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml" "${SSG_SHARED_TRANSFORMS}/xccdf-addremediations.xslt" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml"
        DEPENDS generate-internal-${PRODUCT}-xccdf-unlinked-ocilrefs.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml"
        DEPENDS ${PRODUCT_LANGUAGE_DEPENDS}
        DEPENDS "${SSG_SHARED_TRANSFORMS}/xccdf-addremediations.xslt"
        COMMENT "[${PRODUCT}-content] generating xccdf-unlinked.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-xccdf-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml"
    )
endmacro()

macro(ssg_build_oval_unlinked PRODUCT)
    set(BUILD_CHECKS_DIR "${CMAKE_CURRENT_BINARY_DIR}/checks")
    set(OVAL_COMBINE_PATHS "${BUILD_CHECKS_DIR}/shared/oval" "${SSG_SHARED}/checks/oval" "${BUILD_CHECKS_DIR}/oval" "${CMAKE_CURRENT_SOURCE_DIR}/checks/oval")
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/combine_ovals.py" --build-config-yaml "${CMAKE_BINARY_DIR}/build_config.yml" --product-yaml "${CMAKE_CURRENT_SOURCE_DIR}/product.yml" --output "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml" ${OVAL_COMBINE_PATHS}
        COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml" "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
        DEPENDS generate-internal-templated-content-${PRODUCT}
        DEPENDS "${SSG_BUILD_SCRIPTS}/combine_ovals.py"
        COMMENT "[${PRODUCT}-content] generating oval-unlinked.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-oval-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
    )
endmacro()

macro(ssg_build_cpe_dictionary PRODUCT)

    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/cpe_generate.py" ${PRODUCT} ssg "${CMAKE_BINARY_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml" "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
        DEPENDS generate-internal-${PRODUCT}-oval-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
        DEPENDS generate-internal-${PRODUCT}-shorthand.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml"
        DEPENDS "${SSG_BUILD_SCRIPTS}/cpe_generate.py"
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-cpe-dictionary.xml, ssg-${PRODUCT}-cpe-oval.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-cpe-dictionary.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
    )
    define_validate_product("${PRODUCT}")
    if ("${VALIDATE_PRODUCT}" OR "${FORCE_VALIDATE_EVERYTHING}")
        add_test(
            NAME "validate-ssg-${PRODUCT}-cpe-dictionary.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" cpe validate "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        )
        add_test(
            NAME "validate-ssg-${PRODUCT}-cpe-oval.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" oval validate ${OSCAP_OVAL_SCHEMATRON_OPTION} "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
        )
    endif()
endmacro()

macro(ssg_build_link_xccdf_oval_ocil PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked.xml"
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml"
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/ocil-linked.xml"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/relabel_ids.py" "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml" ssg
        DEPENDS generate-internal-${PRODUCT}-xccdf-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml"
        DEPENDS generate-internal-${PRODUCT}-oval-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
        DEPENDS generate-internal-${PRODUCT}-ocil-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml"
        DEPENDS "${SSG_BUILD_SCRIPTS}/relabel_ids.py"
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
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/unselect_empty_xccdf_groups.py" --input "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" xccdf resolve -o "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-internal-${PRODUCT}-linked-xccdf-oval-ocil.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked.xml"
        DEPENDS "${CMAKE_SOURCE_DIR}/shared/transforms/shared_xccdf-removeaux.xslt"
        DEPENDS "${SSG_BUILD_SCRIPTS}/unselect_empty_xccdf_groups.py"
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-xccdf.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
    )
    define_validate_product("${PRODUCT}")
    if ("${VALIDATE_PRODUCT}" OR "${FORCE_VALIDATE_EVERYTHING}")
        add_test(
            NAME "validate-ssg-${PRODUCT}-xccdf.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" xccdf validate "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        )
    endif()
    add_test(
        NAME "verify-references-ssg-${PRODUCT}-xccdf.xml"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/verify_references.py" --rules-with-invalid-checks --ovaldefs-unused "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
    )
    set_tests_properties("verify-references-ssg-${PRODUCT}-xccdf.xml" PROPERTIES LABELS quick)
    add_test(
        NAME "verify-ssg-${PRODUCT}-xccdf.xml-override-true-all-profile-titles"
        COMMAND "${XMLLINT_EXECUTABLE}" --xpath "//*[local-name()=\"Profile\"]/*[local-name()=\"title\"][not(@override=\"true\")]" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
    )
    set_tests_properties("verify-ssg-${PRODUCT}-xccdf.xml-override-true-all-profile-titles" PROPERTIES LABELS quick)
    add_test(
        NAME "verify-ssg-${PRODUCT}-xccdf.xml-override-true-all-profile-descriptions"
        COMMAND "${XMLLINT_EXECUTABLE}" --xpath "//*[local-name()=\"Profile\"]/*[local-name()=\"description\"][not(@override=\"true\")]" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
    )
    set_tests_properties("verify-ssg-${PRODUCT}-xccdf.xml-override-true-all-profile-descriptions" PROPERTIES LABELS quick)
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
    define_validate_product("${PRODUCT}")
    if ("${VALIDATE_PRODUCT}" OR "${FORCE_VALIDATE_EVERYTHING}")
        add_test(
            NAME "validate-ssg-${PRODUCT}-oval.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" oval validate ${OSCAP_OVAL_SCHEMATRON_OPTION} "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
        )
    endif()
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
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_SHARED_TRANSFORMS}/pcidss/transform_benchmark_to_pcidss.py" "${SSG_SHARED_TRANSFORMS}/pcidss/PCI_DSS.json" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-pcidss-xccdf-1.2.xml"
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
            OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml"
            WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
            # use --skip-valid here to avoid repeatedly validating everything
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-compose --skip-valid "ssg-${PRODUCT}-xccdf-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${SED_EXECUTABLE}" -i 's/schematron-version="[0-9].[0-9]"/schematron-version="1.2"/' "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-add --skip-valid "ssg-${PRODUCT}-cpe-dictionary.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-add --skip-valid "ssg-${PRODUCT}-pcidss-xccdf-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/sds_move_ocil_to_checks.py" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/update_sds_version.py" --version "1.2" --input "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/update_sds_version.py" --version "1.3" --input "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml"
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
            COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-ds.xml and ssg-${PRODUCT}-ds-1.2.xml"
        )
    else()
        add_custom_command(
            OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml"
            WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
            # use --skip-valid here to avoid repeatedly validating everything
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-compose --skip-valid "ssg-${PRODUCT}-xccdf-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${SED_EXECUTABLE}" -i 's/schematron-version="[0-9].[0-9]"/schematron-version="1.2"/' "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-add --skip-valid "ssg-${PRODUCT}-cpe-dictionary.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/sds_move_ocil_to_checks.py" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/update_sds_version.py" --version "1.2" --input "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/update_sds_version.py" --version "1.3" --input "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml"
            DEPENDS generate-ssg-${PRODUCT}-xccdf-1.2.xml
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml"
            DEPENDS generate-ssg-${PRODUCT}-oval.xml
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
            DEPENDS generate-ssg-${PRODUCT}-ocil.xml
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
            DEPENDS generate-ssg-${PRODUCT}-cpe-dictionary.xml
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
            COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-ds.xml and ssg-${PRODUCT}-ds-1.2.xml"
        )
    endif()
    add_custom_target(
        generate-ssg-${PRODUCT}-ds.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml"
    )

    if("${PRODUCT}" MATCHES "rhel(6|7|8|9)")
        add_test(
            NAME "missing-cces-${PRODUCT}"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/tests/missing_cces.py" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        )
        set_tests_properties("missing-cces-${PRODUCT}" PROPERTIES LABELS quick)
    endif()

    define_validate_product("${PRODUCT}")
    if ("${VALIDATE_PRODUCT}" OR "${FORCE_VALIDATE_EVERYTHING}")
        add_test(
            NAME "validate-ssg-${PRODUCT}-ds.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-validate "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        )
        add_test(
            NAME "validate-ssg-${PRODUCT}-ds-1.2.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-validate "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml"
        )
    endif()
endmacro()

macro(ssg_build_html_guides PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/guides/ssg-${PRODUCT}-guide-index.html"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/guides"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/build_all_guides.py" --input "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" --output "${CMAKE_BINARY_DIR}/guides" build
        DEPENDS generate-ssg-${PRODUCT}-ds.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml"
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

macro(ssg_build_profile_bash_scripts PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/bash/all-profile-bash-scripts-${PRODUCT}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/bash"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/build_profile_remediations.py" --input "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" --output "${CMAKE_BINARY_DIR}/bash" --template "urn:xccdf:fix:script:sh" --extension "sh" build
        COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_BINARY_DIR}/bash/all-profile-bash-scripts-${PRODUCT}"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMENT "[${PRODUCT}-bash-scripts] generating Bash remediation scripts for all profiles in ssg-${PRODUCT}-xccdf.xml"
    )
    add_custom_target(
        generate-all-profile-bash-scripts-${PRODUCT}
        DEPENDS "${CMAKE_BINARY_DIR}/bash/all-profile-bash-scripts-${PRODUCT}"
    )
endmacro()

macro(ssg_build_profile_playbooks PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ansible/all-profile-playbooks-${PRODUCT}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/ansible"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/build_profile_remediations.py" --input "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" --output "${CMAKE_BINARY_DIR}/ansible" --template "urn:xccdf:fix:script:ansible" --extension "yml" build
        COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_BINARY_DIR}/ansible/all-profile-playbooks-${PRODUCT}"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMENT "[${PRODUCT}-playbooks] generating Ansible Playbooks for all profiles in ssg-${PRODUCT}-xccdf.xml"
    )
    add_custom_target(
        generate-all-profile-playbooks-${PRODUCT}
        DEPENDS "${CMAKE_BINARY_DIR}/ansible/all-profile-playbooks-${PRODUCT}"
    )
endmacro()

macro(ssg_make_stats_for_product PRODUCT)
    add_custom_target(${PRODUCT}-stats
        COMMAND ${CMAKE_COMMAND} -E echo "Benchmark statistics for '${PRODUCT}':"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/profile_tool.py" stats --benchmark "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" --profile all
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMENT "[${PRODUCT}-stats] generating benchmark statistics"
    )
    add_custom_target(${PRODUCT}-profile-stats
        COMMAND ${CMAKE_COMMAND} -E echo "Per profile statistics for '${PRODUCT}':"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/profile_tool.py" stats --benchmark "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMENT "[${PRODUCT}-profile-stats] generating per profile statistics"
    )
endmacro()

macro(ssg_make_html_stats_for_product PRODUCT)
    add_custom_target(${PRODUCT}-html-stats
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/profile_tool.py" stats --format html --benchmark "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" --profile all --output "${CMAKE_BINARY_DIR}/${PRODUCT}/product-statistics/"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMENT "[${PRODUCT}-html-stats] generating benchmark html statistics"
    )
    add_custom_target(${PRODUCT}-html-profile-stats
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/profile_tool.py" stats --format html --benchmark "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" --output "${CMAKE_BINARY_DIR}/${PRODUCT}/profile-statistics/"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMENT "[${PRODUCT}-html-profile-stats] generating per profile html statistics"
    )
endmacro()

macro(ssg_make_all_tables PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/tables-${PRODUCT}-all.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/gen_tables.py" --build-dir "${CMAKE_BINARY_DIR}" --output-type html --output "${CMAKE_BINARY_DIR}/tables/tables-${PRODUCT}-all.html" "${PRODUCT}"
        # Actually we mean that it depends on resolved rules - see also ssg_build_templated_content
        DEPENDS generate-internal-${PRODUCT}-shorthand.xml
    )
    add_custom_target(generate-ssg-tables-${PRODUCT}-all
        DEPENDS "${CMAKE_BINARY_DIR}/tables/tables-${PRODUCT}-all.html"
    )
endmacro()

macro(ssg_build_product PRODUCT)
    # Enforce folder naming rules, we require SSG contributors to use
    # scap-security-guide/${PRODUCT}/ for all products. This makes it easier
    # to find relevant source-code and build just the relevant product.
    get_filename_component(EXPECTED_CMAKELISTS "${CMAKE_SOURCE_DIR}/${PRODUCT}/CMakeLists.txt" ABSOLUTE)
    get_filename_component(ACTUAL_CMAKELISTS "${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt" ABSOLUTE)

    if (NOT "${ACTUAL_CMAKELISTS}" STREQUAL "${EXPECTED_CMAKELISTS}")
        message(FATAL_ERROR "Expected ${PRODUCT}'s CMakeLists.txt to be at ${EXPECTED_CMAKELISTS}. Instead it's at ${ACTUAL_CMAKELISTS}. Please move it to the correct location.")
    endif()

    add_custom_target(${PRODUCT}-content)

    if(NOT DEFINED PRODUCT_REMEDIATION_LANGUAGES)
        set(PRODUCT_REMEDIATION_LANGUAGES "bash;ansible;puppet;anaconda;ignition;kubernetes")
    endif()
    # Define variables for each language to facilitate assesment of specific remediation languages
    foreach(LANGUAGE ${PRODUCT_REMEDIATION_LANGUAGES})
        string(TOUPPER ${LANGUAGE} _LANGUAGE)
        set(PRODUCT_${_LANGUAGE}_REMEDIATION_ENABLED TRUE)
    endforeach()

    ssg_build_shorthand_xml(${PRODUCT})
    ssg_make_all_tables(${PRODUCT})
    ssg_build_templated_content(${PRODUCT})
    ssg_build_xccdf_unlinked(${PRODUCT})
    ssg_build_ocil_unlinked(${PRODUCT})
    ssg_build_remediations(${PRODUCT})
    if ("${PRODUCT_ANSIBLE_REMEDIATION_ENABLED}")
        ssg_build_ansible_playbooks(${PRODUCT})
    endif()
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
        generate-ssg-tables-${PRODUCT}-all
    )

    add_dependencies(zipfile "generate-ssg-${PRODUCT}-ds.xml")

    if ("${PRODUCT_ANSIBLE_REMEDIATION_ENABLED}")
        add_dependencies(
            ${PRODUCT}-content
            generate-${PRODUCT}-ansible-playbooks
        )
        ssg_build_profile_playbooks(${PRODUCT})
        add_custom_target(
            ${PRODUCT}-profile-playbooks
            DEPENDS generate-all-profile-playbooks-${PRODUCT}
        )
        add_dependencies(${PRODUCT} ${PRODUCT}-profile-playbooks)
        add_dependencies(zipfile ${PRODUCT}-profile-playbooks)
    endif()

    if ("${PRODUCT_BASH_REMEDIATION_ENABLED}")
        ssg_build_profile_bash_scripts(${PRODUCT})
        add_custom_target(
            ${PRODUCT}-profile-bash-scripts
            DEPENDS generate-all-profile-bash-scripts-${PRODUCT}
        )
        add_dependencies(${PRODUCT} ${PRODUCT}-profile-bash-scripts)
        add_dependencies(zipfile ${PRODUCT}-profile-bash-scripts)
    endif()

    ssg_build_html_guides(${PRODUCT})

    add_custom_target(
        ${PRODUCT}-guides
        DEPENDS generate-ssg-${PRODUCT}-guide-index.html
    )
    add_dependencies(${PRODUCT} ${PRODUCT}-guides)
    add_dependencies(zipfile ${PRODUCT}-guides)

    add_custom_target(
        ${PRODUCT}-tables
        # dependencies are added later using add_dependency
    )
    add_dependencies(${PRODUCT} ${PRODUCT}-tables)
    add_dependencies(zipfile ${PRODUCT}-tables)

    ssg_make_stats_for_product(${PRODUCT})
    add_dependencies(stats ${PRODUCT}-stats)
    add_dependencies(profile-stats ${PRODUCT}-profile-stats)
    ssg_make_html_stats_for_product(${PRODUCT})
    add_dependencies(html-stats ${PRODUCT}-html-stats)
    add_dependencies(html-profile-stats ${PRODUCT}-html-profile-stats)

    add_dependencies(man_page ${PRODUCT})

    if (SSG_SEPARATE_SCAP_FILES_ENABLED)
        install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
            DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
        install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
            DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
        install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
            DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
        install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
            DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
        install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
            DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    endif()

    install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")

    install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml"
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
        file(GLOB ROLE_FILES \"${CMAKE_BINARY_DIR}/ansible/${PRODUCT}-playbook-*.yml\") \n
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
        file(GLOB ROLE_FILES \"${CMAKE_BINARY_DIR}/bash/${PRODUCT}-script-*.sh\") \n
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
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/enable_derivatives.py" --enable-${SHORTNAME} -i "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-xccdf.xml" -o "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml" ${ORIGINAL} ${DERIVATIVE} --id-name ssg
        DEPENDS generate-ssg-${ORIGINAL}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-xccdf.xml"
        DEPENDS "${SSG_BUILD_SCRIPTS}/enable_derivatives.py"
        COMMENT "[${DERIVATIVE}-content] generating ssg-${DERIVATIVE}-xccdf.xml"
    )
    add_custom_target(
        generate-ssg-${DERIVATIVE}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml"
    )

    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds-1.2.xml"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/enable_derivatives.py" --enable-${SHORTNAME} -i "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-ds-1.2.xml" -o "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds-1.2.xml" ${ORIGINAL} ${DERIVATIVE} --id-name ssg
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/enable_derivatives.py" --enable-${SHORTNAME} -i "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-ds.xml" -o "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml" ${ORIGINAL} ${DERIVATIVE} --id-name ssg
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds-1.2.xml"
        DEPENDS generate-ssg-${ORIGINAL}-ds.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-ds.xml"
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-ds-1.2.xml"
        DEPENDS "${SSG_BUILD_SCRIPTS}/enable_derivatives.py"
        COMMENT "[${DERIVATIVE}-content] generating ssg-${DERIVATIVE}-ds.xml and ssg-${DERIVATIVE}-ds-1.2.xml"
    )
    add_custom_target(
        generate-ssg-${DERIVATIVE}-ds.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds-1.2.xml"
    )
    define_validate_product("${PRODUCT}")
    if ("${VALIDATE_PRODUCT}" OR "${FORCE_VALIDATE_EVERYTHING}")
        add_test(
            NAME "validate-ssg-${DERIVATIVE}-xccdf.xml"
            COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${DERIVATIVE}-xccdf.xml"
        )
        add_test(
            NAME "validate-ssg-${DERIVATIVE}-ds.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-validate "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        )
        add_test(
            NAME "validate-ssg-${DERIVATIVE}-ds-1.2.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-validate "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds-1.2.xml"
        )
    endif()

    add_custom_target(${DERIVATIVE} ALL)
    add_dependencies(${DERIVATIVE} ${DERIVATIVE}-content)
    add_dependencies(man_page ${DERIVATIVE})

    add_dependencies(
        ${DERIVATIVE}-content
        generate-ssg-${DERIVATIVE}-xccdf.xml
        generate-ssg-${DERIVATIVE}-ds.xml
    )

    add_dependencies(zipfile "generate-ssg-${DERIVATIVE}-ds.xml")

    ssg_build_html_guides(${DERIVATIVE})

    if ("${PRODUCT_BASH_REMEDIATION_ENABLED}")
        ssg_build_profile_bash_scripts(${DERIVATIVE})
        add_custom_target(
            ${DERIVATIVE}-profile-bash-scripts
            DEPENDS generate-all-profile-bash-scripts-${DERIVATIVE}
        )
        add_dependencies(${DERIVATIVE} ${DERIVATIVE}-profile-bash-scripts)
    endif()

    if ("${PRODUCT_ANSIBLE_REMEDIATION_ENABLED}")
        ssg_build_profile_playbooks(${DERIVATIVE})
        add_custom_target(
            ${DERIVATIVE}-profile-playbooks
            DEPENDS generate-all-profile-playbooks-${DERIVATIVE}
        )
        add_dependencies(${DERIVATIVE} ${DERIVATIVE}-profile-playbooks)
    endif()

    add_custom_target(
        ${DERIVATIVE}-guides
        DEPENDS generate-ssg-${DERIVATIVE}-guide-index.html
    )
    add_dependencies(${DERIVATIVE} ${DERIVATIVE}-guides)

    if (SSG_SEPARATE_SCAP_FILES_ENABLED)
        install(FILES "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml"
            DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    endif()

    install(FILES "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")

    install(FILES "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds-1.2.xml"
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
        file(GLOB ROLE_FILES \"${CMAKE_BINARY_DIR}/ansible/${DERIVATIVE}-playbook-*.yml\") \n
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
        file(GLOB ROLE_FILES \"${CMAKE_BINARY_DIR}/bash/${DERIVATIVE}-script-*.sh\") \n
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
    # also needs to set the variable in local scope for next macro tables
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST};${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-${REF}refs.html")
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST}" PARENT_SCOPE)

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
    # also needs to set the variable in local scope for next macro tables
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST};${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-nistrefs-${PROFILE}.html")
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST}" PARENT_SCOPE)

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

    # needs PARENT_SCOPE because this is done across different cmake files via add_directory(..)
    # also needs to set the variable in local scope for next macro tables
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST};${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-anssirefs-${PROFILE}.html")
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST}" PARENT_SCOPE)

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
    # also needs to set the variable in local scope for next macro tables
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST};${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-cces.html")
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST}" PARENT_SCOPE)

    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-cces.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_build_html_srgmap_tables PRODUCT PROFILE_ID DISA_SRG_TYPE)
    file(GLOB DISA_SRG_REF "${SSG_SHARED_REFS}/disa-${DISA_SRG_TYPE}-srg-v[0-9]*r[0-9]*.xml")
    # we have to encode spaces in paths before passing them as stringparams to xsltproc
    string(REPLACE " " "%20" CMAKE_CURRENT_BINARY_DIR_NO_SPACES "${CMAKE_CURRENT_BINARY_DIR}")
    add_custom_command(
      OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked-srg-overlay.xml"
      COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam profileId ${PROFILE_ID} --stringparam productXccdf ${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/xccdf-linked.xml --stringparam overlay ${CMAKE_CURRENT_SOURCE_DIR}/overlays/srg_support.xml --output "${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked-srg-overlay.xml" "${CMAKE_SOURCE_DIR}/shared/transforms/srg-overlay.xslt" ${DISA_SRG_REF}
      DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
      DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
      DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/overlays/srg_support.xml"
      DEPENDS "${CMAKE_SOURCE_DIR}/shared/transforms/srg-overlay.xslt"
      DEPENDS "${DISA_SRG_REF}"
      COMMENT "[${PRODUCT}-tables] Adding custom SRG overrides to XCCDF"
    )
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam map-to-items "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/xccdf-linked-srg-overlay.xml" --stringparam ocil-document "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/ocil-linked.xml" --output "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt" "${DISA_SRG_REF}"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked-srg-overlay.xml"
        DEPENDS "${DISA_SRG_REF}"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt"
        COMMENT "[${PRODUCT}-tables] generating HTML SRG map table (flat=no)"
    )
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap-flat.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND "${XSLTPROC_EXECUTABLE}" --stringparam flat "y" --stringparam map-to-items "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/xccdf-linked-srg-overlay.xml" --stringparam ocil-document "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/ocil-linked.xml" --output "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap-flat.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt" "${DISA_SRG_REF}"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked-srg-overlay.xml"
        DEPENDS "${DISA_SRG_REF}"
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
    # also needs to set the variable in local scope for next macro tables
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST};${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap.html;${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap-flat.html")
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST}" PARENT_SCOPE)

    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap-flat.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_build_html_stig_tables PRODUCT STIG_PROFILE)
    file(GLOB DISA_STIG_REF "${SSG_SHARED_REFS}/disa-stig-${PRODUCT}-v[0-9]*r[0-9]*-xccdf-manual.xml")
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-manual.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-manual.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-stig.xslt" "${DISA_STIG_REF}"
        DEPENDS "${DISA_STIG_REF}"
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
        COMMAND "${XSLTPROC_EXECUTABLE}" -stringparam overlay "${CMAKE_CURRENT_SOURCE_DIR}/overlays/stig_overlay.xml" --stringparam ocil-document "${CMAKE_CURRENT_BINARY_DIR_NO_SPACES}/ocil-linked.xml" --output "${CMAKE_CURRENT_BINARY_DIR}/unlinked-stig-xccdf.xml" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf-apply-overlay-stig.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
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

    # needs PARENT_SCOPE because this is done across different cmake files via add_directory(..)
    # also needs to set the variable in local scope for next macro tables
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST};${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig.html;${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-manual.html;${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-testinfo.html")
    set(SSG_HTML_TABLE_FILE_LIST "${SSG_HTML_TABLE_FILE_LIST}" PARENT_SCOPE)

    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-testinfo.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_define_guide_and_table_tests)
    if (SSG_LINKCHECKER_VALIDATION_ENABLED AND LINKCHECKER_EXECUTABLE)
        add_test(
            NAME "linkchecker-ssg-guides"
            COMMAND "${LINKCHECKER_EXECUTABLE}" --config "${CMAKE_SOURCE_DIR}/tests/linkcheckerrc" --check-extern ${SSG_HTML_GUIDE_FILE_LIST}
        )

        add_test(
            NAME "linkchecker-ssg-tables"
            COMMAND "${LINKCHECKER_EXECUTABLE}" --config "${CMAKE_SOURCE_DIR}/tests/linkcheckerrc" --check-extern ${SSG_HTML_TABLE_FILE_LIST}
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
        add_test(
            NAME "unique-cces"
	    COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/tests/assert_cces_unique.sh"
        )
        set_tests_properties("unique-cces" PROPERTIES LABELS quick)
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
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_SOURCE_DIR}/rhel*/kickstart/*-ks.cfg" -DDEST="zipfile/${ZIPNAME}/kickstart" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/ssg-*-ds.xml" -DDEST="zipfile/${ZIPNAME}" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/ssg-*-ds-1.2.xml" -DDEST="zipfile/${ZIPNAME}" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -E make_directory "zipfile/${ZIPNAME}/bash"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/bash/*.sh" -DDEST="zipfile/${ZIPNAME}/bash" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -E make_directory "zipfile/${ZIPNAME}/ansible"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/ansible/*.yml" -DDEST="zipfile/${ZIPNAME}/ansible" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -E make_directory "zipfile/${ZIPNAME}/guides"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/guides/*" -DDEST="zipfile/${ZIPNAME}/guides" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -E make_directory "zipfile/${ZIPNAME}/tables"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/tables/*" -DDEST="zipfile/${ZIPNAME}/tables" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -E chdir "zipfile" ${CMAKE_COMMAND} -E tar "cvf" "${ZIPNAME}.zip" --format=zip "${ZIPNAME}"
        COMMENT "Building zipfile at ${CMAKE_BINARY_DIR}/zipfile/${ZIPNAME}.zip"
        )
endmacro()
macro(ssg_build_zipfile_target ZIPNAME)
    add_custom_target(
        zipfile
        DEPENDS "${CMAKE_BINARY_DIR}/zipfile/${ZIPNAME}.zip"
    )
endmacro()

macro(ssg_build_vendor_zipfile ZIPNAME)
    # When SCAP1.2 content is no longer built along with 1.3 content, remove the if below
    if("${ZIPNAME}" MATCHES "SCAP-1.3")
        set(SCAP_DS_VERSION_SUFFIX  "")
    else()
        set(SCAP_DS_VERSION_SUFFIX  "-1.2")
    endif()

    # Red Hat zipfile
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/vendor-zipfile/${ZIPNAME}-RedHat.zip"
        COMMAND ${CMAKE_COMMAND} -E remove_directory "vendor-zipfile/"
        COMMAND ${CMAKE_COMMAND} -E make_directory "vendor-zipfile/${ZIPNAME}"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/LICENSE" "vendor-zipfile/${ZIPNAME}"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/ssg-rh*-ds${SCAP_DS_VERSION_SUFFIX}.xml" -DDEST="vendor-zipfile/${ZIPNAME}" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/ssg-ocp*-ds${SCAP_DS_VERSION_SUFFIX}.xml" -DDEST="vendor-zipfile/${ZIPNAME}" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -E make_directory "vendor-zipfile/${ZIPNAME}/bash"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/bash/ssg-rh*.sh" -DDEST="vendor-zipfile/${ZIPNAME}/bash" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/bash/ssg-ocp*.sh" -DDEST="vendor-zipfile/${ZIPNAME}/bash" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -E make_directory "vendor-zipfile/${ZIPNAME}/ansible"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/ansible/ssg-rh*.yml" -DDEST="vendor-zipfile/${ZIPNAME}/ansible" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/ansible/ssg-ocp*.yml" -DDEST="vendor-zipfile/${ZIPNAME}/ansible" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -E make_directory "vendor-zipfile/${ZIPNAME}/guides"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/guides/ssg-rh*" -DDEST="vendor-zipfile/${ZIPNAME}/guides" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/guides/ssg-ocp*" -DDEST="vendor-zipfile/${ZIPNAME}/guides" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -E make_directory "vendor-zipfile/${ZIPNAME}/tables"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/tables/table-rh*" -DDEST="vendor-zipfile/${ZIPNAME}/tables" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/tables/table-ocp*" -DDEST="vendor-zipfile/${ZIPNAME}/tables" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -E chdir "vendor-zipfile" ${CMAKE_COMMAND} -E tar "cvf" "${ZIPNAME}-RedHat.zip" --format=zip "${ZIPNAME}"
        COMMENT "Building Red Hat zipfile at ${CMAKE_BINARY_DIR}/vendor-zipfile/${ZIPNAME}-RedHat.zip"
        DEPENDS rhel7
        DEPENDS rhel8
        DEPENDS rhosp13
        DEPENDS rhv4
        )
    add_custom_target(
        redhat-zipfile
        DEPENDS "${CMAKE_BINARY_DIR}/vendor-zipfile/${ZIPNAME}-RedHat.zip"
    )
    add_custom_target(vendor-zipfile)
    add_dependencies(vendor-zipfile redhat-zipfile)
endmacro()
