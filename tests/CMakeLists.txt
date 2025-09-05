if (ENABLE_PYTHON_COVERAGE)
    set(PYTEST_COVERAGE_OPTIONS --cov-append --cov-report=xml --cov "${CMAKE_SOURCE_DIR}/ssg")
endif()

macro(ssg_python_unit_tests PYTHON_COMPONENT_ID RELATIVE_PYTHONPATH)
    add_test(
        NAME "python-unit-${PYTHON_COMPONENT_ID}"
        COMMAND "${PYTHON_EXECUTABLE}" -m pytest ${PYTEST_COVERAGE_OPTIONS} "${CMAKE_SOURCE_DIR}/tests/unit/${PYTHON_COMPONENT_ID}"
    )
    set_tests_properties ("python-unit-${PYTHON_COMPONENT_ID}" PROPERTIES ENVIRONMENT
        "PYTHONPATH=${CMAKE_SOURCE_DIR}/${RELATIVE_PYTHONPATH}:$ENV{PYTHONPATH}"
        LABELS quick
    )
endmacro()

if (PY_PYTEST)
    ssg_python_unit_tests("build-scripts" "build-scripts")
    ssg_python_unit_tests("utils" "utils")
    ssg_python_unit_tests("ssg-module" ".")
    ssg_python_unit_tests("ssg_test_suite" "tests")
endif()

add_test(
    NAME "max-path-len"
    COMMAND "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/ensure_paths_are_short.py"
)
set_tests_properties("max-path-len" PROPERTIES LABELS quick)

add_test(
    NAME "test-rule-dir-json"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/rule_dir_json.py" "--root" "${CMAKE_SOURCE_DIR}" "--output" "${CMAKE_SOURCE_DIR}/build/rule_dirs.json"
)
set_tests_properties("test-rule-dir-json" PROPERTIES LABELS quick)

add_test(
    NAME "validate-parse-affected"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/test_parse_affected.py" "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}/build_config.yml"
)

add_test(
    NAME "validate-parse-platform"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/test_parse_platform.py" "${CMAKE_SOURCE_DIR}"
)
set_tests_properties("validate-parse-platform" PROPERTIES LABELS quick)

add_test(
    NAME "stable-profile-ids"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/stable_profile_ids.py" "${CMAKE_BINARY_DIR}"
)
set_tests_properties("stable-profile-ids" PROPERTIES LABELS quick)

add_test(
    NAME "stable-profiles"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/test_profile_stability.py" "${CMAKE_BINARY_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/data/profile_stability"
)
set_tests_properties("stable-profiles" PROPERTIES LABELS quick)

add_test(
    NAME "machine-only-rules"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/test_machine_only_rules.py" --source_dir "${CMAKE_SOURCE_DIR}" --build_dir "${CMAKE_BINARY_DIR}"
)
set_tests_properties("machine-only-rules" PROPERTIES LABELS quick)

if (SSG_BATS_TESTS_ENABLED AND BATS_EXECUTABLE)
    add_test(
        NAME "bash-unit-tests"
        COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/unit/bash/execute_tests.sh" "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/unit/bash" "${CMAKE_BINARY_DIR}/tests"
    )
    set_tests_properties("bash-unit-tests" PROPERTIES LABELS quick)
endif()
add_test(
    NAME "macros-oval"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/test_macros_oval.py" "--verbose"
)
set_tests_properties("macros-oval" PROPERTIES LABELS quick)

add_test(
    NAME "fix_rules-empty_identifiers"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/fix_rules.py" "--dry-run" "--root" "${CMAKE_SOURCE_DIR}" "--json" "${CMAKE_SOURCE_DIR}/build/rule_dirs.json" "empty_identifiers"
)
set_tests_properties("fix_rules-empty_identifiers" PROPERTIES LABELS quick)
set_tests_properties("fix_rules-empty_identifiers" PROPERTIES DEPENDS "test-rule-dir-json")

add_test(
    NAME "fix_rules-invalid_identifiers"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/fix_rules.py" "--dry-run" "--root" "${CMAKE_SOURCE_DIR}" "--json" "${CMAKE_SOURCE_DIR}/build/rule_dirs.json" "invalid_identifiers"
)
set_tests_properties("fix_rules-invalid_identifiers" PROPERTIES LABELS quick)
set_tests_properties("fix_rules-invalid_identifiers" PROPERTIES DEPENDS "test-rule-dir-json")

add_test(
    NAME "fix_rules-int_identifiers"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/fix_rules.py" "--dry-run" "--root" "${CMAKE_SOURCE_DIR}" "--json" "${CMAKE_SOURCE_DIR}/build/rule_dirs.json" "int_identifiers"
)
set_tests_properties("fix_rules-int_identifiers" PROPERTIES LABELS quick)
set_tests_properties("fix_rules-int_identifiers" PROPERTIES DEPENDS "test-rule-dir-json")

add_test(
    NAME "fix_rules-empty_references"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/fix_rules.py" "--dry-run" "--root" "${CMAKE_SOURCE_DIR}" "--json" "${CMAKE_SOURCE_DIR}/build/rule_dirs.json" "empty_references"
)
set_tests_properties("fix_rules-empty_references" PROPERTIES LABELS quick)
set_tests_properties("fix_rules-empty_references" PROPERTIES DEPENDS "test-rule-dir-json")

add_test(
    NAME "fix_rules-int_references"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/fix_rules.py" "--dry-run" "--root" "${CMAKE_SOURCE_DIR}" "--json" "${CMAKE_SOURCE_DIR}/build/rule_dirs.json" "int_references"
)
set_tests_properties("fix_rules-int_references" PROPERTIES LABELS quick)
set_tests_properties("fix_rules-int_references" PROPERTIES DEPENDS "test-rule-dir-json")

add_test(
    NAME "fix_rules-duplicate_subkeys"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/fix_rules.py" "--dry-run" "--root" "${CMAKE_SOURCE_DIR}" "--json" "${CMAKE_SOURCE_DIR}/build/rule_dirs.json" "duplicate_subkeys"
)
set_tests_properties("fix_rules-duplicate_subkeys" PROPERTIES LABELS quick)
set_tests_properties("fix_rules-duplicate_subkeys" PROPERTIES DEPENDS "test-rule-dir-json")

add_test(
    NAME "fix_rules-sort_subkeys"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/fix_rules.py" "--dry-run" "--root" "${CMAKE_SOURCE_DIR}" "--json" "${CMAKE_SOURCE_DIR}/build/rule_dirs.json" "sort_subkeys"
)
set_tests_properties("fix_rules-sort_subkeys" PROPERTIES LABELS quick)
set_tests_properties("fix_rules-sort_subkeys" PROPERTIES DEPENDS "test-rule-dir-json")

add_test(
    NAME "fix_rules-sort_prodtypes"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/fix_rules.py" "--dry-run" "--root" "${CMAKE_SOURCE_DIR}" "--json" "${CMAKE_SOURCE_DIR}/build/rule_dirs.json" "sort_prodtypes"
)
set_tests_properties("fix_rules-sort_prodtypes" PROPERTIES LABELS quick)
set_tests_properties("fix_rules-sort_prodtypes" PROPERTIES DEPENDS "test-rule-dir-json")

if (PY_YAMLPATH)
    if (PY_PYTEST)
        add_test(
            NAME "test-function-check_playbook_file_removed_and_added"
            COMMAND "${PYTHON_EXECUTABLE}" -m pytest ${PYTEST_COVERAGE_OPTIONS} "${CMAKE_CURRENT_SOURCE_DIR}/test_check_playbook_file_removed_and_added.py"
        )
    endif()
    add_test(
        NAME "ansible-file-removed-and-added"
        COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/test_ansible_file_removed_and_added.py" --ansible_dir "${CMAKE_BINARY_DIR}/ansible"
    )
    set_tests_properties("fix_rules-sort_subkeys" PROPERTIES LABELS quick)
endif()
