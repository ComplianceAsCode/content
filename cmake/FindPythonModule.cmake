# Find if a Python module is installed
# Found at http://www.cmake.org/pipermail/cmake/2011-January/041666.html
# To use do: find_python_module(PyQt4 REQUIRED)

# Keep filename as is
# lint_cmake: -convention/filename, -package/stdargs

include(FindPackageHandleStandardArgs)

function(find_python_module module)
    string(TOUPPER ${module} module_upper)
    if(NOT PY_${module_upper})
        if(ARGC GREATER 1 AND ARGV1 STREQUAL "REQUIRED")
            set(PY_${module}_FIND_REQUIRED TRUE)
        endif()
        if($ENV{SSG_USE_PIP_PACKAGES})
            execute_process(COMMAND "${PYTHON_EXECUTABLE}" "-c"
                "import platform; print(''.join('python'+platform.python_version()[:-2]))"
                RESULT_VARIABLE _python_version_status
                OUTPUT_VARIABLE _python_version
                ERROR_QUIET
                OUTPUT_STRIP_TRAILING_WHITESPACE)
            if(NOT ${_python_version_status})
                set(ENV{PYTHONPATH} "/usr/local/lib/${_python_version}/site-packages:/usr/local/lib64/${_python_version}/site-packages")
            endif()
        endif()
        # A module's location is usually a directory, but for binary modules
        # it's a .so file.
        execute_process(COMMAND "${PYTHON_EXECUTABLE}" "-c"
            "import re, ${module}; print(re.compile('/__init__.py.*').sub('',${module}.__file__))"
            RESULT_VARIABLE _${module}_status
            OUTPUT_VARIABLE _${module}_location
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE)
        if(NOT _${module}_status)
            set(PY_${module_upper} ${_${module}_location} CACHE STRING
                "Location of Python module ${module}")
        endif()
    endif()
    find_package_handle_standard_args(PY_${module} DEFAULT_MSG PY_${module_upper})
endfunction()
