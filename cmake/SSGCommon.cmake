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
# Any time you use wrapper targets, still add DEPEND(s) on actual files
# involved. Without this depends are not propagated.
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
# This file is organized bottom-up. Looking for a place to start top-down?
# Jump to the ssg_build_product macro definition below. :-)
#
#
# Good luck hacking the SCAP Security Guide build system!


if(SSG_OVAL_SCHEMATRON_VALIDATION_ENABLED)
# Starting OpenSCAP 1.3.5, the schematron validation is the default behaviour
# due to certification requirements, the --schematron has been deprecated
# and --skip-schematron has been introduced.
    if("${OSCAP_VERSION}" VERSION_LESS "1.3.5")
        set(OSCAP_OVAL_SCHEMATRON_OPTION "--schematron")
    else()
        set(OSCAP_OVAL_SCHEMATRON_OPTION "")
    endif()
else()
    if("${OSCAP_VERSION}" VERSION_LESS "1.3.5")
        set(OSCAP_OVAL_SCHEMATRON_OPTION "")
    else()
        set(OSCAP_OVAL_SCHEMATRON_OPTION "--skip-schematron")
    endif()
endif()

set(SSG_HTML_GUIDE_FILE_LIST "")
set(SSG_HTML_TABLE_FILE_LIST "")

# Define VALIDATE_PRODUCT to FALSE if a successful product validation is known to require newer oscap
# that the one that is picked by the build system.
macro(define_validate_product PRODUCT)
    set(VALIDATE_PRODUCT TRUE)
    if("${OSCAP_VERSION}" VERSION_LESS "1.4.0")
        if("${PRODUCT}" MATCHES "^(ocp4|eks|ANOTHER_PROBLEMATIC_PRODUCT)$")
            message(STATUS "Won't validate ${PRODUCT}, as it requires the OpenSCAP scanner that is capable of the validation.")
            set(VALIDATE_PRODUCT FALSE)
        endif()
    endif()
endmacro()

macro(ssg_build_man_page)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/scap-security-guide.8"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/generate_man_page.py" --template "${CMAKE_SOURCE_DIR}/docs/man_page_template.jinja" --input_dir "${CMAKE_BINARY_DIR}" --output "${CMAKE_BINARY_DIR}/scap-security-guide.8" --install-prefix "${CMAKE_INSTALL_PREFIX}" --separate-scap-files "${SSG_SEPARATE_SCAP_FILES_ENABLED}:${SSG_CONTENT_INSTALL_DIR}" --profile-bash "${SSG_BASH_SCRIPTS_ENABLED}:${SSG_BASH_ROLE_INSTALL_DIR}" --profile-ansible "${SSG_ANSIBLE_PLAYBOOKS_ENABLED}:${SSG_ANSIBLE_ROLE_INSTALL_DIR}" --ansible-per-rule "${SSG_ANSIBLE_PLAYBOOKS_PER_RULE_ENABLED}:${SSG_ANSIBLE_PER_RULE_PLAYBOOKS_INSTALL_DIR}" --kickstarts "ON:${SSG_KICKSTART_INSTALL_DIR}" --tailoring "ON:${SSG_TAILORING_INSTALL_DIR}" --content-path "${SSG_CONTENT_INSTALL_DIR}"
        COMMENT "[man-page] generating man page"
    )
    add_custom_target(
        man_page
        ALL
        DEPENDS "${CMAKE_BINARY_DIR}/scap-security-guide.8"
    )
endmacro()

macro(ssg_build_compiled_artifacts PRODUCT)
    file(GLOB STIG_REFERENCE_FILE_LIST "${SSG_SHARED_REFS}/disa-stig-${PRODUCT}-*-xccdf-manual.xml")
    list(APPEND STIG_REFERENCE_FILE_LIST "not-found")
    list(GET STIG_REFERENCE_FILE_LIST 0 STIG_REFERENCE_FILE)

    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/product.yml"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/compile_product.py" --product-yaml "${CMAKE_SOURCE_DIR}/products/${PRODUCT}/product.yml" --product-properties "${CMAKE_SOURCE_DIR}/product_properties" --compiled-product-yaml "${CMAKE_CURRENT_BINARY_DIR}/product.yml"
        COMMENT "[${PRODUCT}-content] compiling product yaml"
    )

    if(STIG_REFERENCE_FILE STREQUAL "not-found")
        add_custom_command(
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
            COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/profiles"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/compile_all.py" --resolved-base "${CMAKE_CURRENT_BINARY_DIR}" --project-root "${CMAKE_SOURCE_DIR}" --build-config-yaml "${CMAKE_BINARY_DIR}/build_config.yml" --product-yaml "${CMAKE_CURRENT_BINARY_DIR}/product.yml" --sce-metadata "${CMAKE_CURRENT_BINARY_DIR}/checks/sce/metadata.json"
            COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
            DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/product.yml"
            DEPENDS generate-internal-${PRODUCT}-sce-metadata.json "${CMAKE_CURRENT_BINARY_DIR}/checks/sce/metadata.json"
            COMMENT "[${PRODUCT}-content] compiling everything"
        )
    else()
        add_custom_command(
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
            COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/profiles"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/compile_all.py" --resolved-base "${CMAKE_CURRENT_BINARY_DIR}" --project-root "${CMAKE_SOURCE_DIR}" --build-config-yaml "${CMAKE_BINARY_DIR}/build_config.yml" --product-yaml "${CMAKE_CURRENT_BINARY_DIR}/product.yml" --sce-metadata "${CMAKE_CURRENT_BINARY_DIR}/checks/sce/metadata.json" --stig-references "${STIG_REFERENCE_FILE}"
            COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
            DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/product.yml"
            DEPENDS generate-internal-${PRODUCT}-sce-metadata.json "${CMAKE_CURRENT_BINARY_DIR}/checks/sce/metadata.json"
            COMMENT "[${PRODUCT}-content] compiling everything"
        )
    endif()
    add_custom_target(
        ${PRODUCT}-compile-all
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
    )
endmacro()

macro(ssg_build_xccdf_oval_ocil PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/build_xccdf.py" --build-ovals-dir "${CMAKE_CURRENT_BINARY_DIR}/checks/oval" --resolved-base "${CMAKE_CURRENT_BINARY_DIR}" --build-config-yaml "${CMAKE_BINARY_DIR}/build_config.yml" --product-yaml "${CMAKE_CURRENT_BINARY_DIR}/product.yml" --xccdf "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" --oval "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-oval.xml" --ocil "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        COMMAND sync
        DEPENDS ${PRODUCT}-compile-all "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
        DEPENDS generate-internal-${PRODUCT}-all-fixes "${CMAKE_CURRENT_BINARY_DIR}/collect-remediations-${PRODUCT}"
        DEPENDS generate-internal-${PRODUCT}-oval-unlinked.xml "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
        COMMENT "[${PRODUCT}-content] generating plain XCCDF, OVAL and OCIL files"
    )

    add_custom_target(
        generate-${PRODUCT}-xccdf-oval-ocil
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
    )
endmacro()

# Build all templated content using the YAML "template" key in this product's
# rules. This includes OVAL, Bash, Ansible, and the like.
macro(ssg_build_templated_content PRODUCT)
    set(BUILD_CHECKS_DIR "${CMAKE_CURRENT_BINARY_DIR}/checks_from_templates")
    set(BUILD_REMEDIATIONS_DIR "${CMAKE_CURRENT_BINARY_DIR}/fixes_from_templates")
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/templated-content-${PRODUCT}"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/build_templated_content.py" --resolved-rules-dir "${CMAKE_CURRENT_BINARY_DIR}/rules" --templates-dir "${SSG_SHARED}/templates" --platforms-dir "${CMAKE_CURRENT_BINARY_DIR}/platforms" --cpe-items-dir "${CMAKE_CURRENT_BINARY_DIR}/cpe_items" --checks-dir "${BUILD_CHECKS_DIR}" --remediations-dir "${BUILD_REMEDIATIONS_DIR}" --build-config-yaml "${CMAKE_BINARY_DIR}/build_config.yml" --product-yaml "${CMAKE_CURRENT_BINARY_DIR}/product.yml"
        COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_CURRENT_BINARY_DIR}/templated-content-${PRODUCT}"
        # Actually we mean that it depends on resolved rules.
        DEPENDS ${PRODUCT}-compile-all "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
        COMMENT "[${PRODUCT}-content] generating templated content"
    )
    add_custom_target(
        generate-internal-templated-content-${PRODUCT}
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/templated-content-${PRODUCT}"
    )
endmacro()

macro(ssg_collect_remediations PRODUCT LANGUAGES)
    set(REMEDIATION_TYPE_OPTIONS "")
    foreach(LANGUAGE ${LANGUAGES})
        list(APPEND REMEDIATION_TYPE_OPTIONS "--remediation-type" "${LANGUAGE}")
    endforeach()
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/collect-remediations-${PRODUCT}"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/collect_remediations.py" --resolved-rules-dir "${CMAKE_CURRENT_BINARY_DIR}/rules" --build-config-yaml "${CMAKE_BINARY_DIR}/build_config.yml" --product-yaml "${CMAKE_CURRENT_BINARY_DIR}/product.yml" ${REMEDIATION_TYPE_OPTIONS} --output-dir "${CMAKE_CURRENT_BINARY_DIR}/fixes" --fixes-from-templates-dir "${BUILD_REMEDIATIONS_DIR}" --platforms-dir "${CMAKE_CURRENT_BINARY_DIR}/platforms" --cpe-items-dir "${CMAKE_CURRENT_BINARY_DIR}/cpe_items"
        COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_CURRENT_BINARY_DIR}/collect-remediations-${PRODUCT}"
        # Acutally we mean that it depends on resolved rules.
        DEPENDS ${PRODUCT}-compile-all "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
        DEPENDS generate-internal-templated-content-${PRODUCT} "${CMAKE_CURRENT_BINARY_DIR}/templated-content-${PRODUCT}"
        COMMENT "[${PRODUCT}-content] collecting all fixes"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-all-fixes
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/collect-remediations-${PRODUCT}"
    )
    if(SSG_SHELLCHECK_BASH_FIXES_VALIDATION_ENABLED AND SHELLCHECK_EXECUTABLE)
        add_test(
            NAME "${PRODUCT}-bash-shellcheck"
            COMMAND "${CMAKE_SOURCE_DIR}/utils/shellcheck_wrapper.sh" "${SHELLCHECK_EXECUTABLE}" "${CMAKE_BINARY_DIR}/${PRODUCT}/fixes/bash" -s bash -S warning
        )
        set_tests_properties("${PRODUCT}-bash-shellcheck" PROPERTIES LABELS quick)
    endif()
endmacro()

# Output per-profile Ansible playbooks for the specified product. This allows
# Ansible hardening to be applied directly from CaC's artifacts without
# needing to invoke OpenSCAP.
macro(ssg_build_ansible_playbooks PRODUCT)
    set(ANSIBLE_PLAYBOOKS_DIR "${CMAKE_CURRENT_BINARY_DIR}/playbooks")
    add_custom_command(
        OUTPUT "${ANSIBLE_PLAYBOOKS_DIR}/ansible_playbooks-${PRODUCT}"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/build_rule_playbooks.py" --input-dir "${CMAKE_CURRENT_BINARY_DIR}/fixes/ansible" --ssg-root "${CMAKE_SOURCE_DIR}" --product "${PRODUCT}" --resolved-rules-dir "${CMAKE_CURRENT_BINARY_DIR}/rules" --resolved-profiles-dir "${CMAKE_CURRENT_BINARY_DIR}/profiles" --output-dir "${ANSIBLE_PLAYBOOKS_DIR}" --build-config-yaml "${CMAKE_BINARY_DIR}/build_config.yml"
        COMMAND ${CMAKE_COMMAND} -E touch "${ANSIBLE_PLAYBOOKS_DIR}/ansible_playbooks-${PRODUCT}"
        DEPENDS generate-internal-${PRODUCT}-all-fixes "${CMAKE_CURRENT_BINARY_DIR}/collect-remediations-${PRODUCT}"
        COMMENT "[${PRODUCT}-content] Generating Ansible Playbooks"
    )
    add_custom_target(
        generate-${PRODUCT}-ansible-playbooks
        DEPENDS "${ANSIBLE_PLAYBOOKS_DIR}/ansible_playbooks-${PRODUCT}"
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
    message(STATUS "Scanning for dependencies of ${PRODUCT} fixes (bash, ansible, puppet, anaconda, ignition, kubernetes and blueprint)...")

    ssg_collect_remediations(${PRODUCT} "${PRODUCT_REMEDIATION_LANGUAGES}")

    if("${PRODUCT_ANSIBLE_REMEDIATION_ENABLED}")
        # only enable the ansible syntax checks if we are using openscap 1.2.17 or higher
        # older openscap causes syntax errors, see https://github.com/OpenSCAP/openscap/pull/977
        if(SSG_ANSIBLE_PLAYBOOKS_ENABLED AND ANSIBLE_PLAYBOOK_EXECUTABLE AND "${OSCAP_VERSION}" VERSION_GREATER "1.2.16")
            add_test(
                NAME "ansible-playbook-syntax-check-${PRODUCT}"
                COMMAND "${CMAKE_SOURCE_DIR}/tests/ansible_playbook_check.sh" "${ANSIBLE_PLAYBOOK_EXECUTABLE}" "${CMAKE_BINARY_DIR}/ansible" "${PRODUCT}"
            )
        endif()
        if(ANSIBLE_CHECKS)
            if(SSG_ANSIBLE_PLAYBOOKS_PER_RULE_ENABLED)
                if(ANSIBLE_LINT_EXECUTABLE)
                    add_test(
                        NAME "ansible-playbook-per-rule-ansible-lint-check-${PRODUCT}"
                        COMMAND "${CMAKE_SOURCE_DIR}/tests/ansible_playbook_check.sh" "${ANSIBLE_LINT_EXECUTABLE}" "${CMAKE_BINARY_DIR}/${PRODUCT}/playbooks/all" "${CMAKE_SOURCE_DIR}/tests/ansible-lint_config.yml"
                    )
                endif()
                if(YAMLLINT_EXECUTABLE)
                    add_test(
                        NAME "ansible-playbook-per-rule-yamllint-check-${PRODUCT}"
                        COMMAND "${CMAKE_SOURCE_DIR}/tests/ansible_playbook_check.sh" "${YAMLLINT_EXECUTABLE}" "${CMAKE_BINARY_DIR}/${PRODUCT}/playbooks/all" "${CMAKE_SOURCE_DIR}/tests/yamllint_config.yml"
                    )
                endif()
            endif()
            if(SSG_ANSIBLE_PLAYBOOKS_ENABLED)
                if(ANSIBLE_LINT_EXECUTABLE AND "${OSCAP_VERSION}" VERSION_GREATER "1.2.16")
                    add_test(
                        NAME "ansible-playbook-per-profile-ansible-lint-check-${PRODUCT}"
                        COMMAND "${CMAKE_SOURCE_DIR}/tests/ansible_playbook_check.sh" "${ANSIBLE_LINT_EXECUTABLE}" "${CMAKE_BINARY_DIR}/ansible" "${CMAKE_SOURCE_DIR}/tests/ansible-lint_config.yml" "${PRODUCT}"
                    )
                endif()
                if(YAMLLINT_EXECUTABLE AND "${OSCAP_VERSION}" VERSION_GREATER "1.2.16")
                    add_test(
                        NAME "ansible-playbook-per-profile-yamllint-check-${PRODUCT}"
                        COMMAND "${CMAKE_SOURCE_DIR}/tests/ansible_playbook_check.sh" "${YAMLLINT_EXECUTABLE}" "${CMAKE_BINARY_DIR}/ansible" "${CMAKE_SOURCE_DIR}/tests/yamllint_config.yml" "${PRODUCT}"
                    )
                endif()
            endif()
        endif()
    endif()
endmacro()

macro(ssg_build_oval_unlinked PRODUCT)
    set(BUILD_CHECKS_DIR "${CMAKE_CURRENT_BINARY_DIR}/checks_from_templates")
    set(OVAL_COMBINE_PATHS "${SSG_SHARED}/checks/oval" "${BUILD_CHECKS_DIR}/oval")
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/combine_ovals.py" --log "${LOG_LEVEL}" --include-benchmark --build-config-yaml "${CMAKE_BINARY_DIR}/build_config.yml" --product-yaml "${CMAKE_CURRENT_BINARY_DIR}/product.yml" --output "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml" ${OVAL_COMBINE_PATHS}
        COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml" "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
        DEPENDS generate-internal-templated-content-${PRODUCT} "${CMAKE_CURRENT_BINARY_DIR}/templated-content-${PRODUCT}"
        COMMENT "[${PRODUCT}-content] generating oval-unlinked.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-oval-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml"
    )
endmacro()

macro(ssg_build_cpe_oval_unlinked PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/cpe-oval-unlinked.xml"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/combine_ovals.py" --log "${LOG_LEVEL}" --build-config-yaml "${CMAKE_BINARY_DIR}/build_config.yml" --product-yaml "${CMAKE_CURRENT_BINARY_DIR}/product.yml" --output "${CMAKE_CURRENT_BINARY_DIR}/cpe-oval-unlinked.xml" --build-ovals-dir "${CMAKE_CURRENT_BINARY_DIR}/checks/oval" "${CMAKE_CURRENT_BINARY_DIR}/checks_from_templates/cpe-oval" "${SSG_SHARED}/checks/oval" "${SSG_SHARED}/applicability/oval"
        COMMAND "${XMLLINT_EXECUTABLE}" --format --output "${CMAKE_CURRENT_BINARY_DIR}/cpe-oval-unlinked.xml" "${CMAKE_CURRENT_BINARY_DIR}/cpe-oval-unlinked.xml"
        DEPENDS generate-internal-templated-content-${PRODUCT} "${CMAKE_CURRENT_BINARY_DIR}/templated-content-${PRODUCT}"
        COMMENT "[${PRODUCT}-content] generating cpe-oval-unlinked.xml"
    )
    add_custom_target(
        generate-internal-${PRODUCT}-cpe-oval-unlinked.xml
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/cpe-oval-unlinked.xml"
    )
endmacro()

macro(ssg_build_manifest PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/manifest-${PRODUCT}.json"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/generate_manifest.py" --output "${CMAKE_CURRENT_BINARY_DIR}/manifest-${PRODUCT}.json" --build-root "${CMAKE_CURRENT_BINARY_DIR}"
        # The manifest requires compiled artifacts on right places and also per-rule OVAL.
        # It is not clear when those things assume their places, so manifest is compiled late
        DEPENDS generate-ssg-${PRODUCT}-ds.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMENT "[${PRODUCT}-content] generating JSON manifest"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-manifest.json
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/manifest-${PRODUCT}.json"
    )
    add_dependencies(zipfile generate-ssg-${PRODUCT}-manifest.json)
endmacro()

# Builds SCE content into the build system. This occurs prior to XCCDF
# generation so that the XCCDF builder can correctly place SCE content
# (without needing a separate XML or XSLT linking step) and also place
# <complex-check /> elements as necessary.
macro(ssg_build_sce PRODUCT)
    set(BUILD_CHECKS_DIR "${CMAKE_CURRENT_BINARY_DIR}/checks")
    # Unlike build_oval_unlinked, here we're ignoring the existing checks from
    # templates and other places and we're merely appending/templating the
    # content from the rules directories. That's why we ignore BUILD_CHECKS_DIR
    # in the combine paths below.
    set(SCE_COMBINE_PATHS "${SSG_SHARED}/checks/sce" "${CMAKE_CURRENT_SOURCE_DIR}/checks/sce")

    if(SSG_SCE_ENABLED)
        # Unlike build_oval_unlinked, we don't depend on templated content yet.
        #
        # This is for two reasons:
        # 1. Support for templated SCE isn't yet implemented.
        # 2. Generating YAML->XCCDF (in ssg_build_xccdf_oval_ocil) relies on
        #    our data, so we need it to occur earlier. However, templating depends
        #    the XCCDF, so we'd have a dependency circle.
        add_custom_command(
            OUTPUT "${BUILD_CHECKS_DIR}/sce/metadata.json"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/build_sce.py" --build-config-yaml "${CMAKE_BINARY_DIR}/build_config.yml" --product-yaml "${CMAKE_CURRENT_BINARY_DIR}/product.yml" --templates-dir "${SSG_SHARED}/templates" --output "${BUILD_CHECKS_DIR}/sce" ${SCE_COMBINE_PATHS}
            COMMENT "[${PRODUCT}-content] generating sce/metadata.json"
            DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/product.yml"
        )
    else()
        # Here we fake generating SCE metadata by creating an empty file.
        # Because every other step reads data from this metadata file, if
        # it is empty, no SCE content will actually be generated.
        add_custom_command(
            OUTPUT "${BUILD_CHECKS_DIR}/sce/metadata.json"
            COMMAND ${CMAKE_COMMAND} -E make_directory "${BUILD_CHECKS_DIR}/sce"
            COMMAND ${CMAKE_COMMAND} -E touch "${BUILD_CHECKS_DIR}/sce/metadata.json"
            COMMENT "[${PRODUCT}-content] generating sce/metadata.json"
        )
    endif()
    add_custom_target(
        generate-internal-${PRODUCT}-sce-metadata.json
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/checks/sce/metadata.json"
    )
endmacro()

# The CPE dictionary is a list of platform-like constructs that get built
# per-product and allow detection of specific features (like OS version or
# package installation state). This is a "dictionary" file and then OVAL
# checks to actually audit the state of each dictionary item. Note that
# these get evaluated separately from the XCCDF and have no knowledge of
# e.g. the state of XCCDF variables in a profile. Most of these are located
# under shared/applicability and shared/checks.
macro(ssg_build_cpe_dictionary PRODUCT)

    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/cpe_generate.py" --product-yaml "${CMAKE_CURRENT_BINARY_DIR}/product.yml" --cpe-items-dir "${CMAKE_CURRENT_BINARY_DIR}/cpe_items" ssg "${CMAKE_BINARY_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" "${CMAKE_CURRENT_BINARY_DIR}/cpe-oval-unlinked.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
        DEPENDS generate-${PRODUCT}-xccdf-oval-ocil "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-oval.xml" "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        DEPENDS generate-internal-${PRODUCT}-cpe-oval-unlinked.xml "${CMAKE_CURRENT_BINARY_DIR}/cpe-oval-unlinked.xml"
        DEPENDS ${PRODUCT}-compile-all "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-cpe-dictionary.xml, ssg-${PRODUCT}-cpe-oval.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-cpe-dictionary.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
    )
    define_validate_product("${PRODUCT}")
    if("${VALIDATE_PRODUCT}" OR "${FORCE_VALIDATE_EVERYTHING}")
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

# Apply a final xmllint pass over the XCCDF document to pretty-format the output
# XCCDF document for the product. Then, generate XCCDF 1.2 version as well.
macro(ssg_build_xccdf_final PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-${PRODUCT}-xccdf-oval-ocil "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-oval.xml" "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-xccdf.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
    )

endmacro()

# Apply a final xmllint pass over the OVAL document to pretty-format the output
# OVAL document for the product.
macro(ssg_build_oval_final PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml" "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
        DEPENDS generate-${PRODUCT}-xccdf-oval-ocil "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-oval.xml" "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-oval.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-oval.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
    )
    define_validate_product("${PRODUCT}")
    if("${VALIDATE_PRODUCT}" OR "${FORCE_VALIDATE_EVERYTHING}")
        add_test(
            NAME "validate-ssg-${PRODUCT}-oval.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" oval validate ${OSCAP_OVAL_SCHEMATRON_OPTION} "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
        )
    endif()
endmacro()

# Apply a final xmllint pass over the OCIL document to pretty-format the output
# OCIL document for the product.
macro(ssg_build_ocil_final PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml" "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        DEPENDS generate-${PRODUCT}-xccdf-oval-ocil "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-oval.xml" "${CMAKE_CURRENT_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        COMMENT "[${PRODUCT}-content] generating ssg-${PRODUCT}-ocil.xml"
    )
    add_custom_target(
        generate-ssg-${PRODUCT}-ocil.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
    )
endmacro()

# Build source data streams (as opposed to result data streams that occur after
# evaluation using e.g., OpenSCAP) by combining XCCDF, OVAL, SCE, and OCIL
# content. This relies heavily on the OpenSCAP executable here.
macro(ssg_build_sds PRODUCT)
    if(SSG_SCE_ENABLED)
        set(COMPOSE_EXTRA_ARGS "--enable-sce")
    else()
        set(COMPOSE_EXTRA_ARGS "")
    endif()

    if(SSG_BUILD_SCAP_12_DS)
        add_custom_command(
            OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml"
            OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/compose_ds.py" --xccdf "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" --oval "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml" --ocil "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml" --cpe-dict "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml" --cpe-oval "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml" --output-12 "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml" --output-13 "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" ${COMPOSE_EXTRA_ARGS}
            COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml"
            COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            DEPENDS generate-ssg-${PRODUCT}-xccdf.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
            DEPENDS generate-ssg-${PRODUCT}-oval.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
            DEPENDS generate-ssg-${PRODUCT}-ocil.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
            DEPENDS generate-ssg-${PRODUCT}-cpe-dictionary.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
            COMMENT "[${PRODUCT}-content] Updating data stream ssg-${PRODUCT}-ds.xml to 1.3"
        )
        add_custom_target(
            generate-ssg-${PRODUCT}-ds.xml
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml"
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        )
    else()
        add_custom_command(
            OUTPUT "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/compose_ds.py" --xccdf "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" --oval "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml" --ocil "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml" --cpe-dict "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml" --cpe-oval "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml" --output-13 "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" ${COMPOSE_EXTRA_ARGS}
            COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            DEPENDS generate-ssg-${PRODUCT}-xccdf.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
            DEPENDS generate-ssg-${PRODUCT}-oval.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
            DEPENDS generate-ssg-${PRODUCT}-ocil.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
            DEPENDS generate-ssg-${PRODUCT}-cpe-dictionary.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
            COMMENT "[${PRODUCT}-content] Updating data stream ssg-${PRODUCT}-ds.xml to 1.3"
        )
        add_custom_target(
            generate-ssg-${PRODUCT}-ds.xml
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        )
    endif()

    add_test(
        NAME "xccdf-values-${PRODUCT}"
        COMMAND "${CMAKE_SOURCE_DIR}/tests/test_xccdf_values_in_ds.sh" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
    )
    set_tests_properties("xccdf-values-${PRODUCT}" PROPERTIES LABELS "quick")

    add_test(
        NAME "reference-titles-in-benchmark-${PRODUCT}"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/tests/test_reference_titles_in_benchmark.py" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "${CMAKE_BINARY_DIR}/${PRODUCT}/product.yml"
    )
    set_tests_properties("reference-titles-in-benchmark-${PRODUCT}" PROPERTIES LABELS quick)

    if("${PRODUCT}" MATCHES "rhel(7|8|9)|sle(12|15)")
        if("${PRODUCT}" MATCHES "sle(12|15)")
            add_test(
                NAME "missing-cces-${PRODUCT}"
                COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/tests/missing_cces.py" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" "-p anssi,hipaa,pci,stig"
            )
        else()
            add_test(
                NAME "missing-cces-${PRODUCT}"
                COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/tests/missing_cces.py" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            )
        endif()
        set_tests_properties("missing-cces-${PRODUCT}" PROPERTIES LABELS quick)
    endif()

    define_validate_product("${PRODUCT}")
    if("${VALIDATE_PRODUCT}" OR "${FORCE_VALIDATE_EVERYTHING}")
        add_test(
            NAME "validate-ssg-${PRODUCT}-ds.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-validate "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        )
        if(SSG_BUILD_SCAP_12_DS)
            add_test(
                NAME "validate-ssg-${PRODUCT}-ds-1.2.xml"
                COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-validate "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml"
            )
        endif()
    endif()
    add_test(
        NAME "verify-references-ssg-${PRODUCT}-ds.xml"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/verify_references.py" --rules-with-invalid-checks --base-dir "${CMAKE_BINARY_DIR}" --ovaldefs-unused "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
    )
    set_tests_properties("verify-references-ssg-${PRODUCT}-ds.xml" PROPERTIES LABELS quick)
    if("${PRODUCT}" MATCHES "rhel")
        if("${PRODUCT}" MATCHES "rhel7")
            set(REFERENCES_CHECK_PROFILE_LIST cis anssi_nt28_high hipaa)
        elseif("${PRODUCT}" MATCHES "rhel8")
            set(REFERENCES_CHECK_PROFILE_LIST cis anssi_bp28_high hipaa)
        endif()
        add_test(
                NAME "missing-references-ssg-${PRODUCT}-ds.xml"
                COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${CMAKE_SOURCE_DIR}/tests/missing_refs.sh" "${PYTHON_EXECUTABLE}" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" ${REFERENCES_CHECK_PROFILE_LIST}
        )
        set_tests_properties("missing-references-ssg-${PRODUCT}-ds.xml" PROPERTIES LABELS quick)

    endif()
    if(("${PRODUCT}" MATCHES "ubuntu2" OR "${PRODUCT}" MATCHES "rhel8") AND SSG_SCE_ENABLED)
        add_test(
            NAME "ds-sce-${PRODUCT}"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/tests/test_ds_sce.py" "${CMAKE_BINARY_DIR}" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        )
    endif()
    if(PYTHON_VERSION_MAJOR GREATER 2 AND PY_PCRE2)
        add_test(
            NAME "check-pcre2-compatibility-ssg-${PRODUCT}-ds.xml"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/tests/check_pcre2_compatibility.py" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        )
        set_tests_properties("check-pcre2-compatibility-ssg-${PRODUCT}-ds.xml" PROPERTIES LABELS quick)
    endif()
endmacro()

# Build per-product HTML guides to see the status of various profiles and
# rules in the generated XCCDF guides.
macro(ssg_build_html_guides PRODUCT)
    if(PYTHON_VERSION_MAJOR GREATER 2 AND PY_LXML)
        add_custom_command(
            OUTPUT "${CMAKE_BINARY_DIR}/guides/ssg-${PRODUCT}-guide-index.html"
            COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/guides"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/generate_guides.py" --data-stream "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" --product "${PRODUCT}" --output-dir "${CMAKE_BINARY_DIR}/guides" --oscap-version "${OSCAP_VERSION}"
            DEPENDS generate-ssg-${PRODUCT}-ds.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMENT "[${PRODUCT}-guides] generating HTML guides for all profiles in ssg-${PRODUCT}-ds.xml"
        )
    else()
        add_custom_command(
            OUTPUT "${CMAKE_BINARY_DIR}/guides/ssg-${PRODUCT}-guide-index.html"
            COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/guides"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/build_all_guides.py" --input "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" --output "${CMAKE_BINARY_DIR}/guides" build
            DEPENDS generate-ssg-${PRODUCT}-ds.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
            COMMENT "[${PRODUCT}-guides] generating HTML guides for all profiles in ssg-${PRODUCT}-ds.xml"
        )
    endif()
    add_custom_target(
        generate-ssg-${PRODUCT}-guide-index.html
        DEPENDS "${CMAKE_BINARY_DIR}/guides/ssg-${PRODUCT}-guide-index.html"
    )

    # despite checking just the index this actually tests all the guides because the index links to them
    # needs PARENT_SCOPE because this is done across different cmake files via add_directory(..)
    list(APPEND SSG_HTML_GUIDE_FILE_LIST "${CMAKE_BINARY_DIR}/guides/ssg-${PRODUCT}-guide-index.html")
    set(SSG_HTML_GUIDE_FILE_LIST ${SSG_HTML_GUIDE_FILE_LIST} PARENT_SCOPE)
endmacro()

# Build per-profile Bash remediation scripts that can be used independently of
# OpenSCAP execution.
macro(ssg_build_profile_bash_scripts PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/bash/all-profile-bash-scripts-${PRODUCT}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/bash"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/generate_profile_remediations.py" --language bash --data-stream "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" --output-dir "${CMAKE_BINARY_DIR}/bash" --product "${PRODUCT}"
        COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_BINARY_DIR}/bash/all-profile-bash-scripts-${PRODUCT}"
        DEPENDS generate-ssg-${PRODUCT}-ds.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMENT "[${PRODUCT}-bash-scripts] generating Bash remediation scripts for all profiles in ssg-${PRODUCT}-ds.xml"
    )
    add_custom_target(
        generate-all-profile-bash-scripts-${PRODUCT}
        DEPENDS "${CMAKE_BINARY_DIR}/bash/all-profile-bash-scripts-${PRODUCT}"
    )
endmacro()

# Build per-profile Ansible remediation scripts that can be used independently
# of OpenSCAP execution.
macro(ssg_build_profile_playbooks PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ansible/all-profile-playbooks-${PRODUCT}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/ansible"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/generate_profile_remediations.py" --language ansible --data-stream "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" --output-dir "${CMAKE_BINARY_DIR}/ansible" --product "${PRODUCT}"
        COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_BINARY_DIR}/ansible/all-profile-playbooks-${PRODUCT}"
        DEPENDS generate-ssg-${PRODUCT}-ds.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMENT "[${PRODUCT}-playbooks] generating Ansible Playbooks for all profiles in ssg-${PRODUCT}-ds.xml"
    )
    add_custom_target(
        generate-all-profile-playbooks-${PRODUCT}
        DEPENDS "${CMAKE_BINARY_DIR}/ansible/all-profile-playbooks-${PRODUCT}"
    )
endmacro()

# Generate benchmark statistics (using build-scripts/profile_tool.py)
# automatically via make/ninja; not part of the default target but
# can be run manually.
macro(ssg_make_stats_for_product PRODUCT)
    add_custom_target(${PRODUCT}-stats
        COMMAND ${CMAKE_COMMAND} -E echo "Benchmark statistics for '${PRODUCT}':"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/profile_tool.py" stats --product "${PRODUCT}" --benchmark "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" --profile all
        DEPENDS generate-ssg-${PRODUCT}-ds.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMENT "[${PRODUCT}-stats] generating benchmark statistics"
    )
    add_custom_target(${PRODUCT}-profile-stats
        COMMAND ${CMAKE_COMMAND} -E echo "Per profile statistics for '${PRODUCT}':"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/profile_tool.py" stats --product "${PRODUCT}" --benchmark "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        DEPENDS generate-ssg-${PRODUCT}-ds.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMENT "[${PRODUCT}-profile-stats] generating per profile statistics"
    )
endmacro()

# As above
macro(ssg_make_html_stats_for_product PRODUCT)
    add_custom_target(${PRODUCT}-html-stats
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/profile_tool.py" stats  --product "${PRODUCT}" --format html --benchmark "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" --profile all --output "${CMAKE_BINARY_DIR}/${PRODUCT}/product-statistics/"
        DEPENDS generate-ssg-${PRODUCT}-ds.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMENT "[${PRODUCT}-html-stats] generating benchmark html statistics"
    )
    add_custom_target(${PRODUCT}-html-profile-stats
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/profile_tool.py" stats  --product "${PRODUCT}" --format html --benchmark "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml" --output "${CMAKE_BINARY_DIR}/${PRODUCT}/profile-statistics/"
        DEPENDS generate-ssg-${PRODUCT}-ds.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMENT "[${PRODUCT}-html-profile-stats] generating per profile html statistics"
    )
endmacro()

macro(ssg_render_policies_for_product PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/${PRODUCT}/rendered-policies/rendered-policies-${PRODUCT}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/${PRODUCT}/rendered-policies"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_UTILS_SCRIPTS}/render_all_policies.py" --ssg-root "${CMAKE_SOURCE_DIR}" --output-dir "${CMAKE_BINARY_DIR}/${PRODUCT}/rendered-policies" --product ${PRODUCT}
        COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_BINARY_DIR}/${PRODUCT}/rendered-policies/rendered-policies-${PRODUCT}"
        DEPENDS generate-ssg-${PRODUCT}-ds.xml
        COMMENT "[${PRODUCT}-render-policies] generating rendered policies for ${PRODUCT}"
    )

    add_custom_target(${PRODUCT}-render-policies
        DEPENDS "${CMAKE_BINARY_DIR}/${PRODUCT}/rendered-policies/rendered-policies-${PRODUCT}"
    )
endmacro()

macro(ssg_make_all_tables PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/tables-${PRODUCT}-all.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/gen_tables.py" --build-dir "${CMAKE_BINARY_DIR}" --output-type html --output "${CMAKE_BINARY_DIR}/tables/tables-${PRODUCT}-all.html" "${PRODUCT}"
        # Actually we mean that it depends on resolved rules - see also ssg_build_templated_content
        DEPENDS ${PRODUCT}-compile-all "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
    )
    add_custom_target(generate-ssg-tables-${PRODUCT}-all
        DEPENDS "${CMAKE_BINARY_DIR}/tables/tables-${PRODUCT}-all.html"
    )
endmacro()

macro(ssg_build_disa_delta PRODUCT PROFILE)
    file(GLOB DISA_SCAP_REF "${SSG_SHARED_REFS}/disa-stig-${PRODUCT}-v[0-9]*r[0-9]*-xccdf-scap.xml")
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/${PRODUCT}/tailoring/${PRODUCT}_${PROFILE}_delta_tailoring.xml"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/${PRODUCT}/tailoring"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/create_scap_delta_tailoring.py" --root "${CMAKE_SOURCE_DIR}" --product "${PRODUCT}" --manual "${DISA_SCAP_REF}" --profile "${PROFILE}" --reference "stigid" --output "${CMAKE_BINARY_DIR}/${PRODUCT}/tailoring/${PRODUCT}_${PROFILE}_delta_tailoring.xml" --quiet --build-root ${CMAKE_BINARY_DIR} --resolved-rules-dir
        DEPENDS "${PRODUCT}-content"
        COMMENT "[${PRODUCT}-generate-ssg-delta] generating disa tailoring file"
    )

    add_custom_target(generate-ssg-delta-${PRODUCT}-${PROFILE}
        DEPENDS "${CMAKE_BINARY_DIR}/${PRODUCT}/tailoring/${PRODUCT}_${PROFILE}_delta_tailoring.xml"
    )

    install(FILES "${CMAKE_BINARY_DIR}/${PRODUCT}/tailoring/${PRODUCT}_${PROFILE}_delta_tailoring.xml"
            DESTINATION ${SSG_TAILORING_INSTALL_DIR})
endmacro()

# Top-level macro to build all output artifacts for the specified product.
# Ensures the various targets we create in the above macros are linked to
# the default build target when applicable and handles installation steps.
# This is called from each product's CMakeLists.txt file.
macro(ssg_build_product PRODUCT)
    # Enforce folder naming rules, we require SSG contributors to use
    # scap-security-guide/${PRODUCT}/ for all products. This makes it easier
    # to find relevant source-code and build just the relevant product.
    get_filename_component(EXPECTED_CMAKELISTS "${CMAKE_SOURCE_DIR}/products/${PRODUCT}/CMakeLists.txt" ABSOLUTE)
    get_filename_component(ACTUAL_CMAKELISTS "${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt" ABSOLUTE)

    if(NOT "${ACTUAL_CMAKELISTS}" STREQUAL "${EXPECTED_CMAKELISTS}")
        message(FATAL_ERROR "Expected ${PRODUCT}'s CMakeLists.txt to be at ${EXPECTED_CMAKELISTS}. Instead it's at ${ACTUAL_CMAKELISTS}. Please move it to the correct location.")
    endif()

    add_custom_target(${PRODUCT}-content)

    if(NOT DEFINED PRODUCT_REMEDIATION_LANGUAGES)
        set(PRODUCT_REMEDIATION_LANGUAGES "bash;ansible;puppet;anaconda;ignition;kubernetes;blueprint")
    endif()
    # Define variables for each language to facilitate assesment of specific remediation languages
    foreach(LANGUAGE ${PRODUCT_REMEDIATION_LANGUAGES})
        string(TOUPPER ${LANGUAGE} _LANGUAGE)
        set(PRODUCT_${_LANGUAGE}_REMEDIATION_ENABLED TRUE)
    endforeach()

    ssg_build_compiled_artifacts(${PRODUCT})
    ssg_build_sce(${PRODUCT})
    ssg_build_xccdf_oval_ocil(${PRODUCT})
    ssg_make_all_tables(${PRODUCT})
    ssg_build_templated_content(${PRODUCT})
    ssg_build_remediations(${PRODUCT})

    if("${PRODUCT_ANSIBLE_REMEDIATION_ENABLED}" AND SSG_ANSIBLE_PLAYBOOKS_PER_RULE_ENABLED)
        ssg_build_ansible_playbooks(${PRODUCT})
        add_dependencies(
            ${PRODUCT}-content
            generate-${PRODUCT}-ansible-playbooks
        )
    endif()
    ssg_build_oval_unlinked(${PRODUCT})
    ssg_build_cpe_oval_unlinked(${PRODUCT})
    ssg_build_manifest(${PRODUCT})
    ssg_build_cpe_dictionary(${PRODUCT})
    ssg_build_xccdf_final(${PRODUCT})
    ssg_build_oval_final(${PRODUCT})
    ssg_build_ocil_final(${PRODUCT})
    ssg_build_sds(${PRODUCT})

    add_custom_target(${PRODUCT} ALL)
    add_dependencies(${PRODUCT} ${PRODUCT}-content)

    add_dependencies(
        ${PRODUCT}-content
        generate-ssg-${PRODUCT}-xccdf.xml
        generate-ssg-${PRODUCT}-oval.xml
        generate-ssg-${PRODUCT}-ocil.xml
        generate-ssg-${PRODUCT}-manifest.json
        generate-ssg-${PRODUCT}-cpe-dictionary.xml
        generate-ssg-${PRODUCT}-ds.xml
        generate-ssg-tables-${PRODUCT}-all
    )

    add_dependencies(zipfile generate-ssg-${PRODUCT}-ds.xml)

    if("${PRODUCT_ANSIBLE_REMEDIATION_ENABLED}" AND SSG_ANSIBLE_PLAYBOOKS_ENABLED)
        ssg_build_profile_playbooks(${PRODUCT})
        add_custom_target(
            ${PRODUCT}-profile-playbooks
            DEPENDS generate-all-profile-playbooks-${PRODUCT} "${CMAKE_BINARY_DIR}/ansible/all-profile-playbooks-${PRODUCT}"
        )
        add_dependencies(${PRODUCT} ${PRODUCT}-profile-playbooks)
        add_dependencies(zipfile ${PRODUCT}-profile-playbooks)
    endif()

    if("${PRODUCT_BASH_REMEDIATION_ENABLED}" AND SSG_BASH_SCRIPTS_ENABLED)
        ssg_build_profile_bash_scripts(${PRODUCT})
        add_custom_target(
            ${PRODUCT}-profile-bash-scripts
            DEPENDS generate-all-profile-bash-scripts-${PRODUCT} "${CMAKE_BINARY_DIR}/bash/all-profile-bash-scripts-${PRODUCT}"
        )
        add_dependencies(${PRODUCT} ${PRODUCT}-profile-bash-scripts)
        add_dependencies(zipfile ${PRODUCT}-profile-bash-scripts)
    endif()

    ssg_build_html_guides(${PRODUCT})

    add_custom_target(
        ${PRODUCT}-guides
        DEPENDS generate-ssg-${PRODUCT}-guide-index.html "${CMAKE_BINARY_DIR}/guides/ssg-${PRODUCT}-guide-index.html"
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

    ssg_render_policies_for_product(${PRODUCT})
    add_dependencies(render-policies ${PRODUCT}-render-policies)

    if(SSG_BUILD_DISA_DELTA_FILES AND "${PRODUCT}" MATCHES "rhel(7|8)")
        ssg_build_disa_delta(${PRODUCT} "stig")
        add_dependencies(${PRODUCT} generate-ssg-delta-${PRODUCT}-stig)
    endif()

    add_dependencies(man_page ${PRODUCT})

    if(SSG_SEPARATE_SCAP_FILES_ENABLED)
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

    if(SSG_BUILD_SCAP_12_DS)
        install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds-1.2.xml"
            DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    endif()

    # This is a common cmake trick, we need the globbing to happen at build time
    # and not configure time.
    install(
        # The globbing expression below is made loose so that it can also match
        # guides for PCIDSS centric benchmarks
        CODE "
        file(GLOB GUIDE_FILES \"${CMAKE_BINARY_DIR}/guides/ssg-${PRODUCT}-*.html\") \n
        if(NOT IS_ABSOLUTE ${SSG_GUIDE_INSTALL_DIR})
            file(INSTALL DESTINATION \"${CMAKE_INSTALL_PREFIX}/${SSG_GUIDE_INSTALL_DIR}\"
                TYPE FILE FILES \${GUIDE_FILES})
        else()
            file(INSTALL DESTINATION \"${SSG_GUIDE_INSTALL_DIR}\"
                TYPE FILE FILES \${GUIDE_FILES})
        endif()
        "
    )
    if(SSG_ANSIBLE_PLAYBOOKS_ENABLED)
        install(
            CODE "
            file(GLOB ROLE_FILES \"${CMAKE_BINARY_DIR}/ansible/${PRODUCT}-playbook-*.yml\") \n
            if(NOT IS_ABSOLUTE ${SSG_ANSIBLE_ROLE_INSTALL_DIR})
                file(INSTALL DESTINATION \"${CMAKE_INSTALL_PREFIX}/${SSG_ANSIBLE_ROLE_INSTALL_DIR}\"
                    TYPE FILE FILES \${ROLE_FILES})
            else()
                file(INSTALL DESTINATION \"${SSG_ANSIBLE_ROLE_INSTALL_DIR}\"
                    TYPE FILE FILES \${ROLE_FILES})
            endif()
            "
        )
    endif()
    if(SSG_BASH_SCRIPTS_ENABLED)
        install(
            CODE "
            file(GLOB ROLE_FILES \"${CMAKE_BINARY_DIR}/bash/${PRODUCT}-script-*.sh\") \n
            if(NOT IS_ABSOLUTE ${SSG_BASH_ROLE_INSTALL_DIR})
                file(INSTALL DESTINATION \"${CMAKE_INSTALL_PREFIX}/${SSG_BASH_ROLE_INSTALL_DIR}\"
                    TYPE FILE FILES \${ROLE_FILES})
            else()
                file(INSTALL DESTINATION \"${SSG_BASH_ROLE_INSTALL_DIR}\"
                    TYPE FILE FILES \${ROLE_FILES})
            endif()
            "
        )
    endif()
    if(SSG_ANSIBLE_PLAYBOOKS_PER_RULE_ENABLED)
        install(
            CODE "
            file(GLOB PLAYBOOK_PER_RULE_FILES \"${CMAKE_BINARY_DIR}/${PRODUCT}/playbooks/*\") \n
            if(NOT IS_ABSOLUTE ${SSG_ANSIBLE_PER_RULE_PLAYBOOKS_INSTALL_DIR})
                file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/${SSG_ANSIBLE_PER_RULE_PLAYBOOKS_INSTALL_DIR}/${PRODUCT}\"
                    TYPE FILE FILES \${PLAYBOOK_PER_RULE_FILES})
            else()
                file(INSTALL DESTINATION \"${SSG_ANSIBLE_PER_RULE_PLAYBOOKS_INSTALL_DIR}/${PRODUCT}\"
                    TYPE FILE FILES \${PLAYBOOK_PER_RULE_FILES})
            endif()
            "
        )
    endif()

    if(ENABLE_SCAPVAL13)
        add_test(
            NAME "scapval-${PRODUCT}"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/tests/run_scapval.py" "--scap-version" "1.3" "--scapval-path" "${SCAPVAL_PATH}" "--datastream" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        )
        set_tests_properties("scapval-${PRODUCT}" PROPERTIES LABELS scapval)
    endif()

    # grab all the kickstarts (if any) and install them
    file(GLOB KICKSTART_FILES "${CMAKE_CURRENT_SOURCE_DIR}/kickstart/ssg-${PRODUCT}-*-ks.cfg")
    install(FILES ${KICKSTART_FILES}
        DESTINATION "${SSG_KICKSTART_INSTALL_DIR}")
endmacro()

# Certain products like CentOS and Scientific Linux are pure derivatives
# (rebuilds) of other products (namely, RHEL in this case). This means that
# we don't need to maintain a separate content repository/product for them
# but can instead rebrand the original product to the new derivative name.
macro(ssg_build_derivative_product ORIGINAL SHORTNAME DERIVATIVE)
    add_custom_target(${DERIVATIVE}-content)

    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/enable_derivatives.py" --enable-${SHORTNAME} -i "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-xccdf.xml" -o "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml" "${CMAKE_CURRENT_BINARY_DIR}/product.yml" ${DERIVATIVE} --id-name ssg --cpe-items-dir "${CMAKE_CURRENT_BINARY_DIR}/cpe_items"
        DEPENDS generate-ssg-${ORIGINAL}-xccdf.xml "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-xccdf.xml"
        DEPENDS ${PRODUCT}-compile-all "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
        COMMENT "[${DERIVATIVE}-content] generating ssg-${DERIVATIVE}-xccdf.xml"
    )
    add_custom_target(
        generate-ssg-${DERIVATIVE}-xccdf.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml"
    )

    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/enable_derivatives.py" --enable-${SHORTNAME} -i "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-ds.xml" -o "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml" "${CMAKE_CURRENT_BINARY_DIR}/product.yml" ${DERIVATIVE} --id-name ssg --cpe-items-dir "${CMAKE_CURRENT_BINARY_DIR}/cpe_items"
        COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        DEPENDS generate-ssg-${ORIGINAL}-ds.xml "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-ds.xml"
        DEPENDS ${PRODUCT}-compile-all "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
        COMMENT "[${DERIVATIVE}-content] generating ssg-${DERIVATIVE}-ds.xml"
    )
    add_custom_target(
        generate-ssg-${DERIVATIVE}-ds.xml
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
    )

    if(SSG_BUILD_SCAP_12_DS)
        add_custom_command(
            OUTPUT "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds-1.2.xml"
            COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${SSG_BUILD_SCRIPTS}/enable_derivatives.py" --enable-${SHORTNAME} -i "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-ds-1.2.xml" -o "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds-1.2.xml" "${CMAKE_CURRENT_BINARY_DIR}/product.yml" ${DERIVATIVE} --id-name ssg --cpe-items-dir "${CMAKE_CURRENT_BINARY_DIR}/cpe_items"
            COMMAND "${XMLLINT_EXECUTABLE}" --nsclean --format --output "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds-1.2.xml" "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds-1.2.xml"
            DEPENDS generate-ssg-${ORIGINAL}-ds.xml "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-ds.xml" "${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-ds-1.2.xml"
            DEPENDS ${PRODUCT}-compile-all "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
            COMMENT "[${DERIVATIVE}-content] generating ssg-${DERIVATIVE}-ds-1.2.xml"
        )
        add_custom_target(
            generate-ssg-${DERIVATIVE}-ds-1.2.xml
            DEPENDS "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds-1.2.xml"
        )
    endif()

    define_validate_product("${DERIVATIVE}")
    if("${VALIDATE_PRODUCT}" OR "${FORCE_VALIDATE_EVERYTHING}")
        add_test(
            NAME "validate-ssg-${DERIVATIVE}-ds.xml"
            COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-validate "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        )
        if(SSG_BUILD_SCAP_12_DS)
            add_test(
                NAME "validate-ssg-${DERIVATIVE}-ds-1.2.xml"
                COMMAND "${OPENSCAP_OSCAP_EXECUTABLE}" ds sds-validate "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds-1.2.xml"
            )
        endif()
    endif()

    add_custom_target(${DERIVATIVE} ALL)
    add_dependencies(${DERIVATIVE} ${DERIVATIVE}-content)
    add_dependencies(man_page ${DERIVATIVE})

    add_dependencies(
        ${DERIVATIVE}-content
        generate-ssg-${DERIVATIVE}-xccdf.xml
        generate-ssg-${DERIVATIVE}-ds.xml
    )
    if(SSG_BUILD_SCAP_12_DS)
        add_dependencies(${DERIVATIVE}-content generate-ssg-${DERIVATIVE}-ds-1.2.xml)
    endif()

    add_dependencies(zipfile generate-ssg-${DERIVATIVE}-ds.xml)

    ssg_build_html_guides(${DERIVATIVE})

    if("${PRODUCT_BASH_REMEDIATION_ENABLED}" AND SSG_BASH_SCRIPTS_ENABLED)
        ssg_build_profile_bash_scripts(${DERIVATIVE})
        add_custom_target(
            ${DERIVATIVE}-profile-bash-scripts
            DEPENDS generate-all-profile-bash-scripts-${DERIVATIVE} "${CMAKE_BINARY_DIR}/bash/all-profile-bash-scripts-${DERIVATIVE}"
        )
        add_dependencies(${DERIVATIVE} ${DERIVATIVE}-profile-bash-scripts)
    endif()

    if("${PRODUCT_ANSIBLE_REMEDIATION_ENABLED}" AND SSG_ANSIBLE_PLAYBOOKS_ENABLED)
        ssg_build_profile_playbooks(${DERIVATIVE})
        add_custom_target(
            ${DERIVATIVE}-profile-playbooks
            DEPENDS generate-all-profile-playbooks-${DERIVATIVE} "${CMAKE_BINARY_DIR}/ansible/all-profile-playbooks-${DERIVATIVE}"
        )
        add_dependencies(${DERIVATIVE} ${DERIVATIVE}-profile-playbooks)
    endif()

    add_custom_target(
        ${DERIVATIVE}-guides
        DEPENDS generate-ssg-${DERIVATIVE}-guide-index.html "${CMAKE_BINARY_DIR}/guides/ssg-${DERIVATIVE}-guide-index.html"
    )
    add_dependencies(${DERIVATIVE} ${DERIVATIVE}-guides)

    if(SSG_SEPARATE_SCAP_FILES_ENABLED)
        install(FILES "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml"
            DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    endif()

    install(FILES "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")

    if(SSG_BUILD_SCAP_12_DS)
        install(FILES "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds-1.2.xml"
            DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    endif()

    # This is a common cmake trick, we need the globbing to happen at build time
    # and not configure time.
    install(
        CODE "
        file(GLOB GUIDE_FILES \"${CMAKE_BINARY_DIR}/guides/ssg-${DERIVATIVE}-guide-*.html\") \n
        if(NOT IS_ABSOLUTE ${SSG_GUIDE_INSTALL_DIR})
            file(INSTALL DESTINATION \"${CMAKE_INSTALL_PREFIX}/${SSG_GUIDE_INSTALL_DIR}\"
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
            file(INSTALL DESTINATION \"${CMAKE_INSTALL_PREFIX}/${SSG_ANSIBLE_ROLE_INSTALL_DIR}\"
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
            file(INSTALL DESTINATION \"${CMAKE_INSTALL_PREFIX}/${SSG_BASH_ROLE_INSTALL_DIR}\"
                TYPE FILE FILES \${ROLE_FILES})
        else()
            file(INSTALL DESTINATION \"${SSG_BASH_ROLE_INSTALL_DIR}\"
                TYPE FILE FILES \${ROLE_FILES})
        endif()
        "
    )
endmacro()

macro(ssg_build_html_ref_tables PRODUCT OUTPUT_TEMPLATE REFERENCES)
    set(OUTPUTS_LIST "")
    set(REFS_STR "")
    foreach(REF ${REFERENCES})
        string(REPLACE "{ref_id}" "${REF}" "basename" "${OUTPUT_TEMPLATE}")
        list(APPEND OUTPUTS_LIST "${CMAKE_BINARY_DIR}/tables/${basename}.html")
        set(REFS_STR "${REFS_STR} ${REF}")
    endforeach()
    add_custom_command(
        OUTPUT ${OUTPUTS_LIST}
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/gen_multiple_reference_tables.py" --build-dir "${CMAKE_BINARY_DIR}" "${PRODUCT}" "${CMAKE_BINARY_DIR}/tables/${OUTPUT_TEMPLATE}.html" ${REFERENCES}
        DEPENDS ${PRODUCT}-compile-all "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
        COMMENT "[${PRODUCT}-tables] generating HTML refs table for ${REFS_STR} references"
    )
    add_custom_target(
        generate-general-ref-tables-${PRODUCT}
        DEPENDS ${OUTPUTS_LIST}
    )
    add_dependencies(${PRODUCT}-tables generate-general-ref-tables-${PRODUCT})

    # needs PARENT_SCOPE because this is done across different cmake files via add_directory(..)
    # also needs to set the variable in local scope for next macro tables
    list(APPEND SSG_HTML_TABLE_FILE_LIST ${OUTPUTS_LIST})
    set(SSG_HTML_TABLE_FILE_LIST ${SSG_HTML_TABLE_FILE_LIST} PARENT_SCOPE)

    install(FILES ${OUTPUTS_LIST} DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()


macro(ssg_build_html_profile_table BASENAME PRODUCT PROFILE REFERENCE)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/${BASENAME}.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/gen_profile_table.py" --build-dir "${CMAKE_BINARY_DIR}" --output "${CMAKE_BINARY_DIR}/tables/${BASENAME}.html" "${PRODUCT}" "${REFERENCE}" "${PROFILE}"
        DEPENDS ${PRODUCT}-compile-all "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
        COMMENT "[${PRODUCT}-tables] generating HTML refs table for ${PROFILE} profile"
    )
    add_custom_target(
        generate-${PRODUCT}-profile-table-${PROFILE}
        DEPENDS "${CMAKE_BINARY_DIR}/tables/${BASENAME}.html"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}-profile-table-${PROFILE})

    # needs PARENT_SCOPE because this is done across different cmake files via add_directory(..)
    # also needs to set the variable in local scope for next macro tables
    list(APPEND SSG_HTML_TABLE_FILE_LIST "${CMAKE_BINARY_DIR}/tables/${BASENAME}.html")
    set(SSG_HTML_TABLE_FILE_LIST ${SSG_HTML_TABLE_FILE_LIST} PARENT_SCOPE)

    install(FILES "${CMAKE_BINARY_DIR}/tables/${BASENAME}.html"
    DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_build_html_cce_table PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-cces.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND "${XSLTPROC_EXECUTABLE}" --output "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-cces.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-cce.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        DEPENDS generate-ssg-${PRODUCT}-ds.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        COMMENT "[${PRODUCT}-tables] generating HTML CCE identifiers table"
    )
    add_custom_target(
        generate-${PRODUCT}-table-cces
        DEPENDS "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-cces.html"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}-table-cces)

    # needs PARENT_SCOPE because this is done across different cmake files via add_directory(..)
    # also needs to set the variable in local scope for next macro tables
    list(APPEND SSG_HTML_TABLE_FILE_LIST "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-cces.html")
    set(SSG_HTML_TABLE_FILE_LIST ${SSG_HTML_TABLE_FILE_LIST} PARENT_SCOPE)

    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-cces.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_build_html_srgmap_tables PRODUCT)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap.html"
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap-flat.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/gen_srg_table.py" --build-dir "${CMAKE_BINARY_DIR}" "${PRODUCT}" "${SSG_SHARED_REFS}/disa-os-srg-v2r7.xml" "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap.html" "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap-flat.html"
        DEPENDS ${PRODUCT}-compile-all "${CMAKE_CURRENT_BINARY_DIR}/ssg_build_compile_all-${PRODUCT}"
        COMMENT "[${PRODUCT}-tables] generating HTML SRG map tables"
    )
    add_custom_target(
        generate-${PRODUCT}-table-srg
        DEPENDS "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap.html"
        DEPENDS "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap-flat.html"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}-table-srg)

    # needs PARENT_SCOPE because this is done across different cmake files via add_directory(..)
    # also needs to set the variable in local scope for next macro tables
    list(APPEND SSG_HTML_TABLE_FILE_LIST "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap.html" "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap-flat.html")
    set(SSG_HTML_TABLE_FILE_LIST ${SSG_HTML_TABLE_FILE_LIST} PARENT_SCOPE)

    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-srgmap-flat.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_build_html_stig_tables PRODUCT)
    file(GLOB DISA_STIG_REF "${SSG_SHARED_REFS}/disa-stig-${PRODUCT}-v[0-9]*r[0-9]*-xccdf-manual.xml")
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-manual.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/gen_stig_table.py" "${DISA_STIG_REF}" "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-manual.html"
        DEPENDS "${DISA_STIG_REF}"
        COMMENT "[${PRODUCT}-tables] generating HTML MANUAL STIG table"
    )
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/${PRODUCT}/overlays/stig_overlay.xml"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/${PRODUCT}/overlays"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/create-stig-overlay.py" --quiet --disa-xccdf="${DISA_STIG_REF}" --ssg-xccdf="${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml" -o "${CMAKE_BINARY_DIR}/${PRODUCT}/overlays/stig_overlay.xml"
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${DISA_STIG_REF}"
        COMMENT "[${PRODUCT}-tables] generating STIG XML overlay"
    )
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/unlinked-stig-xccdf.xml"
        COMMAND "${XSLTPROC_EXECUTABLE}" -stringparam overlay "${CMAKE_BINARY_DIR}/${PRODUCT}/overlays/stig_overlay.xml" --stringparam ocil-document "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml" --output "${CMAKE_CURRENT_BINARY_DIR}/unlinked-stig-xccdf.xml" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf-apply-overlay-stig.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf-apply-overlay-stig.xslt"
        DEPENDS "${CMAKE_BINARY_DIR}/${PRODUCT}/overlays/stig_overlay.xml"
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        COMMENT "[${PRODUCT}-tables] generating unlinked STIG XCCDF XML file"
    )
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/gen_stig_table.py" "${CMAKE_CURRENT_BINARY_DIR}/unlinked-stig-xccdf.xml" "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig.html"
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/unlinked-stig-xccdf.xml"
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
    list(APPEND SSG_HTML_TABLE_FILE_LIST "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig.html" "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-manual.html" "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig-testinfo.html")
    set(SSG_HTML_TABLE_FILE_LIST ${SSG_HTML_TABLE_FILE_LIST} PARENT_SCOPE)

    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-stig.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(rule_dir_json)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/rule_dirs.json"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/rule_dir_json.py" "--root" "${CMAKE_SOURCE_DIR}" "--output" "${CMAKE_BINARY_DIR}/rule_dirs.json" --quiet
        COMMENT "[rule-dir-json] creating build/rule_dirs.json"
    )
    add_custom_target(
        rule_dir_json
        DEPENDS "${CMAKE_SOURCE_DIR}/build/rule_dirs.json"
    )
endmacro()


macro(ssg_build_xlsx_srg_export PRODUCT CONTROL)
    rule_dir_json()
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/${PRODUCT}/${PRODUCT}_${CONTROL}_srg_export.xlsx"
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        DEPENDS "${CMAKE_BINARY_DIR}/rule_dirs.json"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/${PRODUCT}"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/create_srg_export.py" --root "${CMAKE_SOURCE_DIR}" --json "${CMAKE_BINARY_DIR}/rule_dirs.json" --control "${CMAKE_SOURCE_DIR}/controls/${CONTROL}.yml" --product "${PRODUCT}" --out-format xlsx --output "${CMAKE_BINARY_DIR}/${PRODUCT}/${PRODUCT}_${CONTROL}_srg_export.xlsx" --build-config-yaml "${CMAKE_BINARY_DIR}/build_config.yml"
        COMMENT "[${PRODUCT}-tables] generating XLSX SRG Export"
    )
    add_custom_target(
        generate-${PRODUCT}_${CONTROL}_srg_export
        DEPENDS "${CMAKE_BINARY_DIR}/${PRODUCT}/${PRODUCT}_${CONTROL}_srg_export.xlsx"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}_${CONTROL}_srg_export)
endmacro()

macro(ssg_build_html_stig_tables_per_profile PRODUCT STIG_PROFILE)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-${STIG_PROFILE}-testinfo.html"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/tables"
        COMMAND "${XSLTPROC_EXECUTABLE}" -stringparam profile "${STIG_PROFILE}" -stringparam testinfo "y" -stringparam ocil-document "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml" --output "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-${STIG_PROFILE}-testinfo.html" "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profileccirefs.xslt" "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DEPENDS "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profileccirefs.xslt"
        DEPENDS generate-ssg-${PRODUCT}-xccdf.xml "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        COMMENT "[${PRODUCT}-tables] generating HTML STIG test info document for ${STIG_PROFILE}"
    )
    add_custom_target(
        generate-${PRODUCT}-table-stig_per_profile_${STIG_PROFILE}
        DEPENDS "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-${STIG_PROFILE}-testinfo.html"
    )
    add_dependencies(${PRODUCT}-tables generate-${PRODUCT}-table-stig_per_profile_${STIG_PROFILE})
    install(FILES "${CMAKE_BINARY_DIR}/tables/table-${PRODUCT}-${STIG_PROFILE}-testinfo.html"
        DESTINATION "${SSG_TABLE_INSTALL_DIR}")
endmacro()

macro(ssg_define_guide_and_table_tests)
    if(SSG_LINKCHECKER_VALIDATION_ENABLED AND LINKCHECKER_EXECUTABLE)
        add_test(
            NAME "linkchecker-ssg-guides"
            COMMAND "${LINKCHECKER_EXECUTABLE}" --config "${CMAKE_SOURCE_DIR}/tests/linkcheckerrc" --check-extern ${SSG_HTML_GUIDE_FILE_LIST}
        )

        add_test(
            NAME "linkchecker-ssg-tables"
            COMMAND "${LINKCHECKER_EXECUTABLE}" --config "${CMAKE_SOURCE_DIR}/tests/linkcheckerrc" --check-extern ${SSG_HTML_TABLE_FILE_LIST}
        )
    endif()

    if(GREP_EXECUTABLE)
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

    if(PYTHON_VERSION_MAJOR GREATER 2)
        add_test(
            NAME "unique-cces"
            COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/tests/assert_reference_unique.py" "${CMAKE_SOURCE_DIR}" "cce"
        )
        # Disable unique-stigids temporarily since it breaks many jobs. There are multiple duplicates
        # of STIG IDs and they should be fixed by DISA first.
        # add_test(
        #     NAME "unique-stigids"
        #     COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/tests/assert_reference_unique.py" "${CMAKE_SOURCE_DIR}" "stigid"
        # )
        set_tests_properties("unique-cces" PROPERTIES LABELS quick)
        # set_tests_properties("unique-stigids" PROPERTIES LABELS quick)
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
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_SOURCE_DIR}/products/rhel*/kickstart/*-ks.cfg" -DDEST="zipfile/${ZIPNAME}/kickstart" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
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
        COMMAND ${CMAKE_COMMAND} -E make_directory "zipfile/${ZIPNAME}/manifests"
        COMMAND ${CMAKE_COMMAND} -DSOURCE="${CMAKE_BINARY_DIR}/*/manifest-*.json" -DDEST="zipfile/${ZIPNAME}/manifests" -P "${CMAKE_SOURCE_DIR}/cmake/CopyFiles.cmake"
        COMMAND ${CMAKE_COMMAND} -E chdir "zipfile" ${CMAKE_COMMAND} -E tar "cvf" "${ZIPNAME}.zip" --format=zip "${ZIPNAME}"
        COMMAND ${CMAKE_COMMAND} -E chdir "zipfile" ${CMAKE_COMMAND} -E sha512sum "${ZIPNAME}.zip" > "zipfile/${ZIPNAME}.zip.sha512"
        COMMENT "Building zipfile at ${CMAKE_BINARY_DIR}/zipfile/${ZIPNAME}.zip"
    )
endmacro()
macro(ssg_build_zipfile_target ZIPNAME)
    add_custom_target(
        zipfile
        DEPENDS "${CMAKE_BINARY_DIR}/zipfile/${ZIPNAME}.zip"
    )
endmacro()
