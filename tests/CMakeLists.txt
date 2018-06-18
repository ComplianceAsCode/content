if (ENABLE_PYTHON_COVERAGE)
    set(PYTEST_COVERAGE_OPTIONS --cov-append --cov-report=xml --cov "${CMAKE_SOURCE_DIR}/shared/")
endif()

macro(ssg_python_unit_tests PYTHON_COMPONENT)
    add_test(
        NAME "python-unit-${PYTHON_COMPONENT}"
        COMMAND "${PYTHON_EXECUTABLE}" -m pytest ${PYTEST_COVERAGE_OPTIONS} "${CMAKE_SOURCE_DIR}/tests/unit/${PYTHON_COMPONENT}"
    )
    set_tests_properties ("python-unit-${PYTHON_COMPONENT}" PROPERTIES ENVIRONMENT
        "PYTHONPATH=${CMAKE_SOURCE_DIR}/${PYTHON_COMPONENT}:$ENV{PYTHONPATH}"
    )
endmacro()

if (PY_PYTEST)
    ssg_python_unit_tests("build-scripts")
    ssg_python_unit_tests("utils")
endif()

add_test(
    NAME "max-path-len"
    COMMAND "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/ensure_paths_are_short.py"
)
