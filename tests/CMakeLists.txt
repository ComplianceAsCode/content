if (ENABLE_PYTHON_COVERAGE)
    set(PYTEST_COVERAGE_OPTIONS --cov-append --cov-report=xml --cov "${CMAKE_SOURCE_DIR}/")
endif()

macro(ssg_python_unit_tests PYTHON_COMPONENT_ID RELATIVE_PYTHONPATH)
    add_test(
        NAME "python-unit-${PYTHON_COMPONENT_ID}"
        COMMAND "${PYTHON_EXECUTABLE}" -m pytest ${PYTEST_COVERAGE_OPTIONS} "${CMAKE_SOURCE_DIR}/tests/unit/${PYTHON_COMPONENT_ID}"
    )
    set_tests_properties ("python-unit-${PYTHON_COMPONENT_ID}" PROPERTIES ENVIRONMENT
        "PYTHONPATH=${CMAKE_SOURCE_DIR}/${RELATIVE_PYTHONPATH}:$ENV{PYTHONPATH}"
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

add_test(
    NAME "test-rule-dir-json"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/utils/rule_dir_json.py"
)

add_test(
    NAME "validate-parse-affected"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/test_parse_affected.py" "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}/build_config.yml"
)

add_test(
    NAME "validate-parse-platform"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/test_parse_platform.py" "${CMAKE_SOURCE_DIR}"
)

add_test(
    NAME "stable-profile-ids"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/stable_profile_ids.py" "${CMAKE_BINARY_DIR}"
)

add_test(
    NAME "machine-only-rules"
    COMMAND env "PYTHONPATH=$ENV{PYTHONPATH}" "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/test_machine_only_rules.py" --source_dir "${CMAKE_SOURCE_DIR}" --build_dir "${CMAKE_BINARY_DIR}"
)
